import 'package:compaexpress/models/ModelProvider.dart';

class OrderItemData {
  final Producto producto;
  final ProductoPrecios? precio;
  final int quantity;
  final int tax;

  OrderItemData({
    required this.producto,
    this.precio,
    required this.quantity,
    required this.tax,
  });

  double get subtotal => precio != null ? precio!.precio * quantity : 0.0;
  double get total => subtotal + (subtotal * tax / 100);

  OrderItemData copyWith({
    Producto? producto,
    ProductoPrecios? precio,
    int? quantity,
    int? tax,
  }) {
    return OrderItemData(
      producto: producto ?? this.producto,
      precio: precio ?? this.precio,
      quantity: quantity ?? this.quantity,
      tax: tax ?? this.tax,
    );
  }
}

