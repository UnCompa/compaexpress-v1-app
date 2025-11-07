import 'dart:typed_data';

import 'package:compaexpress/entities/invoice_with_details.dart';
import 'package:compaexpress/entities/order_with_details.dart';
import 'package:compaexpress/models/Negocio.dart';
import 'package:compaexpress/utils/invoice_design.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class PrinterThermal {
  /// Genera bytes según el diseño seleccionado
  static Future<List<int>> generarBytesFactura(
    InvoiceWithDetails invoiceWithDetails,
    Negocio negocio, {
    InvoiceDesign design = InvoiceDesign.classic,
    bool incluirLogo = false,
    String logoUrl = '',
    String? mensajePie,
  }) async {
    switch (design) {
      case InvoiceDesign.classic:
        return _generarDisenioClasico(
          invoiceWithDetails,
          negocio,
          incluirLogo: incluirLogo,
          logoUrl: logoUrl,
          mensajePie: mensajePie,
        );
      case InvoiceDesign.compact:
        return _generarDisenioCompacto(
          invoiceWithDetails,
          negocio,
          mensajePie: mensajePie,
        );
      case InvoiceDesign.detailed:
        return _generarDisenioDetallado(
          invoiceWithDetails,
          negocio,
          incluirLogo: incluirLogo,
          mensajePie: mensajePie,
        );
      case InvoiceDesign.modern:
        return _generarDisenioModerno(
          invoiceWithDetails,
          negocio,
          mensajePie: mensajePie,
        );
      case InvoiceDesign.simple:
        return _generarDisenioSimple(invoiceWithDetails, negocio);
    }
  }

  /// DISEÑO CLÁSICO - Tradicional con detalles completos
  static Future<List<int>> _generarDisenioClasico(
    InvoiceWithDetails invoiceWithDetails,
    Negocio negocio, {
    bool incluirLogo = false,
    String logoUrl = '',
    String? mensajePie,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    final factura = invoiceWithDetails.invoice;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Encabezado empresa
    bytes += generator.text(
      negocio.nombre.toUpperCase(),
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.feed(1);

    if (negocio.ruc.isNotEmpty) {
      bytes += generator.text(
        'RUC: ${negocio.ruc}',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
    }

    if (negocio.direccion != null && negocio.direccion!.isNotEmpty) {
      bytes += generator.text(
        negocio.direccion!,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    final ubicacion = [
      negocio.ciudad,
      negocio.provincia,
      negocio.pais,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
    if (ubicacion.isNotEmpty) {
      bytes += generator.text(
        ubicacion,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    if (negocio.telefono != null && negocio.telefono!.isNotEmpty) {
      bytes += generator.text(
        'Tel: ${negocio.telefono}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    if (negocio.correoElectronico != null &&
        negocio.correoElectronico!.isNotEmpty) {
      bytes += generator.text(
        negocio.correoElectronico!,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.feed(1);
    bytes += generator.hr(ch: '=');

    // Datos factura
    bytes += generator.text(
      'FACTURA',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      'No. ${factura.invoiceNumber}',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Fecha: ${dateFormat.format(factura.invoiceDate.getDateTimeInUtc())}',
    );
    bytes += generator.hr(ch: '=');

    // Tabla de productos
    bytes += generator.row([
      PosColumn(
        text: 'Producto',
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: 'Cant',
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.center),
      ),
      PosColumn(
        text: 'P.Unit',
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
      PosColumn(
        text: 'Total',
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
    bytes += generator.hr(ch: '-');

    double subtotal = 0.0;
    double totalImpuestos = 0.0;

    for (final detalle in invoiceWithDetails.invoiceDetails) {
      final cantidad = detalle.invoiceItem.quantity;
      final precio = detalle.precios.precio / detalle.precios.quantity;
      final itemSubtotal = detalle.invoiceItem.subtotal;
      final itemTotal = detalle.invoiceItem.total;
      final impuesto = itemTotal - itemSubtotal;

      subtotal += itemSubtotal;
      totalImpuestos += impuesto;

      final nombreProducto = detalle.productos.nombre;
      bytes += generator.row([
        PosColumn(
          text: nombreProducto.length > 25
              ? '${nombreProducto.substring(0, 22)}...'
              : nombreProducto,
          width: 6,
        ),
        PosColumn(
          text: '$cantidad',
          width: 2,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: '\$${precio.toStringAsFixed(2)}',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: '\$${itemTotal.toStringAsFixed(2)}',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      if (detalle.precios.quantity > 1) {
        bytes += generator.text(
          '  (${detalle.precios.nombre} - ${detalle.precios.quantity} unid.)',
          styles: const PosStyles(align: PosAlign.left),
        );
      }
    }

    bytes += generator.hr(ch: '-');

    // Totales
    bytes += _generarTotales(generator, subtotal, totalImpuestos);
    bytes += generator.hr(ch: '=');

    // Pagos
    bytes += _generarSeccionPagos(
      generator,
      invoiceWithDetails,
      subtotal + totalImpuestos,
    );

    // Pie de página
    bytes += _generarPiePagina(generator, mensajePie);

    return bytes;
  }

  /// DISEÑO COMPACTO - Minimalista que ahorra papel
  static Future<List<int>> _generarDisenioCompacto(
    InvoiceWithDetails invoiceWithDetails,
    Negocio negocio, {
    String? mensajePie,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    final factura = invoiceWithDetails.invoice;
    final dateFormat = DateFormat('dd/MM/yy HH:mm');

    // Encabezado compacto
    bytes += generator.text(
      negocio.nombre,
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'RUC: ${negocio.ruc}',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr(ch: '-');
    bytes += generator.text(
      'FACTURA #${factura.invoiceNumber}',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      dateFormat.format(factura.invoiceDate.getDateTimeInUtc()),
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr(ch: '-');

    // Productos en formato compacto
    double total = 0.0;
    for (final detalle in invoiceWithDetails.invoiceDetails) {
      final cantidad = detalle.invoiceItem.quantity;
      final itemTotal = detalle.invoiceItem.total;
      total += itemTotal;

      final nombre = detalle.productos.nombre.length > 28
          ? '${detalle.productos.nombre.substring(0, 25)}...'
          : detalle.productos.nombre;

      bytes += generator.text(nombre);
      bytes += generator.row([
        PosColumn(
          text: '  $cantidad x \$${(itemTotal / cantidad).toStringAsFixed(2)}',
          width: 8,
        ),
        PosColumn(
          text: '\$${itemTotal.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr(ch: '-');
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL:',
        width: 6,
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: '\$${total.toStringAsFixed(2)}',
        width: 6,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.hr(ch: '-');

    bytes += generator.text(
      mensajePie ?? '¡Gracias!',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);
    bytes += generator.cut();

    return bytes;
  }

  /// DISEÑO DETALLADO - Incluye toda la información posible
  static Future<List<int>> _generarDisenioDetallado(
    InvoiceWithDetails invoiceWithDetails,
    Negocio negocio, {
    bool incluirLogo = false,
    String? mensajePie,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    final factura = invoiceWithDetails.invoice;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

    // Encabezado completo
    bytes += generator.hr(ch: '=');
    bytes += generator.text(
      negocio.nombre.toUpperCase(),
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.hr(ch: '=');
    bytes += generator.feed(1);

    // Información detallada del negocio
    bytes += generator.text(
      'INFORMACIÓN FISCAL',
      styles: const PosStyles(bold: true, align: PosAlign.center),
    );
    bytes += generator.hr(ch: '-');
    bytes += generator.text(
      'RUC: ${negocio.ruc}',
      styles: const PosStyles(bold: true),
    );
    if (negocio.direccion != null) {
      bytes += generator.text('Dir: ${negocio.direccion}');
    }
    if (negocio.ciudad != null) {
      bytes += generator.text('Ciudad: ${negocio.ciudad}');
    }
    if (negocio.telefono != null) {
      bytes += generator.text('Tel: ${negocio.telefono}');
    }
    if (negocio.correoElectronico != null) {
      bytes += generator.text('Email: ${negocio.correoElectronico}');
    }
    bytes += generator.hr(ch: '=');

    // Información de factura detallada
    bytes += generator.text(
      'DOCUMENTO FISCAL',
      styles: const PosStyles(
        bold: true,
        align: PosAlign.center,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      'FACTURA No. ${factura.invoiceNumber}',
      styles: const PosStyles(bold: true, align: PosAlign.center),
    );
    bytes += generator.text(
      'Fecha emision:',
      styles: const PosStyles(bold: true),
    );
    bytes += generator.text(
      dateFormat.format(factura.invoiceDate.getDateTimeInUtc()),
    );
    bytes += generator.hr(ch: '=');

    // Detalle completo de productos
    bytes += generator.text(
      'DETALLE DE PRODUCTOS',
      styles: const PosStyles(bold: true, align: PosAlign.center),
    );
    bytes += generator.hr(ch: '-');

    double subtotal = 0.0;
    double totalImpuestos = 0.0;
    int itemNumber = 1;

    for (final detalle in invoiceWithDetails.invoiceDetails) {
      final cantidad = detalle.invoiceItem.quantity;
      final precioUnitario = detalle.precios.precio / detalle.precios.quantity;
      final itemSubtotal = detalle.invoiceItem.subtotal;
      final itemTotal = detalle.invoiceItem.total;
      final impuesto = itemTotal - itemSubtotal;

      subtotal += itemSubtotal;
      totalImpuestos += impuesto;

      bytes += generator.text(
        '[$itemNumber] ${detalle.productos.nombre}',
        styles: const PosStyles(bold: true),
      );
      bytes += generator.text('    Código: ${detalle.productos.barCode}');
      bytes += generator.row([
        PosColumn(text: '    Cantidad:', width: 6),
        PosColumn(
          text: '$cantidad',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: '    Precio Unit:', width: 6),
        PosColumn(
          text: '\$${precioUnitario.toStringAsFixed(4)}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: '    Subtotal:', width: 6),
        PosColumn(
          text: '\$${itemSubtotal.toStringAsFixed(2)}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      if (impuesto > 0) {
        bytes += generator.row([
          PosColumn(text: '    IVA:', width: 6),
          PosColumn(
            text: '\$${impuesto.toStringAsFixed(2)}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
      bytes += generator.row([
        PosColumn(
          text: '    TOTAL:',
          width: 6,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: '\$${itemTotal.toStringAsFixed(2)}',
          width: 6,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);

      if (detalle.precios.quantity > 1) {
        bytes += generator.text('    Oferta: ${detalle.precios.nombre}');
      }

      bytes += generator.hr(ch: '.');
      itemNumber++;
    }

    // Resumen financiero detallado
    bytes += generator.hr(ch: '=');
    bytes += generator.text(
      'RESUMEN FINANCIERO',
      styles: const PosStyles(bold: true, align: PosAlign.center),
    );
    bytes += generator.hr(ch: '-');
    bytes += generator.row([
      PosColumn(text: 'Subtotal (Base imponible):', width: 8),
      PosColumn(
        text: '\$${subtotal.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    if (totalImpuestos > 0) {
      bytes += generator.row([
        PosColumn(
          text:
              'IVA (\$${((totalImpuestos / subtotal) * 100).toStringAsFixed(1)}%):',
          width: 8,
        ),
        PosColumn(
          text: '\$${totalImpuestos.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.hr(ch: '-');
    final total = subtotal + totalImpuestos;
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL A PAGAR:',
        width: 6,
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: '\$${total.toStringAsFixed(2)}',
        width: 6,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.hr(ch: '=');

    // Información de pagos detallada
    if (invoiceWithDetails.invoice.invoicePayments != null &&
        invoiceWithDetails.invoice.invoicePayments!.isNotEmpty) {
      bytes += generator.text(
        'METODOS DE PAGO',
        styles: const PosStyles(bold: true, align: PosAlign.center),
      );
      bytes += generator.hr(ch: '-');
      for (final pago in invoiceWithDetails.invoice.invoicePayments!) {
        bytes += generator.row([
          PosColumn(
            text: _formatearTipoPago(pago.tipoPago.toString()),
            width: 8,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: '\$${pago.monto.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
        if (pago.detalles != null && pago.detalles!.isNotEmpty) {
          bytes += generator.text('  Ref: ${pago.detalles}');
        }
      }
      bytes += generator.hr(ch: '-');
    }

    if (factura.invoiceReceivedTotal > 0) {
      bytes += generator.row([
        PosColumn(text: 'Recibido:', width: 8),
        PosColumn(
          text: '\$${factura.invoiceReceivedTotal.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      final cambio = factura.invoiceReceivedTotal - total;
      if (cambio > 0) {
        bytes += generator.row([
          PosColumn(
            text: 'Cambio:',
            width: 8,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: '\$${cambio.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(bold: true, align: PosAlign.right),
          ),
        ]);
      }
      bytes += generator.hr(ch: '-');
    }

    bytes += generator.feed(1);
    bytes += generator.text(
      mensajePie ?? 'Gracias por su preferencia!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'Documento valido como comprobante',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  /// DISEÑO MODERNO - Contemporáneo con formato limpio
  static Future<List<int>> _generarDisenioModerno(
    InvoiceWithDetails invoiceWithDetails,
    Negocio negocio, {
    String? mensajePie,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    final factura = invoiceWithDetails.invoice;
    final dateFormat = DateFormat('dd MMM yyyy - HH:mm');

    // Header moderno
    bytes += generator.feed(1);
    bytes += generator.text(
      negocio.nombre.toUpperCase(),
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.hr(ch: '=');
    bytes += generator.text(
      'RUC ${negocio.ruc}',
      styles: const PosStyles(align: PosAlign.center),
    );

    if (negocio.telefono != null) {
      bytes += generator.text(
        'Tel: ${negocio.telefono}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.feed(1);
    bytes += generator.text(
      'FACTURA',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      '#${factura.invoiceNumber}',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      dateFormat.format(factura.invoiceDate.getDateTimeInUtc()),
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr(ch: '=');
    bytes += generator.feed(1);

    // Productos con estilo moderno
    double total = 0.0;
    for (final detalle in invoiceWithDetails.invoiceDetails) {
      final cantidad = detalle.invoiceItem.quantity;
      final itemTotal = detalle.invoiceItem.total;
      total += itemTotal;

      bytes += generator.text(
        detalle.productos.nombre,
        styles: const PosStyles(bold: true),
      );
      bytes += generator.row([
        PosColumn(
          text: '  $cantidad x \$${(itemTotal / cantidad).toStringAsFixed(2)}',
          width: 8,
        ),
        PosColumn(
          text: '\$${itemTotal.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += generator.feed(1);
    }

    bytes += generator.hr(ch: '=');
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL',
        width: 6,
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: '\$${total.toStringAsFixed(2)}',
        width: 6,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size3,
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.hr(ch: '=');

    // Pagos si existen
    if (invoiceWithDetails.invoice.invoicePayments != null &&
        invoiceWithDetails.invoice.invoicePayments!.isNotEmpty) {
      bytes += generator.feed(1);
      for (final pago in invoiceWithDetails.invoice.invoicePayments!) {
        bytes += generator.row([
          PosColumn(
            text: _formatearTipoPago(pago.tipoPago.toString()),
            width: 8,
          ),
          PosColumn(
            text: '\$${pago.monto.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
    }

    bytes += generator.feed(2);
    bytes += generator.text(
      mensajePie ?? 'Gracias por tu compra',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'Vuelve pronto',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  /// DISEÑO SIMPLE - Recibo básico
  static Future<List<int>> _generarDisenioSimple(
    InvoiceWithDetails invoiceWithDetails,
    Negocio negocio,
  ) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    final factura = invoiceWithDetails.invoice;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    bytes += generator.text(
      negocio.nombre,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.feed(1);
    bytes += generator.hr();
    bytes += generator.text(
      'RECIBO',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'No. ${factura.invoiceNumber}',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      dateFormat.format(factura.invoiceDate.getDateTimeInUtc()),
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();

    double total = 0.0;
    for (final detalle in invoiceWithDetails.invoiceDetails) {
      total += detalle.invoiceItem.total;
    }

    bytes += generator.row([
      PosColumn(
        text: 'TOTAL:',
        width: 6,
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: '\$${total.toStringAsFixed(2)}',
        width: 6,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.hr();
    bytes += generator.text(
      '¡Gracias!',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  // ========== MÉTODOS AUXILIARES ==========

  static List<int> _generarTotales(
    Generator generator,
    double subtotal,
    double totalImpuestos,
  ) {
    List<int> bytes = [];
    bytes += generator.row([
      PosColumn(
        text: 'Subtotal:',
        width: 8,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: '\$${subtotal.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);

    if (totalImpuestos > 0) {
      bytes += generator.row([
        PosColumn(text: 'IVA:', width: 8, styles: const PosStyles(bold: true)),
        PosColumn(
          text: '\$${totalImpuestos.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);
    }

    final total = subtotal + totalImpuestos;
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL:',
        width: 8,
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: '\$${total.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          align: PosAlign.right,
        ),
      ),
    ]);

    return bytes;
  }

  static List<int> _generarSeccionPagos(
    Generator generator,
    InvoiceWithDetails invoiceWithDetails,
    double total,
  ) {
    List<int> bytes = [];

    if (invoiceWithDetails.invoice.invoicePayments != null &&
        invoiceWithDetails.invoice.invoicePayments!.isNotEmpty) {
      bytes += generator.text(
        'FORMA DE PAGO',
        styles: const PosStyles(bold: true),
      );
      bytes += generator.hr(ch: '-');

      for (final pago in invoiceWithDetails.invoice.invoicePayments!) {
        bytes += generator.row([
          PosColumn(
            text: _formatearTipoPago(pago.tipoPago.toString()),
            width: 8,
          ),
          PosColumn(
            text: '\$${pago.monto.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
        if (pago.detalles != null && pago.detalles!.isNotEmpty) {
          bytes += generator.text(
            '  ${pago.detalles}',
            styles: const PosStyles(align: PosAlign.left),
          );
        }
      }
      bytes += generator.hr(ch: '-');
    }

    if (invoiceWithDetails.invoice.invoiceReceivedTotal > 0) {
      bytes += generator.row([
        PosColumn(text: 'Recibido:', width: 8),
        PosColumn(
          text:
              '\$${invoiceWithDetails.invoice.invoiceReceivedTotal.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      final cambio = invoiceWithDetails.invoice.invoiceReceivedTotal - total;
      if (cambio > 0) {
        bytes += generator.row([
          PosColumn(
            text: 'Cambio:',
            width: 8,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: '\$${cambio.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(bold: true, align: PosAlign.right),
          ),
        ]);
      }
      bytes += generator.hr(ch: '-');
    }

    return bytes;
  }

  static List<int> _generarPiePagina(Generator generator, String? mensajePie) {
    List<int> bytes = [];
    bytes += generator.feed(1);
    bytes += generator.text(
      mensajePie ?? '¡Gracias por su compra!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'Vuelva pronto',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  static String _formatearTipoPago(String tipoPago) {
    final Map<String, String> tiposPago = {
      'TiposPago.EFECTIVO': 'Efectivo',
      'TiposPago.TRANSFERENCIA': 'Transferencia',
      'TiposPago.TARJETA_DEBITO': 'Tarjeta Débito',
      'TiposPago.TARJETA_CREDITO': 'Tarjeta Crédito',
      'TiposPago.CHEQUE': 'Cheque',
      'TiposPago.PAYPHONE': 'Payphone',
      'TiposPago.DATAFAST': 'Datafast',
      'TiposPago.LINK_DE_PAGO': 'Link de Pago',
      'TiposPago.DEPOSITO_BANCARIO': 'Depósito Bancario',
      'TiposPago.BILLETERA_DIGITAL': 'Billetera Digital',
      'TiposPago.CRIPTOMONEDA': 'Criptomoneda',
      'TiposPago.VALE': 'Vale',
      'TiposPago.OTRO': 'Otro',
    };
    return tiposPago[tipoPago] ?? tipoPago.replaceAll('TiposPago.', '');
  }

  static Future<List<int>> generarBytesOrden(
    OrderWithDetails orderWithDetails,
    Negocio negocio, {
    InvoiceDesign design = InvoiceDesign.classic,
    bool incluirLogo = false,
    String? logoUrl,
    String? mensajePie,
  }) async {
    switch (design) {
      case InvoiceDesign.classic:
        return _generarOrdenDisenioClasico(
          orderWithDetails,
          negocio,
          incluirLogo: incluirLogo,
          logoUrl: logoUrl,
          mensajePie: mensajePie,
        );
      case InvoiceDesign.compact:
        return _generarOrdenDisenioCompacto(
          orderWithDetails,
          negocio,
          mensajePie: mensajePie,
        );
      case InvoiceDesign.detailed:
        return _generarOrdenDisenioDetallado(
          orderWithDetails,
          negocio,
          incluirLogo: incluirLogo,
          mensajePie: mensajePie,
        );
      case InvoiceDesign.modern:
        return _generarOrdenDisenioModerno(
          orderWithDetails,
          negocio,
          mensajePie: mensajePie,
        );
      case InvoiceDesign.simple:
        return _generarOrdenDisenioSimple(orderWithDetails, negocio);
    }
  }

  /// DISEÑO CLÁSICO - Orden tradicional con detalles completos
  static Future<List<int>> _generarOrdenDisenioClasico(
    OrderWithDetails orderWithDetails,
    Negocio negocio, {
    bool incluirLogo = false,
    String? logoUrl,
    String? mensajePie,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    final orden = orderWithDetails.order;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    if (logoUrl != null) {
      final image = await processImageFromUrl(logoUrl, maxWidth: 384);
      if (image != null) {
        bytes += generator.imageRaster(image);
      }
    }

    // Encabezado empresa
    bytes += generator.text(
      negocio.nombre.toUpperCase(),
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.feed(1);

    if (negocio.ruc.isNotEmpty) {
      bytes += generator.text(
        'RUC: ${negocio.ruc}',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
    }

    if (negocio.direccion != null && negocio.direccion!.isNotEmpty) {
      bytes += generator.text(
        negocio.direccion!,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    final ubicacion = [
      negocio.ciudad,
      negocio.provincia,
      negocio.pais,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
    if (ubicacion.isNotEmpty) {
      bytes += generator.text(
        ubicacion,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    if (negocio.telefono != null && negocio.telefono!.isNotEmpty) {
      bytes += generator.text(
        'Tel: ${negocio.telefono}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.feed(1);
    bytes += generator.hr(ch: '=');

    // Datos orden
    bytes += generator.text(
      'ORDEN DE COMPRA',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      'No. ${orden.orderNumber}',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Fecha: ${dateFormat.format(orden.orderDate.getDateTimeInUtc())}',
    );
    if (orden.orderStatus != null) {
      bytes += generator.text(
        'Estado: ${orden.orderStatus}',
        styles: const PosStyles(bold: true),
      );
    }
    bytes += generator.hr(ch: '=');

    // Tabla de productos
    bytes += generator.row([
      PosColumn(
        text: 'Producto',
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: 'Cant',
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.center),
      ),
      PosColumn(
        text: 'P.Unit',
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
      PosColumn(
        text: 'Total',
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
    bytes += generator.hr(ch: '-');

    double subtotal = 0.0;
    double totalImpuestos = 0.0;

    for (final detalle in orderWithDetails.orderDetails) {
      final cantidad = detalle.orderItem.quantity;
      final precio = detalle.precios.precio / detalle.precios.quantity;
      final itemSubtotal = detalle.orderItem.subtotal;
      final itemTotal = detalle.orderItem.total;
      final impuesto = itemTotal - itemSubtotal;

      subtotal += itemSubtotal;
      totalImpuestos += impuesto;

      final nombreProducto = detalle.productos.nombre;
      bytes += generator.row([
        PosColumn(
          text: nombreProducto.length > 25
              ? '${nombreProducto.substring(0, 22)}...'
              : nombreProducto,
          width: 6,
        ),
        PosColumn(
          text: '$cantidad',
          width: 2,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: '\$${precio.toStringAsFixed(2)}',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: '\$${itemTotal.toStringAsFixed(2)}',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      if (detalle.precios.quantity > 1) {
        bytes += generator.text(
          '  (${detalle.precios.nombre} - ${detalle.precios.quantity} unid.)',
          styles: const PosStyles(align: PosAlign.left),
        );
      }
    }

    bytes += generator.hr(ch: '-');

    // Totales
    bytes += _generarTotales(generator, subtotal, totalImpuestos);
    bytes += generator.hr(ch: '=');

    // Pagos
    bytes += _generarSeccionPagosOrden(
      generator,
      orderWithDetails,
      subtotal + totalImpuestos,
    );

    // Pie de página
    bytes += _generarPiePagina(generator, mensajePie);

    return bytes;
  }

  /// DISEÑO COMPACTO - Orden minimalista que ahorra papel
  static Future<List<int>> _generarOrdenDisenioCompacto(
    OrderWithDetails orderWithDetails,
    Negocio negocio, {
    String? mensajePie,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    final orden = orderWithDetails.order;
    final dateFormat = DateFormat('dd/MM/yy HH:mm');

    // Encabezado compacto
    bytes += generator.text(
      negocio.nombre,
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'RUC: ${negocio.ruc}',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr(ch: '-');
    bytes += generator.text(
      'ORDEN #${orden.orderNumber}',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      dateFormat.format(orden.orderDate.getDateTimeInUtc()),
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr(ch: '-');

    // Productos en formato compacto
    double total = 0.0;
    for (final detalle in orderWithDetails.orderDetails) {
      final cantidad = detalle.orderItem.quantity;
      final itemTotal = detalle.orderItem.total;
      total += itemTotal;

      final nombre = detalle.productos.nombre.length > 28
          ? '${detalle.productos.nombre.substring(0, 25)}...'
          : detalle.productos.nombre;

      bytes += generator.text(nombre);
      bytes += generator.row([
        PosColumn(
          text: '  $cantidad x \$${(itemTotal / cantidad).toStringAsFixed(2)}',
          width: 8,
        ),
        PosColumn(
          text: '\$${itemTotal.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr(ch: '-');
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL:',
        width: 6,
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: '\$${total.toStringAsFixed(2)}',
        width: 6,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.hr(ch: '-');

    bytes += generator.text(
      mensajePie ?? '¡Gracias!',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);
    bytes += generator.cut();

    return bytes;
  }

  /// DISEÑO DETALLADO - Orden con toda la información posible
  static Future<List<int>> _generarOrdenDisenioDetallado(
    OrderWithDetails orderWithDetails,
    Negocio negocio, {
    bool incluirLogo = false,
    String? mensajePie,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    final orden = orderWithDetails.order;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

    // Encabezado completo
    bytes += generator.hr(ch: '=');
    bytes += generator.text(
      negocio.nombre.toUpperCase(),
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.hr(ch: '=');
    bytes += generator.feed(1);

    // Información detallada del negocio
    bytes += generator.text(
      'INFORMACIÓN FISCAL',
      styles: const PosStyles(bold: true, align: PosAlign.center),
    );
    bytes += generator.hr(ch: '-');
    bytes += generator.text(
      'RUC: ${negocio.ruc}',
      styles: const PosStyles(bold: true),
    );
    if (negocio.direccion != null) {
      bytes += generator.text('Dir: ${negocio.direccion}');
    }
    if (negocio.ciudad != null) {
      bytes += generator.text('Ciudad: ${negocio.ciudad}');
    }
    if (negocio.telefono != null) {
      bytes += generator.text('Tel: ${negocio.telefono}');
    }
    if (negocio.correoElectronico != null) {
      bytes += generator.text('Email: ${negocio.correoElectronico}');
    }
    bytes += generator.hr(ch: '=');

    // Información de orden detallada
    bytes += generator.text(
      'ORDEN DE COMPRA',
      styles: const PosStyles(
        bold: true,
        align: PosAlign.center,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      'ORDEN No. ${orden.orderNumber}',
      styles: const PosStyles(bold: true, align: PosAlign.center),
    );
    bytes += generator.text(
      'Fecha emision:',
      styles: const PosStyles(bold: true),
    );
    bytes += generator.text(
      dateFormat.format(orden.orderDate.getDateTimeInUtc()),
    );
    if (orden.orderStatus != null) {
      bytes += generator.text(
        'Estado: ${orden.orderStatus}',
        styles: const PosStyles(bold: true),
      );
    }
    bytes += generator.hr(ch: '=');

    // Detalle completo de productos
    bytes += generator.text(
      'DETALLE DE PRODUCTOS',
      styles: const PosStyles(bold: true, align: PosAlign.center),
    );
    bytes += generator.hr(ch: '-');

    double subtotal = 0.0;
    double totalImpuestos = 0.0;
    int itemNumber = 1;

    for (final detalle in orderWithDetails.orderDetails) {
      final cantidad = detalle.orderItem.quantity;
      final precioUnitario = detalle.precios.precio / detalle.precios.quantity;
      final itemSubtotal = detalle.orderItem.subtotal;
      final itemTotal = detalle.orderItem.total;
      final impuesto = itemTotal - itemSubtotal;

      subtotal += itemSubtotal;
      totalImpuestos += impuesto;

      bytes += generator.text(
        '[$itemNumber] ${detalle.productos.nombre}',
        styles: const PosStyles(bold: true),
      );
      bytes += generator.text('    Código: ${detalle.productos.barCode}');
      bytes += generator.row([
        PosColumn(text: '    Cantidad:', width: 6),
        PosColumn(
          text: '$cantidad',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: '    Precio Unit:', width: 6),
        PosColumn(
          text: '\$${precioUnitario.toStringAsFixed(4)}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: '    Subtotal:', width: 6),
        PosColumn(
          text: '\$${itemSubtotal.toStringAsFixed(2)}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      if (impuesto > 0) {
        bytes += generator.row([
          PosColumn(text: '    IVA:', width: 6),
          PosColumn(
            text: '\$${impuesto.toStringAsFixed(2)}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
      bytes += generator.row([
        PosColumn(
          text: '    TOTAL:',
          width: 6,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: '\$${itemTotal.toStringAsFixed(2)}',
          width: 6,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);

      if (detalle.precios.quantity > 1) {
        bytes += generator.text('    Oferta: ${detalle.precios.nombre}');
      }

      bytes += generator.hr(ch: '.');
      itemNumber++;
    }

    // Resumen financiero detallado
    bytes += generator.hr(ch: '=');
    bytes += generator.text(
      'RESUMEN FINANCIERO',
      styles: const PosStyles(bold: true, align: PosAlign.center),
    );
    bytes += generator.hr(ch: '-');
    bytes += generator.row([
      PosColumn(text: 'Subtotal (Base imponible):', width: 8),
      PosColumn(
        text: '\$${subtotal.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    if (totalImpuestos > 0) {
      bytes += generator.row([
        PosColumn(
          text:
              'IVA (\$${((totalImpuestos / subtotal) * 100).toStringAsFixed(1)}%):',
          width: 8,
        ),
        PosColumn(
          text: '\$${totalImpuestos.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.hr(ch: '-');
    final total = subtotal + totalImpuestos;
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL A PAGAR:',
        width: 6,
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: '\$${total.toStringAsFixed(2)}',
        width: 6,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.hr(ch: '=');

    // Información de pagos detallada
    if (orderWithDetails.order.orderPayments != null &&
        orderWithDetails.order.orderPayments!.isNotEmpty) {
      bytes += generator.text(
        'METODOS DE PAGO',
        styles: const PosStyles(bold: true, align: PosAlign.center),
      );
      bytes += generator.hr(ch: '-');
      for (final pago in orderWithDetails.order.orderPayments!) {
        bytes += generator.row([
          PosColumn(
            text: _formatearTipoPago(pago.tipoPago.toString()),
            width: 8,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: '\$${pago.monto.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
        if (pago.detalles != null && pago.detalles!.isNotEmpty) {
          bytes += generator.text('  Ref: ${pago.detalles}');
        }
      }
      bytes += generator.hr(ch: '-');
    }

    if (orden.orderReceivedTotal > 0) {
      bytes += generator.row([
        PosColumn(text: 'Recibido:', width: 8),
        PosColumn(
          text: '\$${orden.orderReceivedTotal.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      final cambio = orden.orderReceivedTotal - total;
      if (cambio > 0) {
        bytes += generator.row([
          PosColumn(
            text: 'Cambio:',
            width: 8,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: '\$${cambio.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(bold: true, align: PosAlign.right),
          ),
        ]);
      }
      bytes += generator.hr(ch: '-');
    }

    bytes += generator.feed(1);
    bytes += generator.text(
      mensajePie ?? 'Gracias por su preferencia!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'Documento valido como comprobante',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  /// DISEÑO MODERNO - Orden contemporánea con formato limpio
  static Future<List<int>> _generarOrdenDisenioModerno(
    OrderWithDetails orderWithDetails,
    Negocio negocio, {
    String? mensajePie,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    final orden = orderWithDetails.order;
    final dateFormat = DateFormat('dd MMM yyyy - HH:mm');

    // Header moderno
    bytes += generator.feed(1);
    bytes += generator.text(
      negocio.nombre.toUpperCase(),
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.hr(ch: '=');
    bytes += generator.text(
      'RUC ${negocio.ruc}',
      styles: const PosStyles(align: PosAlign.center),
    );

    if (negocio.telefono != null) {
      bytes += generator.text(
        'Tel: ${negocio.telefono}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.feed(1);
    bytes += generator.text(
      'ORDEN',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      '#${orden.orderNumber}',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      dateFormat.format(orden.orderDate.getDateTimeInUtc()),
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr(ch: '=');
    bytes += generator.feed(1);

    // Productos con estilo moderno
    double total = 0.0;
    for (final detalle in orderWithDetails.orderDetails) {
      final cantidad = detalle.orderItem.quantity;
      final itemTotal = detalle.orderItem.total;
      total += itemTotal;

      bytes += generator.text(
        detalle.productos.nombre,
        styles: const PosStyles(bold: true),
      );
      bytes += generator.row([
        PosColumn(
          text: '  $cantidad x \$${(itemTotal / cantidad).toStringAsFixed(2)}',
          width: 8,
        ),
        PosColumn(
          text: '\$${itemTotal.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += generator.feed(1);
    }

    bytes += generator.hr(ch: '=');
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL',
        width: 6,
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: '\$${total.toStringAsFixed(2)}',
        width: 6,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size3,
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.hr(ch: '=');

    // Pagos si existen
    if (orderWithDetails.order.orderPayments != null &&
        orderWithDetails.order.orderPayments!.isNotEmpty) {
      bytes += generator.feed(1);
      for (final pago in orderWithDetails.order.orderPayments!) {
        bytes += generator.row([
          PosColumn(
            text: _formatearTipoPago(pago.tipoPago.toString()),
            width: 8,
          ),
          PosColumn(
            text: '\$${pago.monto.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
    }

    bytes += generator.feed(2);
    bytes += generator.text(
      mensajePie ?? 'Gracias por tu compra',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'Vuelve pronto',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  /// DISEÑO SIMPLE - Recibo básico de orden
  static Future<List<int>> _generarOrdenDisenioSimple(
    OrderWithDetails orderWithDetails,
    Negocio negocio,
  ) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    final orden = orderWithDetails.order;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    bytes += generator.text(
      negocio.nombre,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.feed(1);
    bytes += generator.hr();
    bytes += generator.text(
      'ORDEN',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'No. ${orden.orderNumber}',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      dateFormat.format(orden.orderDate.getDateTimeInUtc()),
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();

    double total = 0.0;
    for (final detalle in orderWithDetails.orderDetails) {
      total += detalle.orderItem.total;
    }

    bytes += generator.row([
      PosColumn(
        text: 'TOTAL:',
        width: 6,
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: '\$${total.toStringAsFixed(2)}',
        width: 6,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.hr();
    bytes += generator.text(
      '¡Gracias!',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  // Método auxiliar para pagos de órdenes
  static List<int> _generarSeccionPagosOrden(
    Generator generator,
    OrderWithDetails orderWithDetails,
    double total,
  ) {
    List<int> bytes = [];

    if (orderWithDetails.order.orderPayments != null &&
        orderWithDetails.order.orderPayments!.isNotEmpty) {
      bytes += generator.text(
        'FORMA DE PAGO',
        styles: const PosStyles(bold: true),
      );
      bytes += generator.hr(ch: '-');

      for (final pago in orderWithDetails.order.orderPayments!) {
        bytes += generator.row([
          PosColumn(
            text: _formatearTipoPago(pago.tipoPago.toString()),
            width: 8,
          ),
          PosColumn(
            text: '\$${pago.monto.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
        if (pago.detalles != null && pago.detalles!.isNotEmpty) {
          bytes += generator.text(
            '  ${pago.detalles}',
            styles: const PosStyles(align: PosAlign.left),
          );
        }
      }
      bytes += generator.hr(ch: '-');
    }

    if (orderWithDetails.order.orderReceivedTotal > 0) {
      bytes += generator.row([
        PosColumn(text: 'Recibido:', width: 8),
        PosColumn(
          text:
              '\$${orderWithDetails.order.orderReceivedTotal.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      final cambio = orderWithDetails.order.orderReceivedTotal - total;
      if (cambio > 0) {
        bytes += generator.row([
          PosColumn(
            text: 'Cambio:',
            width: 8,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: '\$${cambio.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(bold: true, align: PosAlign.right),
          ),
        ]);
      }
      bytes += generator.hr(ch: '-');
    }

    return bytes;
  }

  static Future<img.Image?> processImageFromUrl(
    String url, {
    int? maxWidth,
  }) async {
    try {
      // Descarga la imagen
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      final Uint8List bytes = response.bodyBytes;

      // Decodifica
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      // Convierte a gris
      image = img.grayscale(image);

      // Dithering para mejor calidad en B/N
      image = img.quantize(
        image,
        numberOfColors: 2,
        method: img.QuantizeMethod.octree,
      );

      // Redimensiona si se especifica (ej. para papel de 58mm ~384px)
      if (maxWidth != null) {
        image = img.copyResize(image, width: maxWidth);
      }

      return image;
    } catch (e) {
      print('Error procesando imagen: $e');
      return null;
    }
  }
}
