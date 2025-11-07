import 'package:compaexpress/widget/balance_card.dart';
import 'package:flutter/material.dart';

class BalanceCards extends StatelessWidget {
  final double saldoInicial;
  final double? saldoTransferencias;
  final double? saldoTarjetas;
  final double? saldoOtros;

  const BalanceCards({
    super.key,
    required this.saldoInicial,
    this.saldoTransferencias,
    this.saldoTarjetas,
    this.saldoOtros,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.spaceBetween,
          children: [
            SizedBox(
              width: isSmallScreen
                  ? double.infinity
                  : constraints.maxWidth / 4 - 12,
              child: BalanceCard(
                title: 'Caja',
                amount: '\$${saldoInicial.toStringAsFixed(2)}',
                colorLight: Colors.green.shade400,
                colorDark: Colors.green.shade600,
              ),
            ),
            SizedBox(
              width: isSmallScreen
                  ? double.infinity
                  : constraints.maxWidth / 4 - 12,
              child: BalanceCard(
                title: 'Transferencias',
                amount: saldoTransferencias != null
                    ? '\$${saldoTransferencias!.toStringAsFixed(2)}'
                    : '\$0.00',
                colorLight: Colors.cyan.shade400,
                colorDark: Colors.cyan.shade600,
              ),
            ),
            SizedBox(
              width: isSmallScreen
                  ? double.infinity
                  : constraints.maxWidth / 4 - 12,
              child: BalanceCard(
                title: 'Tarjetas',
                amount: saldoTarjetas != null
                    ? '\$${saldoTarjetas!.toStringAsFixed(2)}'
                    : '\$0.00',
                colorLight: Colors.blue.shade400,
                colorDark: Colors.blue.shade600,
              ),
            ),
            SizedBox(
              width: isSmallScreen
                  ? double.infinity
                  : constraints.maxWidth / 4 - 12,
              child: BalanceCard(
                title: 'Otros',
                amount: saldoOtros != null
                    ? '\$${saldoOtros!.toStringAsFixed(2)}'
                    : '\$0.00',
                colorLight: Colors.deepPurple.shade400,
                colorDark: Colors.deepPurple.shade600,
              ),
            ),
          ],
        );
      },
    );
  }
}
