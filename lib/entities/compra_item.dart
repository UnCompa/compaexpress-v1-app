import 'package:flutter/material.dart';

class CompraItemModel {
  String productoID;
  String productoNombre;
  String? barCode;
  int? stockActual;
  int cantidad;
  double precioUnitario;
  double subtotal;
  TextEditingController cantidadController; // Nuevo controlador

  CompraItemModel({
    required this.productoID,
    required this.productoNombre,
    this.barCode,
    this.stockActual,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  }) : cantidadController = TextEditingController(text: cantidad.toString());

  void updateSubtotal() {
    subtotal = cantidad * precioUnitario;
  }

  // Método para liberar el controlador
  void dispose() {
    cantidadController.dispose();
  }
}
