import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/utils/denominaciones.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VendedorCierreCajaPage extends StatefulWidget {
  final Caja caja;

  const VendedorCierreCajaPage({super.key, required this.caja});

  @override
  State<VendedorCierreCajaPage> createState() => _VendedorCierreCajaPageState();
}

class _VendedorCierreCajaPageState extends State<VendedorCierreCajaPage> {
  final _formKey = GlobalKey<FormState>();
  final _observacionesController = TextEditingController();
  bool _isLoading = false;
  List<CajaMonedaForm> _monedas = [];
  final Map<String, List<double>> _denominacionesPorMoneda =
      Denominaciones.denominaciones;

  @override
  void initState() {
    super.initState();
    _initializeMonedasDefecto();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateActive(context);
    });
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  void _initializeMonedasDefecto() {
    final denominacionesUSD = _denominacionesPorMoneda['USD'] ?? [];
    setState(() {
      _monedas = denominacionesUSD.map((denominacion) {
        return CajaMonedaForm(
          moneda: 'USD',
          denominacion: denominacion,
          cantidad: 0,
        );
      }).toList();
    });
  }

  void _validateActive(BuildContext context) {
    try {
      final cajaIsActive = widget.caja.isActive;

      if (!cajaIsActive) {
        // Muestra el modal
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Caja inactiva'),
              content: const Text('La caja seleccionada no está activa.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Cierra el modal
                    Navigator.of(
                      context,
                    ).pop(); // Realiza el pop de la pantalla actual
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Manejo de errores, por ejemplo, si widget.caja o isActive son nulos
      print('Error al validar la caja: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Cierre de Caja'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _cerrarCaja,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save, size: 18),
              label: const Text('CERRAR CAJA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCajaInfoSection(),
                    const SizedBox(height: 24),
                    _buildMonedasSection(),
                    const SizedBox(height: 24),
                    _buildObservacionesSection(),
                  ],
                ),
              ),
            ),
            _buildBottomSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildCajaInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Información de la Caja',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total en Caja:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${widget.caja.saldoInicial.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservacionesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.note,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Observaciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _observacionesController,
              decoration: InputDecoration(
                labelText: 'Notas del cierre',
                prefixIcon: Icon(Icons.edit, color: Colors.blue.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                ),
                helperText:
                    'Opcional: Ingrese cualquier observación sobre el cierre',
                fillColor: Colors.grey[50],
                filled: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonedasSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.monetization_on,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Denominaciones Físicas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ingrese la cantidad de cada denominación presente en la caja',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            _buildMonedasList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonedasList() {
    return Column(
      children: _monedas.asMap().entries.map((entry) {
        final index = entry.key;
        final moneda = entry.value;
        return _buildMonedaItem(moneda, index);
      }).toList(),
    );
  }

  Widget _buildMonedaItem(CajaMonedaForm moneda, int index) {
    final montoCalculado = moneda.cantidad * moneda.denominacion;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  moneda.moneda,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _formatDenominacion(moneda.denominacion),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDenominacionLabel(moneda.moneda, moneda.denominacion),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Total: \$${montoCalculado.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextFormField(
              initialValue: moneda.cantidad.toString(),
              decoration: InputDecoration(
                labelText: 'Cantidad',
                labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                prefixIcon: Icon(
                  Icons.numbers,
                  size: 18,
                  color: Colors.grey[600],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                final cantidad = int.tryParse(value) ?? 0;
                setState(() {
                  _monedas[index] = moneda.copyWith(cantidad: cantidad);
                });
              },
              validator: (value) {
                final cantidad = int.tryParse(value ?? '0') ?? 0;
                if (cantidad < 0) {
                  return 'Cantidad inválida';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary() {
    final totalMonedas = _monedas.fold<double>(
      0.0,
      (sum, moneda) => sum + (moneda.cantidad * moneda.denominacion),
    );
    final saldoInicial = widget.caja.saldoInicial ?? 0.0;
    final diferencia = totalMonedas - saldoInicial;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Total en Monedas:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${totalMonedas.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Total en Caja:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${saldoInicial.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          diferencia == 0 ? Icons.balance : Icons.warning,
                          color: diferencia == 0 ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Diferencia:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${diferencia.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: diferencia == 0 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (diferencia != 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      diferencia > 0
                          ? 'Hay \$${diferencia.toStringAsFixed(2)} más en monedas que en el total'
                          : 'Hay \$${(-diferencia).toStringAsFixed(2)} menos en monedas que en el total',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDenominacion(double denominacion) {
    if (denominacion < 1) {
      return '${(denominacion * 100).toInt()}¢';
    } else {
      return '\$${denominacion.toStringAsFixed(denominacion == denominacion.toInt() ? 0 : 2)}';
    }
  }

  String _getDenominacionLabel(String moneda, double denominacion) {
    if (denominacion < 1) {
      return '$moneda - ${(denominacion * 100).toInt()} centavos';
    } else if (denominacion == 1) {
      return '$moneda - 1 ${moneda == 'USD' ? 'dólar' : 'euro'}';
    } else {
      return '$moneda - ${denominacion.toInt()} ${moneda == 'USD' ? 'dólares' : 'euros'}';
    }
  }

  Future<void> _cerrarCaja() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final negocioData = await NegocioService.getCurrentUserInfo();
      final totalMonedas = _monedas.fold<double>(
        0.0,
        (sum, moneda) => sum + (moneda.cantidad * moneda.denominacion),
      );

      // Actualizar monedas existentes
      final monedasRequest = ModelQueries.list(
        CajaMoneda.classType,
        where: CajaMoneda.CAJAID
            .eq(widget.caja.id)
            .and(CajaMoneda.ISDELETED.eq(false)),
      );
      final monedasResponse = await Amplify.API
          .query(request: monedasRequest)
          .response;
      final monedasExistentes =
          monedasResponse.data?.items.whereType<CajaMoneda>().toList() ?? [];

      for (final monedaForm in _monedas.where((m) => m.cantidad > 0)) {
        final monto = monedaForm.cantidad * monedaForm.denominacion;
        final existingMoneda = monedasExistentes.firstWhere(
          (m) =>
              m.denominacion == monedaForm.denominacion &&
              m.moneda == monedaForm.moneda,
          orElse: () => CajaMoneda(
            cajaID: widget.caja.id,
            negocioID: widget.caja.negocioID,
            moneda: monedaForm.moneda,
            denominacion: monedaForm.denominacion,
            monto: 0.0,
            isDeleted: false,
            createdAt: TemporalDateTime.now(),
            updatedAt: TemporalDateTime.now(),
          ),
        );

        final updatedMoneda = existingMoneda.copyWith(
          monto: monto,
          updatedAt: TemporalDateTime.now(),
        );

        await Amplify.API
            .mutate(request: ModelMutations.update(updatedMoneda))
            .response;
      }

      // Crear registro de cierre
      final diferencia = totalMonedas - (widget.caja.saldoInicial ?? 0.0);
      final cierreCaja = CierreCaja(
        cajaID: widget.caja.id,
        negocioID: widget.caja.negocioID,
        saldoFinal: totalMonedas,
        diferencia: diferencia,
        observaciones: _observacionesController.text.isNotEmpty
            ? _observacionesController.text
            : null,
        isDeleted: false,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
      );
      await Amplify.API
          .mutate(request: ModelMutations.create(cierreCaja))
          .response;

      // Desactivar caja
      final updatedCaja = widget.caja.copyWith(
        isActive: false,
        updatedAt: TemporalDateTime.now(),
      );
      await Amplify.API
          .mutate(request: ModelMutations.update(updatedCaja))
          .response;

      // Crear historial
      final cierreHistorial = CierreCajaHistorial(
        cierreCajaID: cierreCaja.id,
        negocioID: widget.caja.negocioID,
        usuarioID: negocioData.userId,
        fechaCierre: TemporalDateTime.now(),
        isDeleted: false,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
      );
      await Amplify.API
          .mutate(request: ModelMutations.create(cierreHistorial))
          .response;

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Caja cerrada exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error al cerrar la caja: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class CajaMonedaForm {
  final String? id;
  final String moneda;
  final double denominacion;
  final int cantidad;

  CajaMonedaForm({
    this.id,
    required this.moneda,
    required this.denominacion,
    required this.cantidad,
  });

  CajaMonedaForm copyWith({
    String? id,
    String? moneda,
    double? denominacion,
    int? cantidad,
  }) {
    return CajaMonedaForm(
      id: id ?? this.id,
      moneda: moneda ?? this.moneda,
      denominacion: denominacion ?? this.denominacion,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}
