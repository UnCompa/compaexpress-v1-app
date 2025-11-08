import 'package:compaexpress/entities/payment_option.dart';
import 'package:compaexpress/models/ModelProvider.dart'; // Asume que incluye OrderItem-like structures

class Preorder {
  final String id; // UUID o generado para identificación única
  final String name; // Nombre descriptivo (ej. "Venta Rápida Café")
  final String description; // Descripción opcional
  final List<PreorderItem>
  orderItems; // Lista de items (similar a orderItems en saveOrder)
  final List<PaymentOption> paymentOptions; // Opciones de pago predefinidas
  final double totalOrden; // Total calculado de la orden
  final double totalPago; // Total pagado (debe >= totalOrden)
  final double cambio; // Cambio calculado
  final String orderStatus; // Estado por defecto (ej. "COMPLETADA")

  Preorder({
    required this.id,
    required this.name,
    this.description = '',
    required this.orderItems,
    required this.paymentOptions,
    required this.totalOrden,
    required this.totalPago,
    required this.cambio,
    this.orderStatus = 'COMPLETADA',
  });

  // Serialización para shared_preferences (JSON)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'orderItems': orderItems.map((item) => item.toJson()).toList(),
    'paymentOptions': paymentOptions
        .map((opt) => opt.toJson())
        .toList(),
    'totalOrden': totalOrden,
    'totalPago': totalPago,
    'cambio': cambio,
    'orderStatus': orderStatus,
  };

  factory Preorder.fromJson(Map<String, dynamic> json) => Preorder(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    orderItems: (json['orderItems'] as List)
        .map((item) => PreorderItem.fromJson(item))
        .toList(),
    paymentOptions: (json['paymentOptions'] as List)
        .map(
          (opt) => PaymentOption.fromJson(opt),
        ) // Asume fromJson en PaymentOption
        .toList(),
    totalOrden: json['totalOrden'],
    totalPago: json['totalPago'],
    cambio: json['cambio'],
    orderStatus: json['orderStatus'],
  );
}

// Sub-entidad para items (basado en orderItems de saveOrder)
class PreorderItem {
  final Producto producto; // De ModelProvider
  final int quantity; // Cantidad
  final ProductoPrecios? precio; // Precio seleccionado (de ModelProvider)
  final double tax; // Impuesto
  final double subtotal; // Subtotal
  final double total; // Total

  PreorderItem({
    required this.producto,
    required this.quantity,
    required this.precio,
    required this.tax,
    required this.subtotal,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
    'producto': producto.toJson(), // Asume Producto tiene toJson
    'quantity': quantity,
    'precio': precio?.toJson(), // Asume Precio tiene toJson
    'tax': tax,
    'subtotal': subtotal,
    'total': total,
  };

  factory PreorderItem.fromJson(Map<String, dynamic> json) => PreorderItem(
    producto: Producto.fromJson(json['producto']),
    quantity: json['quantity'],
    precio: ProductoPrecios.fromJson(json['precio']),
    tax: json['tax'],
    subtotal: json['subtotal'],
    total: json['total'],
  );
}
