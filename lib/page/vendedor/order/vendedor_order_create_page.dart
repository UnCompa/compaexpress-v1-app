import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/entities/order_item_data.dart';
import 'package:compaexpress/entities/payment_option.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/vendedor/invoice/vendedor_invoice_create_page.dart';
import 'package:compaexpress/services/caja_service.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/services/order_service.dart';
import 'package:compaexpress/utils/product_quick_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class VendedorOrderCreatePage extends StatefulWidget {
  const VendedorOrderCreatePage({super.key});

  @override
  State<VendedorOrderCreatePage> createState() =>
      _VendedorOrderCreatePageState();
}

class _VendedorOrderCreatePageState extends State<VendedorOrderCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _orderNumberController = TextEditingController();
  final _scrollController = ScrollController();

  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'Pagada';
  bool isPaymentSectionExpanded = true;
  final List<PaymentOption> _paymentOptions = TiposPago.values
      .map((tipo) => PaymentOption(tipo: tipo))
      .toList();
  List<Producto> _productos = [];
  final Map<String, List<ProductoPrecios>> _productoPrecios = {};
  final List<OrderItemData> _orderItems = [];
  bool _isLoading = false;
  bool _isLoadingProducts = false;
  bool _isLoadingCaja = false;
  Caja? _caja;

  // Lista de denominaciones disponibles para pago
  final List<DenominacionData> _denominacionesPago = [];

  final List<String> _statusOptions = ['Pendiente', 'Pagada', 'Cancelada'];

  bool _productosLoaded = false;
  bool _cajaLoaded = false;

  @override
  void initState() {
    super.initState();
    _generateOrderNumber();
    _loadInitialData();
  }

  @override
  void dispose() {
    _orderNumberController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingProducts = true;
      _isLoadingCaja = true;
    });

    // Ejecutar ambas cargas en paralelo
    await Future.wait([_loadProducts(), _loadCajaData()]);
  }

  Future<void> _loadCajaData() async {
    if (_cajaLoaded) return;

    setState(() => _isLoadingCaja = true);
    try {
      final caja = await CajaService.getCurrentCaja();
      setState(() {
        _caja = caja;
        _cajaLoaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos de caja: $e')),
      );
    } finally {
      setState(() => _isLoadingCaja = false);
    }
  }

  void updateDenominacionPago(int index, int change) {
    final denominacion = _denominacionesPago[index];
    final newCantidad = denominacion.cantidad + change;

    if (newCantidad < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad no puede ser negativa')),
      );
      return;
    }

    setState(() {
      _denominacionesPago[index] = denominacion.copyWith(cantidad: newCantidad);
    });
    _validatePagoVsOrden();
  }

  void _addOrderItemSmart(Producto producto, ProductoPrecios? precio) {
    // Buscar si el producto ya existe en la lista
    final existingIndex = _orderItems.indexWhere(
      (item) =>
          item.producto.id == producto.id && item.precio?.id == precio?.id,
    );

    if (existingIndex != -1) {
      // Si existe, incrementar cantidad
      final existingItem = _orderItems[existingIndex];
      final newQuantity = existingItem.quantity + 1;

      // Validar stock antes de incrementar
      final quantityWithPrice = precio != null
          ? newQuantity * precio.quantity
          : newQuantity;

      if (quantityWithPrice > producto.stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stock insuficiente. Solo hay ${producto.stock} unidades disponibles',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _orderItems[existingIndex] = existingItem.copyWith(
          quantity: newQuantity,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cantidad actualizada para ${producto.nombre}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Si no existe, agregar nuevo item
      setState(() {
        _orderItems.add(
          OrderItemData(
            producto: producto,
            precio: precio,
            quantity: 1,
            tax: 0,
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${producto.nombre} agregado a la orden'),
          backgroundColor: Colors.blue,
        ),
      );
    }

    _validatePagoVsOrden();
  }

  void _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = DateFormat('yyyyMMddHHmm').format(now);
    _orderNumberController.text = 'ORD-$timestamp';
  }

  Future<void> _loadProducts() async {
    if (_productosLoaded) return; // Evitar recargas innecesarias

    setState(() => _isLoadingProducts = true);
    try {
      final userData = await NegocioService.getCurrentUserInfo();

      // OPTIMIZACIÓN: Cargar productos con límite inicial
      final request = ModelQueries.list(
        Producto.classType,
        where: Producto.NEGOCIOID
            .eq(userData.negocioId)
            .and(Producto.STOCK.gt(0)),
        limit: 50, // Cargar solo los primeros 50 productos
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final productos = response.data!.items.whereType<Producto>().toList();

        // OPTIMIZACIÓN: Cargar precios solo cuando sea necesario (lazy loading)
        setState(() {
          _productos = productos;
          _productosLoaded = true;
        });

        // Cargar precios de forma asíncrona en segundo plano
        _loadPreciosAsync(productos);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar productos: $e')));
    } finally {
      setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _loadPreciosAsync(List<Producto> productos) async {
    final preciosMap = <String, List<ProductoPrecios>>{};

    // Cargar precios en lotes pequeños para no bloquear la UI
    for (int i = 0; i < productos.length; i += 5) {
      final batch = productos.skip(i).take(5);

      await Future.wait(
        batch.map((producto) async {
          try {
            final precioRequest = ModelQueries.list(
              ProductoPrecios.classType,
              where: ProductoPrecios.PRODUCTOID
                  .eq(producto.id)
                  .and(ProductoPrecios.ISDELETED.eq(false)),
            );
            final precioResponse = await Amplify.API
                .query(request: precioRequest)
                .response;

            preciosMap[producto.id] =
                precioResponse.data?.items
                    .whereType<ProductoPrecios>()
                    .toList() ??
                [];
          } catch (e) {
            debugPrint('Error cargando precios para ${producto.id}: $e');
          }
        }),
      );

      // Actualizar UI cada lote
      if (mounted) {
        setState(() {
          _productoPrecios.addAll(preciosMap);
        });
      }

      // Pequeña pausa para no sobrecargar
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void _updateItemQuantity(int index, int change) {
    final item = _orderItems[index];
    final newQuantity = item.quantity + change;

    if (newQuantity <= 0) {
      _removeOrderItem(index);
      return;
    }

    // Validar stock
    final quantityWithPrice = item.precio != null
        ? newQuantity * item.precio!.quantity
        : newQuantity;

    if (quantityWithPrice > item.producto.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock insuficiente. Solo hay ${item.producto.stock} unidades disponibles',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _orderItems[index] = item.copyWith(quantity: newQuantity);
    });
    _validatePagoVsOrden();
  }

  Widget _buildCantidadFieldWithButtons(dynamic item, int index) {
    return Row(
      children: [
        // Botón decrementar
        IconButton(
          onPressed: () => _updateItemQuantity(index, -1),
          icon: Icon(Icons.remove_circle_outline),
          color: Colors.blue[800], // Cambiado a azul oscuro
          constraints: BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ), // Ligeramente más grande
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue[50], // Fondo azul claro
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Bordes más redondeados
            ),
          ),
        ),

        // Espaciado
        SizedBox(width: 8),

        // Campo de cantidad
        Expanded(
          child: TextFormField(
            key: ValueKey('${index}_${item.quantity}'),
            initialValue: item.quantity.toString(),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.blue[50], // Fondo azul claro
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  12,
                ), // Bordes más redondeados
                borderSide: BorderSide(color: Colors.blue[300]!), // Borde azul
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[300]!), // Borde azul
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blue[600]!,
                  width: 2,
                ), // Borde azul más oscuro al enfocar
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ), // Más padding
              isDense: true,
            ),
            style: TextStyle(color: Colors.blue[900]), // Texto azul oscuro
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              final quantity = int.tryParse(value) ?? 1;
              final change = quantity - item.quantity;
              if (change != 0) {
                _updateItemQuantity(index, change.toString() as int);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              final quantity = int.tryParse(value);
              if (quantity == null || quantity <= 0) return 'Inválido';

              final quantityWithPrice = item.precio != null
                  ? quantity * item.precio.quantity
                  : quantity;
              if (quantityWithPrice > item.producto.stock) {
                return 'Stock insuficiente';
              }
              return null;
            },
          ),
        ),

        // Espaciado
        SizedBox(width: 8),

        // Botón incrementar
        IconButton(
          onPressed: () => _updateItemQuantity(index, 1),
          icon: Icon(Icons.add_circle_outline),
          color: Colors.blue[800], // Cambiado a azul oscuro
          constraints: BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ), // Ligeramente más grande
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue[50], // Fondo azul claro
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Bordes más redondeados
            ),
          ),
        ),
      ],
    );
  }

  double _calculateTotal() {
    return _orderItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double _getCambio() {
    final total = _calculateTotal();
    final totalPagado = _getTotalPagos();
    return totalPagado - total;
  }

  bool _validatePagoVsOrden() {
    final total = _calculateTotal();
    final totalPagado = _getTotalPagos();
    return totalPagado >= total;
  }

  void _removeOrderItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
    _validatePagoVsOrden();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<String?> _saveOrder() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final totalOrden = _calculateTotal();
      final totalPago = _getTotalPagos();
      final cambio = _getCambio();
      await OrderService.saveOrder(
        context,
        _formKey,
        _orderItems,
        totalOrden,
        totalPago,
        cambio,
        _orderNumberController.text,
        _selectedStatus,
        _selectedDate,
        _paymentOptions,
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
    return null;
  }

  Future<void> _scanBarcode() async {
    try {
      final result = await SimpleBarcodeScanner.scanBarcode(
        context,
        barcodeAppBar: const BarcodeAppBar(
          appBarTitle: 'Escanear Código de Barras',
          centerTitle: false,
          enableBackButton: true,
          backButtonIcon: Icon(Icons.arrow_back_ios),
        ),
        isShowFlashIcon: true,
        delayMillis: 2000,
        cameraFace: CameraFace.front,
      );
      if (result != null && result != '-1') {
        await _getProductByBarCode(result);
      }
    } catch (e) {
      debugPrint('Error al escanear: $e');
    }
  }

  Future<void> _getProductByBarCode(String barCode) async {
    try {
      final request = ModelQueries.list(
        Producto.classType,
        where: Producto.BARCODE.eq(barCode),
      );
      final response = await Amplify.API.query(request: request).response;
      final productos = response.data?.items.whereType<Producto>().toList();

      if (productos != null && productos.isNotEmpty) {
        final producto = productos.first;

        if (producto.stock <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto ${producto.nombre} sin stock'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Cargar precios si no están cargados
        if (!_productoPrecios.containsKey(producto.id)) {
          await _loadPreciosForProduct(producto.id);
        }

        final precios = _productoPrecios[producto.id] ?? [];
        final precioSeleccionado = precios.isNotEmpty ? precios.first : null;

        // Usar el método mejorado que maneja duplicados
        _addOrderItemSmart(producto, precioSeleccionado);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto no encontrado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener producto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadPreciosForProduct(String productoId) async {
    try {
      final precioRequest = ModelQueries.list(
        ProductoPrecios.classType,
        where: ProductoPrecios.PRODUCTOID
            .eq(productoId)
            .and(ProductoPrecios.ISDELETED.eq(false)),
      );
      final precioResponse = await Amplify.API
          .query(request: precioRequest)
          .response;

      setState(() {
        _productoPrecios[productoId] =
            precioResponse.data?.items.whereType<ProductoPrecios>().toList() ??
            [];
      });
    } catch (e) {
      debugPrint('Error cargando precios para producto $productoId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Orden'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: _validatePagoVsOrden() ? _saveOrder : null,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
        ],
      ),
      body: _isLoadingProducts || _isLoadingCaja
          ? _buildLoadingSection()
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildBasicInfoSection(),
                    const SizedBox(height: 16),
                    buildCompleteItemsSection(),
                    const SizedBox(height: 16),
                    buildTotalAndPagoSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _scanBarcode,
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            tooltip: 'Escanear código',
            child: const Icon(Icons.qr_code_scanner),
          ),
          /* const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: _addOrderItem,
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            label: const Text('Agregar Producto'),
            icon: const Icon(Icons.add),
            tooltip: 'Agregar producto',
          ), */
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      color: Colors.black.withOpacity(0.3), // Fondo semi-transparente
      child: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.blue[600], // Color azul para el indicador
              ),
              SizedBox(height: 16),
              Text(
                _isLoadingProducts
                    ? 'Cargando productos...'
                    : 'Cargando caja...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBasicInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Básica',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _orderNumberController,
              decoration: InputDecoration(
                labelText: 'Número de Orden',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Ingrese número de orden'
                  : null,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              items: _statusOptions
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget buildCompleteItemsSection() {
    return Column(
      children: [
        // Selector rápido de productos
        ProductQuickSelector(
          productos: _productos,
          productoPrecios: _productoPrecios,
          onProductSelected: (producto, orderItem) {
            _addOrderItemSmart(producto.producto, orderItem.precio);
          },
        ),
        const SizedBox(height: 16),

        buildItemsSection(),
      ],
    );
  }

  Widget buildItemsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productos Seleccionados',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    Text(
                      '${_orderItems.length} ítems',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _orderItems.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No hay productos seleccionados',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          'Usa el selector rápido de arriba o el botón +',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _orderItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) => buildOrderItemCard(index),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderItemCard(int index) {
    final item = _orderItems[index];
    final precios = _productoPrecios[item.producto.id] ?? [];

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 768;
          final isMobile = constraints.maxWidth <= 480;

          if (isDesktop) {
            return _buildDesktopLayout(item, precios, index);
          } else {
            return _buildMobileLayout(item, precios, index, isMobile);
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout(
    dynamic item,
    List<ProductoPrecios> precios,
    int index,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Producto y Precio - Lado izquierdo
        Expanded(
          flex: 4,
          child: Row(
            children: [
              Expanded(child: _buildProductoDropdown(item, index)),
              const SizedBox(width: 12),
              Expanded(child: _buildPrecioDropdown(item, precios, index)),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Cantidad e IVA - Centro
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildCantidadFieldWithButtons(item, index),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildIvaField(item, index)),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Total y acciones - Lado derecho
        Expanded(flex: 2, child: _buildTotalAndActions(item, index)),
      ],
    );
  }

  Widget _buildTotalAndActions(dynamic item, int index) {
    return Column(
      children: [
        Row(
          children: [
            _buildTotalQuantity(item),
            const SizedBox(width: 8),
            Expanded(child: _buildTotalSection(item)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _removeOrderItem(index),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red[200]!),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    dynamic item,
    List<ProductoPrecios> precios,
    int index,
    bool isMobile,
  ) {
    return Column(
      children: [
        // Primera fila: Producto
        _buildProductoDropdown(item, index),
        const SizedBox(height: 12),

        // Segunda fila: Precio
        _buildPrecioDropdown(item, precios, index),
        const SizedBox(height: 12),

        // Tercera fila: Cantidad, IVA y Total
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Expanded(flex: 2, child: _buildCantidadField(item, index)),
            Expanded(
              flex: 2,
              child: _buildCantidadFieldWithButtons(item, index),
            ),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _buildIvaField(item, index)),
          ],
        ),
        const SizedBox(height: 8),
        // Cuarte fila: Cantidad total,Total
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildTotalQuantity(item)),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _buildTotalSection(item)),
          ],
        ),
        const SizedBox(height: 8),

        // Botón de eliminar centrado
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () => _removeOrderItem(index),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Eliminar',
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductoDropdown(dynamic item, int index) {
    final selectedProducto =
        item.producto ?? (_productos.isNotEmpty ? _productos[0] : null);

    return DropdownButtonFormField<Producto>(
      value: selectedProducto,
      itemHeight: 50,
      decoration: InputDecoration(
        labelText: 'Producto',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      items: _productos.map((Producto producto) {
        return DropdownMenuItem<Producto>(
          value: producto,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${producto.nombre} - Stock: ${producto.stock}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: (Producto? producto) {
        if (producto != null) {
          final nuevosPrecios = _productoPrecios[producto.id] ?? [];
          final precioSeleccionado = nuevosPrecios.isNotEmpty
              ? nuevosPrecios[0]
              : null;
          setState(() {
            _orderItems[index] = item.copyWith(
              producto: producto,
              precio: precioSeleccionado,
            );
            _validatePagoVsOrden();
          });
        }
      },
    );
  }

  Widget _buildPrecioDropdown(
    dynamic item,
    List<ProductoPrecios> precios,
    int index,
  ) {
    return DropdownButtonFormField<ProductoPrecios>(
      value: item.precio,
      decoration: InputDecoration(
        labelText: 'Precio',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: precios
          .map(
            (ProductoPrecios precio) => DropdownMenuItem<ProductoPrecios>(
              value: precio,
              child: Text(
                '${precio.nombre}: \$${precio.precio.toStringAsFixed(2)} - Cantidad: ${precio.quantity}',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (ProductoPrecios? precio) {
        setState(() {
          _orderItems[index] = item.copyWith(precio: precio);
          _validatePagoVsOrden();
        });
      },
      validator: (ProductoPrecios? value) =>
          value == null ? 'Seleccione un precio' : null,
    );
  }

  Widget _buildCantidadField(dynamic item, int index) {
    String initialValue = item.quantity.toString();
    return TextFormField(
      key: ValueKey('${index}_${item.quantity}'),
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: 'Cantidad',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        final quantity = int.tryParse(value) ?? 1;
        final existsPrice = item.precio != null;
        final quantityWithPrice = existsPrice
            ? quantity * item.precio.quantity
            : quantity;

        if (quantityWithPrice > item.producto.stock) {
          setState(() {
            // Restablece la cantidad al valor anterior en _orderItems
            _orderItems[index] = item.copyWith(quantity: item.quantity);
          });
          /* ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Stock insuficiente, solo hay ${item.producto.stock} productos de ${item.producto.nombre}',
              ),
              backgroundColor: Colors.deepOrange,
            ),
          ); */
          return;
        }
        setState(() {
          _orderItems[index] = item.copyWith(quantity: quantity);
          _validatePagoVsOrden();
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingrese cantidad';
        }
        final quantity = int.tryParse(value);
        if (quantity == null || quantity <= 0) {
          return 'Cantidad debe ser mayor a 0';
        }
        final existsPrice = item.precio != null;
        final quantityWithPrice = existsPrice
            ? quantity * item.precio.quantity
            : quantity;
        if (quantityWithPrice > item.producto.stock) {
          return 'Stock insuficiente';
        }
        return null;
      },
    );
  }

  Widget _buildIvaField(dynamic item, int index) {
    return TextFormField(
      initialValue: item.tax.toString(),
      decoration: InputDecoration(
        labelText: 'IVA (%)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        final tax = int.tryParse(value) ?? 0;
        setState(() {
          _orderItems[index] = item.copyWith(tax: tax);
          _validatePagoVsOrden();
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingrese IVA';
        final tax = int.tryParse(value);
        if (tax == null || tax < 0) return 'IVA no válido';
        return null;
      },
    );
  }

  Widget _buildTotalSection(dynamic item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Text(
            'Total',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${item.total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalQuantity(dynamic item) {
    final quantityTotal = item.quantity * item.precio.quantity;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Text(
            'Cantidad total',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'x${quantityTotal.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTotalAndPagoSection() {
    final total = _calculateTotal();
    final totalPagado = _getTotalPagos();
    final cambio = _getCambio();
    final isValid = totalPagado >= total;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen y Pago',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Saldo inicial
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saldo en caja:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  _caja?.saldoInicial.toStringAsFixed(2) ?? '0.00',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Total de la orden
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Orden:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sección de métodos de pago
            // Agregar esta variable de estado a tu clase

            // Widget mejorado con UX colapsable y selección por tap
            Card(
              elevation: 2,
              child: Column(
                children: [
                  // Header colapsable
                  InkWell(
                    onTap: () {
                      setState(() {
                        isPaymentSectionExpanded = !isPaymentSectionExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: isPaymentSectionExpanded
                            ? BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              )
                            : BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.payment,
                            color: Colors.grey[700],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Métodos de Pago',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          // Indicador de pagos seleccionados
                          if (_getSelectedPayments().isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_getSelectedPayments().length}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          SizedBox(width: 8),
                          // Ícono de expansión
                          AnimatedRotation(
                            turns: isPaymentSectionExpanded ? 0.5 : 0,
                            duration: Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Contenido colapsable
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: isPaymentSectionExpanded ? null : 0,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 200),
                      opacity: isPaymentSectionExpanded ? 1.0 : 0.0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: [
                            SizedBox(height: 8),
                            ..._paymentOptions.map((option) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        option.seleccionado =
                                            !option.seleccionado;
                                        if (!option.seleccionado) {
                                          option.monto = 0;
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 200),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: option.seleccionado
                                            ? Colors.blue[50]
                                            : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: option.seleccionado
                                              ? Colors.blue[300]!
                                              : Colors.grey[300]!,
                                          width: option.seleccionado ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              // Ícono del método de pago
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: option.seleccionado
                                                      ? Colors.blue[100]
                                                      : Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  _getPaymentIcon(
                                                    option.tipo.name,
                                                  ),
                                                  size: 20,
                                                  color: option.seleccionado
                                                      ? Colors.blue[700]
                                                      : Colors.grey[600],
                                                ),
                                              ),
                                              SizedBox(width: 12),

                                              // Nombre del método
                                              Expanded(
                                                child: Text(
                                                  option.tipo.name,
                                                  style: TextStyle(
                                                    fontWeight:
                                                        option.seleccionado
                                                        ? FontWeight.w600
                                                        : FontWeight.w500,
                                                    fontSize: 16,
                                                    color: option.seleccionado
                                                        ? Colors.blue[800]
                                                        : Colors.grey[700],
                                                  ),
                                                ),
                                              ),

                                              // Indicador de selección
                                              AnimatedContainer(
                                                duration: Duration(
                                                  milliseconds: 200,
                                                ),
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: option.seleccionado
                                                      ? Colors.blue[600]
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: option.seleccionado
                                                        ? Colors.blue[600]!
                                                        : Colors.grey[400]!,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: option.seleccionado
                                                      ? Colors.white
                                                      : Colors.transparent,
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Campo de monto (aparece con animación)
                                          AnimatedSize(
                                            duration: Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                            child: option.seleccionado
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                      top: 12,
                                                    ),
                                                    child: TextFormField(
                                                      initialValue:
                                                          option.monto > 0
                                                          ? option.monto
                                                                .toString()
                                                          : '',
                                                      keyboardType:
                                                          TextInputType.numberWithOptions(
                                                            decimal: true,
                                                          ),
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            "Monto a pagar",
                                                        hintText: "0.00",
                                                        prefixText: "\$",
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              borderSide: BorderSide(
                                                                color: Colors
                                                                    .blue[600]!,
                                                                width: 2,
                                                              ),
                                                            ),
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 12,
                                                            ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          option.monto =
                                                              double.tryParse(
                                                                value,
                                                              ) ??
                                                              0;
                                                        });
                                                      },
                                                      validator: (value) {
                                                        if (option
                                                                .seleccionado &&
                                                            (value == null ||
                                                                value
                                                                    .isEmpty)) {
                                                          return 'El monto es requerido';
                                                        }
                                                        if (option
                                                                .seleccionado &&
                                                            (double.tryParse(
                                                                      value!,
                                                                    ) ??
                                                                    0) <=
                                                                0) {
                                                          return 'Ingrese un monto válido';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  )
                                                : SizedBox.shrink(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),

                            // Resumen rápido (solo cuando está colapsado)
                            if (!isPaymentSectionExpanded &&
                                _getSelectedPayments().isNotEmpty)
                              Container(
                                margin: EdgeInsets.only(top: 8),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green[200]!),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Pagos:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                    Text(
                                      '\$${_getTotalPagos().toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Resumen de pagos
            if (_getSelectedPayments().isNotEmpty)
              Card(
                elevation: 2,
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen de Pagos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      ..._getSelectedPayments().map((option) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(option.tipo.name),
                              Text(
                                '\$${option.monto.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      }),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Pagado:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${totalPagado.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 16),

            // Estado del pago y cambio
            Card(
              elevation: 2,
              color: isValid ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Orden:', style: TextStyle(fontSize: 14)),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pagado:', style: TextStyle(fontSize: 14)),
                        Text(
                          '\$${totalPagado.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Divider(),

                    // Estado del pago
                    if (totalPagado == total)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          SizedBox(width: 8),
                          Text(
                            'Pago Completo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      )
                    else if (totalPagado > total)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cambio:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${cambio.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Faltante:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${cambio.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Mensaje de validación
            if (!isValid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[700], size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'El pago no cubre el total de la orden',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Método auxiliar para obtener iconos según el tipo de pago
  IconData _getPaymentIcon(String paymentType) {
    switch (paymentType.toUpperCase()) {
      case 'EFECTIVO':
        return Icons.money;
      case 'TRANSFERENCIA':
        return Icons.account_balance;
      case 'TARJETA':
        return Icons.credit_card;
      case 'CHEQUE':
        return Icons.receipt_long;
      default:
        return Icons.payment;
    }
  }

  // Métodos auxiliares (mantén los que ya tienes)
  List<PaymentOption> _getSelectedPayments() {
    return _paymentOptions
        .where((option) => option.seleccionado && option.monto > 0)
        .toList();
  }

  double _getTotalPagos() {
    return _paymentOptions
        .where((option) => option.seleccionado)
        .fold(0, (total, option) => total + option.monto);
  }
}
