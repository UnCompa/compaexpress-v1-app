import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/Caja.dart';
import 'package:compaexpress/models/CajaMoneda.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CajaMonedasPage extends StatefulWidget {
  final Caja caja;

  const CajaMonedasPage({super.key, required this.caja});

  @override
  State<CajaMonedasPage> createState() => _CajaMonedasPageState();
}

class _CajaMonedasPageState extends State<CajaMonedasPage> {
  List<CajaMoneda> _monedas = [];
  bool _isLoading = true;
  bool _isEditing = false;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadMonedas();
  }

  @override
  void dispose() {
    // Dispose controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMonedas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final request = ModelQueries.list(
        CajaMoneda.classType,
        where: CajaMoneda.CAJAID
            .eq(widget.caja.id)
            .and(CajaMoneda.ISDELETED.ne(true)),
      );
      final result = await Amplify.API.query(request: request).response;
      final monedas = result.data?.items;

      setState(() {
        _monedas =
            monedas
                ?.where((moneda) => moneda != null)
                .cast<CajaMoneda>()
                .toList() ??
            [];
        _initializeControllers();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar monedas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _initializeControllers() {
    _controllers.clear();
    for (final moneda in _monedas) {
      _controllers[moneda.id] = TextEditingController(
        text: moneda.monto.toStringAsFixed(2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monedas - Caja'),
         backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: _showAddMonedaDialog,
              icon: const Icon(Icons.add),
            ),
          if (!_isEditing)
            IconButton(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.edit),
              tooltip: 'Editar monedas',
            )
          else ...[
            TextButton(
              onPressed: _cancelEdit,
              child: const Text(
                'CANCELAR',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: _saveChanges,
              child: const Text(
                'GUARDAR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildCajaHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _monedas.isEmpty
                ? _buildEmptyState()
                : _buildMonedasContent(),
          ),
          if (!_isLoading) _buildSummaryFooter(),
        ],
      ),
    );
  }

  Widget _buildCajaHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Caja',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.caja.isActive ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.caja.isActive ? 'Activa' : 'Inactiva',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Saldo Inicial: \$${widget.caja.saldoInicial.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monetization_on_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay monedas registradas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para agregar denominaciones',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMonedasContent() {
    // Agrupar monedas por tipo de moneda
    final monedasGrouped = <String, List<CajaMoneda>>{};
    for (final moneda in _monedas) {
      monedasGrouped.putIfAbsent(moneda.moneda, () => []).add(moneda);
    }

    // Ordenar cada grupo por denominación
    for (final group in monedasGrouped.values) {
      group.sort((a, b) => a.denominacion.compareTo(b.denominacion));
    }

    return RefreshIndicator(
      onRefresh: _loadMonedas,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: monedasGrouped.entries.map((entry) {
          return _buildMonedaGroup(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _buildMonedaGroup(String tipoMoneda, List<CajaMoneda> monedas) {
    final totalGrupo = monedas.fold<double>(0.0, (sum, m) => sum + m.monto);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tipoMoneda,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: \$${totalGrupo.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ...monedas.map((moneda) => _buildMonedaItem(moneda)),
        ],
      ),
    );
  }

  Widget _buildMonedaItem(CajaMoneda moneda) {
    final controller = _controllers[moneda.id];
    if (controller == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Denominación visual
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getDenominationColor(moneda.denominacion),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatDenominacion(moneda.denominacion),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cantidad: ${_getCantidad(moneda.monto, moneda.denominacion)} unidades',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Campo de monto
          SizedBox(
            width: _isEditing ? 120 : 80,
            child: _isEditing
                ? TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${moneda.monto.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Monto',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
          ),

          // Botón de eliminar (solo en modo edición)
          if (_isEditing) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _deleteMoneda(moneda),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              iconSize: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryFooter() {
    final totalGeneral = _monedas.fold<double>(0.0, (sum, m) => sum + m.monto);
    final diferencia = totalGeneral - widget.caja.saldoInicial;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total en Monedas:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                '\$${totalGeneral.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo Inicial:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                '\$${widget.caja.saldoInicial.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Diferencia:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${diferencia >= 0 ? '+' : ''}\$${diferencia.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: diferencia == 0
                      ? Colors.black
                      : diferencia < 0
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ],
          ),
          // Mostrar botón de sobreescribir solo si hay diferencia
          if (diferencia != 0) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sobreescribirSaldo,
                icon: const Icon(Icons.sync_alt),
                label: const Text('SOBREESCRIBIR SALDO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esto actualizará el saldo inicial de la caja a \$${totalGeneral.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods
  Color _getDenominationColor(double denominacion) {
    if (denominacion < 1) {
      return Colors.brown; // Centavos
    } else if (denominacion <= 5) {
      return Colors.green; // Billetes pequeños
    } else if (denominacion <= 20) {
      return Colors.blue; // Billetes medianos
    } else {
      return Colors.purple; // Billetes grandes
    }
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

  int _getCantidad(double monto, double denominacion) {
    if (denominacion == 0) return 0;
    return (monto / denominacion).round();
  }

  // Actions
  void _toggleEditMode() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _initializeControllers(); // Restablecer valores originales
    });
  }

  Future<void> _saveChanges() async {
    try {
      // TODO: Implementar guardado de cambios
      for (final moneda in _monedas) {
        final controller = _controllers[moneda.id];
        if (controller != null) {
          final nuevoMonto = double.tryParse(controller.text) ?? 0.0;
          if (nuevoMonto != moneda.monto) {
            await _updateMoneda(moneda, nuevoMonto);
          }
        }
      }

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cambios guardados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadMonedas(); // Recargar datos
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar cambios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateMoneda(CajaMoneda moneda, double nuevoMonto) async {
    // TODO: Implementar actualización de moneda
    final updatedMoneda = moneda.copyWith(
      monto: nuevoMonto,
      updatedAt: TemporalDateTime.now(),
    );

    final request = ModelMutations.update(updatedMoneda);
    await Amplify.API.mutate(request: request).response;
  }

  Future<void> _sobreescribirSaldo() async {
    final totalGeneral = _monedas.fold<double>(0.0, (sum, m) => sum + m.monto);
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobreescribir Saldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Estás seguro de que deseas sobreescribir el saldo inicial de la caja?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Saldo actual:'),
                Text('\$${widget.caja.saldoInicial.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nuevo saldo:'),
                Text(
                  '\$${totalGeneral.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acción actualizará permanentemente el saldo inicial de la caja.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sobreescribir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Actualizar el saldo inicial de la caja
        final updatedCaja = widget.caja.copyWith(
          saldoInicial: totalGeneral,
          updatedAt: TemporalDateTime.now(),
        );

        final request = ModelMutations.update(updatedCaja);
        await Amplify.API.mutate(request: request).response;

        // Actualizar el widget con los nuevos datos
        setState(() {
          // El widget.caja se actualizará en la siguiente recarga
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Saldo inicial actualizado a \$${totalGeneral.toStringAsFixed(2)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
          
          // Recargar la página para reflejar los cambios
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar saldo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteMoneda(CajaMoneda moneda) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Denominación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar ${_getDenominacionLabel(moneda.moneda, moneda.denominacion)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // TODO: Implementar eliminación lógica
        final deletedMoneda = moneda.copyWith(
          isDeleted: true,
          updatedAt: TemporalDateTime.now(),
        );

        final request = ModelMutations.update(deletedMoneda);
        await Amplify.API.mutate(request: request).response;

        await _loadMonedas(); // Recargar datos

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Denominación eliminada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showAddMonedaDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMonedaDialog(
        cajaId: widget.caja.id,
        negocioId: widget.caja.negocioID,
        onMonedaAdded: _loadMonedas,
      ),
    );
  }
}

// Diálogo para agregar nueva denominación
class AddMonedaDialog extends StatefulWidget {
  final String cajaId;
  final String negocioId;
  final VoidCallback onMonedaAdded;

  const AddMonedaDialog({
    super.key,
    required this.cajaId,
    required this.negocioId,
    required this.onMonedaAdded,
  });

  @override
  State<AddMonedaDialog> createState() => _AddMonedaDialogState();
}

class _AddMonedaDialogState extends State<AddMonedaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _denominacionController = TextEditingController();
  final _montoController = TextEditingController();
  String _selectedMoneda = 'USD';
  bool _isLoading = false;

  @override
  void dispose() {
    _denominacionController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Denominación'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMoneda,
              decoration: const InputDecoration(
                labelText: 'Tipo de Moneda',
                border: OutlineInputBorder(),
              ),
              items: ['USD', 'EUR'].map((moneda) {
                return DropdownMenuItem(value: moneda, child: Text(moneda));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMoneda = value ?? 'USD';
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _denominacionController,
              decoration: const InputDecoration(
                labelText: 'Denominación',
                helperText: 'Ej: 0.25 para 25 centavos, 5.00 para 5 dólares',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La denominación es requerida';
                }
                final denominacion = double.tryParse(value);
                if (denominacion == null || denominacion <= 0) {
                  return 'Ingrese una denominación válida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _montoController,
              decoration: const InputDecoration(
                labelText: 'Monto Inicial',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El monto es requerido';
                }
                final monto = double.tryParse(value);
                if (monto == null || monto < 0) {
                  return 'Ingrese un monto válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addMoneda,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Agregar'),
        ),
      ],
    );
  }

  Future<void> _addMoneda() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implementar creación de nueva moneda
      final nuevaMoneda = CajaMoneda(
        cajaID: widget.cajaId,
        negocioID: widget.negocioId,
        moneda: _selectedMoneda,
        denominacion: double.parse(_denominacionController.text),
        monto: double.parse(_montoController.text),
        isDeleted: false,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
      );

      final request = ModelMutations.create(nuevaMoneda);
      await Amplify.API.mutate(request: request).response;

      if (mounted) {
        Navigator.pop(context);
        widget.onMonedaAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Denominación agregada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar denominación: $e'),
            backgroundColor: Colors.red,
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
