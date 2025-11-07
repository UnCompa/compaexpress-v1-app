import 'package:compaexpress/providers/invoice_design_provider.dart';
import 'package:compaexpress/utils/invoice_design.dart';
import 'package:compaexpress/widget/invoide_design_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget que muestra una previsualización del diseño de factura seleccionado
class InvoiceDesignPreview extends ConsumerWidget {
  const InvoiceDesignPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDesign = ref.watch(invoiceDesignProvider);

    return Card(
      elevation: 3,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vista Previa',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Chip(
                  label: Text(
                    currentDesign.nombre,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: _getDesignColor(
                    currentDesign,
                  ).withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Contenedor que simula papel térmico
            Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildPreviewContent(currentDesign),
            ),
            const SizedBox(height: 12),
            Text(
              currentDesign.descripcion,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent(InvoiceDesign design) {
    switch (design) {
      case InvoiceDesign.classic:
        return _buildClassicPreview();
      case InvoiceDesign.compact:
        return _buildCompactPreview();
      case InvoiceDesign.detailed:
        return _buildDetailedPreview();
      case InvoiceDesign.modern:
        return _buildModernPreview();
      case InvoiceDesign.simple:
        return _buildSimplePreview();
    }
  }

  // CLÁSICO
  Widget _buildClassicPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildText('MI NEGOCIO S.A.', bold: true, size: 18),
        const SizedBox(height: 4),
        _buildText('RUC: 1234567890001', bold: true, size: 11),
        _buildText('Av. Principal 123', size: 10),
        _buildText('Quito, Ecuador', size: 10),
        _buildText('Tel: 02-1234567', size: 10),
        const SizedBox(height: 8),
        _buildDivider('='),
        const SizedBox(height: 4),
        _buildText('FACTURA', bold: true, size: 16),
        _buildText('No. 001-001-000001234', bold: true, size: 11),
        const SizedBox(height: 4),
        _buildText('Fecha: 05/11/2025 14:30', size: 10, align: TextAlign.left),
        const SizedBox(height: 4),
        _buildDivider('='),
        const SizedBox(height: 8),
        // Encabezado tabla
        _buildTableHeader(),
        _buildDivider('-'),
        // Productos
        _buildProductRow('Producto A', '2', '5.00', '10.00'),
        _buildProductRow('Producto B', '1', '15.50', '15.50'),
        _buildProductRow('Producto C', '3', '3.25', '9.75'),
        const SizedBox(height: 4),
        _buildDivider('-'),
        const SizedBox(height: 4),
        // Totales
        _buildTotalRow('Subtotal:', '35.25'),
        _buildTotalRow('IVA:', '4.23'),
        const SizedBox(height: 4),
        _buildTotalRow('TOTAL:', '39.48', bold: true, size: 14),
        const SizedBox(height: 8),
        _buildDivider('='),
        const SizedBox(height: 8),
        _buildText('¡Gracias por su compra!', bold: true, size: 11),
        _buildText('Vuelva pronto', size: 10),
      ],
    );
  }

  // COMPACTO
  Widget _buildCompactPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildText('MI NEGOCIO S.A.', bold: true, size: 14),
        _buildText('RUC: 1234567890001', size: 10),
        _buildDivider('-'),
        _buildText('FACTURA #001-001-000001234', bold: true, size: 11),
        _buildText('05/11/25 14:30', size: 9),
        _buildDivider('-'),
        const SizedBox(height: 4),
        _buildCompactProduct('Producto A', '2 x \$5.00', '10.00'),
        _buildCompactProduct('Producto B', '1 x \$15.50', '15.50'),
        _buildCompactProduct('Producto C', '3 x \$3.25', '9.75'),
        const SizedBox(height: 4),
        _buildDivider('-'),
        const SizedBox(height: 4),
        _buildTotalRow('TOTAL:', '39.48', bold: true, size: 16),
        const SizedBox(height: 4),
        _buildDivider('-'),
        const SizedBox(height: 4),
        _buildText('¡Gracias!', bold: true, size: 10),
      ],
    );
  }

  // DETALLADO
  Widget _buildDetailedPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildDivider('='),
        _buildText('MI NEGOCIO S.A.', bold: true, size: 16),
        _buildDivider('='),
        const SizedBox(height: 6),
        _buildText('INFORMACIÓN FISCAL', bold: true, size: 11),
        _buildDivider('-'),
        _buildDetailedInfo('RUC:', '1234567890001'),
        _buildDetailedInfo('Dir:', 'Av. Principal 123'),
        _buildDetailedInfo('Tel:', '02-1234567'),
        _buildDivider('='),
        _buildText('DOCUMENTO FISCAL', bold: true, size: 12),
        _buildText('FACTURA No. 001-001-000001234', bold: true, size: 10),
        _buildText(
          'Fecha emision:',
          bold: true,
          size: 9,
          align: TextAlign.left,
        ),
        _buildText('05/11/2025 14:30:45', size: 9, align: TextAlign.left),
        _buildDivider('='),
        _buildText('DETALLE DE PRODUCTOS', bold: true, size: 10),
        _buildDivider('-'),
        const SizedBox(height: 4),
        _buildDetailedProduct('[1]', 'Producto A', '2', '5.0000', '10.00'),
        _buildDetailedProduct('[2]', 'Producto B', '1', '15.5000', '15.50'),
        const SizedBox(height: 4),
        _buildDivider('='),
        _buildTotalRow('Subtotal:', '35.25'),
        _buildTotalRow('IVA:', '4.23'),
        _buildTotalRow('TOTAL:', '39.48', bold: true, size: 14),
        const SizedBox(height: 6),
        _buildText('Gracias por su preferencia!', bold: true, size: 10),
      ],
    );
  }

  // MODERNO
  Widget _buildModernPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 4),
        _buildText('MI NEGOCIO S.A.', bold: true, size: 16),
        _buildDivider('='),
        _buildText('RUC 1234567890001', size: 10),
        _buildText('Tel: 02-1234567', size: 10),
        const SizedBox(height: 8),
        _buildText('FACTURA', size: 14),
        _buildText('#001-001-000001234', bold: true, size: 16),
        _buildText('05 Nov 2025 - 14:30', size: 10),
        _buildDivider('='),
        const SizedBox(height: 8),
        _buildModernProduct('Producto A', '2 x \$5.00', '10.00'),
        _buildModernProduct('Producto B', '1 x \$15.50', '15.50'),
        _buildModernProduct('Producto C', '3 x \$3.25', '9.75'),
        const SizedBox(height: 8),
        _buildDivider('='),
        const SizedBox(height: 8),
        _buildTotalRow('TOTAL', '39.48', bold: true, size: 18),
        _buildDivider('='),
        const SizedBox(height: 8),
        _buildText('Efectivo    \$50.00', size: 9),
        const SizedBox(height: 8),
        _buildText('Gracias por tu compra', bold: true, size: 11),
        _buildText('Vuelve pronto', size: 9),
      ],
    );
  }

  // SIMPLE
  Widget _buildSimplePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildText('MI NEGOCIO S.A.', bold: true, size: 16),
        const SizedBox(height: 8),
        _buildDivider('─'),
        const SizedBox(height: 8),
        _buildText('RECIBO', bold: true, size: 12),
        _buildText('No. 001-001-000001234', size: 10),
        _buildText('05/11/2025 14:30', size: 10),
        const SizedBox(height: 8),
        _buildDivider('─'),
        const SizedBox(height: 12),
        _buildTotalRow('TOTAL:', '39.48', bold: true, size: 20),
        const SizedBox(height: 12),
        _buildDivider('─'),
        const SizedBox(height: 8),
        _buildText('¡Gracias!', size: 11),
      ],
    );
  }

  // ========== HELPERS ==========

  Widget _buildText(
    String text, {
    bool bold = false,
    double size = 10,
    TextAlign align = TextAlign.center,
  }) {
    return Text(
      text,
      style: GoogleFonts.robotoMono(
        fontSize: size,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        height: 1.3,
      ),
      textAlign: align,
    );
  }

  Widget _buildDivider(String char) {
    return Text(
      char * 32,
      style: GoogleFonts.robotoMono(fontSize: 8),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: _buildText(
            'Producto',
            bold: true,
            size: 9,
            align: TextAlign.left,
          ),
        ),
        Expanded(flex: 2, child: _buildText('Cant', bold: true, size: 9)),
        Expanded(
          flex: 2,
          child: _buildText(
            'P.Unit',
            bold: true,
            size: 9,
            align: TextAlign.right,
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildText(
            'Total',
            bold: true,
            size: 9,
            align: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildProductRow(
    String nombre,
    String cant,
    String precio,
    String total,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: _buildText(nombre, size: 9, align: TextAlign.left),
          ),
          Expanded(flex: 2, child: _buildText(cant, size: 9)),
          Expanded(
            flex: 2,
            child: _buildText('\$$precio', size: 9, align: TextAlign.right),
          ),
          Expanded(
            flex: 2,
            child: _buildText('\$$total', size: 9, align: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    String amount, {
    bool bold = false,
    double size = 10,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildText(label, bold: bold, size: size, align: TextAlign.left),
          _buildText(
            '\$$amount',
            bold: bold,
            size: size,
            align: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactProduct(String nombre, String detalle, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText(nombre, size: 9, align: TextAlign.left),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildText('  $detalle', size: 8, align: TextAlign.left),
              _buildText('\$$total', size: 9, align: TextAlign.right),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          _buildText(label, bold: true, size: 9, align: TextAlign.left),
          const SizedBox(width: 4),
          Expanded(child: _buildText(value, size: 9, align: TextAlign.left)),
        ],
      ),
    );
  }

  Widget _buildDetailedProduct(
    String num,
    String nombre,
    String cant,
    String precio,
    String total,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText(
            '$num $nombre',
            bold: true,
            size: 9,
            align: TextAlign.left,
          ),
          _buildDetailedInfo('  Cantidad:', cant),
          _buildDetailedInfo('  Precio Unit:', '\$$precio'),
          _buildDetailedInfo('  TOTAL:', '\$$total'),
        ],
      ),
    );
  }

  Widget _buildModernProduct(String nombre, String detalle, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText(nombre, bold: true, size: 10, align: TextAlign.left),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildText('  $detalle', size: 9, align: TextAlign.left),
              _buildText(
                '\$$total',
                bold: true,
                size: 10,
                align: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDesignColor(InvoiceDesign design) {
    switch (design) {
      case InvoiceDesign.classic:
        return Colors.blue;
      case InvoiceDesign.compact:
        return Colors.green;
      case InvoiceDesign.detailed:
        return Colors.purple;
      case InvoiceDesign.modern:
        return Colors.orange;
      case InvoiceDesign.simple:
        return Colors.grey;
    }
  }
}

/// Página completa de previsualización con selector
class InvoiceDesignPreviewPage extends ConsumerWidget {
  const InvoiceDesignPreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diseño de Factura', style: GoogleFonts.poppins()),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const InvoiceDesignPreview(),
            const SizedBox(height: 16),
            const InvoiceDesignSelector(),
          ],
        ),
      ),
    );
  }
}

/// Widget combinado más compacto para usar en configuraciones
class InvoiceDesignSelectorWithPreview extends ConsumerWidget {
  const InvoiceDesignSelectorWithPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const InvoiceDesignPreview(),
        const SizedBox(height: 16),
        const InvoiceDesignSelector(),
      ],
    );
  }
}
