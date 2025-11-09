import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/entities/order_item_data.dart';
import 'package:compaexpress/entities/payment_option.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/caja_service.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/utils/fecha_ecuador.dart';
import 'package:flutter/material.dart';

class OrderService {
  static Future<String?> saveOrder(
    BuildContext context,
    GlobalKey<dynamic>? formKey,
    List<OrderItemData> orderItems,
    double totalOrden,
    double totalPago,
    double cambio,
    String orderNumber,
    String orderStatus,
    DateTime selectDate,
    List<PaymentOption> paymentOptions,
  ) async {
    debugPrint('Iniciando _saveOrder');

    if (formKey != null && formKey.currentState != null) {
      if (!formKey.currentState!.validate()) {
        debugPrint('Validación del formulario fallida');
        return null;
      }
    }
    if (orderItems.isEmpty) {
      _showSnackBar(context, 'Debe agregar al menos un producto');
      return null;
    }

    if (!_validateOrderItems(context, orderItems)) {
      return null;
    }

    if (totalPago < totalOrden) {
      _showSnackBar(
        context,
        'El pago (\$${totalPago.toStringAsFixed(2)}) debe ser mayor que la orden (\$${totalOrden.toStringAsFixed(2)})',
      );
      return null;
    }

    debugPrint('Iniciando proceso de guardado optimizado');

    try {
      final futures = await Future.wait([
        NegocioService.getCurrentUserInfo(),
        CajaService.getCurrentCaja(forceRefresh: true),
      ]);

      final userData = futures[0];
      final caja = futures[1] as Caja;

      if (!caja.isActive) {
        throw Exception('La caja no está activa');
      }
      debugPrint("Guardando: $totalOrden, Pago: $totalPago, Cambio: $cambio");
      final formatDate = FechaEcuador.aZonaEcuador(selectDate);
      final order = _createOrder(
        orderNumber,
        formatDate,
        totalOrden,
        cambio,
        orderStatus,
        userData,
        caja,
      );

      final orderResponse = await _createOrderInDB(order);
      final createdOrder = orderResponse.data!;
      debugPrint('Orden creada: $createdOrder');

      await _processOrderInParallel(
        context,
        createdOrder,
        orderItems,
        paymentOptions,
        caja,
        userData,
        totalOrden,
      );

      _showSnackBar(context, 'Orden creada exitosamente');
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error capturado: $e');
      _showSnackBar(context, 'Error al crear la orden: $e');
      return null;
    }

    return null;
  }

  static Future<void> _processOrderInParallel(
    BuildContext context,
    Order createdOrder,
    List orderItems,
    List<PaymentOption> paymentOptions,
    caja,
    userData,
    double totalOrden,
  ) async {
    final List<Future> futures = [];

    futures.add(_createPayments(createdOrder.id, paymentOptions));

    futures.add(_processOrderItemsBatch(createdOrder.id, orderItems));

    final movementFuture = _createCajaMovement(
      caja,
      userData,
      totalOrden,
      createdOrder.id,
    );
    futures.add(movementFuture);

    await Future.wait(futures.take(2));

    final movement = await movementFuture;
    await _updateCajaAndOrder(
      caja,
      totalOrden,
      createdOrder,
      movement.id,
      paymentOptions,
    );
  }

