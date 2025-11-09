import 'package:compaexpress/entities/payment_option.dart';
import 'package:compaexpress/page/vendedor/order/vendedor_order_create_page.dart';
import 'package:flutter/material.dart';

class PaymentOptionItem extends StatelessWidget {
  final PaymentOption option;
  final VoidCallback onTap;
  final void Function(String) onAmountChanged;
  final String? Function(String?)? validator;

  const PaymentOptionItem({
    super.key,
    required this.option,
    required this.onTap,
    required this.onAmountChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: option.seleccionado
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: option.seleccionado
                    ? colorScheme.primary
                    : colorScheme.outline,
                width: option.seleccionado ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: option.seleccionado
                            ? colorScheme.primary.withOpacity(0.2)
                            : colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getPaymentIcon(option.tipo.name),
                        size: 20,
                        color: option.seleccionado
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option.tipo.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: option.seleccionado
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: option.seleccionado
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: option.seleccionado
                            ? colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: option.seleccionado
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: option.seleccionado
                            ? colorScheme.onPrimary
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: option.seleccionado
                      ? Container(
                          margin: const EdgeInsets.only(top: 12),
                          child: ThemedTextField(
                            initialValue: option.monto > 0
                                ? option.monto.toString()
                                : '',
                            labelText: "Dinero recibido",
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: onAmountChanged,
                            validator: validator,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String paymentType) {
    switch (paymentType.toUpperCase()) {
      case 'EFECTIVO':
        return Icons.money;
      case 'TRANSFERENCIA':
        return Icons.account_balance;
      case 'TARJETA':
        return Icons.credit_card;
      case 'CHEQUE':
        return Icons.receipt_long;
      default:
        return Icons.payment;
    }
  }
}
