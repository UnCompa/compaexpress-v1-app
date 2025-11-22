import 'package:compaexpress/models/ModelProvider.dart';

class OrderItemWithProduct {
  final OrderItem orderItem;
  final Producto? producto;
  final List<OrderPayment?>? payments;
  final List<DocumentMetadata?>? metadata;

  OrderItemWithProduct({required this.orderItem, this.producto, this.metadata, this.payments});
}
