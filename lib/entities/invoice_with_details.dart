import 'package:compaexpress/models/ModelProvider.dart';

class InvoiceWithDetails {
  final Invoice invoice;
  final List<InvoiceDetailsWithProductsAndPrice> invoiceDetails;

  InvoiceWithDetails({
    required this.invoice,
    required this.invoiceDetails,
  });
}

class InvoiceDetailsWithProductsAndPrice {
  final InvoiceItem invoiceItem;
  final ProductoPrecios precios;
  final Producto productos;

  InvoiceDetailsWithProductsAndPrice({
    required this.invoiceItem,
    required this.precios,
    required this.productos,
  });
}