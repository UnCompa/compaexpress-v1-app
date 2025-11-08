import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/utils/format_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AdminCompraDetailPage extends StatefulWidget {
  final String compraID;

  const AdminCompraDetailPage({super.key, required this.compraID});

  @override
  _AdminCompraDetailPageState createState() => _AdminCompraDetailPageState();
}

class _AdminCompraDetailPageState extends State<AdminCompraDetailPage> {
  CompraProveedor? _compra;
  Proveedor? _proveedor;
  List<CompraItemDetailModel> _items = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCompraDetails();
  }

  Future<void> _loadCompraDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await _loadCompra();
      await _loadProveedor();
      await _loadItems();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error al cargar los detalles: $e';
      });
    }
  }

  Future<void> _loadCompra() async {
    final request = ModelQueries.get(
      CompraProveedor.classType,
      CompraProveedorModelIdentifier(id: widget.compraID),
    );
    final response = await Amplify.API.query(request: request).response;

    if (response.data == null) {
      throw Exception('Compra no encontrada');
    }

    _compra = response.data!;
  }

  Future<void> _loadProveedor() async {
    if (_compra?.proveedorID == null) return;

    final request = ModelQueries.get(
      Proveedor.classType,
      ProveedorModelIdentifier(id: _compra!.proveedorID),
    );
    final response = await Amplify.API.query(request: request).response;
    _proveedor = response.data;
  }

  Future<void> _loadItems() async {
    final request = ModelQueries.list(
      CompraItem.classType,
      where: CompraItem.COMPRAID.eq(widget.compraID),
    );
    final response = await Amplify.API.query(request: request).response;
    final items = response.data?.items ?? [];

    List<CompraItemDetailModel> itemsWithProducts = [];

    for (final item in items.whereType<CompraItem>()) {
      // Cargar información del producto
      final productRequest = ModelQueries.get(
        Producto.classType,
        ProductoModelIdentifier(id: item.productoID),
      );
      final productResponse = await Amplify.API
          .query(request: productRequest)
          .response;

      itemsWithProducts.add(
        CompraItemDetailModel(compraItem: item, producto: productResponse.data),
      );
    }

    _items = itemsWithProducts
      ..sort(
        (a, b) =>
            (a.producto?.nombre ?? '').compareTo(b.producto?.nombre ?? ''),
      );
  }

  Future<void> _showDeleteConfirmation() async {
    final totalItems = _items.fold(
      0,
      (sum, item) => sum + item.compraItem.cantidad,
    );

    bool isDeleteEnable = false; // Estado local para el diálogo

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red[700], size: 28),
              const SizedBox(width: 8),
              const Expanded(child: Text('Confirmar Eliminación')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Está seguro de que desea eliminar esta compra?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Consecuencias:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Se revertirá el stock de ${_items.length} productos',
                    ),
                    Text('• Se eliminarán $totalItems unidades del inventario'),
                    Text(
                      '• Total de compra: \$${_compra?.totalCompra.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '⚠️ Esta acción no se puede deshacer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Escriba "ELIMINAR" para confirmar:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) {
                  setState(() {
                    isDeleteEnable = value == "ELIMINAR";
                  });
                },
                decoration: InputDecoration(
                  hintText: 'ELIMINAR',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.keyboard, color: Colors.red[700]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isDeleteEnable
                  ? () => Navigator.of(context).pop(true)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDeleteEnable
                    ? Colors.red[700]
                    : Colors.red[100],
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar Compra'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      await _deleteCompra();
    }
  }

  Future<void> _deleteCompra() async {
    if (_compra == null) return;

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.blue[700]),
            const SizedBox(height: 16),
            const Text('Eliminando compra...'),
            const Text(
              'Esto puede tomar unos momentos',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    try {
      // 1. Primero revertir el stock de todos los productos
      await _revertirStockProductos();

      // 2. Eliminar todos los items de compra
      await _eliminarItemsCompra();

      // 3. Marcar la compra como eliminada (soft delete) o eliminarla completamente
      await _eliminarCompraProveedor();

      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Compra eliminada exitosamente'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error al eliminar: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _revertirStockProductos() async {
    for (final item in _items) {
      if (item.producto == null) continue;

      try {
        // Obtener el producto actual para tener el stock más reciente
        final request = ModelQueries.get(
          Producto.classType,
          ProductoModelIdentifier(id: item.producto!.id),
        );
        final response = await Amplify.API.query(request: request).response;
        final productoActual = response.data;

        if (productoActual != null) {
          // Restar la cantidad comprada del stock actual
          final nuevoStock = productoActual.stock - item.compraItem.cantidad;

          // Validar que el stock no quede negativo
          if (nuevoStock < 0) {
            throw Exception(
              'No se puede eliminar la compra: El producto "${productoActual.nombre}" '
              'quedaría con stock negativo ($nuevoStock). '
              'Stock actual: ${productoActual.stock}, '
              'Cantidad a restar: ${item.compraItem.cantidad}',
            );
          }

          // Actualizar el producto con el nuevo stock
          final productoActualizado = productoActual.copyWith(
            stock: nuevoStock,
            updatedAt: TemporalDateTime.now(),
          );

          final updateRequest = ModelMutations.update(productoActualizado);
          final updateResponse = await Amplify.API
              .mutate(request: updateRequest)
              .response;

          if (updateResponse.data == null) {
            throw Exception(
              'Error al actualizar stock del producto: ${productoActual.nombre}',
            );
          }
        } else {
          throw Exception('Producto no encontrado: ${item.producto!.nombre}');
        }
      } catch (e) {
        throw Exception(
          'Error al revertir stock del producto "${item.producto!.nombre}": $e',
        );
      }
    }
  }

  Future<void> _eliminarItemsCompra() async {
    for (final item in _items) {
      try {
        final compraActualizada = item.compraItem.copyWith(
          isDeleted: true,
          updatedAt: TemporalDateTime.now(),
        );
        final deleteRequest = ModelMutations.update(compraActualizada);
        final deleteResponse = await Amplify.API
            .mutate(request: deleteRequest)
            .response;

        if (deleteResponse.errors.isNotEmpty) {
          throw Exception(
            'Error al eliminar item: ${deleteResponse.errors.first.message}',
          );
        }
      } catch (e) {
        throw Exception('Error al eliminar item de compra: $e');
      }
    }
  }

  Future<void> _eliminarCompraProveedor() async {
    try {
      // Opción 1: Soft delete (recomendado para auditoría)
      final compraActualizada = _compra!.copyWith(
        isDeleted: true,
        updatedAt: TemporalDateTime.now(),
      );

      final updateRequest = ModelMutations.update(compraActualizada);
      final updateResponse = await Amplify.API
          .mutate(request: updateRequest)
          .response;

      if (updateResponse.data == null) {
        // Si no tienes soft delete, usar hard delete
        final deleteRequest = ModelMutations.delete(_compra!);
        final deleteResponse = await Amplify.API
            .mutate(request: deleteRequest)
            .response;

        if (deleteResponse.errors.isNotEmpty) {
          throw Exception(
            'Error al eliminar compra: ${deleteResponse.errors.first.message}',
          );
        }
      }
    } catch (e) {
      throw Exception('Error al eliminar compra principal: $e');
    }
  }

  void _shareCompra() {
    final compraInfo = _generateCompraText();
    Clipboard.setData(ClipboardData(text: compraInfo));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Información copiada al portapapeles'),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _generateCompraText() {
    if (_compra == null) return '';

    final buffer = StringBuffer();
    buffer.writeln('=== DETALLE DE COMPRA ===');
    buffer.writeln(
      'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(_compra!.fechaCompra.getDateTimeInUtc())}',
    );
    buffer.writeln('Proveedor: ${_proveedor?.nombre ?? 'N/A'}');
    buffer.writeln('Total: \$${_compra!.totalCompra.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('PRODUCTOS:');

    for (final item in _items) {
      buffer.writeln('• ${item.producto?.nombre ?? 'N/A'}');
      buffer.writeln('  Cantidad: ${item.compraItem.cantidad}');
      buffer.writeln(
        '  Precio: \$${item.compraItem.precioUnitario.toStringAsFixed(2)}',
      );
      buffer.writeln(
        '  Subtotal: \$${item.compraItem.subtotal.toStringAsFixed(2)}',
      );
      buffer.writeln('');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Compra'),
        elevation: 0,
        actions: [
          if (!_isLoading && !_hasError) ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareCompra,
              tooltip: 'Compartir',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    _showDeleteConfirmation();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      const Text('Eliminar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue[700]),
            const SizedBox(height: 16),
            Text(
              'Cargando detalles...',
              style: TextStyle(color: Colors.blue[700]),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCompraDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCompraDetails,
      color: Colors.blue[700],
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompraHeader(),
            const SizedBox(height: 16),
            _buildProveedorInfo(),
            const SizedBox(height: 16),
            _buildItemsList(),
            const SizedBox(height: 16),
            _buildSummary(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCompraHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COMPRA',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '#${widget.compraID.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                _compra != null
                    ? FormatDate.formatFecha(
                        _compra!.fechaCompra.getDateTimeInUtc(),
                      )
                    : 'Fecha no disponible',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProveedorInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.business, color: Colors.blue[700]),
                ),
                const SizedBox(width: 12),
                Text(
                  'Información del Proveedor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.store,
              'Nombre',
              _proveedor?.nombre ?? 'No disponible',
            ),
            if (_proveedor?.direccion.isNotEmpty == true)
              _buildInfoRow(
                Icons.location_city,
                'Dirección',
                _proveedor!.direccion,
              ),
            if (_proveedor?.ciudad.isNotEmpty == true)
              _buildInfoRow(Icons.location_on, 'Ciudad', _proveedor!.ciudad),
            if (_proveedor?.direccion.isNotEmpty == true)
              _buildInfoRow(
                Icons.location_on,
                'Dirección',
                _proveedor!.direccion,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.inventory, color: Colors.blue[700]),
                ),
                const SizedBox(width: 12),
                Text(
                  'Productos (${_items.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildProductItem(item),
                  if (index < _items.length - 1)
                    Divider(color: Colors.grey[200], height: 24),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(CompraItemDetailModel item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[25],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: Colors.blue[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.producto?.nombre ?? 'Producto no disponible',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    if (item.producto?.barCode.isNotEmpty == true)
                      Text(
                        'Código: ${item.producto!.barCode}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProductDetail(
                  'Cantidad',
                  '${item.compraItem.cantidad}',
                  Icons.confirmation_number,
                ),
              ),
              Expanded(
                child: _buildProductDetail(
                  'Precio Unit.',
                  '\$${item.compraItem.precioUnitario.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
              ),
              Expanded(
                child: _buildProductDetail(
                  'Subtotal',
                  '\$${item.compraItem.subtotal.toStringAsFixed(2)}',
                  Icons.calculate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetail(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.blue[600]),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final totalItems = _items.fold(
      0,
      (sum, item) => sum + item.compraItem.cantidad,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'RESUMEN DE COMPRA',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Productos',
                '${_items.length}',
                Icons.inventory,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildSummaryItem(
                'Unidades',
                '$totalItems',
                Icons.confirmation_number,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildSummaryItem(
                'Total',
                '\$${_compra?.totalCompra.toStringAsFixed(2) ?? '0.00'}',
                Icons.attach_money,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class CompraItemDetailModel {
  final CompraItem compraItem;
  final Producto? producto;

  CompraItemDetailModel({required this.compraItem, this.producto});
}
