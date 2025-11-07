import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/utils/denominaciones.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminCajaEditPage extends StatefulWidget {
  final Caja caja;
  const AdminCajaEditPage({super.key, required this.caja});

  @override
  State<AdminCajaEditPage> createState() => _AdminCajaEditPageState();
}

class _AdminCajaEditPageState extends State<AdminCajaEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _saldoInicialController =
      TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  List<CajaMonedaForm> _monedas = [];
  List<CajaMoneda> _monedasExistentes = [];

  final Map<String, List<double>> _denominacionesPorMoneda =
      Denominaciones.denominaciones;

  @override
  void initState() {
    super.initState();
    _saldoInicialController.text = widget.caja.saldoInicial.toString();
    _isActive = widget.caja.isActive;
    _loadExistingMonedas();
  }

  @override
  void dispose() {
    _saldoInicialController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingMonedas() async {
    try {
      final request = ModelQueries.list(
        CajaMoneda.classType,
        where: CajaMoneda.CAJAID
            .eq(widget.caja.id)
            .and(CajaMoneda.ISDELETED.eq(false)),
      );
      final response = await Amplify.API.query(request: request).response;
      _monedasExistentes =
          response.data?.items.whereType<CajaMoneda>().toList() ?? [];

      _initializeMonedasWithExisting();
    } catch (e) {
      _initializeMonedasDefecto();
    }
  }

  void _initializeMonedasWithExisting() {
    // Determinar qué moneda usar (USD por defecto o la primera existente)
    String monedaActual = 'USD';
    if (_monedasExistentes.isNotEmpty) {
      monedaActual = _monedasExistentes.first.moneda;
    }

    final denominaciones = _denominacionesPorMoneda[monedaActual] ?? [];

    setState(() {
      _monedas = denominaciones.map((denominacion) {
        // Buscar si existe una moneda con esta denominación
        final monedaExistente = _monedasExistentes.firstWhere(
          (m) => m.denominacion == denominacion && m.moneda == monedaActual,
          orElse: () => CajaMoneda(
            cajaID: widget.caja.id,
            negocioID: widget.caja.negocioID,
            moneda: monedaActual,
            denominacion: denominacion,
            monto: 0.0,
            isDeleted: false,
            createdAt: TemporalDateTime.now(),
            updatedAt: TemporalDateTime.now(),
          ),
        );

        // Calcular cantidad basada en el monto existente
        final cantidad = denominacion > 0
            ? (monedaExistente.monto / denominacion).round()
            : 0;

        return CajaMonedaForm(
          id: monedaExistente.id,
          moneda: monedaActual,
          denominacion: denominacion,
          cantidad: cantidad,
        );
      }).toList();
    });
  }

  void _initializeMonedasDefecto() {
    // Inicializar con denominaciones USD por defecto
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Editar Caja'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _guardarCaja,
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
              label: const Text('GUARDAR'),
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
                    Icons.edit,
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
            TextFormField(
              controller: _saldoInicialController,
              decoration: InputDecoration(
                labelText: 'Saldo Inicial',
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: Colors.green.shade600,
                ),
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                ),
                helperText: 'Ingrese el saldo inicial de la caja',
                fillColor: Colors.grey[50],
                filled: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El saldo inicial es requerido';
                }
                final saldo = double.tryParse(value);
                if (saldo == null || saldo < 0) {
                  return 'Ingrese un saldo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isActive ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isActive
                      ? Colors.green.shade200
                      : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value ?? true;
                      });
                    },
                    activeColor: Colors.green.shade600,
                  ),
                  Icon(
                    _isActive ? Icons.check_circle : Icons.pause_circle,
                    color: _isActive
                        ? Colors.green.shade600
                        : Colors.orange.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isActive ? 'Caja activa' : 'Caja inactiva',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _isActive
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
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
                      'Denominaciones de Monedas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.currency_exchange,
                          color: Colors.blue.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _monedas.isNotEmpty ? _monedas.first.moneda : 'USD',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blue.shade600,
                          size: 16,
                        ),
                      ],
                    ),
                    tooltip: 'Cambiar moneda',
                    onSelected: _cambiarMoneda,
                    itemBuilder: (context) => _denominacionesPorMoneda.keys
                        .map(
                          (moneda) => PopupMenuItem(
                            value: moneda,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.currency_exchange,
                                  size: 18,
                                  color: Colors.blue.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text('Cambiar a $moneda'),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Configure las cantidades de cada denominación disponible en la caja',
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
          // Icono de denominación
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

          // Información de la denominación
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

          // Campo de cantidad
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
    final saldoInicial = double.tryParse(_saldoInicialController.text) ?? 0.0;
    final diferencia = saldoInicial - totalMonedas;

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
                          'Saldo Inicial:',
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
                          ? 'Hay \$${diferencia.toStringAsFixed(2)} más en saldo inicial que en monedas'
                          : 'Hay \$${(-diferencia).toStringAsFixed(2)} más en monedas que en saldo inicial',
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

  void _cambiarMoneda(String nuevaMoneda) {
    final denominaciones = _denominacionesPorMoneda[nuevaMoneda] ?? [];
    setState(() {
      _monedas = denominaciones.map((denominacion) {
        return CajaMonedaForm(
          moneda: nuevaMoneda,
          denominacion: denominacion,
          cantidad: 0,
        );
      }).toList();
    });
  }

  Future<void> _guardarCaja() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _actualizarCaja();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Caja actualizada exitosamente'),
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
                Expanded(child: Text('Error al actualizar la caja: $e')),
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

  Future<void> _actualizarCaja() async {
    final saldoInicial = double.parse(_saldoInicialController.text);

    // 1. Actualizar la caja
    final cajaActualizada = widget.caja.copyWith(
      saldoInicial: saldoInicial,
      isActive: _isActive,
      updatedAt: TemporalDateTime.now(),
    );

    await Amplify.API
        .mutate(request: ModelMutations.update(cajaActualizada))
        .response;

    // 2. Eliminar monedas existentes (soft delete)
    for (final monedaExistente in _monedasExistentes) {
      final monedaEliminada = monedaExistente.copyWith(
        isDeleted: true,
        updatedAt: TemporalDateTime.now(),
      );
      await Amplify.API
          .mutate(request: ModelMutations.update(monedaEliminada))
          .response;
    }

    // 3. Crear las nuevas monedas
    final monedasACrear = _monedas.where((m) => m.cantidad > 0).toList();

    for (final monedaForm in monedasACrear) {
      final monto = monedaForm.cantidad * monedaForm.denominacion;
      final cajaMoneda = CajaMoneda(
        cajaID: widget.caja.id,
        negocioID: widget.caja.negocioID,
        moneda: monedaForm.moneda,
        denominacion: monedaForm.denominacion,
        monto: monto,
        isDeleted: false,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
      );

      await Amplify.API
          .mutate(request: ModelMutations.create(cajaMoneda))
          .response;
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
