/* import 'dart:math';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/user_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_providers.g.dart';

// ============================================================================
// MODELOS DE DATOS
// ============================================================================

class DashboardSummary {
  final Map<String, double> ventasPorVendedor;
  final double totalCaja;
  final double totalGeneral;
  final double maxCierreCaja;

  DashboardSummary({
    required this.ventasPorVendedor,
    required this.totalCaja,
    required this.totalGeneral,
    required this.maxCierreCaja,
  });
}

class BusinessMetrics {
  final Map<String, int> distribucionTipoPago;
  final Map<String, double> ingresosPorFecha;
  final double diferenciaAcumuladaCierreCaja;
  final Map<String, int> conteoOrdenesYFacturas;
  final Map<String, int> productosBajoStock;
  final double gananciaPorcentual;

  BusinessMetrics({
    required this.distribucionTipoPago,
    required this.ingresosPorFecha,
    required this.diferenciaAcumuladaCierreCaja,
    required this.conteoOrdenesYFacturas,
    required this.productosBajoStock,
    required this.gananciaPorcentual,
  });
}

class ProductMetrics {
  final List<Producto> bestSellingProducts;
  final Map<String, int> totalUnitsSold;
  final List<Producto> productsByInvoiceCount;

  ProductMetrics({
    required this.bestSellingProducts,
    required this.totalUnitsSold,
    required this.productsByInvoiceCount,
  });
}

// ============================================================================
// PROVIDER DE NEGOCIO (DEPENDENCY INJECTION)
// ============================================================================

/// Provider que provee el ID del negocio actual
@riverpod
String negocioId(NegocioIdRef ref) {
  throw UnimplementedError('Debes proveer el negocioID en tu app');
}

// ============================================================================
// DASHBOARD PROVIDERS (Sección Principal)
// ============================================================================

/// Provider para obtener ventas por vendedor
@riverpod
class VentasPorVendedor extends _$VentasPorVendedor {
  @override
  Future<Map<String, double>> build() async {
    final negocioID = ref.watch(negocioIdProvider);
    return _fetchVentasPorVendedor(negocioID);
  }

  Future<Map<String, double>> _fetchVentasPorVendedor(String negocioID) async {
    final query = ModelQueries.list(
      Invoice.classType,
      where: Invoice.NEGOCIOID.eq(negocioID).and(Invoice.ISDELETED.ne(true)),
    );

    final result = await Amplify.API.query(request: query).response;
    final data = result.data?.items ?? [];
    final user = await UserService.fetchUsersSellers();

    final Map<String, String> userIdToUsername = {
      for (var u in user!.users) u.id: u.email,
    };

    final Map<String, double> ventas = {};
    for (final factura in data) {
      if (factura == null) continue;

      final sellerID = factura.sellerID;

      final total = factura.invoiceReceivedTotal.toDouble();
      final username = userIdToUsername[sellerID] ?? 'Desconocido';

      ventas[username] = (ventas[username] ?? 0) + total;
    }

    return ventas;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final negocioID = ref.read(negocioIdProvider);
      return _fetchVentasPorVendedor(negocioID);
    });
  }
}

/// Provider para obtener el total en cajas
@riverpod
class TotalCajas extends _$TotalCajas {
  @override
  Future<double> build() async {
    final negocioID = ref.watch(negocioIdProvider);
    return _fetchTotalCajas(negocioID);
  }

  Future<double> _fetchTotalCajas(String negocioID) async {
    final query = ModelQueries.list(
      Caja.classType,
      where: Caja.NEGOCIOID.eq(negocioID).and(Caja.ISDELETED.ne(true)),
    );

    final result = await Amplify.API.query(request: query).response;
    final data = result.data?.items ?? [];
    double total = 0.0;

    for (final caja in data) {
      if (caja == null) continue;
      final saldo = caja.saldoInicial.toDouble();
      total += saldo;
    }

    return total;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final negocioID = ref.read(negocioIdProvider);
      return _fetchTotalCajas(negocioID);
    });
  }
}

/// Provider para obtener el total general
@riverpod
class TotalGeneral extends _$TotalGeneral {
  @override
  Future<double> build() async {
    final negocioID = ref.watch(negocioIdProvider);
    return _fetchTotalGeneral(negocioID);
  }

  Future<double> _fetchTotalGeneral(String negocioID) async {
    final query = ModelQueries.list(
      Caja.classType,
      where: Caja.NEGOCIOID.eq(negocioID).and(Caja.ISDELETED.ne(true)),
    );

    final result = await Amplify.API.query(request: query).response;
    final data = result.data?.items ?? [];
    double total = 0.0;

    for (final caja in data) {
      if (caja == null) continue;
      final saldo =
          caja.saldoInicial +
          (caja.saldoTransferencias ?? 0.0) +
          (caja.saldoTarjetas ?? 0.0) +
          (caja.saldoOtros ?? 0.0).toDouble();
      total += saldo;
    }

    return total;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final negocioID = ref.read(negocioIdProvider);
      return _fetchTotalGeneral(negocioID);
    });
  }
}

/// Provider para obtener el mayor cierre de caja
@riverpod
class MayorCierreCaja extends _$MayorCierreCaja {
  @override
  Future<double> build() async {
    final negocioID = ref.watch(negocioIdProvider);
    return _fetchMayorCierreCaja(negocioID);
  }

  Future<double> _fetchMayorCierreCaja(String negocioID) async {
    final query = ModelQueries.list(
      CierreCaja.classType,
      where: CierreCaja.NEGOCIOID
          .eq(negocioID)
          .and(CierreCaja.ISDELETED.ne(true)),
    );

    final result = await Amplify.API.query(request: query).response;
    final data = result.data?.items ?? [];
    double max = 0.0;

    for (final cierre in data) {
      if (cierre == null) continue;
      final saldo = cierre.saldoFinal.toDouble();
      if (saldo > max) {
        max = saldo;
      }
    }

    return max;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final negocioID = ref.read(negocioIdProvider);
      return _fetchMayorCierreCaja(negocioID);
    });
  }
}

/// Provider combinado del dashboard principal
@riverpod
class DashboardSummaryData extends _$DashboardSummaryData {
  @override
  Future<DashboardSummary> build() async {
    final results = await Future.wait([
      ref.watch(ventasPorVendedorProvider.future),
      ref.watch(totalCajasProvider.future),
      ref.watch(totalGeneralProvider.future),
      ref.watch(mayorCierreCajaProvider.future),
    ]);

    return DashboardSummary(
      ventasPorVendedor: results[0] as Map<String, double>,
      totalCaja: results[1] as double,
      totalGeneral: results[2] as double,
      maxCierreCaja: results[3] as double,
    );
  }

  Future<void> refreshAll() async {
    ref.invalidate(ventasPorVendedorProvider);
    ref.invalidate(totalCajasProvider);
    ref.invalidate(totalGeneralProvider);
    ref.invalidate(mayorCierreCajaProvider);
    ref.invalidateSelf();
  }
}

// ============================================================================
// BUSINESS METRICS PROVIDERS (Métricas de Negocio)
// ============================================================================

/// Provider para distribución de tipo de pago
@riverpod
class DistribucionTipoPago extends _$DistribucionTipoPago {
  @override
  Future<Map<String, int>> build() async {
    final negocioID = ref.watch(negocioIdProvider);
    return _fetchDistribucionTipoPago(negocioID);
  }

  Future<Map<String, int>> _fetchDistribucionTipoPago(String negocioID) async {
    final query = ModelQueries.list(
      Invoice.classType,
      where: Invoice.NEGOCIOID.eq(negocioID).and(Invoice.ISDELETED.ne(true)),
    );
    final queryOrder = ModelQueries.list(
      Order.classType,
      where: Order.NEGOCIOID.eq(negocioID).and(Order.ISDELETED.ne(true)),
    );

    final results = await Future.wait([
      Amplify.API.query(request: query).response,
      Amplify.API.query(request: queryOrder).response,
    ]);

    final data = results[0].data?.items ?? [];
    final dataOrder = results[1].data?.items ?? [];
    int efectivo = 0;
    int transferencia = 0;

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

    return {'EFECTIVO': efectivo, 'TRANSFERENCIA': transferencia};
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final negocioID = ref.read(negocioIdProvider);
      return _fetchDistribucionTipoPago(negocioID);
    });
  }
}

/// Provider para ingresos por fecha (últimos 30 días)
@riverpod
class IngresosPorFecha extends _$IngresosPorFecha {
  @override
  Future<Map<String, double>> build() async {
    final negocioID = ref.watch(negocioIdProvider);
    return _fetchIngresosPorFecha(negocioID);
  }

  Future<Map<String, double>> _fetchIngresosPorFecha(String negocioID) async {
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

    final results = await Future.wait([
      Amplify.API.query(request: query).response,
      Amplify.API.query(request: queryOrder).response,
    ]);

    final data = results[0].data?.items ?? [];
    final dataOrder = results[1].data?.items ?? [];
    final Map<String, double> ingresos = {};

    for (final item in data) {
      if (item == null) continue;
      final fecha = DateTime.parse(
        item.invoiceDate.toString(),
      ).toIso8601String().substring(0, 10);
      final total = item.invoiceReceivedTotal.toDouble();
      ingresos[fecha] = (ingresos[fecha] ?? 0.0) + total;
    }

    for (final item in dataOrder) {
      if (item == null) continue;
      final fecha = DateTime.parse(
        item.orderDate.toString(),
      ).toIso8601String().substring(0, 10);
      final total = item.orderReceivedTotal.toDouble();
      ingresos[fecha] = (ingresos[fecha] ?? 0.0) + total;
    }

    return ingresos;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final negocioID = ref.read(negocioIdProvider);
      return _fetchIngresosPorFecha(negocioID);
    });
  }
}

/// Provider para diferencia acumulada de cierre de caja
@riverpod
class DiferenciaAcumuladaCierreCaja extends _$DiferenciaAcumuladaCierreCaja {
  @override
  Future<double> build() async {
    final negocioID = ref.watch(negocioIdProvider);
    return _fetchDiferenciaAcumulada(negocioID);
  }

  Future<double> _fetchDiferenciaAcumulada(String negocioID) async {
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
      total += item.diferencia.toDouble();
    }

    return total;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final negocioID = ref.read(negocioIdProvider);
      return _fetchDiferenciaAcumulada(negocioID);
    });
  }
}

/// Provider para conteo de órdenes y facturas
@riverpod
class ConteoOrdenesYFacturas extends _$ConteoOrdenesYFacturas {
  @override
  Future<Map<String, int>> build() async {
    final negocioID = ref.watch(negocioIdProvider);
    return _fetchConteoOrdenesYFacturas(negocioID);
  }

  Future<Map<String, int>> _fetchConteoOrdenesYFacturas(
    String negocioID,
  ) async {
    final facturasQuery = ModelQueries.list(
      Invoice.classType,
      where: Invoice.NEGOCIOID.eq(negocioID).and(Invoice.ISDELETED.ne(true)),
    );

    final ordenesQuery = ModelQueries.list(
      Order.classType,
      where: Order.NEGOCIOID.eq(negocioID).and(Order.ISDELETED.ne(true)),
    );

    final results = await Future.wait([
      Amplify.API.query(request: facturasQuery).response,
      Amplify.API.query(request: ordenesQuery).response,
    ]);

    return {
      'facturas': (results[0].data?.items ?? []).length,
      'ordenes': (results[1].data?.items ?? []).length,
    };
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final negocioID = ref.read(negocioIdProvider);
      return _fetchConteoOrdenesYFacturas(negocioID);
    });
  }
}

/// Provider para productos con bajo stock
@riverpod
class ProductosBajoStock extends _$ProductosBajoStock {
  @override
  Future<Map<String, int>> build({int umbral = 5}) async {
    final negocioID = ref.watch(negocioIdProvider);
    return _fetchProductosBajoStock(negocioID, umbral);
  }

  Future<Map<String, int>> _fetchProductosBajoStock(
    String negocioID,
    int umbral,
  ) async {
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

    return {'sinStock': sinStock, 'bajoStock': bajoStock};
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final negocioID = ref.read(negocioIdProvider);
      return _fetchProductosBajoStock(negocioID, 5);
    });
  }
}

/// Provider para ganancia porcentual
@riverpod
class GananciaPorcentual extends _$GananciaPorcentual {
  @override
  Future<double> build({int dias = 30}) async {
    final negocioID = ref.watch(negocioIdProvider);
    return _fetchGananciaPorcentual(negocioID, dias);
  }

  Future<double> _fetchGananciaPorcentual(String negocioID, int dias) async {
    final now = DateTime.now();
    final desde = now.subtract(Duration(days: dias)).toIso8601String();

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

    final productoMap = {for (var p in productos) p.id: p};

    final invoiceItems = <InvoiceItem>[];
    final orderItems = <OrderItem>[];
    const batchSize = 10;

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

    for (final producto in productos) {
      final stock = producto.stock ?? 0;
      final precioCompra = producto.precioCompra ?? 0.0;
      costoTotal += precioCompra * stock;
    }

    for (final item in invoiceItems) {
      final producto = productoMap[item.productoID];
      if (producto == null) continue;
      costoProductosVendidos += producto.precioCompra * (item.quantity ?? 0);
    }

    for (final item in orderItems) {
      final producto = productoMap[item.productoID];
      if (producto == null) continue;
      costoProductosVendidos += producto.precioCompra * (item.quantity ?? 0);
    }

    gananciaTotal += invoices.fold(
      0.0,
      (sum, i) => sum + (i.invoiceReceivedTotal ?? 0.0),
    );
    gananciaTotal += orders.fold(
      0.0,
      (sum, o) => sum + (o.orderReceivedTotal ?? 0.0),
    );

    gananciaTotal -= costoProductosVendidos;

    final gananciaFinal = costoTotal == 0
        ? 0.0
        : (gananciaTotal / costoTotal * 100).toDouble();

    return gananciaFinal;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final negocioID = ref.read(negocioIdProvider);
      return _fetchGananciaPorcentual(negocioID, 30);
    });
  }
}

/// Provider combinado de todas las métricas de negocio
@riverpod
class BusinessMetricsData extends _$BusinessMetricsData {
  @override
  Future<BusinessMetrics> build() async {
    final results = await Future.wait([
      ref.watch(distribucionTipoPagoProvider.future),
      ref.watch(ingresosPorFechaProvider.future),
      ref.watch(diferenciaAcumuladaCierreCajaProvider.future),
      ref.watch(conteoOrdenesYFacturasProvider.future),
      ref.watch(productosBajoStockProvider.future),
      ref.watch(gananciaPorcentualProvider.future),
    ]);

    return BusinessMetrics(
      distribucionTipoPago: results[0] as Map<String, int>,
      ingresosPorFecha: results[1] as Map<String, double>,
      diferenciaAcumuladaCierreCaja: results[2] as double,
      conteoOrdenesYFacturas: results[3] as Map<String, int>,
      productosBajoStock: results[4] as Map<String, int>,
      gananciaPorcentual: results[5] as double,
    );
  }

  Future<void> refreshAll() async {
    ref.invalidate(distribucionTipoPagoProvider);
    ref.invalidate(ingresosPorFechaProvider);
    ref.invalidate(diferenciaAcumuladaCierreCajaProvider);
    ref.invalidate(conteoOrdenesYFacturasProvider);
    ref.invalidate(productosBajoStockProvider);
    ref.invalidate(gananciaPorcentualProvider);
    ref.invalidateSelf();
  }
}

// ============================================================================
// PRODUCT METRICS PROVIDERS (Métricas de Productos)
// ============================================================================

/// Provider para productos más vendidos
@riverpod
class BestSellingProducts extends _$BestSellingProducts {
  @override
  Future<List<Producto>> build({int limit = 5}) async {
    final negocioID = ref.watch(negocioIdProvider);
    return _fetchBestSellingProducts(negocioID, limit);
  }

  Future<List<Producto>> _fetchBestSellingProducts(
    String negocioID,
    int limit,
  ) async {
    // Validar negocio
    await _getValidNegocio(negocioID);

    // Obtener productos válidos
    final productos = await _getProductosActivosDelNegocio(negocioID);
    final productosMap = {for (var p in productos) p.id: p};

    // Obtener InvoiceItem y OrderItem
    final invoiceItems = await _getInvoiceItems();
    final orderItems = await _getOrderItems();

    // Sumar ventas
    final salesByProduct = <String, num>{};
    for (var item in [...invoiceItems, ...orderItems]) {
      final productoID = item is InvoiceItem
          ? item.productoID
          : (item as OrderItem).productoID;
      if (productosMap.containsKey(productoID)) {
        salesByProduct[productoID] =
            (salesByProduct[productoID] ?? 0) +
            (item is InvoiceItem
                ? item.quantity
                : (item as OrderItem).quantity ?? 0);
      }
    }

    final sortedIds = salesByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedIds
        .take(limit)
        .map((entry) => productosMap[entry.key]!)
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final negocioID = ref.read(negocioIdProvider);
      return _fetchBestSellingProducts(negocioID, 5);
    });
  }
}

/// Provider para total de unidades vendidas por producto
@riverpod
class TotalUnitsSoldByProduct extends _$TotalUnitsSoldByProduct {
  @override
  Future<Map<String, int>> build() async {
    final negocioID = ref.watch(negocioIdProvider);
    return _fetchTotalUnitsSold(negocioID);
  }

  Future<Map<String, int>> _fetchTotalUnitsSold(String negocioID) async {
    // Validar negocio
    final negocioRequest = ModelQueries.get(
      Negocio.classType,
      NegocioModelIdentifier(id: negocioID),
    );
    final negocioResponse = await Amplify.API
        .query(request: negocioRequest)
        .response;
    final negocio = negocioResponse.data;
    if (negocio == null || negocio.isDeleted == true) {
      throw Exception("Negocio no válido o eliminado.");
    }

    // Obtener productos válidos del negocio
    final productoRequest = ModelQueries.list(
      Producto.classType,
      where: Producto.NEGOCIOID.eq(negocioID).and(Producto.ISDELETED.eq(false)),
    );
    final productoResponse = await Amplify.API
        .query(request: productoRequest)
        .response;
    final productos =
        productoResponse.data?.items.whereType<Producto>().toList() ?? [];
    final productosMap = {for (var p in productos) p.id: p};

    // Obtener InvoiceItem y OrderItem
    final invoiceItems = await _getInvoiceItems();
    final orderItems = await _getOrderItems();

    // Sumar cantidades por productoID
    final unitsSold = <String, int>{};
    for (var item in [...invoiceItems, ...orderItems]) {
      final productoID = item is InvoiceItem
          ? item.productoID
          : (item as OrderItem).productoID;
      if (productosMap.containsKey(productoID)) {
        unitsSold[productoID] =
            (unitsSold[productoID] ?? 0) +
            (item is InvoiceItem
                ? item.quantity
                : (item as OrderItem).quantity ?? 0);
      }
    }

    return unitsSold;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final negocioID = ref.read(negocioIdProvider);
      return _fetchTotalUnitsSold(negocioID);
    });
  }
}

/// Provider para productos ordenados por cantidad de facturas
@riverpod
class ProductsByInvoiceCount extends _$ProductsByInvoiceCount {
  @override
  Future<List<Producto>> build({int limit = 5}) async {
    return _fetchProductsByInvoiceCount(limit);
  }

  Future<List<Producto>> _fetchProductsByInvoiceCount(int limit) async {
    // Obtener InvoiceItem y OrderItem
    final invoiceItems = await _getInvoiceItems();
    final orderItems = await _getOrderItems();

    // Contar apariciones de cada productoID
    final invoiceCountByProduct = <String, int>{};
    for (var item in [...invoiceItems, ...orderItems]) {
      final productId = item is InvoiceItem
          ? item.productoID
          : (item as OrderItem).productoID;
      invoiceCountByProduct[productId] =
          (invoiceCountByProduct[productId] ?? 0) + 1;
    }

    // Ordenar por cantidad de facturas descendente
    final sortedProductIds =
        invoiceCountByProduct.entries
            .map((e) => {'id': e.key, 'invoiceCount': e.value})
            .toList()
          ..sort(
            (a, b) =>
                (b['invoiceCount'] as int).compareTo(a['invoiceCount'] as int),
          );

    // Tomar los top 'limit' product IDs
    final topProductIds = sortedProductIds
        .take(limit)
        .map((e) => e['id'] as String)
        .toList();

    // Recuperar detalles de los productos top
    final topProducts = <Producto>[];
    for (var id in topProductIds) {
      final productRequest = ModelQueries.get(
        Producto.classType,
        ProductoModelIdentifier(id: id),
      );
      final productResponse = await Amplify.API
          .query(request: productRequest)
          .response;
      final product = productResponse.data;
      if (product != null) {
        topProducts.add(product);
      }
    }

    return topProducts;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _fetchProductsByInvoiceCount(5);
    });
  }
}

/// Provider combinado de todas las métricas de productos
@riverpod
class ProductMetricsData extends _$ProductMetricsData {
  @override
  Future<ProductMetrics> build() async {
    final results = await Future.wait([
      ref.watch(bestSellingProductsProvider.future),
      ref.watch(totalUnitsSoldByProductProvider.future),
      ref.watch(productsByInvoiceCountProvider.future),
    ]);

    return ProductMetrics(
      bestSellingProducts: results[0] as List<Producto>,
      totalUnitsSold: results[1] as Map<String, int>,
      productsByInvoiceCount: results[2] as List<Producto>,
    );
  }

  Future<void> refreshAll() async {
    ref.invalidate(bestSellingProductsProvider);
    ref.invalidate(totalUnitsSoldByProductProvider);
    ref.invalidate(productsByInvoiceCountProvider);
    ref.invalidateSelf();
  }
}

// ============================================================================
// HELPER METHODS (Métodos auxiliares)
// ============================================================================

Future<Negocio> _getValidNegocio(String negocioID) async {
  final negocioRequest = ModelQueries.get(
    Negocio.classType,
    NegocioModelIdentifier(id: negocioID),
  );
  final negocioResponse = await Amplify.API
      .query(request: negocioRequest)
      .response;
  final negocio = negocioResponse.data;
  if (negocio == null || negocio.isDeleted == true) {
    throw Exception("Negocio no válido o eliminado.");
  }
  return negocio;
}

Future<List<Producto>> _getProductosActivosDelNegocio(String negocioID) async {
  final productoRequest = ModelQueries.list(
    Producto.classType,
    where: Producto.NEGOCIOID.eq(negocioID).and(Producto.ISDELETED.eq(false)),
  );
  final response = await Amplify.API.query(request: productoRequest).response;
  return response.data?.items.whereType<Producto>().toList() ?? [];
}

Future<List<InvoiceItem>> _getInvoiceItems() async {
  final request = ModelQueries.list(InvoiceItem.classType);
  final response = await Amplify.API.query(request: request).response;
  return response.data?.items.whereType<InvoiceItem>().toList() ?? [];
}

Future<List<OrderItem>> _getOrderItems() async {
  final request = ModelQueries.list(OrderItem.classType);
  final response = await Amplify.API.query(request: request).response;
  return response.data?.items.whereType<OrderItem>().toList() ?? [];
}
 */