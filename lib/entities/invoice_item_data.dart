import 'package:compaexpress/models/ModelProvider.dart';

class InvoiceItemData {
  final Producto producto;
  final ProductoPrecios? precio;
  final int quantity;
  final int tax;

  InvoiceItemData({
    required this.producto,
    this.precio,
    required this.quantity,
    required this.tax,
  });

  double get subtotal => precio != null ? precio!.precio * quantity : 0.0;
  double get total => subtotal + (subtotal * tax / 100);

  InvoiceItemData copyWith({
    Producto? producto,
    ProductoPrecios? precio,
    int? quantity,
    int? tax,
  }) {
    return InvoiceItemData(
      producto: producto ?? this.producto,
      precio: precio ?? this.precio,
      quantity: quantity ?? this.quantity,
      tax: tax ?? this.tax,
    );
  }
}