  static Future<void> _createPayments(
    String orderId,
    List<PaymentOption> paymentOptions,
  ) async {
    final pagosSeleccionados = paymentOptions
        .where((p) => p.seleccionado && p.monto > 0)
        .map(
          (p) => OrderPayment(
            orderID: orderId,
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

  static Future<void> _updateCajaAndOrder(
    Caja caja,
    double totalOrden,
    Order createdOrder,
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
      debugPrint('Monto del pago: ${payment.monto}');
      debugPrint("Retorno: ${createdOrder.orderReturnedTotal}");
      switch (payment.tipo) {
        case TiposPago.EFECTIVO:
          saldoEfectivo += payment.monto - createdOrder.orderReturnedTotal;
          break;
        case TiposPago.TRANSFERENCIA:
        case TiposPago.DEPOSITO_BANCARIO:
          saldoTransferencias +=
              payment.monto - createdOrder.orderReturnedTotal;
          break;
        case TiposPago.TARJETA_DEBITO:
        case TiposPago.TARJETA_CREDITO:
          saldoTarjetas += payment.monto - createdOrder.orderReturnedTotal;
          break;
        case TiposPago.CHEQUE:
        case TiposPago.PAYPHONE:
        case TiposPago.DATAFAST:
        case TiposPago.LINK_DE_PAGO:
        case TiposPago.BILLETERA_DIGITAL:
        case TiposPago.CRIPTOMONEDA:
        case TiposPago.VALE:
        case TiposPago.OTRO:
          saldoOtros += payment.monto - createdOrder.orderReturnedTotal;
          break;
      }
    }

    debugPrint('Saldo efectivo - Antes/Ahora: ${caja.saldoInicial}/$saldoEfectivo');
    debugPrint('Saldo transferencias - Antes/Ahora: ${caja.saldoTransferencias}/$saldoTransferencias');
    debugPrint('Saldo tarjetas - Antes/Ahora: ${caja.saldoTarjetas}/$saldoTarjetas');
    debugPrint('Saldo otros - Antes/Ahora: ${caja.saldoOtros}/$saldoOtros');

    final cajaActualizada = caja.copyWith(
      saldoInicial: (caja.saldoInicial) + saldoEfectivo,
      saldoTransferencias:
          (caja.saldoTransferencias ?? 0.0) + saldoTransferencias,
      saldoTarjetas: (caja.saldoTarjetas ?? 0.0) + saldoTarjetas,
      saldoOtros: (caja.saldoOtros ?? 0.0) + saldoOtros,
      updatedAt: TemporalDateTime.now(),
    );

    debugPrint('Caja actualizada: $cajaActualizada');

    final updatedOrder = createdOrder.copyWith(cajaMovimientoID: movementId);

    final futures = [
      Amplify.API
          .mutate(request: ModelMutations.update(cajaActualizada))
          .response,
      Amplify.API.mutate(request: ModelMutations.update(updatedOrder)).response,
    ];

    final responses = await Future.wait(futures);

    for (final response in responses) {
      if (response.hasErrors) {
        throw Exception('Error en actualización: ${response.errors}');
      }
    }

    // Actualizar la caché con la caja actualizada
    CajaService.updateCache(cajaActualizada);
    debugPrint('Caché actualizada con caja: $cajaActualizada');
  }

  static Future<void> _processOrderItemsBatch(
    String orderId,
    List orderItems,
  ) async {
    const int batchSize = 5;

    for (int i = 0; i < orderItems.length; i += batchSize) {
      final batch = orderItems.skip(i).take(batchSize);
      final batchFutures = batch.map(
        (itemData) => _processOrderItem(orderId, itemData),
      );
      await Future.wait(batchFutures);
    }
  }

  static Future<void> _processOrderItem(String orderId, itemData) async {
    final orderItem = OrderItem(
      orderID: orderId,
      productoID: itemData.producto.id,
      quantity: itemData.quantity,
      precioID: itemData.precio!.id,
      tax: itemData.tax,
      subtotal: itemData.subtotal,
      total: double.parse(itemData.total.toStringAsFixed(2)),
      createdAt: TemporalDateTime.now(),
      updatedAt: TemporalDateTime.now(),
    );

    final unidadesVendidas = itemData.quantity * itemData.precio!.quantity;
    final updatedProduct = itemData.producto.copyWith(
      stock: itemData.producto.stock - unidadesVendidas,
    );

    final futures = [
      Amplify.API.mutate(request: ModelMutations.create(orderItem)).response,
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
    double totalOrden,
    String orderId,
  ) async {
    final movement = CajaMovimiento(
      cajaID: caja.id,
      tipo: 'INGRESO',
      origen: 'ORDEN',
      monto: totalOrden,
      negocioID: userData.negocioId,
      descripcion: 'Ingreso por orden ID: $orderId',
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

  static bool _validateOrderItems(BuildContext context, List orderItems) {
    for (var item in orderItems) {
      if (item.precio == null) {
        _showSnackBar(
          context,
          'Todos los productos deben tener un precio seleccionado',
        );
        return false;
      }

      final validTotalStock = item.quantity * item.precio!.quantity;
      if (validTotalStock > item.producto.stock) {
        _showSnackBar(
          context,
          'El producto ${item.producto.nombre} no tiene stock suficiente',
        );
        return false;
      }
    }
    return true;
  }

  static Order _createOrder(
    String orderNumber,
    DateTime selectDate,
    double totalOrden,
    double cambio,
    String orderStatus,
    userData,
    caja,
  ) {
    final dateSave = FechaEcuador.aZonaEcuador(selectDate);
    return Order(
      orderNumber: orderNumber,
      orderDate: TemporalDateTime(dateSave),
      orderReceivedTotal: totalOrden,
      orderReturnedTotal: cambio,
      orderStatus: orderStatus,
      sellerID: userData.userId,
      negocioID: userData.negocioId,
      cajaID: caja.id,
      isDeleted: false,
      createdAt: TemporalDateTime.now(),
      updatedAt: TemporalDateTime.now(),
    );
  }

  static Future<GraphQLResponse<Order>> _createOrderInDB(Order order) async {
    final response = await Amplify.API
        .mutate(request: ModelMutations.create(order))
        .response;

    if (response.data == null) {
      throw Exception('Error al crear la orden: ${response.errors}');
    }

    return response;
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
