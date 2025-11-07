/// Tipos de diseño disponibles para impresión de facturas
enum InvoiceDesign {
  classic('Clásico', 'Diseño tradicional con detalles completos'),
  compact('Compacto', 'Diseño minimalista que ahorra papel'),
  detailed('Detallado', 'Incluye toda la información posible'),
  modern('Moderno', 'Diseño contemporáneo con formato limpio'),
  simple('Simple', 'Recibo básico sin detalles de productos');

  final String nombre;
  final String descripcion;

  const InvoiceDesign(this.nombre, this.descripcion);

  /// Obtiene el diseño desde un string
  static InvoiceDesign fromString(String value) {
    return InvoiceDesign.values.firstWhere(
      (design) => design.name == value,
      orElse: () => InvoiceDesign.classic,
    );
  }
}
