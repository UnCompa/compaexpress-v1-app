import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';

class ProductSummaryService {
  /// Obtiene los productos más vendidos basado en la suma de 'quantity' de InvoiceItem.
  static Future<List<Producto>> getBestsProducts({
    required String negocioID,
    int limit = 5,
  }) async {
    try {
      // Validar negocio
      await _getValidNegocio(negocioID);

      // Obtener productos válidos
      final productos = await _getProductosActivosDelNegocio(negocioID);
      final productosMap = {for (var p in productos) p.id: p};

      // Obtener InvoiceItem y OrderItem
      final invoiceItems = await _getInvoiceItems();
      final orderItems = await _getOrderItems();

      // Sumar ventas
      final salesByProduct =
          <String, num>{}; // Cambiado a num para soportar double
      for (var item in [...invoiceItems, ...orderItems]) {
        final productoID = item is InvoiceItem
            ? item
                  .productoID
            : (item as OrderItem).productoID;
        if (productosMap.containsKey(productoID)) {
          salesByProduct[productoID] =
              (salesByProduct[productoID] ?? 0) + (item is InvoiceItem
            ? item
                  .quantity
            : (item as OrderItem).quantity ?? 0);
        }
      }

      final sortedIds = salesByProduct.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedIds
          .take(limit)
          .map((entry) => productosMap[entry.key]!)
          .toList();
    } catch (e) {
      throw Exception("Error al obtener productos más vendidos: $e");
    }
  }

  /// Obtiene un mapa con el total de unidades vendidas por producto.
  static Future<Map<String, int>> getTotalUnitsSold({
  required String negocioID,
}) async {
  try {
    // Validar negocio
    final negocioRequest = ModelQueries.get(
      Negocio.classType,
      NegocioModelIdentifier(id: negocioID),
    );
    final negocioResponse = await Amplify.API.query(request: negocioRequest).response;
    final negocio = negocioResponse.data;
    if (negocio == null || negocio.isDeleted == true) {
      throw Exception("Negocio no válido o eliminado.");
    }

    // Obtener productos válidos del negocio
    final productoRequest = ModelQueries.list(
      Producto.classType,
      where: Producto.NEGOCIOID.eq(negocioID).and(Producto.ISDELETED.eq(false)),
    );
    final productoResponse = await Amplify.API.query(request: productoRequest).response;
    final productos = productoResponse.data?.items.whereType<Producto>().toList() ?? [];
    final productosMap = {for (var p in productos) p.id: p};

    // Obtener InvoiceItem y OrderItem
    final invoiceItems = await _getInvoiceItems();
    final orderItems = await _getOrderItems();

    // Sumar cantidades por productoID
    final unitsSold = <String, int>{}; // Cambiado a num
    for (var item in [...invoiceItems, ...orderItems]) {
      final productoID = item is InvoiceItem
          ? item.productoID // Ajusta si el campo es diferente
          : (item as OrderItem).productoID; // Ajusta si el campo es diferente
      if (productosMap.containsKey(productoID)) {
        unitsSold[productoID] = (unitsSold[productoID] ?? 0) + (item is InvoiceItem
            ? item
                  .quantity
            : (item as OrderItem).quantity ?? 0);
      }
    }

    return unitsSold;
  } catch (e) {
    throw Exception("No se pudieron obtener las unidades vendidas: $e");
  }
}

  /// Obtiene los productos con mayor cantidad de facturas (apariciones en InvoiceItem).
  static Future<List<Producto>> getProductsByInvoiceCount({int limit = 5}) async {
    try {
      // Obtener InvoiceItem y OrderItem
      final invoiceItems = await _getInvoiceItems();
      final orderItems = await _getOrderItems();

      // Contar apariciones de cada productoID
      final invoiceCountByProduct = <String, int>{};
      for (var item in [...invoiceItems, ...orderItems]) {
        final productId = item is InvoiceItem
            ? item
                  .productoID // Ajusta si el campo es diferente
            : (item as OrderItem).productoID; // Ajusta si el campo es diferente
        invoiceCountByProduct[productId] =
            (invoiceCountByProduct[productId] ?? 0) + 1;
      }

      // Ordenar por cantidad de facturas descendente
      final sortedProductIds =
          invoiceCountByProduct.entries
              .map((e) => {'id': e.key, 'invoiceCount': e.value})
              .toList()
            ..sort(
              (a, b) => (b['invoiceCount'] as int).compareTo(
                a['invoiceCount'] as int,
              ),
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
    } catch (e) {
      throw Exception("No se encontraron datos: $e");
    }
  }

  static Future<Negocio> _getValidNegocio(String negocioID) async {
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

  static Future<List<Producto>> _getProductosActivosDelNegocio(
    String negocioID,
  ) async {
    final productoRequest = ModelQueries.list(
      Producto.classType,
      where: Producto.NEGOCIOID.eq(negocioID).and(Producto.ISDELETED.eq(false)),
    );
    final response = await Amplify.API.query(request: productoRequest).response;
    return response.data?.items.whereType<Producto>().toList() ?? [];
  }

  static Future<List<InvoiceItem>> _getInvoiceItems() async {
    final request = ModelQueries.list(InvoiceItem.classType);
    final response = await Amplify.API.query(request: request).response;
    return response.data?.items.whereType<InvoiceItem>().toList() ?? [];
  }

  static Future<List<OrderItem>> _getOrderItems() async {
    final request = ModelQueries.list(OrderItem.classType);
    final response = await Amplify.API.query(request: request).response;
    return response.data?.items.whereType<OrderItem>().toList() ?? [];
  }
}
