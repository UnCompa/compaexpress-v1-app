import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/entities/payment_option.dart';
import 'package:compaexpress/entities/user_info.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/auditoria_service.dart';
import 'package:compaexpress/services/caja_service.dart';
import 'package:compaexpress/services/negocio/negocio_controller.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InvoiceService {
  static Future<String?> saveInvoice(
    BuildContext context,
    GlobalKey<dynamic> formKey,
    invoiceItems,
    double totalFactura,
    double totalPago,
    double cambio,
    String invoiceNumber,
    String invoiceStatus,
    DateTime selectDate,
    List<PaymentOption> paymentOptions,
    XFile? comprobanteFile,
  ) async {
    debugPrint('Iniciando _saveInvoice');

    if (!formKey.currentState!.validate()) {
      debugPrint('Validación del formulario fallida');
      return null;
    }

    if (invoiceItems.isEmpty) {
      debugPrint('Mostrando SnackBar: Debe agregar al menos un producto');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos un producto')),
      );
      return null;
    }

    if (!_validateInvoiceItems(context, invoiceItems)) {
      return null;
    }

    if (totalPago < totalFactura) {
      debugPrint('Mostrando SnackBar: Pago y factura no coinciden');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El pago (\$${totalPago.toStringAsFixed(2)}) debe ser mayor al total (\$${totalFactura.toStringAsFixed(2)})',
          ),
        ),
      );
      return null;
    }

    debugPrint('Iniciando proceso de guardado optimizado');

    try {
      final futures = await Future.wait([
        NegocioService.getCurrentUserInfo(),
        CajaService.getCurrentCaja(),
      ]);

      final userData = futures[0] as UserInfo;
      final caja = futures[1] as Caja;

      final negocio = await NegocioController.getById(userData.negocioId);

      if (!caja.isActive) {
        throw Exception('La caja no está activa');
      }

      String logoKey = "";
      if (comprobanteFile != null) {
        final fileName =
            'facturas/${negocio!.nombre}/${invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}';
        logoKey = await StorageService.uploadFile(
          File(comprobanteFile.path),
          fileName,
        );
      }

      final invoice = _createInvoice(
        invoiceNumber,
        selectDate,
        totalFactura,
        cambio,
        invoiceStatus,
        logoKey,
        userData,
        caja,
      );

      final invoiceResponse = await _createInvoiceInDB(invoice);
      final createdInvoice = invoiceResponse.data!;
      debugPrint('Factura creada con ID: ${createdInvoice.id}');

      await _processInvoiceInParallel(
        context,
        createdInvoice,
        invoiceItems,
        paymentOptions,
        caja,
        userData,
        totalFactura,
      );

      await AuditoriaService.createAuditoria(
        userId: userData.userId,
        grupo: "FACTURACION",
        accion: 'CREAR_FACTURA',
        entidad: 'Invoice',
        entidadId: createdInvoice.id,
        descripcion: 'Factura creada para cliente ${userData.email}',
        negocioId: userData.negocioId,
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error capturado: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear la factura: $e')));
      return null;
    }

    return null;
  }

  static Future<void> _processInvoiceInParallel(
    BuildContext context,
    Invoice createdInvoice,
    List invoiceItems,
    List<PaymentOption> paymentOptions,
    Caja caja,
    userData,
    double totalFactura,
  ) async {
    final List<Future> futures = [];

    futures.add(_createPayments(createdInvoice.id, paymentOptions));

    futures.add(_processInvoiceItemsBatch(createdInvoice.id, invoiceItems));

    final movementFuture = _createCajaMovement(
      caja,
      userData,
      totalFactura,
      createdInvoice.id,
    );
    futures.add(movementFuture);

    await Future.wait(futures.take(2));

    final movement = await movementFuture;
    await _updateCajaAndInvoice(
      caja,
      totalFactura,
      createdInvoice,
      movement.id,
      paymentOptions,
    );
  }

  static Future<void> _createPayments(
    String invoiceId,
    List<PaymentOption> paymentOptions,
  ) async {
    final pagosSeleccionados = paymentOptions
        .where((p) => p.seleccionado && p.monto > 0)
        .map(
          (p) => InvoicePayment(
            invoiceID: invoiceId,
            tipoPago: p.tipo,
            monto: p.monto,
            detalles: '',
            isDeleted: false,
            createdAt: TemporalDateTime.now(),
            updatedAt: TemporalDateTime.now(),
          ),
        )
        .toList();

    final paymentFutures = pagosSeleccionados
        .map(
          (pago) =>
              Amplify.API.mutate(request: ModelMutations.create(pago)).response,
        )
        .toList();

    if (paymentFutures.isNotEmpty) {
      await Future.wait(paymentFutures);
    }
  }

  static Future<void> _updateCajaAndInvoice(
    Caja caja,
    double totalFactura,
    Invoice createdInvoice,
    String movementId,
    List<PaymentOption> paymentOptions,
  ) async {
    double saldoEfectivo = 0.0;
    double saldoTransferencias = 0.0;
    double saldoTarjetas = 0.0;
    double saldoOtros = 0.0;

    for (var payment in paymentOptions.where(
      (p) => p.seleccionado && p.monto > 0,
    )) {
      switch (payment.tipo) {
        case TiposPago.EFECTIVO:
          saldoEfectivo += payment.monto;
          break;
        case TiposPago.TRANSFERENCIA:
        case TiposPago.DEPOSITO_BANCARIO:
          saldoTransferencias += payment.monto;
          break;
        case TiposPago.TARJETA_DEBITO:
        case TiposPago.TARJETA_CREDITO:
          saldoTarjetas += payment.monto;
          break;
        case TiposPago.CHEQUE:
        case TiposPago.PAYPHONE:
        case TiposPago.DATAFAST:
        case TiposPago.LINK_DE_PAGO:
        case TiposPago.BILLETERA_DIGITAL:
        case TiposPago.CRIPTOMONEDA:
        case TiposPago.VALE:
        case TiposPago.OTRO:
          saldoOtros += payment.monto;
          break;
      }
    }

    final cajaActualizada = caja.copyWith(
      saldoInicial: (caja.saldoInicial ?? 0.0) + saldoEfectivo,
      saldoTransferencias:
          (caja.saldoTransferencias ?? 0.0) + saldoTransferencias,
      saldoTarjetas: (caja.saldoTarjetas ?? 0.0) + saldoTarjetas,
      saldoOtros: (caja.saldoOtros ?? 0.0) + saldoOtros,
      updatedAt: TemporalDateTime.now(),
    );

    final updatedInvoice = createdInvoice.copyWith(
      cajaMovimientoID: movementId,
    );

    final futures = [
      Amplify.API
          .mutate(request: ModelMutations.update(cajaActualizada))
          .response,
      Amplify.API
          .mutate(request: ModelMutations.update(updatedInvoice))
          .response,
    ];

    final responses = await Future.wait(futures);

    for (final response in responses) {
      if (response.hasErrors) {
        throw Exception('Error en actualización: ${response.errors}');
      }
    }

    CajaService.updateCache(cajaActualizada);
    debugPrint('Caché actualizada con caja: $cajaActualizada');
  }

  static Future<void> _processInvoiceItemsBatch(
    String invoiceId,
    List invoiceItems,
  ) async {
    const int batchSize = 5;

    for (int i = 0; i < invoiceItems.length; i += batchSize) {
      final batch = invoiceItems.skip(i).take(batchSize);
      final batchFutures = batch.map(
        (itemData) => _processInvoiceItem(invoiceId, itemData),
      );
      await Future.wait(batchFutures);
    }
  }

  static Future<void> _processInvoiceItem(String invoiceId, itemData) async {
    final invoiceItem = InvoiceItem(
      invoiceID: invoiceId,
      precioID: itemData.precio!.id,
      productoID: itemData.producto.id,
      quantity: itemData.quantity,
      tax: itemData.tax,
      subtotal: itemData.subtotal,
      total: double.parse(itemData.total.toStringAsFixed(2)),
      createdAt: TemporalDateTime.now(),
      updatedAt: TemporalDateTime.now(),
    );

    final unidadesVendidas = itemData.quantity * itemData.precio!.quantity;
    final updatedProduct = itemData.producto.copyWith(
      stock: itemData.producto.stock - unidadesVendidas,
      updatedAt: TemporalDateTime.now(),
    );

    final futures = [
      Amplify.API.mutate(request: ModelMutations.create(invoiceItem)).response,
      Amplify.API
          .mutate(request: ModelMutations.update(updatedProduct))
          .response,
    ];

    final responses = await Future.wait(futures);

    for (final response in responses) {
      if (response.hasErrors) {
        throw Exception('Error en operación: ${response.errors}');
      }
    }
  }

  static Future<CajaMovimiento> _createCajaMovement(
    caja,
    userData,
    double totalFactura,
    String invoiceId,
  ) async {
    final movement = CajaMovimiento(
      cajaID: caja.id,
      tipo: 'INGRESO',
      origen: 'FACTURA',
      monto: totalFactura,
      negocioID: userData.negocioId,
      descripcion: 'Ingreso por factura ID: $invoiceId',
      isDeleted: false,
      createdAt: TemporalDateTime.now(),
      updatedAt: TemporalDateTime.now(),
    );

    final response = await Amplify.API
        .mutate(request: ModelMutations.create(movement))
        .response;

    if (response.hasErrors) {
      throw Exception('Error al crear movimiento de caja: ${response.errors}');
    }

    return response.data!;
  }

  static bool _validateInvoiceItems(BuildContext context, List invoiceItems) {
    for (var item in invoiceItems) {
      if (item.precio == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Todos los productos deben tener un precio seleccionado',
            ),
          ),
        );
        return false;
      }
      final validTotalStock = item.quantity * item.precio!.quantity;
      if (item.producto.stock < validTotalStock) {
        final nombre = item.producto.nombre;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El producto $nombre no tiene stock suficiente'),
          ),
        );
        return false;
      }
    }
    return true;
  }

  static Invoice _createInvoice(
    String invoiceNumber,
    DateTime selectDate,
    double totalFactura,
    double cambio,
    String invoiceStatus,
    String logoKey,
    userData,
    caja,
  ) {
    return Invoice(
      invoiceNumber: invoiceNumber,
      invoiceDate: TemporalDateTime(selectDate),
      invoiceReceivedTotal: totalFactura,
      invoiceReturnedTotal: cambio,
      invoiceImages: logoKey.isNotEmpty ? [logoKey] : null,
      invoiceStatus: invoiceStatus,
      sellerID: userData.userId,
      negocioID: userData.negocioId,
      cajaID: caja.id,
      isDeleted: false,
      createdAt: TemporalDateTime.now(),
      updatedAt: TemporalDateTime.now(),
    );
  }

  static Future<GraphQLResponse<Invoice>> _createInvoiceInDB(
    Invoice invoice,
  ) async {
    final response = await Amplify.API
        .mutate(request: ModelMutations.create(invoice))
        .response;

    if (response.data == null) {
      throw Exception('Error al crear la factura: ${response.errors}');
    }

    return response;
  }
}
