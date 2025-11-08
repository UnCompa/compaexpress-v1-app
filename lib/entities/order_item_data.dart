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

  /// 🔹 Convierte la clase a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'producto': producto.toJson(),
      'precio': precio?.toJson(),
      'quantity': quantity,
      'tax': tax,
    };
  }

  /// 🔹 Crea una instancia desde un mapa JSON
  factory OrderItemData.fromJson(Map<String, dynamic> json) {
    return OrderItemData(
      producto: Producto.fromJson(Map<String, dynamic>.from(json['producto'])),
      precio: json['precio'] != null
          ? ProductoPrecios.fromJson(Map<String, dynamic>.from(json['precio']))
          : null,
      quantity: json['quantity'] ?? 0,
      tax: json['tax'] ?? 0,
    );
  }
}
