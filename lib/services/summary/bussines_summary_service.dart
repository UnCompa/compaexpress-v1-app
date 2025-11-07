import 'dart:math';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';

class BussinesSummaryService {
  final String negocioID;

  BussinesSummaryService({required this.negocioID});

  /// 🔹 Tipo de pago: porcentaje efectivo vs transferencia
  Future<Map<String, int>> obtenerDistribucionTipoPago() async {
    print("OBTENIENDO DISTRIBUCIONES");
    final query = ModelQueries.list(
      Invoice.classType,
      where: Invoice.NEGOCIOID.eq(negocioID).and(Invoice.ISDELETED.ne(true)),
    );
    final queryOrder = ModelQueries.list(
      Order.classType,
      where: Order.NEGOCIOID.eq(negocioID).and(Order.ISDELETED.ne(true)),
    );

    final result = await Amplify.API.query(request: query).response;
    final resultOrder = await Amplify.API.query(request: queryOrder).response;
    final data = result.data?.items ?? [];
    final dataOrder = resultOrder.data?.items ?? [];
    int efectivo = 0;
    int transferencia = 0;

    // Procesar pagos de facturas
    for (final item in data) {
      if (item == null ||
          item.invoicePayments == null ||
          item.invoicePayments!.isEmpty) {
        continue;
      }
      for (final payment in item.invoicePayments!) {
        final tipo = payment.tipoPago;
        if (tipo == TiposPago.EFECTIVO) {
          efectivo++;
        } else if (tipo == TiposPago.TRANSFERENCIA) {
          transferencia++;
        }
      }
    }

    // Procesar pagos de órdenes
    for (final item in dataOrder) {
      if (item == null ||
          item.orderPayments == null ||
          item.orderPayments!.isEmpty) {
        continue;
      }
      for (final payment in item.orderPayments!) {
        final tipo = payment.tipoPago;
        if (tipo == TiposPago.EFECTIVO) {
          efectivo++;
        } else if (tipo == TiposPago.TRANSFERENCIA) {
          transferencia++;
        }
      }
    }

    print("FIN DISTRIBUCIONES");
    return {'EFECTIVO': efectivo, 'TRANSFERENCIA': transferencia};
  }

  /// 🔹 Ingresos últimos 30 días (mapa fecha → total)
  Future<Map<String, double>> obtenerIngresosPorFecha() async {
    print("OBTENIENDO INGRESOS POR FECHA");
    final now = DateTime.now();
    final desde = now.subtract(const Duration(days: 30)).toIso8601String();

    final query = ModelQueries.list(
      Invoice.classType,
      where: Invoice.NEGOCIOID
          .eq(negocioID)
          .and(Invoice.ISDELETED.ne(true))
          .and(Invoice.INVOICEDATE.ge(desde)),
    );
    final queryOrder = ModelQueries.list(
      Order.classType,
      where: Order.NEGOCIOID
          .eq(negocioID)
          .and(Order.ISDELETED.ne(true))
          .and(Order.ORDERDATE.ge(desde)),
    );

    final result = await Amplify.API.query(request: query).response;
    final resultOrder = await Amplify.API.query(request: queryOrder).response;
    final data = result.data?.items ?? [];
    final dataOrder = resultOrder.data?.items ?? [];
    final Map<String, double> ingresos = {};

    for (final item in data) {
      if (item == null) continue;
      final fecha = DateTime.parse(
        item.invoiceDate.toString(),
      ).toIso8601String().substring(0, 10); // yyyy-MM-dd
      final total = item.invoiceReceivedTotal.toDouble() ?? 0.0;
      ingresos[fecha] = (ingresos[fecha] ?? 0.0) + total;
    }
    for (final item in dataOrder) {
      if (item == null) continue;
      final fecha = DateTime.parse(
        item.orderDate.toString(),
      ).toIso8601String().substring(0, 10); // yyyy-MM-dd
      final total = item.orderReceivedTotal.toDouble() ?? 0.0;
      ingresos[fecha] = (ingresos[fecha] ?? 0.0) + total;
    }
    print("FIN INGRESOS POR FECHA");
    return ingresos;
  }

  /// 🔹 Diferencia total en cierres de caja
  Future<double> obtenerDiferenciaAcumuladaCierreCaja() async {
    print("OBTENIENDO DIFERENCIA");
    final query = ModelQueries.list(
      CierreCaja.classType,
      where: CierreCaja.NEGOCIOID
          .eq(negocioID)
          .and(CierreCaja.ISDELETED.ne(true)),
    );

    final result = await Amplify.API.query(request: query).response;
    final data = result.data?.items ?? [];
    double total = 0.0;

    for (final item in data) {
      if (item == null) continue;
      total += item.diferencia.toDouble() ?? 0.0;
    }
    print("FIN DIFERENCIA");
    return total;
  }

  /// 🔹 Comparativa total de órdenes vs facturas
  Future<Map<String, int>> obtenerConteoOrdenesYFacturas() async {
    print("OBTENIENDO CONTEO");
    final facturasQuery = ModelQueries.list(
      Invoice.classType,
      where: Invoice.NEGOCIOID.eq(negocioID).and(Invoice.ISDELETED.ne(true)),
    );

    final ordenesQuery = ModelQueries.list(
      Order.classType,
      where: Order.NEGOCIOID.eq(negocioID).and(Order.ISDELETED.ne(true)),
    );

    final facturasResult = await Amplify.API
        .query(request: facturasQuery)
        .response;
    final ordenesResult = await Amplify.API
        .query(request: ordenesQuery)
        .response;
    print("FIN CONTEO");
    return {
      'facturas': (facturasResult.data?.items ?? []).length,
      'ordenes': (ordenesResult.data?.items ?? []).length,
    };
  }

