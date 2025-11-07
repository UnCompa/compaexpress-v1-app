import 'package:compaexpress/entities/payment_option.dart';
import 'package:compaexpress/widget/collapsible_section.dart';
import 'package:compaexpress/widget/payment_option_item.dart';
import 'package:flutter/material.dart';

// Widget principal genérico para la sección de pago
class PaymentSectionWidget extends StatefulWidget {
  final double totalAmount;
  final double? initialBalance;
  final List<PaymentOption> paymentOptions;
  final Function(List<PaymentOption>) onPaymentChanged;
  final VoidCallback? onPaymentComplete;
  final String title;
  final String balanceLabel;
  final String totalLabel;
  final bool showBalance;
  final bool enableQuickKeyboard;
  final VoidCallback? onRequestFocus; // Nuevo: notifica cuando necesita focus
  final VoidCallback? onReleaseFocus; // Nuevo: notifica cuando libera focus

  const PaymentSectionWidget({
    super.key,
    required this.totalAmount,
    required this.paymentOptions,
    required this.onPaymentChanged,
    this.initialBalance,
    this.onPaymentComplete,
    this.title = 'Resumen y Pago',
    this.balanceLabel = 'Saldo en caja:',
    this.totalLabel = 'Total:',
    this.showBalance = true,
    this.enableQuickKeyboard = true,
    this.onRequestFocus,
    this.onReleaseFocus,
  });

  @override
  State<PaymentSectionWidget> createState() => PaymentSectionWidgetState();
}

class PaymentSectionWidgetState extends State<PaymentSectionWidget> {
  bool _isPaymentSectionExpanded = false;
  bool _isQuickKeyboardActive = false;
  String _quickAmount = '';
  DateTime? _lastKeyPressTime;
  static const _keyPressTimeout = Duration(milliseconds: 300);

  @override
  void dispose() {
    if (_isQuickKeyboardActive) {
      widget.onReleaseFocus?.call();
    }
    super.dispose();
  }

  double get _totalPaid {
    return widget.paymentOptions
        .where((o) => o.seleccionado)
        .fold(0, (sum, o) => sum + o.monto);
  }

  double get _change => _totalPaid - widget.totalAmount;
  bool get _isValid => _totalPaid >= widget.totalAmount;

  List<PaymentOption> get _selectedPayments {
    return widget.paymentOptions.where((o) => o.seleccionado).toList();
  }

  // Separar pagos principales (Efectivo, Transferencia) de otros
  List<PaymentOption> get _mainPaymentOptions {
    return widget.paymentOptions.where((option) {
      final name = option.tipo.name.toUpperCase();
      return name.contains('EFECTIVO') || name.contains('TRANSFERENCIA');
    }).toList();
  }

  List<PaymentOption> get _otherPaymentOptions {
    return widget.paymentOptions.where((option) {
      final name = option.tipo.name.toUpperCase();
      return !name.contains('EFECTIVO') && !name.contains('TRANSFERENCIA');
    }).toList();
  }

  // Hacer público para poder activarlo externamente
  void activateQuickKeyboard() {
    if (!_isQuickKeyboardActive) {
      setState(() {
        _isQuickKeyboardActive = true;
        _quickAmount = ''; // Limpiar al activar
      });
      widget.onRequestFocus?.call();
      debugPrint('✅ Pago rápido ACTIVADO');
    }
  }

  void _deactivateQuickKeyboard() {
    if (_isQuickKeyboardActive) {
      setState(() {
        _isQuickKeyboardActive = false;
        _quickAmount = '';
      });
      widget.onReleaseFocus?.call();
      debugPrint('❌ Pago rápido DESACTIVADO');
    }
  }

