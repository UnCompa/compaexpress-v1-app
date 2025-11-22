import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/entities/order_item_data.dart';
import 'package:compaexpress/entities/payment_option.dart';
import 'package:compaexpress/entities/user_info.dart';
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
    List<DocumentMetadata?>? metadata,
  ) async {
    debugPrint('\n${'=' * 80}');
    debugPrint('🚀 INICIANDO CREACIÓN DE ORDEN');
    debugPrint('=' * 80);
    debugPrint('📋 Número de orden: $orderNumber');
    debugPrint('💰 Total orden: \$${totalOrden.toStringAsFixed(2)}');
    debugPrint('💵 Total pago: \$${totalPago.toStringAsFixed(2)}');
    debugPrint('💸 Cambio: \$${cambio.toStringAsFixed(2)}');
    debugPrint('📦 Cantidad de items: ${orderItems.length}');
    debugPrint(
      '💳 Opciones de pago: ${paymentOptions.where((p) => p.seleccionado).length}',
    );
    debugPrint('=' * 80);

    if (formKey != null && formKey.currentState != null) {
      if (!formKey.currentState!.validate()) {
        debugPrint('❌ Validación del formulario fallida');
        return null;
      }
      debugPrint('✅ Validación del formulario exitosa');
    }

    if (orderItems.isEmpty) {
      debugPrint('❌ Error: No hay productos en la orden');
      _showSnackBar(context, 'Debe agregar al menos un producto');
      return null;
    }

    if (!_validateOrderItems(context, orderItems)) {
      debugPrint('❌ Error: Validación de items fallida');
      return null;
    }
    debugPrint('✅ Validación de items exitosa');

    if (totalPago < totalOrden) {
      debugPrint('❌ Error: Pago insuficiente');
      _showSnackBar(
        context,
        'El pago (\$${totalPago.toStringAsFixed(2)}) debe ser mayor que la orden (\$${totalOrden.toStringAsFixed(2)})',
      );
      return null;
    }
    debugPrint('✅ Validación de pago exitosa');

    debugPrint('\n📍 Iniciando proceso de guardado optimizado...');

    // Variables para el reporte final
    final Map<String, dynamic> reporteFinal = {
      'orden_creada': false,
      'orden_id': '',
      'pagos_creados': 0,
      'pagos_detalle': <Map<String, dynamic>>[],
      'items_creados': 0,
      'items_detalle': <Map<String, dynamic>>[],
      'metadata_creada': 0,
      'metadata_detalle': <String>[],
      'movimiento_caja_creado': false,
      'movimiento_caja_id': '',
      'caja_actualizada': false,
      'orden_actualizada': false,
    };

    try {
      debugPrint('\n🔄 Obteniendo información de usuario y caja...');
      final futures = await Future.wait([
        NegocioService.getCurrentUserInfo(forceRefresh: true),
        CajaService.getCurrentCaja(forceRefresh: true),
      ]);

      final userData = futures[0] as UserInfo;
      final caja = futures[1] as Caja;
      debugPrint('✅ Usuario obtenido: $userData');
      debugPrint('✅ Caja obtenida: ${caja.id} - Activa: ${caja.isActive}');

      if (!caja.isActive) {
        throw Exception('La caja no está activa');
      }

      debugPrint('\n🏗️  Creando orden en base de datos...');
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
      reporteFinal['orden_creada'] = true;
      reporteFinal['orden_id'] = createdOrder.id;
      debugPrint('✅ Orden creada exitosamente');
      debugPrint('   🆔 ID: ${createdOrder.id}');
      debugPrint('   📋 Número: ${createdOrder.orderNumber}');
      debugPrint('   💰 Total: \$${createdOrder.orderReceivedTotal}');

      await _processOrderInParallel(
        context,
        createdOrder,
        orderItems,
        paymentOptions,
        caja,
        userData,
        totalOrden,
        metadata,
        reporteFinal,
      );

      // REPORTE FINAL
      _printFinalReport(reporteFinal, totalOrden);

      _showSnackBar(context, 'Orden creada exitosamente');
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('\n${'=' * 80}');
      debugPrint('❌ ERROR CRÍTICO EN CREACIÓN DE ORDEN');
      debugPrint('=' * 80);
      debugPrint('Error: $e');
      debugPrint('=' * 80);
      _showSnackBar(context, 'Error al crear la orden: $e');
      return null;
    }

    return null;
  }

  static void _printFinalReport(
    Map<String, dynamic> reporte,
    double totalOrden,
  ) {
    debugPrint('\n${'=' * 80}');
    debugPrint('📊 REPORTE FINAL DE CREACIÓN DE ORDEN');
    debugPrint('=' * 80);

    // Orden
    if (reporte['orden_creada']) {
      debugPrint('✅ [✓] Orden creada');
      debugPrint('   └─ ID: ${reporte['orden_id']}');
      debugPrint('   └─ Total: \$${totalOrden.toStringAsFixed(2)}');
    } else {
      debugPrint('❌ [✗] Orden NO creada');
    }

    // Pagos
    debugPrint('\n💳 PAGOS:');
    if (reporte['pagos_creados'] > 0) {
      debugPrint('✅ [✓] ${reporte['pagos_creados']} pago(s) creado(s)');
      for (var pago in reporte['pagos_detalle']) {
        debugPrint(
          '   └─ ${pago['tipo']}: \$${pago['monto'].toStringAsFixed(2)}',
        );
      }
    } else {
      debugPrint('⚠️  [!] No se crearon pagos');
    }

    // Items
    debugPrint('\n📦 ITEMS:');
    if (reporte['items_creados'] > 0) {
      debugPrint('✅ [✓] ${reporte['items_creados']} item(s) creado(s)');
      for (var item in reporte['items_detalle']) {
        debugPrint(
          '   └─ ${item['nombre']} x${item['cantidad']} = \$${item['total'].toStringAsFixed(2)}',
        );
      }
    } else {
      debugPrint('❌ [✗] No se crearon items');
    }

    // Metadata
    debugPrint('\n📄 METADATA:');
    if (reporte['metadata_creada'] > 0) {
      debugPrint('✅ [✓] ${reporte['metadata_creada']} documento(s) adjunto(s)');
      for (var doc in reporte['metadata_detalle']) {
        debugPrint('   └─ $doc');
      }
    } else {
      debugPrint('ℹ️  [·] Sin documentos adjuntos');
    }

    // Movimiento de Caja
    debugPrint('\n🏦 MOVIMIENTO DE CAJA:');
    if (reporte['movimiento_caja_creado']) {
      debugPrint('✅ [✓] Movimiento creado');
      debugPrint('   └─ ID: ${reporte['movimiento_caja_id']}');
    } else {
      debugPrint('❌ [✗] Movimiento NO creado');
    }

    // Actualizaciones
    debugPrint('\n🔄 ACTUALIZACIONES:');
    debugPrint(
      reporte['caja_actualizada']
          ? '✅ [✓] Caja actualizada'
          : '❌ [✗] Caja NO actualizada',
    );
    debugPrint(
      reporte['orden_actualizada']
          ? '✅ [✓] Orden actualizada con movimiento'
          : '❌ [✗] Orden NO actualizada',
    );

    debugPrint('\n${'=' * 80}');
    debugPrint('🎉 PROCESO COMPLETADO EXITOSAMENTE');
  }

  static Future<void> _processOrderInParallel(
    BuildContext context,
    Order createdOrder,
    List orderItems,
    List<PaymentOption> paymentOptions,
    caja,
    userData,
    double totalOrden,
    List<DocumentMetadata?>? metadata,
    Map<String, dynamic> reporteFinal,
  ) async {
    debugPrint('\n🔄 Procesando operaciones en paralelo...');
    final List<Future> futures = [];

    // Pagos
    debugPrint('📍 Iniciando creación de pagos...');
    futures.add(_createPayments(createdOrder.id, paymentOptions, reporteFinal));

    // Metadata
    final cleanedMetadata = metadata
        ?.where((m) => m != null)
        .map((m) => m!)
        .toList();

    if (cleanedMetadata != null && cleanedMetadata.isNotEmpty) {
      debugPrint(
        '📍 Iniciando creación de metadata (${cleanedMetadata.length} documentos)...',
      );
      futures.add(_createMetadata(createdOrder, cleanedMetadata, reporteFinal));
    } else {
      debugPrint('ℹ️  Sin metadata para crear');
    }

    // Items
    debugPrint('📍 Iniciando procesamiento de items...');
    futures.add(
      _processOrderItemsBatch(createdOrder.id, orderItems, reporteFinal),
    );

    // Movimiento de caja
    debugPrint('📍 Iniciando creación de movimiento de caja...');
    final movementFuture = _createCajaMovement(
      caja,
      userData,
      totalOrden,
      createdOrder.id,
      reporteFinal,
    );

    futures.add(movementFuture);

    debugPrint('⏳ Esperando primeras operaciones...');
    await Future.wait(futures.take(2));
    debugPrint('✅ Primeras operaciones completadas');

    debugPrint('⏳ Esperando movimiento de caja...');
    final movement = await movementFuture;
    debugPrint('✅ Movimiento de caja completado');

    debugPrint('📍 Actualizando caja y orden...');
    await _updateCajaAndOrder(
      caja,
      totalOrden,
      createdOrder,
      movement.id,
      paymentOptions,
      reporteFinal,
    );
    debugPrint('✅ Caja y orden actualizadas');
  }

  static Future<void> _createPayments(
    String orderId,
    List<PaymentOption> paymentOptions,
    Map<String, dynamic> reporteFinal,
  ) async {
    debugPrint('\n🔵 === CREACIÓN DE PAGOS ===');
    debugPrint('📋 Orden ID: $orderId');

    final pagosSeleccionados = paymentOptions
        .where((p) => p.seleccionado && p.monto > 0)
        .map((p) {
          debugPrint('   • Pago: ${p.tipo} → \$${p.monto.toStringAsFixed(2)}');
          reporteFinal['pagos_detalle'].add({
            'tipo': p.tipo.toString().split('.').last,
            'monto': p.monto,
          });
          return OrderPayment(
            orderID: orderId,
            tipoPago: p.tipo,
            monto: p.monto,
            detalles: '',
            isDeleted: false,
            createdAt: TemporalDateTime.now(),
            updatedAt: TemporalDateTime.now(),
          );
        })
        .toList();

    if (pagosSeleccionados.isEmpty) {
      debugPrint('⚠️  No hay pagos para crear');
      return;
    }

    debugPrint('📤 Creando ${pagosSeleccionados.length} pago(s) en BD...');

    final paymentFutures = pagosSeleccionados.map((pago) {
      return Amplify.API.mutate(request: ModelMutations.create(pago)).response;
    }).toList();

    await Future.wait(paymentFutures);

    reporteFinal['pagos_creados'] = pagosSeleccionados.length;
    debugPrint('✅ ${pagosSeleccionados.length} pago(s) creado(s) exitosamente');
  }

  static Future<void> _createMetadata(
    Order order,
    List<DocumentMetadata>? metadata,
    Map<String, dynamic> reporteFinal,
  ) async {
    debugPrint('\n🔵 === CREACIÓN DE METADATA ===');
    debugPrint('📋 Orden ID: ${order.id}');

    if (metadata == null || metadata.isEmpty) {
      debugPrint('⚠️  Sin metadata para crear');
      return;
    }

    final metadataOrder = metadata.map((d) {
      final newMeta = d.copyWith(orderID: order.id);
      final docName = newMeta.key ?? 'sin nombre';
      debugPrint('   • Documento: $docName');
      reporteFinal['metadata_detalle'].add(docName);
      return newMeta;
    }).toList();

    debugPrint('📤 Creando ${metadataOrder.length} documento(s) en BD...');

    final metadataOrderFutures = metadataOrder.map((m) {
      return Amplify.API.mutate(request: ModelMutations.create(m)).response;
    }).toList();

    await Future.wait(metadataOrderFutures);

    reporteFinal['metadata_creada'] = metadataOrder.length;
    debugPrint('✅ ${metadataOrder.length} documento(s) creado(s) exitosamente');
  }

  static Future<void> _updateCajaAndOrder(
    Caja caja,
    double totalOrden,
    Order createdOrder,
    String movementId,
    List<PaymentOption> paymentOptions,
    Map<String, dynamic> reporteFinal,
  ) async {
    debugPrint('\n🔵 === ACTUALIZACIÓN DE CAJA Y ORDEN ===');

    double saldoEfectivo = 0.0;
    double saldoTransferencias = 0.0;
    double saldoTarjetas = 0.0;
    double saldoOtros = 0.0;

    for (var payment in paymentOptions.where(
      (p) => p.seleccionado && p.monto > 0,
    )) {
      final montoNeto = payment.monto - createdOrder.orderReturnedTotal;
      debugPrint(
        '💳 Procesando pago: ${payment.tipo} - Monto neto: \$${montoNeto.toStringAsFixed(2)}',
      );

      switch (payment.tipo) {
        case TiposPago.EFECTIVO:
          saldoEfectivo += montoNeto;
          break;
        case TiposPago.TRANSFERENCIA:
        case TiposPago.DEPOSITO_BANCARIO:
          saldoTransferencias += montoNeto;
          break;
        case TiposPago.TARJETA_DEBITO:
        case TiposPago.TARJETA_CREDITO:
          saldoTarjetas += montoNeto;
          break;
        default:
          saldoOtros += montoNeto;
          break;
      }
    }

    debugPrint('\n📊 Cambios en saldos:');
    debugPrint(
      '   💵 Efectivo: ${caja.saldoInicial} → ${caja.saldoInicial + saldoEfectivo} (+${saldoEfectivo.toStringAsFixed(2)})',
    );
    debugPrint(
      '   🏦 Transferencias: ${caja.saldoTransferencias ?? 0.0} → ${(caja.saldoTransferencias ?? 0.0) + saldoTransferencias} (+${saldoTransferencias.toStringAsFixed(2)})',
    );
    debugPrint(
      '   💳 Tarjetas: ${caja.saldoTarjetas ?? 0.0} → ${(caja.saldoTarjetas ?? 0.0) + saldoTarjetas} (+${saldoTarjetas.toStringAsFixed(2)})',
    );
    debugPrint(
      '   📋 Otros: ${caja.saldoOtros ?? 0.0} → ${(caja.saldoOtros ?? 0.0) + saldoOtros} (+${saldoOtros.toStringAsFixed(2)})',
    );

    final cajaActualizada = caja.copyWith(
      saldoInicial: (caja.saldoInicial) + saldoEfectivo,
      saldoTransferencias:
          (caja.saldoTransferencias ?? 0.0) + saldoTransferencias,
      saldoTarjetas: (caja.saldoTarjetas ?? 0.0) + saldoTarjetas,
      saldoOtros: (caja.saldoOtros ?? 0.0) + saldoOtros,
      updatedAt: TemporalDateTime.now(),
    );

    final updatedOrder = createdOrder.copyWith(cajaMovimientoID: movementId);

    debugPrint('📤 Enviando actualizaciones a BD...');
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

    CajaService.updateCache(cajaActualizada);

    reporteFinal['caja_actualizada'] = true;
    reporteFinal['orden_actualizada'] = true;

    debugPrint('✅ Caja actualizada correctamente');
    debugPrint('✅ Orden vinculada con movimiento: $movementId');
    debugPrint('✅ Caché actualizada');
  }

  static Future<void> _processOrderItemsBatch(
    String orderId,
    List orderItems,
    Map<String, dynamic> reporteFinal,
  ) async {
    debugPrint('\n🔵 === PROCESAMIENTO DE ITEMS ===');
    debugPrint('📋 Orden ID: $orderId');
    debugPrint('📦 Total items: ${orderItems.length}');

    const int batchSize = 5;
    int itemsCreados = 0;

    for (int i = 0; i < orderItems.length; i += batchSize) {
      final batch = orderItems.skip(i).take(batchSize);
      final batchNumber = (i ~/ batchSize) + 1;
      final totalBatches = (orderItems.length / batchSize).ceil();

      debugPrint(
        '\n📦 Procesando lote $batchNumber/$totalBatches (${batch.length} items)...',
      );

      final batchFutures = batch.map(
        (itemData) => _processOrderItem(orderId, itemData, reporteFinal),
      );
      await Future.wait(batchFutures);

      itemsCreados += batch.length;
      debugPrint(
        '✅ Lote $batchNumber completado ($itemsCreados/${orderItems.length} items)',
      );
    }

    reporteFinal['items_creados'] = itemsCreados;
    debugPrint('✅ Todos los items procesados: $itemsCreados');
  }

  static Future<void> _processOrderItem(
    String orderId,
    itemData,
    Map<String, dynamic> reporteFinal,
  ) async {
    final productoNombre = itemData.producto.nombre ?? 'Sin nombre';
    debugPrint('   📦 Item: $productoNombre x${itemData.quantity}');

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
    final stockAnterior = itemData.producto.stock;
    final stockNuevo = stockAnterior - unidadesVendidas;

    debugPrint(
      '      └─ Stock: $stockAnterior → $stockNuevo (-$unidadesVendidas)',
    );
    debugPrint('      └─ Total: \$${itemData.total.toStringAsFixed(2)}');

    final updatedProduct = itemData.producto.copyWith(stock: stockNuevo);

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

    reporteFinal['items_detalle'].add({
      'nombre': productoNombre,
      'cantidad': itemData.quantity,
      'total': itemData.total,
    });
  }

  static Future<CajaMovimiento> _createCajaMovement(
    caja,
    userData,
    double totalOrden,
    String orderId,
    Map<String, dynamic> reporteFinal,
  ) async {
    debugPrint('\n🔵 === CREACIÓN DE MOVIMIENTO DE CAJA ===');
    debugPrint('🏦 Caja ID: ${caja.id}');
    debugPrint('💰 Monto: \$${totalOrden.toStringAsFixed(2)}');
    debugPrint('📋 Orden ID: $orderId');

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

    debugPrint('📤 Creando movimiento en BD...');
    final response = await Amplify.API
        .mutate(request: ModelMutations.create(movement))
        .response;

    if (response.hasErrors) {
      throw Exception('Error al crear movimiento de caja: ${response.errors}');
    }

    reporteFinal['movimiento_caja_creado'] = true;
    reporteFinal['movimiento_caja_id'] = response.data!.id;

    debugPrint('✅ Movimiento creado: ${response.data!.id}');
    return response.data!;
  }

  static bool _validateOrderItems(BuildContext context, List orderItems) {
    debugPrint('\n🔍 Validando items de la orden...');

    for (var item in orderItems) {
      final productoNombre = item.producto.nombre ?? 'Sin nombre';

      if (item.precio == null) {
        debugPrint('❌ Error: $productoNombre sin precio');
        _showSnackBar(
          context,
          'Todos los productos deben tener un precio seleccionado',
        );
        return false;
      }

      final validTotalStock = item.quantity * item.precio!.quantity;
      if (validTotalStock > item.producto.stock) {
        debugPrint(
          '❌ Error: $productoNombre - Stock insuficiente (necesita: $validTotalStock, disponible: ${item.producto.stock})',
        );
        _showSnackBar(
          context,
          'El producto $productoNombre no tiene stock suficiente',
        );
        return false;
      }

      debugPrint('   ✓ $productoNombre: OK');
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
