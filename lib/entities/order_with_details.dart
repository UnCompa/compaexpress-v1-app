import 'package:compaexpress/models/ModelProvider.dart';

/// Entidad que representa una orden con sus detalles completos
class OrderWithDetails {
  final Order order;
  final List<OrderDetailsWithProductsAndPrice> orderDetails;

  OrderWithDetails({required this.order, required this.orderDetails});
}

/// Detalle de un item de orden con su producto y precio
class OrderDetailsWithProductsAndPrice {
  final OrderItem orderItem;
  final ProductoPrecios precios;
  final Producto productos;

  OrderDetailsWithProductsAndPrice({
    required this.orderItem,
    required this.precios,
    required this.productos,
  });
}