  void _handleKeyPress(String key) {
    if (!_isQuickKeyboardActive) {
      debugPrint('⚠️ Tecla recibida pero modo inactivo: $key');
      return;
    }

    debugPrint('⌨️ Tecla en pago rápido: $key (monto actual: $_quickAmount)');

    final now = DateTime.now();
    _lastKeyPressTime = now;

    setState(() {
      if ('0123456789'.contains(key)) {
        _quickAmount += key;
        debugPrint('💰 Nuevo monto: $_quickAmount');
      } else if (key == '.' || key == ',') {
        if (!_quickAmount.contains('.')) {
          _quickAmount += '.';
          debugPrint('💰 Decimal agregado: $_quickAmount');
        }
      }
    });
  }

  void _handleEnter() {
    debugPrint(
      '↩️ Enter presionado - Activo: $_isQuickKeyboardActive, Monto: $_quickAmount',
    );

    if (_isQuickKeyboardActive && _quickAmount.isNotEmpty) {
      _applyQuickAmount();
    } else if (_isQuickKeyboardActive && _quickAmount.isEmpty) {
      debugPrint('⚠️ No hay monto para aplicar');
      // Mostrar un mensaje visual
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese un monto antes de presionar Enter'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleEscape() {
    debugPrint('⎋ Escape presionado');
    if (_isQuickKeyboardActive) {
      _deactivateQuickKeyboard();
    }
  }

  void _handleBackspace() {
    if (_isQuickKeyboardActive && _quickAmount.isNotEmpty) {
      setState(() {
        _quickAmount = _quickAmount.substring(0, _quickAmount.length - 1);
        debugPrint('⌫ Backspace - Nuevo monto: $_quickAmount');
      });
    }
  }

  void _applyQuickAmount() {
    if (_quickAmount.isEmpty) return;

    final amount = double.tryParse(_quickAmount);
    if (amount == null || amount <= 0) {
      debugPrint('❌ Monto inválido: $_quickAmount');
      return;
    }

    debugPrint('✅ Aplicando monto: \$$amount');

    setState(() {
      // Buscar primer método de pago efectivo o el primero disponible
      final efectivo = widget.paymentOptions.firstWhere(
        (o) => o.tipo.name.toUpperCase().contains('EFECTIVO'),
        orElse: () => widget.paymentOptions.first,
      );

      efectivo.seleccionado = true;
      efectivo.monto = amount;
      _quickAmount = '';

      widget.onPaymentChanged(widget.paymentOptions);

      // Desactivar el teclado rápido después de aplicar
      _deactivateQuickKeyboard();

      debugPrint('💵 Monto aplicado a ${efectivo.tipo.name}: \$$amount');

      // Si el pago es completo, llamar callback
      if (_isValid && widget.onPaymentComplete != null) {
        debugPrint('✅ Pago completo - llamando callback');
        widget.onPaymentComplete!();
      }
    });

    // Mostrar confirmación visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pago de \$${amount.toStringAsFixed(2)} aplicado'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.enableQuickKeyboard)
                  _buildQuickKeyboardToggle(theme, colorScheme),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.showBalance && widget.initialBalance != null)
              _buildSaldoRow(
                widget.balanceLabel,
                widget.initialBalance!,
                theme,
              ),
            if (widget.showBalance && widget.initialBalance != null)
              const SizedBox(height: 8),
            _buildSaldoRow(
              widget.totalLabel,
              widget.totalAmount,
              theme,
              isPrimary: true,
            ),
            if (_isQuickKeyboardActive) ...[
              const SizedBox(height: 12),
              _buildQuickAmountDisplay(theme, colorScheme),
            ],
            const SizedBox(height: 16),

            // NUEVO: Métodos de pago principales (siempre visibles)
            if (_mainPaymentOptions.isNotEmpty) ...[
              _buildMainPaymentsSection(theme, colorScheme),
              const SizedBox(height: 16),
            ],

            // Otros métodos de pago (colapsables)
            if (_otherPaymentOptions.isNotEmpty)
              _buildCollapsibleSection(theme, colorScheme),

            const SizedBox(height: 16),
            if (_selectedPayments.isNotEmpty)
              _buildPaymentSummary(_totalPaid, theme, colorScheme),
            const SizedBox(height: 16),
            _buildPaymentStatus(
              widget.totalAmount,
              _totalPaid,
              _change,
              _isValid,
              theme,
              colorScheme,
            ),
            if (!_isValid) _buildValidationWarning(colorScheme),
            if (widget.enableQuickKeyboard && _isQuickKeyboardActive) ...[
              const SizedBox(height: 12),
              _buildKeyboardHints(theme, colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickKeyboardToggle(ThemeData theme, ColorScheme colorScheme) {
    return InkWell(
      onTap: () {
        debugPrint(
          '🖱️ Toggle clicked - Current state: $_isQuickKeyboardActive',
        );
        if (_isQuickKeyboardActive) {
          _deactivateQuickKeyboard();
        } else {
          activateQuickKeyboard();
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isQuickKeyboardActive
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isQuickKeyboardActive
                ? colorScheme.primary
                : colorScheme.outline,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isQuickKeyboardActive ? Icons.keyboard : Icons.keyboard_outlined,
              size: 18,
              color: _isQuickKeyboardActive
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              _isQuickKeyboardActive ? 'Pago Rápido ON' : 'Pago Rápido OFF',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _isQuickKeyboardActive
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _isQuickKeyboardActive
                    ? colorScheme.onPrimary.withOpacity(0.2)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _isQuickKeyboardActive
                      ? colorScheme.onPrimary
                      : colorScheme.outline,
                ),
              ),
              child: Text(
                'F2',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _isQuickKeyboardActive
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountDisplay(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.keyboard,
                  size: 24,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Monto rápido:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          Text(
            _quickAmount.isEmpty ? '\$0.00' : '\$$_quickAmount',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardHints(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Modo Pago Rápido Activo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHint('0-9', 'Monto', colorScheme),
              _buildHint('.', 'Decimal', colorScheme),
              _buildHint('Enter', 'Aplicar', colorScheme),
              _buildHint('⌫', 'Borrar', colorScheme),
              _buildHint('Esc', 'Salir', colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHint(String key, String label, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: colorScheme.primary, width: 1.5),
          ),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: colorScheme.onPrimaryContainer),
        ),
      ],
    );
  }

  // NUEVO: Sección de métodos de pago principales
  Widget _buildMainPaymentsSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Métodos de Pago Principales',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._mainPaymentOptions.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PaymentOptionItem(
                option: option,
                onTap: () {
                  setState(() {
                    option.seleccionado = !option.seleccionado;
                    if (!option.seleccionado) option.monto = 0;
                    widget.onPaymentChanged(widget.paymentOptions);
                    // Desactivar teclado rápido al interactuar con opciones
                    if (_isQuickKeyboardActive) {
                      _deactivateQuickKeyboard();
                    }
                  });
                },
                onAmountChanged: (value) {
                  setState(() {
                    option.monto = double.tryParse(value) ?? 0;
                    widget.onPaymentChanged(widget.paymentOptions);
                  });
                },
                validator: (value) {
                  if (option.seleccionado && (value == null || value.isEmpty)) {
                    return 'El monto es requerido';
                  }
                  if (option.seleccionado &&
                      (double.tryParse(value!) ?? 0) <= 0) {
                    return 'Ingrese un monto válido';
                  }
                  return null;
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection(ThemeData theme, ColorScheme colorScheme) {
    return CollapsibleSection(
      title: 'Otros Métodos de Pago',
      icon: Icons.credit_card,
      isExpanded: _isPaymentSectionExpanded,
      onTap: () => setState(() {
        _isPaymentSectionExpanded = !_isPaymentSectionExpanded;
        // Desactivar teclado rápido al expandir/colapsar
        if (_isQuickKeyboardActive) {
          _deactivateQuickKeyboard();
        }
      }),
      badgeCount: _otherPaymentOptions.where((o) => o.seleccionado).length,
      child: Column(
        children: _otherPaymentOptions.map((option) {
          return PaymentOptionItem(
            option: option,
            onTap: () {
              setState(() {
                option.seleccionado = !option.seleccionado;
                if (!option.seleccionado) option.monto = 0;
                widget.onPaymentChanged(widget.paymentOptions);
                // Desactivar teclado rápido al interactuar con opciones
                if (_isQuickKeyboardActive) {
                  _deactivateQuickKeyboard();
                }
              });
            },
            onAmountChanged: (value) {
              setState(() {
                option.monto = double.tryParse(value) ?? 0;
                widget.onPaymentChanged(widget.paymentOptions);
              });
            },
            validator: (value) {
              if (option.seleccionado && (value == null || value.isEmpty)) {
                return 'El monto es requerido';
              }
              if (option.seleccionado && (double.tryParse(value!) ?? 0) <= 0) {
                return 'Ingrese un monto válido';
              }
              return null;
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSaldoRow(
    String label,
    double amount,
    ThemeData theme, {
    bool isPrimary = false,
  }) {
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isPrimary ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(
    double totalPagado,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 1,
      color: colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Pagos',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            ..._selectedPayments.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      option.tipo.name,
                      style: TextStyle(color: colorScheme.onSecondaryContainer),
                    ),
                    Text(
                      '\$${option.monto.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              );
            }),
            Divider(color: colorScheme.onSecondaryContainer.withOpacity(0.3)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pagado:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                Text(
                  '\$${totalPagado.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatus(
    double total,
    double totalPagado,
    double cambio,
    bool isValid,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 1,
      color: isValid
          ? colorScheme.tertiaryContainer
          : colorScheme.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPaymentRow(
              'Total Orden:',
              '\$${total.toStringAsFixed(2)}',
              theme,
              colorScheme,
              isValid,
            ),
            _buildPaymentRow(
              'Total Pagado:',
              '\$${totalPagado.toStringAsFixed(2)}',
              theme,
              colorScheme,
              isValid,
            ),
            Divider(
              color:
                  (isValid
                          ? colorScheme.onTertiaryContainer
                          : colorScheme.onErrorContainer)
                      .withOpacity(0.3),
            ),
            if (totalPagado == total)
              _buildStatusRow(
                Icons.check_circle,
                'Pago Completo',
                null,
                theme,
                colorScheme,
                isValid,
              )
            else if (totalPagado > total)
              _buildStatusRow(
                Icons.monetization_on,
                'Cambio:',
                '\$${cambio.toStringAsFixed(2)}',
                theme,
                colorScheme,
                isValid,
              )
            else
              _buildStatusRow(
                Icons.warning,
                'Faltante:',
                '\$${cambio.abs().toStringAsFixed(2)}',
                theme,
                colorScheme,
                isValid,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    String value,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isValid,
  ) {
    final textColor = isValid
        ? colorScheme.onTertiaryContainer
        : colorScheme.onErrorContainer;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: textColor)),
        Text(value, style: TextStyle(fontSize: 14, color: textColor)),
      ],
    );
  }

  Widget _buildStatusRow(
    IconData icon,
    String label,
    String? value,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isValid,
  ) {
    final textColor = isValid
        ? colorScheme.onTertiaryContainer
        : colorScheme.onErrorContainer;

    return Row(
      mainAxisAlignment: value != null
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        if (value != null)
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
      ],
    );
  }

  Widget _buildValidationWarning(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.error),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: colorScheme.error, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'El pago no cubre el total de la orden',
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos públicos para ser llamados externamente
  void handleKeyPress(String key) => _handleKeyPress(key);
  void handleEnter() => _handleEnter();
  void handleEscape() => _handleEscape();
  void handleBackspace() => _handleBackspace();
}
