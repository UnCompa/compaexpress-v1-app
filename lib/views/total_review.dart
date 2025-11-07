import 'dart:io';

import 'package:compaexpress/models/ModelProvider.dart';
import 'package:flutter/material.dart';

class TotalAndPagoSection extends StatefulWidget {
  final TextEditingController montoRecibidoController;
  final VoidCallback pickLogo;
  final String? comprobantePreviewUrl;
  final double? saldoInicial;
  final TiposPago? selectedPaymentType;
  final double Function() calculateTotal;
  final double Function() getMontoRecibido;
  final double Function() getCambio;

  const TotalAndPagoSection({
    super.key,
    required this.montoRecibidoController,
    required this.pickLogo,
    this.comprobantePreviewUrl,
    this.saldoInicial,
    this.selectedPaymentType,
    required this.calculateTotal,
    required this.getMontoRecibido,
    required this.getCambio,
  });

  @override
  _TotalAndPagoSectionState createState() => _TotalAndPagoSectionState();
}

class _TotalAndPagoSectionState extends State<TotalAndPagoSection> {
  @override
  Widget build(BuildContext context) {
    final total = widget.calculateTotal();
    final totalPago = widget.getMontoRecibido();
    final isValid = totalPago >= total;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de monto recibido
            TextFormField(
              controller: widget.montoRecibidoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Monto recibido',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.attach_money),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 10 : 12,
                  horizontal: 12,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
            if (!isValid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'El pago debe ser mayor que el total',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Sección de comprobante
            Text(
              'Comprobante de pago (imagen o QR)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: isSmallScreen ? 16 : 18,
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: isSmallScreen ? 2 : 1,
                      child: Row(
                        mainAxisAlignment: isSmallScreen
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            color: Theme.of(context).primaryColor,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.comprobantePreviewUrl != null
                                  ? 'Comprobante seleccionado'
                                  : 'Comprobante logo',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: isSmallScreen ? 3 : 2,
                      child: ElevatedButton.icon(
                        onPressed: widget.pickLogo,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          widget.comprobantePreviewUrl != null
                              ? 'Cambiar comprobante'
                              : 'Subir comprobante',
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).primaryColor,
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          minimumSize: Size(
                            isSmallScreen ? 100 : 150,
                            isSmallScreen ? 36 : 40,
                          ),
                        ),
                      ),
                    ),
                    if (widget.comprobantePreviewUrl != null) ...[
                      const SizedBox(width: 12),
                      Flexible(
                        flex: isSmallScreen ? 3 : 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(widget.comprobantePreviewUrl!),
                            height: isSmallScreen ? 60 : 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Resumen y Pago
            Text(
              'Resumen y Pago',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: isSmallScreen ? 18 : 20,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              label: 'Saldo Inicial:',
              value: widget.saldoInicial?.toStringAsFixed(2) ?? '0.00',
              isSmallScreen: isSmallScreen,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              label: 'Total Factura:',
              value: total.toStringAsFixed(2),
              isSmallScreen: isSmallScreen,
              textColor: isValid ? Colors.green[700] : Colors.red[700],
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              label: 'Total Pagado:',
              value: totalPago.toStringAsFixed(2),
              isSmallScreen: isSmallScreen,
              textColor: isValid ? Colors.green[700] : Colors.red[700],
            ),
            if (widget.selectedPaymentType == 'EFECTIVO') ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                context,
                label: 'Cambio:',
                value: widget.getCambio().toStringAsFixed(2),
                isSmallScreen: isSmallScreen,
                textColor: Colors.blue[700],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    required bool isSmallScreen,
    Color? textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 14 : 16,
            color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
