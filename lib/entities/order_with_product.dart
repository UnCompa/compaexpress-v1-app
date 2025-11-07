import 'package:compaexpress/models/ModelProvider.dart';

class OrderItemWithProduct {
  final OrderItem orderItem;
  final Producto? producto;

  OrderItemWithProduct({required this.orderItem, this.producto});
}
