import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/utils/denominaciones.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:toastification/toastification.dart';

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

  final Map<int, FocusNode> _focusNodes = {};
  final ScrollController _scrollController = ScrollController();

  // Para animaciones
  bool _showSummary = false;

  @override
  void initState() {
    super.initState();
    _initializeMonedasDefecto();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateActive(context);
      setState(() => _showSummary = true);
    });
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _scrollController.dispose();
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _initializeMonedasDefecto() {
    // Crear una copia mutable de la lista antes de ordenar
    final denominacionesUSD = List<double>.from(
      _denominacionesPorMoneda['USD'] ?? [],
    );
    denominacionesUSD.sort((a, b) => b.compareTo(a));

    _monedas = denominacionesUSD.map((denominacion) {
      return CajaMonedaForm(
        moneda: 'USD',
        denominacion: denominacion,
        cantidad: 0,
      );
    }).toList();

    // Inicializar FocusNodes
    for (int i = 0; i < _monedas.length; i++) {
      _focusNodes[i] = FocusNode();
    }
  }

  void _validateActive(BuildContext context) {
    try {
      final cajaIsActive = widget.caja.isActive;

      if (!cajaIsActive) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            final colorScheme = Theme.of(dialogContext).colorScheme;

            return AlertDialog(
              icon: Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.error,
                size: 48,
              ),
              title: const Text('Caja inactiva'),
              content: const Text(
                'La caja seleccionada no está activa y no puede ser cerrada.',
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Entendido'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error al validar la caja: $e');
    }
  }

  void _limpiarTodo() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.clear_all, color: colorScheme.error, size: 48),
        title: const Text('Limpiar cantidades'),
        content: const Text(
          '¿Está seguro que desea borrar todas las cantidades ingresadas?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () {
              setState(() {
                _monedas = _monedas
                    .map((m) => m.copyWith(cantidad: 0))
                    .toList();
              });
              Navigator.pop(context);
              _showToast('Cantidades limpiadas', ToastificationType.info);
            },
            child: const Text('Limpiar todo'),
          ),
        ],
      ),
    );
  }

  void _onCantidadChanged(int index, String value) {
    final cantidad = int.tryParse(value) ?? 0;
    setState(() {
      _monedas[index] = _monedas[index].copyWith(cantidad: cantidad);
    });

    // Auto-avanzar si ingresó un número
    if (value.isNotEmpty && index < _monedas.length - 1) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _focusNodes[index + 1]?.requestFocus();
        }
      });
    }
  }

  void _showToast(String message, ToastificationType type) {
    toastification.show(
      context: context,
      title: Text(message),
      type: type,
      autoCloseDuration: const Duration(seconds: 3),
      style: ToastificationStyle.fillColored,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cierre de Caja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpiar todo',
            onPressed: _limpiarTodo,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Resumen sticky animado
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _showSummary ? null : 0,
              child: _showSummary
                  ? _buildStickyTopSummary()
                  : const SizedBox.shrink(),
            ),

            Expanded(
              child: AnimationLimiter(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _buildCajaInfoSection(),
                      const SizedBox(height: 16),
                      _buildMonedasSection(),
                      const SizedBox(height: 16),
                      _buildObservacionesSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildStickyTopSummary() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalMonedas = _monedas.fold<double>(
      0.0,
      (sum, moneda) => sum + (moneda.cantidad * moneda.denominacion),
    );
    final saldoInicial = widget.caja.saldoInicial ?? 0.0;
    final diferencia = totalMonedas - saldoInicial;
    final isCuadrado = diferencia == 0 && totalMonedas > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCuadrado
              ? [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withOpacity(0.5),
                ]
              : diferencia != 0 && totalMonedas > 0
              ? [
                  colorScheme.errorContainer,
                  colorScheme.errorContainer.withOpacity(0.5),
                ]
              : [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surfaceContainerHighest.withOpacity(0.5),
                ],
        ),
        border: Border(
          bottom: BorderSide(
            color: isCuadrado
                ? colorScheme.primary
                : diferencia != 0 && totalMonedas > 0
                ? colorScheme.error
                : colorScheme.outline,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickStat(
              'Contado',
              totalMonedas,
              Icons.monetization_on_outlined,
              colorScheme.primary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: colorScheme.outline.withOpacity(0.3),
          ),
          Expanded(
            child: _buildQuickStat(
              'Esperado',
              saldoInicial,
              Icons.account_balance_outlined,
              colorScheme.secondary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: colorScheme.outline.withOpacity(0.3),
          ),
          Expanded(
            child: _buildQuickStat(
              'Diferencia',
              diferencia.abs(),
              isCuadrado
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_outlined,
              isCuadrado ? colorScheme.primary : colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    String label,
    double value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalMonedas = _monedas.fold<double>(
      0.0,
      (sum, moneda) => sum + (moneda.cantidad * moneda.denominacion),
    );
    final saldoInicial = widget.caja.saldoInicial ?? 0.0;
    final diferencia = totalMonedas - saldoInicial;
    final cantidadBilletes = _monedas.fold<int>(
      0,
      (sum, m) => sum + m.cantidad,
    );

    return AnimatedScale(
      scale: cantidadBilletes > 0 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card de resumen
            if (cantidadBilletes > 0)
              Card(
                elevation: 8,
                color: diferencia == 0
                    ? colorScheme.primaryContainer
                    : colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: diferencia == 0
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onErrorContainer,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$cantidadBilletes unidades',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: diferencia == 0
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$${totalMonedas.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: diferencia == 0
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (diferencia != 0) ...[
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              diferencia > 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: colorScheme.onErrorContainer,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              diferencia > 0
                                  ? 'Sobrante: \$${diferencia.toStringAsFixed(2)}'
                                  : 'Faltante: \$${(-diferencia).toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            // Botón de acción
            FilledButton.icon(
              onPressed: _isLoading ? null : _cerrarCaja,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.lock_clock, size: 24),
              label: Text(
                _isLoading ? 'Cerrando...' : 'CERRAR CAJA',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCajaInfoSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: colorScheme.onPrimaryContainer,
                size: 40,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo Inicial de Caja',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.caja.saldoInicial.toStringAsFixed(2)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      height: 1.2,
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

  Widget _buildObservacionesSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Observaciones',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Opcional: Agregue notas sobre el cierre',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacionesController,
              decoration: InputDecoration(
                hintText: 'Ej: Hubo un faltante de \$5 en billetes pequeños...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 4,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonedasSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conteo de Efectivo',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ingrese la cantidad de cada denominación',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        return _buildMonedaItemCompact(moneda, index);
      }).toList(),
    );
  }

  Widget _buildMonedaItemCompact(CajaMonedaForm moneda, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final montoCalculado = moneda.cantidad * moneda.denominacion;
    final isLast = index == _monedas.length - 1;
    final hasValue = moneda.cantidad > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: hasValue
            ? colorScheme.secondaryContainer.withOpacity(0.5)
            : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasValue
              ? colorScheme.secondary
              : colorScheme.outline.withOpacity(0.3),
          width: hasValue ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Chip de denominación
            Container(
              width: 90,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.secondary,
                    colorScheme.secondary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: hasValue
                    ? [
                        BoxShadow(
                          color: colorScheme.secondary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    moneda.moneda,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDenominacion(moneda.denominacion),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSecondary,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Campo de entrada
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDenominacionLabel(moneda.moneda, moneda.denominacion),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasValue
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.3),
                        width: hasValue ? 2 : 1,
                      ),
                    ),
                    child: TextFormField(
                      key: ValueKey('moneda_$index'),
                      focusNode: _focusNodes[index],
                      initialValue: moneda.cantidad == 0
                          ? ''
                          : moneda.cantidad.toString(),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.tag,
                          size: 20,
                          color: hasValue
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: isLast
                          ? TextInputAction.done
                          : TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4), // Máximo 9999
                      ],
                      onChanged: (value) => _onCantidadChanged(index, value),
                      onFieldSubmitted: (_) {
                        if (!isLast) {
                          _focusNodes[index + 1]?.requestFocus();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Total y botón de limpiar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: hasValue
                        ? colorScheme.tertiaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '\$${montoCalculado.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: hasValue
                              ? colorScheme.onTertiaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasValue) ...[
                  const SizedBox(height: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.close, size: 18),
                    iconSize: 18,
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.errorContainer,
                      foregroundColor: colorScheme.onErrorContainer,
                      minimumSize: const Size(32, 32),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      setState(() {
                        _monedas[index] = moneda.copyWith(cantidad: 0);
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
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
      return 'Moneda de ${(denominacion * 100).toInt()} centavos';
    } else if (denominacion == 1) {
      return 'Billete de 1 ${moneda == 'USD' ? 'dólar' : 'euro'}';
    } else {
      return 'Billete de ${denominacion.toInt()} ${moneda == 'USD' ? 'dólares' : 'euros'}';
    }
  }

  Future<void> _cerrarCaja() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final totalMonedas = _monedas.fold<double>(
      0.0,
      (sum, moneda) => sum + (moneda.cantidad * moneda.denominacion),
    );

    if (totalMonedas == 0) {
      _showToast(
        'Debe contar al menos una denominación',
        ToastificationType.warning,
      );
      return;
    }

    // Confirmación mejorada
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final diferencia = totalMonedas - widget.caja.saldoInicial;
        final isCuadrado = diferencia == 0;

        return AlertDialog(
          icon: Icon(
            isCuadrado
                ? Icons.check_circle_outline
                : Icons.warning_amber_outlined,
            color: isCuadrado ? colorScheme.primary : colorScheme.error,
            size: 48,
          ),
          title: Text(
            isCuadrado ? '¡Caja Cuadrada!' : 'Confirmar Cierre',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildResumenRow(
                      'Total contado:',
                      '\$${totalMonedas.toStringAsFixed(2)}',
                      colorScheme.primary,
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildResumenRow(
                      'Total esperado:',
                      '\$${widget.caja.saldoInicial.toStringAsFixed(2)}',
                      colorScheme.secondary,
                      theme,
                    ),
                    const Divider(height: 24),
                    _buildResumenRow(
                      'Diferencia:',
                      '\$${diferencia.toStringAsFixed(2)}',
                      isCuadrado ? colorScheme.primary : colorScheme.error,
                      theme,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              if (!isCuadrado) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        diferencia > 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          diferencia > 0
                              ? 'Hay un sobrante de \$${diferencia.toStringAsFixed(2)}'
                              : 'Hay un faltante de \$${(-diferencia).toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Revisar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar Cierre'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final negocioData = await NegocioService.getCurrentUserInfo();

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
        _showToast('Caja cerrada exitosamente', ToastificationType.success);
      }
    } catch (e) {
      if (mounted) {
        _showToast('Error al cerrar la caja: $e', ToastificationType.error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildResumenRow(
    String label,
    String value,
    Color color,
    ThemeData theme, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              (isTotal
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.bodyMedium)
                  ?.copyWith(
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  ),
        ),
        Text(
          value,
          style:
              (isTotal
                      ? theme.textTheme.titleLarge
                      : theme.textTheme.titleMedium)
                  ?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
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
