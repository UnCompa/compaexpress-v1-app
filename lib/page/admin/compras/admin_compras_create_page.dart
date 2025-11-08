import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/entities/compra_item.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AdminComprasCreatePage extends StatefulWidget {
  final String negocioID;

  const AdminComprasCreatePage({super.key, required this.negocioID});

  @override
  _AdminComprasCreatePageState createState() => _AdminComprasCreatePageState();
}

class _AdminComprasCreatePageState extends State<AdminComprasCreatePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProveedorId;
  Proveedor? _selectedProveedor;
  DateTime _fechaCompra = DateTime.now();
  List<Proveedor> _proveedores = [];
  List<Producto> _productos = [];
  List<Producto> _productosFiltrados = [];
  final List<CompraItemModel> _itemsCompra = [];
  bool _isLoadingProveedores = false;
  bool _isLoadingProductos = false;
  bool _isSaving = false;
  final _searchController = TextEditingController();
  final _notasController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProveedores();
    _loadProductos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notasController.dispose();
    _tabController.dispose();
    for (var item in _itemsCompra) {
      item.dispose(); // Liberar los controladores de cada item
    }
    super.dispose();
  }

  Future<void> _loadProveedores() async {
    setState(() => _isLoadingProveedores = true);
    try {
      final request = ModelQueries.list(
        Proveedor.classType,
        where: Proveedor.NEGOCIOID
            .eq(widget.negocioID)
            .and(Proveedor.ISDELETED.eq(false)),
      );
      final response = await Amplify.API.query(request: request).response;
      final proveedores = response.data?.items ?? [];
      setState(() {
        _proveedores = proveedores.whereType<Proveedor>().toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
        _isLoadingProveedores = false;
      });
    } catch (e) {
      setState(() => _isLoadingProveedores = false);
      _showError('Error al cargar proveedores: $e');
    }
  }

  Future<void> _loadProductos() async {
    setState(() => _isLoadingProductos = true);
    try {
      final request = ModelQueries.list(
        Producto.classType,
        where: Producto.NEGOCIOID
            .eq(widget.negocioID)
            .and(Producto.ISDELETED.eq(false)),
      );
      final response = await Amplify.API.query(request: request).response;
      final productos = response.data?.items ?? [];
      setState(() {
        _productos = productos.whereType<Producto>().toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
        _productosFiltrados = List.from(_productos);
        _isLoadingProductos = false;
      });
    } catch (e) {
      setState(() => _isLoadingProductos = false);
      _showError('Error al cargar productos: $e');
    }
  }

  void _filterProductosByProveedor() {
    setState(() {
      if (_selectedProveedorId != null) {
        _productosFiltrados = _productos
            .where((p) => p.proveedorID == _selectedProveedorId)
            .toList();
      } else {
        _productosFiltrados = List.from(_productos);
      }
      _searchController.clear();
    });
  }

  void _searchProductos(String query) {
    setState(() {
      if (query.isEmpty) {
        _productosFiltrados = _selectedProveedorId != null
            ? _productos
                  .where((p) => p.proveedorID == _selectedProveedorId)
                  .toList()
            : List.from(_productos);
      } else {
        _productosFiltrados =
            (_selectedProveedorId != null
                    ? _productos.where(
                        (p) => p.proveedorID == _selectedProveedorId,
                      )
                    : _productos)
                .where(
                  (p) =>
                      p.nombre.toLowerCase().contains(query.toLowerCase()) ||
                      p.barCode.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  void _addProductoToCompra(Producto producto) {
    final existingIndex = _itemsCompra.indexWhere(
      (item) => item.productoID == producto.id,
    );

    if (existingIndex >= 0) {
      setState(() {
        _itemsCompra[existingIndex].cantidadController.text =
            (_itemsCompra[existingIndex].cantidad += 1).toString();

        _itemsCompra[existingIndex].updateSubtotal();
      });
    } else {
      setState(() {
        _itemsCompra.add(
          CompraItemModel(
            productoID: producto.id,
            productoNombre: producto.nombre,
            barCode: producto.barCode,
            stockActual: producto.stock,
            cantidad: 1,
            precioUnitario: producto.precioCompra,
            subtotal: producto.precioCompra,
          ),
        );
      });
    }
    _showSnackBar('${producto.nombre} agregado al carrito', Colors.green);
    _tabController.animateTo(1);
  }

  void _updateItemCantidad(int index, int nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      setState(() {
        _itemsCompra[index].dispose(); // Liberar el controlador
        _itemsCompra.removeAt(index);
      });
    } else {
      setState(() {
        _itemsCompra[index].cantidad = nuevaCantidad;
        _itemsCompra[index].cantidadController.text = nuevaCantidad
            .toString(); // Actualizar el controlador
        _itemsCompra[index].updateSubtotal();
      });
    }
  }

  void _updateItemCantidadRemove(int index) {
    if (_itemsCompra[index].cantidad == 1) {
      setState(() {
        _itemsCompra[index].dispose(); // Liberar el controlador
        _itemsCompra.removeAt(index);
      });
    } else {
      setState(() {
        _itemsCompra[index].cantidad -= 1;
        _itemsCompra[index].cantidadController.text = _itemsCompra[index]
            .cantidad
            .toString();
        _itemsCompra[index].updateSubtotal();
      });
    }
  }

  void _updateItemCantidadPlus(int index) {
    setState(() {
      _itemsCompra[index].cantidad += 1;
      _itemsCompra[index].cantidadController.text = _itemsCompra[index].cantidad
          .toString(); // Actualizar el controlador
      _itemsCompra[index].updateSubtotal();
    });
  }

  void _updateItemPrecio(int index, double nuevoPrecio) {
    setState(() {
      _itemsCompra[index].precioUnitario = nuevoPrecio;
      _itemsCompra[index].updateSubtotal();
    });
  }

  void _removeItem(int index) {
    setState(() => _itemsCompra.removeAt(index));
  }

  double get _totalCompra {
    return _itemsCompra.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  int get _totalItems {
    return _itemsCompra.fold(0, (sum, item) => sum + item.cantidad);
  }

  Future<void> _saveCompra() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProveedorId == null) {
      _showError('Debe seleccionar un proveedor');
      return;
    }
    if (_itemsCompra.isEmpty) {
      _showError('Debe agregar al menos un producto');
      return;
    }

    final bool? confirm = await _showConfirmDialog();
    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      final compra = CompraProveedor(
        proveedorID: _selectedProveedorId!,
        negocioID: widget.negocioID,
        fechaCompra: TemporalDateTime(_fechaCompra),
        totalCompra: _totalCompra,
        isDeleted: false,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
      );

      final compraRequest = ModelMutations.create(compra);
      final compraResponse = await Amplify.API
          .mutate(request: compraRequest)
          .response;

      if (compraResponse.data == null) {
        throw Exception('Error al crear la compra');
      }

      final compraCreada = compraResponse.data!;

      for (final item in _itemsCompra) {
        final compraItem = CompraItem(
          compraID: compraCreada.id,
          productoID: item.productoID,
          cantidad: item.cantidad,
          precioUnitario: item.precioUnitario,
          subtotal: item.subtotal,
          isDeleted: false,
          createdAt: TemporalDateTime.now(),
          updatedAt: TemporalDateTime.now(),
        );

        final itemRequest = ModelMutations.create(compraItem);
        await Amplify.API.mutate(request: itemRequest).response;

        await _updateProductoStock(item.productoID, item.cantidad);
      }

      Navigator.of(context).pop(true);
      _showSnackBar(
        'Compra creada exitosamente. Total: \$${_totalCompra.toStringAsFixed(2)}',
        Colors.green,
      );
    } catch (e) {
      setState(() => _isSaving = false);
      _showError('Error al guardar la compra: $e');
    }
  }

  Future<void> _updateProductoStock(
    String productoID,
    int cantidadComprada,
  ) async {
    try {
      final request = ModelQueries.get(
        Producto.classType,
        ProductoModelIdentifier(id: productoID),
      );
      final response = await Amplify.API.query(request: request).response;
      final producto = response.data;

      if (producto != null) {
        final productoActualizado = producto.copyWith(
          stock: producto.stock + cantidadComprada,
          updatedAt: TemporalDateTime.now(),
        );

        final updateRequest = ModelMutations.update(productoActualizado);
        await Amplify.API.mutate(request: updateRequest).response;
      }
    } catch (e) {
      print('Error actualizando stock del producto $productoID: $e');
    }
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Proveedor: ${_selectedProveedor?.nombre ?? ""}'),
            Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_fechaCompra)}'),
            Text('Items: $_totalItems productos'),
            Text(
              'Total: '
              '\$${_totalCompra.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('¿Desea confirmar esta compra?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    _showSnackBar(message, Colors.red);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Compra'),
        elevation: 0,
        actions: [
          if (_itemsCompra.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(child: Text('$_totalItems items')),
            ),
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : TextButton.icon(
                  onPressed:
                      _itemsCompra.isEmpty || _selectedProveedorId == null
                      ? null
                      : _saveCompra,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'GUARDAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHeader(theme),
            _buildSearchBar(theme),
            Expanded(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    indicatorColor: theme.colorScheme.primary,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurface,
                    isScrollable: false,
                    tabs: const [
                      Tab(text: 'Productos'),
                      Tab(text: 'Carrito'),
                    ],
                    onTap: _selectedProveedorId == null
                        ? null // Deshabilita la interacción con las pestañas
                        : (index) {
                            setState(() {
                              _tabController.index = index;
                            });
                          },
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProductosList(theme),
                        _buildCarrito(theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_itemsCompra.isNotEmpty) _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Proveedor *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              prefixIcon: Icon(
                Icons.business,
                color: theme.colorScheme.primary,
              ),
            ),
            value: _selectedProveedorId,
            autofocus: true,
            items: _proveedores
                .map(
                  (p) => DropdownMenuItem(value: p.id, child: Text(p.nombre)),
                )
                .toList(),
            onChanged: _isLoadingProveedores
                ? null
                : (value) {
                    setState(() {
                      _selectedProveedorId = value;
                      _selectedProveedor = _proveedores.firstWhere(
                        (p) => p.id == value,
                      );
                    });
                    _filterProductosByProveedor();
                  },
            validator: (value) =>
                value == null ? 'Seleccione un proveedor' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _fechaCompra,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: theme.colorScheme.primary,
                              onPrimary: Colors.white,
                              onSurface: theme.colorScheme.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) setState(() => _fechaCompra = date);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha de Compra',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(_fechaCompra)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '\$${_totalCompra.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        enabled:
            _selectedProveedorId != null, // Deshabilita si no hay proveedor
        decoration: InputDecoration(
          labelText: 'Buscar productos por nombre o código',
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
          suffixIcon:
              _searchController.text.isNotEmpty && _selectedProveedorId != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchProductos('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: _selectedProveedorId == null
              ? theme.colorScheme.surface.withValues(alpha: 0.2)
              : theme.colorScheme.surface,
          hintText: _selectedProveedorId == null
              ? 'Seleccione un proveedor primero'
              : null,
        ),
        onChanged: _selectedProveedorId != null ? _searchProductos : null,
      ),
    );
  }

  Widget _buildProductosList(ThemeData theme) {
    if (_selectedProveedorId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Por favor, seleccione un proveedor para ver los productos.',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.inventory, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Productos (${_productosFiltrados.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingProductos
              ? Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                )
              : _productosFiltrados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron productos',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _productosFiltrados.length,
                  itemBuilder: (context, index) {
                    final producto = _productosFiltrados[index];
                    final isInCart = _itemsCompra.any(
                      (item) => item.productoID == producto.id,
                    );

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: isInCart
                            ? BorderSide(color: Colors.green, width: 2)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          producto.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Código: ${producto.barCode}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'Stock actual: ${producto.stock}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'Precio compra: \$${producto.precioCompra.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // En _buildProductosList, modifica el trailing
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: isInCart
                                ? Colors.green[600]
                                : theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isInCart
                                      ? Icons.check
                                      : Icons.add_shopping_cart,
                                  color: Colors.white,
                                ),
                                onPressed: () => _addProductoToCompra(producto),
                              ),
                              if (isInCart)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    'x${_itemsCompra.firstWhere((item) => item.productoID == producto.id).cantidad}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        onTap: () => _addProductoToCompra(producto),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCarrito(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_cart, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Carrito (${_itemsCompra.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (_itemsCompra.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (var item in _itemsCompra) {
                        item.dispose();
                      }
                      _itemsCompra.clear();
                    });
                    _showSnackBar('Carrito vaciado', theme.colorScheme.primary);
                  },
                  child: const Text(
                    'Vaciar carrito',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _itemsCompra.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Carrito vacío',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega productos desde la lista',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _itemsCompra.length,
                  itemBuilder: (context, index) {
                    final item = _itemsCompra[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.productoNombre,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeItem(index),
                                ),
                              ],
                            ),
                            Text(
                              'Código: ${item.barCode}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Stock actual: ${item.stockActual}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'Cant: ',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.remove,
                                    color: theme.colorScheme.primary,
                                  ),
                                  onPressed: () =>
                                      _updateItemCantidadRemove(index),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    key: ValueKey(item.productoID),
                                    controller: item.cantidadController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                    ),
                                    onChanged: (value) {
                                      final cantidad = int.tryParse(value) ?? 0;
                                      _updateItemCantidad(index, cantidad);
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    color: theme.colorScheme.primary,
                                  ),
                                  onPressed: () =>
                                      _updateItemCantidadPlus(index),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'Precio: \$',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.precioUnitario
                                        .toStringAsFixed(2),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}'),
                                      ),
                                    ],
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                    ),
                                    onChanged: (value) {
                                      final precio =
                                          double.tryParse(value) ?? 0.0;
                                      _updateItemPrecio(index, precio);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Subtotal:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '\$${item.subtotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_totalItems productos',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 14,
                ),
              ),
              Text(
                'Total: \$${_totalCompra.toStringAsFixed(2)}',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _isSaving || _selectedProveedorId == null
                ? null
                : _saveCompra,
            icon: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Guardando...' : 'Guardar Compra'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
