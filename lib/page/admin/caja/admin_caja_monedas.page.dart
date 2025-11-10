import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/Caja.dart';
import 'package:compaexpress/models/CajaMoneda.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
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

      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Error al cargar monedas: $e');
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Monedas - Caja',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: _showAddMonedaDialog,
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Agregar denominación',
            ),
          if (!_isEditing)
            IconButton(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar monedas',
            )
          else ...[
            TextButton.icon(
              onPressed: _cancelEdit,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Cancelar'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Guardar'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildCajaHeader(colorScheme, textTheme),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppLoadingIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando monedas...',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : _monedas.isEmpty
                ? _buildEmptyState(colorScheme, textTheme)
                : _buildMonedasContent(colorScheme, textTheme),
          ),
          if (!_isLoading) _buildSummaryFooter(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildCajaHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Información de la Caja',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.caja.isActive
                        ? colorScheme.tertiaryContainer
                        : colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.caja.isActive
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 16,
                        color: widget.caja.isActive
                            ? colorScheme.onTertiaryContainer
                            : colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.caja.isActive ? 'Activa' : 'Inactiva',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.caja.isActive
                              ? colorScheme.onTertiaryContainer
                              : colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.savings_outlined,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Saldo Inicial:',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${widget.caja.saldoInicial.toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
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

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monetization_on_outlined,
              size: 80,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No hay monedas registradas',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Presiona el botón + para agregar denominaciones',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonedasContent(ColorScheme colorScheme, TextTheme textTheme) {
    final monedasGrouped = <String, List<CajaMoneda>>{};
    for (final moneda in _monedas) {
      monedasGrouped.putIfAbsent(moneda.moneda, () => []).add(moneda);
    }

    for (final group in monedasGrouped.values) {
      group.sort((a, b) => a.denominacion.compareTo(b.denominacion));
    }

    return RefreshIndicator(
      onRefresh: _loadMonedas,
      color: colorScheme.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: monedasGrouped.entries.map((entry) {
          return _buildMonedaGroup(
            entry.key,
            entry.value,
            colorScheme,
            textTheme,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonedaGroup(
    String tipoMoneda,
    List<CajaMoneda> monedas,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final totalGrupo = monedas.fold<double>(0.0, (sum, m) => sum + m.monto);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tipoMoneda,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.account_balance_outlined,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  'Total: \$${totalGrupo.toStringAsFixed(2)}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          ...monedas.map(
            (moneda) => _buildMonedaItem(moneda, colorScheme, textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildMonedaItem(
    CajaMoneda moneda,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final controller = _controllers[moneda.id];
    if (controller == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          // Denominación visual
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _getDenominationColor(moneda.denominacion, colorScheme),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _formatDenominacion(moneda.denominacion),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
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
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.apps,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_getCantidad(moneda.monto, moneda.denominacion)} unidades',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Campo de monto
          SizedBox(
            width: _isEditing ? 120 : 90,
            child: _isEditing
                ? TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                      ),
                      prefixText: '\$ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    style: textTheme.bodyMedium,
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
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Monto',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),

          // Botón de eliminar (solo en modo edición)
          if (_isEditing) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _deleteMoneda(moneda),
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.error,
              iconSize: 22,
              tooltip: 'Eliminar',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryFooter(ColorScheme colorScheme, TextTheme textTheme) {
    final totalGeneral = _monedas.fold<double>(0.0, (sum, m) => sum + m.monto);
    final diferencia = totalGeneral - widget.caja.saldoInicial;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant, width: 2),
          ),
        ),
        child: Column(
          children: [
            _buildSummaryRow(
              'Total en Monedas:',
              '\$${totalGeneral.toStringAsFixed(2)}',
              colorScheme,
              textTheme,
              isHighlighted: true,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Saldo Inicial:',
              '\$${widget.caja.saldoInicial.toStringAsFixed(2)}',
              colorScheme,
              textTheme,
            ),
            Divider(height: 24, color: colorScheme.outline),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Diferencia:',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: diferencia == 0
                        ? colorScheme.surfaceContainerHighest
                        : diferencia < 0
                        ? colorScheme.errorContainer
                        : colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (diferencia != 0)
                        Icon(
                          diferencia < 0
                              ? Icons.trending_down
                              : Icons.trending_up,
                          size: 18,
                          color: diferencia < 0
                              ? colorScheme.error
                              : colorScheme.tertiary,
                        ),
                      if (diferencia != 0) const SizedBox(width: 4),
                      Text(
                        '${diferencia >= 0 ? '+' : ''}\$${diferencia.abs().toStringAsFixed(2)}',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: diferencia == 0
                              ? colorScheme.onSurface
                              : diferencia < 0
                              ? colorScheme.error
                              : colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (diferencia != 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _sobreescribirSaldo,
                  icon: const Icon(Icons.sync_alt),
                  label: const Text('Sobreescribir Saldo Inicial'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esto actualizará el saldo inicial de la caja a \$${totalGeneral.toStringAsFixed(2)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlighted ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getDenominationColor(double denominacion, ColorScheme colorScheme) {
    if (denominacion < 1) {
      return Colors.brown.shade600; // Centavos
    } else if (denominacion <= 5) {
      return Colors.green.shade600; // Billetes pequeños
    } else if (denominacion <= 20) {
      return Colors.blue.shade600; // Billetes medianos
    } else {
      return Colors.purple.shade600; // Billetes grandes
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
      _initializeControllers();
    });
  }

  Future<void> _saveChanges() async {
    try {
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

      _showSuccessSnackBar('Cambios guardados exitosamente');
      await _loadMonedas();
    } catch (e) {
      _showErrorSnackBar('Error al guardar cambios: $e');
    }
  }

  Future<void> _updateMoneda(CajaMoneda moneda, double nuevoMonto) async {
    final updatedMoneda = moneda.copyWith(
      monto: nuevoMonto,
      updatedAt: TemporalDateTime.now(),
    );

    final request = ModelMutations.update(updatedMoneda);
    await Amplify.API.mutate(request: request).response;
  }

  Future<void> _sobreescribirSaldo() async {
    final totalGeneral = _monedas.fold<double>(0.0, (sum, m) => sum + m.monto);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.sync_alt, color: colorScheme.primary, size: 32),
        title: const Text('Sobreescribir Saldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Estás seguro de que deseas sobreescribir el saldo inicial de la caja?',
            ),
            const SizedBox(height: 20),
            _buildDialogRow(
              'Saldo actual:',
              '\$${widget.caja.saldoInicial.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildDialogRow(
              'Nuevo saldo:',
              '\$${totalGeneral.toStringAsFixed(2)}',
              isHighlighted: true,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Esta acción actualizará permanentemente el saldo inicial de la caja.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSecondaryContainer,
                      ),
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
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sobreescribir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final updatedCaja = widget.caja.copyWith(
          saldoInicial: totalGeneral,
          updatedAt: TemporalDateTime.now(),
        );

        final request = ModelMutations.update(updatedCaja);
        await Amplify.API.mutate(request: request).response;

        if (mounted) {
          _showSuccessSnackBar(
            'Saldo inicial actualizado a \$${totalGeneral.toStringAsFixed(2)}',
          );
          Navigator.pop(context);
        }
      } catch (e) {
        _showErrorSnackBar('Error al actualizar saldo: $e');
      }
    }
  }

  Widget _buildDialogRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Future<void> _deleteMoneda(CajaMoneda moneda) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 32),
        title: const Text('Eliminar Denominación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar ${_getDenominacionLabel(moneda.moneda, moneda.denominacion)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final deletedMoneda = moneda.copyWith(
          isDeleted: true,
          updatedAt: TemporalDateTime.now(),
        );

        final request = ModelMutations.update(deletedMoneda);
        await Amplify.API.mutate(request: request).response;

        await _loadMonedas();
        _showSuccessSnackBar('Denominación eliminada');
      } catch (e) {
        _showErrorSnackBar('Error al eliminar: $e');
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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onError,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      icon: Icon(
        Icons.add_circle_outline,
        color: colorScheme.primary,
        size: 32,
      ),
      title: Text(
        'Agregar Denominación',
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMoneda,
              decoration: InputDecoration(
                labelText: 'Tipo de Moneda',
                labelStyle: TextStyle(color: colorScheme.primary),
                prefixIcon: Icon(
                  Icons.currency_exchange,
                  color: colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
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
              decoration: InputDecoration(
                labelText: 'Denominación',
                labelStyle: TextStyle(color: colorScheme.primary),
                helperText: 'Ej: 0.25 para 25¢, 5.00 para \$5',
                helperMaxLines: 2,
                prefixIcon: Icon(Icons.money, color: colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.error),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
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
              decoration: InputDecoration(
                labelText: 'Monto Inicial',
                labelStyle: TextStyle(color: colorScheme.primary),
                prefixText: '\$ ',
                prefixIcon: Icon(
                  Icons.account_balance_wallet,
                  color: colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.error),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
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
        FilledButton.icon(
          onPressed: _isLoading ? null : _addMoneda,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: AppLoadingIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add),
          label: const Text('Agregar'),
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
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Denominación agregada exitosamente'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onError,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Error al agregar denominación: $e')),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
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