  /// 🔹 Productos con stock bajo o agotado
  Future<Map<String, int>> obtenerProductosBajoStock({int umbral = 5}) async {
    print("OBTENIENDO STOCK");
    final query = ModelQueries.list(
      Producto.classType,
      where: Producto.NEGOCIOID.eq(negocioID).and(Producto.ISDELETED.ne(true)),
    );

    final result = await Amplify.API.query(request: query).response;
    final data = result.data?.items ?? [];
    int sinStock = 0;
    int bajoStock = 0;

    for (final item in data) {
      if (item == null) continue;
      final stock = item.stock ?? 0;
      if (stock <= 0) {
        sinStock++;
      } else if (stock <= umbral) {
        bajoStock++;
      }
    }
    print("FIN STOCK");

    return {'sinStock': sinStock, 'bajoStock': bajoStock};
  }

  Future<double> obtenerGananciaPorcentual({int dias = 30}) async {
    print("OBTENIENDO GANANCIAS");
    final now = DateTime.now();
    final desde = now.subtract(Duration(days: dias)).toIso8601String();

    // Consultas paralelas para facturas, órdenes y productos
    final results = await Future.wait([
      Amplify.API
          .query(
            request: ModelQueries.list(
              Invoice.classType,
              where: Invoice.NEGOCIOID
                  .eq(negocioID)
                  .and(Invoice.ISDELETED.ne(true))
                  .and(Invoice.INVOICEDATE.ge(desde)),
            ),
          )
          .response,
      Amplify.API
          .query(
            request: ModelQueries.list(
              Order.classType,
              where: Order.NEGOCIOID
                  .eq(negocioID)
                  .and(Order.ISDELETED.ne(true))
                  .and(Order.ORDERDATE.ge(desde)),
            ),
          )
          .response,
      Amplify.API
          .query(
            request: ModelQueries.list(
              Producto.classType,
              where: Producto.NEGOCIOID
                  .eq(negocioID)
                  .and(Producto.ISDELETED.ne(true)),
            ),
          )
          .response,
    ]);

    final invoices = results[0].data?.items.whereType<Invoice>().toList() ?? [];
    final orders = results[1].data?.items.whereType<Order>().toList() ?? [];
    final productos =
        results[2].data?.items.whereType<Producto>().toList() ?? [];

    // Mapa de productos para acceso rápido por ID
    final productoMap = {for (var p in productos) p.id: p};

    // Obtener InvoiceItems y OrderItems en lotes
    final invoiceItems = <InvoiceItem>[];
    final orderItems = <OrderItem>[];
    const batchSize = 10; // Ajustar según límites de Amplify

    // Consultar InvoiceItems por invoiceID
    final invoiceIds = invoices.map((i) => i.id).toList();
    for (var i = 0; i < invoiceIds.length; i += batchSize) {
      final batch = invoiceIds.sublist(
        i,
        min(i + batchSize, invoiceIds.length),
      );
      for (var id in batch) {
        final response = await Amplify.API
            .query(
              request: ModelQueries.list(
                InvoiceItem.classType,
                where: InvoiceItem.INVOICEID
                    .eq(id)
                    .and(InvoiceItem.ISDELETED.ne(true)),
              ),
            )
            .response;
        invoiceItems.addAll(
          response.data?.items.whereType<InvoiceItem>() ?? [],
        );
      }
    }

    // Consultar OrderItems por orderID
    final orderIds = orders.map((o) => o.id).toList();
    for (var i = 0; i < orderIds.length; i += batchSize) {
      final batch = orderIds.sublist(i, min(i + batchSize, orderIds.length));
      for (var id in batch) {
        final response = await Amplify.API
            .query(
              request: ModelQueries.list(
                OrderItem.classType,
                where: OrderItem.ORDERID
                    .eq(id)
                    .and(OrderItem.ISDELETED.ne(true)),
              ),
            )
            .response;
        orderItems.addAll(response.data?.items.whereType<OrderItem>() ?? []);
      }
    }

    double gananciaTotal = 0.0;
    double costoTotal = 0.0;
    double costoProductosVendidos = 0.0;

    // Calcular costo total del inventario
    for (final producto in productos) {
      final stock = producto.stock ?? 0;
      final precioCompra = producto.precioCompra ?? 0.0;
      costoTotal += precioCompra * stock;
    }

    // Calcular costos de productos vendidos en ítems de facturas
    for (final item in invoiceItems) {
      final producto = productoMap[item.productoID];
      if (producto == null) continue;
      costoProductosVendidos += producto.precioCompra * (item.quantity ?? 0);
    }

    // Calcular costos de productos vendidos en ítems de órdenes
    for (final item in orderItems) {
      final producto = productoMap[item.productoID];
      if (producto == null) continue;
      costoProductosVendidos += producto.precioCompra * (item.quantity ?? 0);
    }

    // Sumar ingresos de facturas y órdenes
    gananciaTotal += invoices.fold(
      0.0,
      (sum, i) => sum + (i.invoiceReceivedTotal ?? 0.0),
    );
    gananciaTotal += orders.fold(
      0.0,
      (sum, o) => sum + (o.orderReceivedTotal ?? 0.0),
    );

    // Ajustar ganancia total restando el costo de productos vendidos
    gananciaTotal -= costoProductosVendidos;

    print("GANANCIAS: $gananciaTotal");
    print("COSTOS: $costoTotal");
    print("COSTOS PRODUCTOS VENDIDOS: $costoProductosVendidos");
    final gananciaFinal = costoTotal == 0
        ? 0.0
        : (gananciaTotal / costoTotal * 100).toDouble();
    print("GANANCIA: $gananciaFinal");
    return gananciaFinal;
  }
}
