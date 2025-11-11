import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/entities/invoice_item_data.dart';
import 'package:compaexpress/entities/payment_option.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/providers/products_provider.dart';
import 'package:compaexpress/services/caja_service.dart';
import 'package:compaexpress/services/invoice_service.dart';
import 'package:compaexpress/utils/barcode_listener_wrapper.dart';
import 'package:compaexpress/utils/denominaciones.dart';
import 'package:compaexpress/utils/product_quick_selector.dart';
import 'package:compaexpress/widget/client_selector.dart';
import 'package:compaexpress/widget/negocio_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
// Clase para manejar denominaciones
class DenominacionData {
  final String moneda;
  final double denominacion;
  int cantidad;

  DenominacionData({
    required this.moneda,
    required this.denominacion,
    this.cantidad = 0,
  });

  double get total => cantidad * denominacion;

  DenominacionData copyWith({
    String? moneda,
    double? denominacion,
    int? cantidad,
  }) {
    return DenominacionData(
      moneda: moneda ?? this.moneda,
      denominacion: denominacion ?? this.denominacion,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}

class VendedorCreateInvoiceScreen extends ConsumerStatefulWidget {
  const VendedorCreateInvoiceScreen({super.key});

  @override
  ConsumerState<VendedorCreateInvoiceScreen> createState() =>
      _VendedorCreateInvoiceScreenState();
}

class _VendedorCreateInvoiceScreenState
    extends ConsumerState<VendedorCreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _scrollController = ScrollController();
  final _montoRecibidoController = TextEditingController();

  XFile? _comprobanteFile;
  String? _comprobantePreviewUrl;
  bool _isPaymentSectionExpanded = true;

  final List<PaymentOption> _paymentOptions = TiposPago.values
      .map((tipo) => PaymentOption(tipo: tipo))
      .toList();

  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'Pagada';
  final List<InvoiceItemData> _invoiceItems = [];

  bool _isLoading = false;
  Client? _client;
  bool _isLoadingCaja = false;
  Caja? _caja;

  final List<DenominacionData> _denominacionesPago = [];
  final String _monedaSeleccionada = 'USD';

  static const List<String> _statusOptions = [
    'Pendiente',
    'Pagada',
    'Vencida',
    'Cancelada',
  ];

  @override
  void initState() {
    super.initState();
    _generateInvoiceNumber();
    _loadCajaData();
    _initializeDenominaciones();
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _scrollController.dispose();
    _montoRecibidoController.dispose();
    super.dispose();
  }

  // ============= MÉTODOS DE CÁLCULO =============

  void _initializeDenominaciones() {
    _denominacionesPago.clear();
    final denominaciones =
        Denominaciones.denominaciones[_monedaSeleccionada] ?? [];
    _denominacionesPago.addAll(
      denominaciones.map(
        (d) => DenominacionData(
          moneda: _monedaSeleccionada,
          denominacion: d,
          cantidad: 0,
        ),
      ),
    );
    setState(() {});
  }

  double _calculateTotal() =>
      _invoiceItems.fold(0.0, (sum, item) => sum + item.total);

  double _getTotalPagos() => _paymentOptions
      .where((opt) => opt.seleccionado)
      .fold(0.0, (sum, opt) => sum + opt.monto);

  double _getCambio() => _getTotalPagos() - _calculateTotal();

  bool _validatePagoVsFactura() {
    final isValid = _getTotalPagos() >= _calculateTotal();
    return isValid;
  }

  List<PaymentOption> _getSelectedPayments() => _paymentOptions
      .where((opt) => opt.seleccionado && opt.monto > 0)
      .toList();

  // ============= MÉTODOS DE CARGA DE DATOS =============

  Future<void> _loadCajaData() async {
    setState(() => _isLoadingCaja = true);
    try {
      _caja = await CajaService.getCurrentCaja(forceRefresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos de caja: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingCaja = false);
    }
  }

  void _generateInvoiceNumber() {
    final timestamp = DateFormat('yyyyMMddHHmm').format(DateTime.now());
    _invoiceNumberController.text = 'INV-$timestamp';
  }


  // ============= MÉTODOS DE ITEMS =============

  void _addInvoiceItem() {
    final productsState = ref.watch(productsProvider);
    final products = productsState.productos;
    final preciosMap = productsState.productoPrecios;
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos disponibles')),
      );
      return;
    }

    final producto = products.first;
    final precios = preciosMap[producto.id] ?? [];
    final precioSeleccionado = precios.isNotEmpty ? precios.first : null;

    setState(() {
      _invoiceItems.add(
        InvoiceItemData(
          producto: producto,
          precio: precioSeleccionado,
          quantity: 1,
          tax: 0,
        ),
      );
    });
    _validatePagoVsFactura();
  }

  void _removeInvoiceItem(int index) {
    setState(() => _invoiceItems.removeAt(index));
    _validatePagoVsFactura();
  }

  void _updateItemQuantity(int index, int change) {
    final item = _invoiceItems[index];
    final newQuantity = item.quantity + change;

    if (newQuantity <= 0) {
      _removeInvoiceItem(index);
      return;
    }

    final quantityWithPrice = item.precio != null
        ? newQuantity * item.precio!.quantity
        : newQuantity;

    if (quantityWithPrice > item.producto.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock insuficiente. Solo hay ${item.producto.stock} unidades',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _invoiceItems[index] = item.copyWith(quantity: newQuantity);
    });
    _validatePagoVsFactura();
  }

  void _addOrderItemSmart(Producto producto, ProductoPrecios? precio) {
    final existingIndex = _invoiceItems.indexWhere(
      (item) =>
          item.producto.id == producto.id && item.precio?.id == precio?.id,
    );

    if (existingIndex != -1) {
      final existingItem = _invoiceItems[existingIndex];
      final newQuantity = existingItem.quantity + 1;
      final quantityWithPrice = precio != null
          ? newQuantity * precio.quantity
          : newQuantity;

      if (quantityWithPrice > producto.stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stock insuficiente. Solo hay ${producto.stock} unidades',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _invoiceItems[existingIndex] = existingItem.copyWith(
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
      setState(() {
        _invoiceItems.add(
          InvoiceItemData(
            producto: producto,
            precio: precio,
            quantity: 1,
            tax: 0,
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${producto.nombre} agregado'),
          backgroundColor: Colors.blue,
        ),
      );
    }

    _validatePagoVsFactura();
  }

  // ============= MÉTODOS DE UI ACTIONS =============

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

  Future<void> _pickLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seleccionar Comprobante'),
          content: const Text(
            '¿Desde dónde quieres seleccionar el comprobante?',
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Cámara'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galería'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );

      if (source != null) {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          setState(() {
            _comprobanteFile = pickedFile;
            _comprobantePreviewUrl = pickedFile.path;
          });
        }
      }
    } catch (e) {
      safePrint('Error picking logo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al seleccionar el logo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveInvoice() async {
    setState(() => _isLoading = true);

    try {
      await InvoiceService.saveInvoice(
        context,
        _formKey,
        _invoiceItems,
        _calculateTotal(),
        _getTotalPagos(),
        _getCambio(),
        _invoiceNumberController.text,
        _selectedStatus,
        _selectedDate,
        _paymentOptions,
        _comprobanteFile,
        _client,
      );
    } catch (e) {
      debugPrint("Error en _saveInvoice: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      final productsState = ref.watch(productsProvider);
      final preciosProductos = productsState.productoPrecios;
      final request = ModelQueries.list(
        Producto.classType,
        where: Producto.BARCODE.eq(barCode),
      );
      final response = await Amplify.API.query(request: request).response;
      final productos = response.data?.items.whereType<Producto>().toList();

      if (productos != null && productos.isNotEmpty) {
        final producto = productos.first;

        if (_invoiceItems.any((item) => item.producto.id == producto.id)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Producto ${producto.nombre} ya agregado')),
          );
          return;
        }

        if (producto.stock <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Producto ${producto.nombre} sin stock')),
          );
          return;
        }

        final precios = preciosProductos[producto.id] ?? [];
        final precioSeleccionado = precios.isNotEmpty ? precios.first : null;

        setState(() {
          _invoiceItems.add(
            InvoiceItemData(
              producto: producto,
              precio: precioSeleccionado,
              quantity: 1,
              tax: 0,
            ),
          );
        });

        _validatePagoVsFactura();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto ${producto.nombre} agregado')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Producto no encontrado')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al obtener producto: $e')));
    }
  }

  // ============= BUILD METHODS =============

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final productsState = ref.watch(productsProvider);
    

    return BarcodeListenerWrapper(
      onBarcodeScanned: _getProductByBarCode,
      contextName: 'invoice',
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Crear Factura'),
            actions: [
              _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: AppLoadingIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FilledButton.icon(
                        onPressed: _validatePagoVsFactura()
                            ? _saveInvoice
                            : null,
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('Guardar'),
                      ),
                    ),
            ],
            bottom: TabBar(
              indicatorColor: colorScheme.onPrimary,
              labelColor: colorScheme.onPrimary,
              unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.6),
              tabs: const [
                Tab(icon: Icon(Icons.shopping_cart), text: 'Productos'),
                Tab(icon: Icon(Icons.receipt_long), text: 'Datos de Factura'),
              ],
            ),
          ),
          body: productsState.isLoading || _isLoadingCaja
              ? _buildLoadingSection()
              : TabBarView(
                  children: [_buildProductsTab(), _buildInvoiceDataTab(theme)],
                ),
          floatingActionButton: _buildFloatingActionButtons(colorScheme),
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final productsState = ref.watch(productsProvider);
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppLoadingIndicator(color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  productsState.isLoading
                      ? 'Cargando productos...'
                      : 'Cargando caja...',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTab() {
    return Form(
      key: _productKey,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductsCard(),
            const SizedBox(height: 16),
            _buildSummaryCard(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_cart),
                const SizedBox(width: 8),
                Text(
                  'Productos Seleccionados',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCompleteItemsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Resumen',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:', style: theme.textTheme.titleLarge),
                Text(
                  '\$${_calculateTotal().toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDataTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoCard(theme),
            const SizedBox(height: 16),
            _buildTotalAndPagoSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final negocio = ref.watch(currentUserNegocioProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Información Básica', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _invoiceNumberController,
              decoration: const InputDecoration(
                labelText: 'Número de Factura',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Ingrese número de factura' : null,
            ),
            const SizedBox(height: 16),
            ClientSelector(
              negocioID: negocio.value?.id ?? '',
              onClientSelected: (client) {
                setState(() {
                  _client = client;
                });
              },
              initialClient: null,
              hintText: 'Selecciona un cliente',
              enabled: true,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: _statusOptions
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
            const SizedBox(height: 16),
            _buildComprobanteSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildComprobanteSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comprobante de pago',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        MasonryGridView.count(
          crossAxisCount: isSmallScreen ? 1 : 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _comprobantePreviewUrl != null ? 3 : 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Row(
                children: [
                  Icon(
                    Icons.image,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _comprobantePreviewUrl != null
                          ? 'Comprobante seleccionado'
                          : 'Comprobante logo',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            } else if (index == 1) {
              return FilledButton.tonalIcon(
                onPressed: _pickLogo,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  _comprobantePreviewUrl != null
                      ? 'Cambiar comprobante'
                      : 'Subir comprobante',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            } else if (index == 2 && _comprobantePreviewUrl != null) {
              return GestureDetector(
                onTap: () => _showImagePreview(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.file(
                      File(_comprobantePreviewUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _showImagePreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Image.file(
                File(_comprobantePreviewUrl!),
                fit: BoxFit.contain,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: _scanBarcode,
          heroTag: "scan",
          tooltip: 'Escanear código',
          child: const Icon(Icons.qr_code_scanner),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          onPressed: _addInvoiceItem,
          heroTag: "add",
          label: const Text('Agregar Producto'),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildCompleteItemsSection() {
    final productState = ref.watch(productsProvider);

    return Column(
      children: [
        ProductQuickSelector(
          productos: productState.productos,
          productoPrecios: productState.productoPrecios,
          preciosLoaded: productState.preciosLoaded,
          onProductSelected: (orderItem, _) {
            _addOrderItemSmart(orderItem.producto, orderItem.precio);
          },
        ),
        const SizedBox(height: 16),
        _buildItemsList(),
      ],
    );
  }

  Widget _buildItemsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Productos Seleccionados'),
                Row(
                  children: [
                    Text(
                      '${_invoiceItems.length} ítems',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addInvoiceItem,
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Agregar producto manual',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _invoiceItems.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _invoiceItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _buildInvoiceItemCard(index),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_cart_outlined, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No hay productos seleccionados',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            'Usa el selector rápido o el botón +',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItemCard(int index) {
    final item = _invoiceItems[index];
    final productsState = ref.watch(productsProvider);
    final precios = productsState.productoPrecios[item.producto.id] ?? [];

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return constraints.maxWidth > 768
                ? _buildDesktopItemLayout(item, precios, index)
                : _buildMobileItemLayout(item, precios, index);
          },
        ),
      ),
    );
  }

  Widget _buildDesktopItemLayout(
    InvoiceItemData item,
    List<ProductoPrecios> precios,
    int index,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(child: _buildCantidadFieldWithButtons(item, index)),
              const SizedBox(width: 12),
              Expanded(child: _buildIvaField(item, index)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildTotalAndActions(item, index)),
      ],
    );
  }

  Widget _buildMobileItemLayout(
    InvoiceItemData item,
    List<ProductoPrecios> precios,
    int index,
  ) {
    return Column(
      children: [
        _buildProductoDropdown(item, index),
        const SizedBox(height: 12),
        _buildPrecioDropdown(item, precios, index),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildCantidadFieldWithButtons(item, index),
            ),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _buildIvaField(item, index)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(flex: 2, child: _buildTotalQuantity(item)),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _buildTotalSection(item)),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () => _removeInvoiceItem(index),
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.error.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductoDropdown(InvoiceItemData item, int index) {
    final productsState = ref.watch(productsProvider);
    final products = productsState.productos;
    final precios = productsState.productoPrecios[item.producto.id] ?? [];
    return DropdownButtonFormField<Producto>(
      value: item.producto,
      decoration: const InputDecoration(
        labelText: 'Producto',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: products.map((producto) {
        return DropdownMenuItem<Producto>(
          value: producto,
          child: Text(
            "${producto.nombre} - Stock: ${producto.stock}",
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (producto) {
        if (producto != null) {
          final nuevosPrecios = precios;
          setState(() {
            _invoiceItems[index] = item.copyWith(
              producto: producto,
              precio: nuevosPrecios.isNotEmpty ? nuevosPrecios.first : null,
            );
          });
          _validatePagoVsFactura();
        }
      },
    );
  }

  Widget _buildPrecioDropdown(
    InvoiceItemData item,
    List<ProductoPrecios> precios,
    int index,
  ) {
    return DropdownButtonFormField<ProductoPrecios>(
      value: item.precio ?? (precios.isNotEmpty ? precios.first : null),
      decoration: const InputDecoration(
        labelText: 'Precio',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: precios.map((precio) {
        return DropdownMenuItem<ProductoPrecios>(
          value: precio,
          child: Text(
            '${precio.nombre}: \$${precio.precio.toStringAsFixed(2)} - x${precio.quantity}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (precio) {
        if (precio != null) {
          setState(() {
            _invoiceItems[index] = item.copyWith(precio: precio);
          });
          _validatePagoVsFactura();
        }
      },
      validator: (value) => value == null ? 'Seleccione un precio' : null,
    );
  }

  Widget _buildCantidadFieldWithButtons(InvoiceItemData item, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton(
          onPressed: () => _updateItemQuantity(index, -1),
          icon: const Icon(Icons.remove_circle_outline),
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            key: ValueKey('${index}_${item.quantity}'),
            initialValue: item.quantity.toString(),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              isDense: true,
              filled: true,
              fillColor: colorScheme.primaryContainer.withOpacity(0.3),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              final quantity = int.tryParse(value) ?? 1;
              final change = quantity - item.quantity;
              if (change != 0) {
                _updateItemQuantity(index, change);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              final quantity = int.tryParse(value);
              if (quantity == null || quantity <= 0) return 'Inválido';
              final quantityWithPrice = item.precio != null
                  ? quantity * item.precio!.quantity
                  : quantity;
              if (quantityWithPrice > item.producto.stock) {
                return 'Stock insuficiente';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _updateItemQuantity(index, 1),
          icon: const Icon(Icons.add_circle_outline),
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildIvaField(InvoiceItemData item, int index) {
    return TextFormField(
      initialValue: item.tax.toString(),
      decoration: const InputDecoration(
        labelText: 'IVA (%)',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        final tax = int.tryParse(value) ?? 0;
        setState(() {
          _invoiceItems[index] = item.copyWith(tax: tax);
        });
        _validatePagoVsFactura();
      },
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingrese IVA';
        final tax = int.tryParse(value);
        if (tax == null || tax < 0) return 'IVA no válido';
        return null;
      },
    );
  }

  Widget _buildTotalSection(InvoiceItemData item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text('Total', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            '\$${item.total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalQuantity(InvoiceItemData item) {
    final quantityTotal = item.precio != null
        ? item.quantity * item.precio!.quantity
        : item.quantity;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text('Cantidad total', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            'x${quantityTotal.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAndActions(InvoiceItemData item, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTotalQuantity(item)),
            const SizedBox(width: 8),
            Expanded(child: _buildTotalSection(item)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _removeInvoiceItem(index),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Eliminar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalAndPagoSection(ThemeData theme) {
    final total = _calculateTotal();
    final totalPagado = _getTotalPagos();
    final cambio = _getCambio();
    final isValid = totalPagado >= total;
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen y Pago', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            // Saldo inicial
            _buildInfoRow(
              'Saldo en caja:',
              _caja?.saldoInicial.toStringAsFixed(2) ?? '0.00',
            ),
            const SizedBox(height: 8),

            // Total de la orden
            _buildInfoRow(
              'Total Orden:',
              '\$${total.toStringAsFixed(2)}',
              valueStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Sección de métodos de pago
            _buildPaymentMethodsCard(theme),
            const SizedBox(height: 16),

            // Resumen de pagos
            if (_getSelectedPayments().isNotEmpty) ...[
              _buildPaymentSummaryCard(theme, totalPagado),
              const SizedBox(height: 16),
            ],

            // Estado del pago
            _buildPaymentStatusCard(theme, total, totalPagado, cambio, isValid),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          value,
          style: valueStyle ?? const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isPaymentSectionExpanded = !_isPaymentSectionExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.payment, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Métodos de Pago',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_getSelectedPayments().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_getSelectedPayments().length}',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isPaymentSectionExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _isPaymentSectionExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: _paymentOptions.map((option) {
                        return _buildPaymentOptionTile(option, theme);
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionTile(PaymentOption option, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            option.seleccionado = !option.seleccionado;
            if (!option.seleccionado) option.monto = 0;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: option.seleccionado
                ? colorScheme.primaryContainer
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: option.seleccionado
                  ? colorScheme.primary
                  : colorScheme.outline,
              width: option.seleccionado ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: option.seleccionado
                          ? colorScheme.primary.withOpacity(0.2)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getPaymentIcon(option.tipo.name),
                      size: 20,
                      color: option.seleccionado
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.tipo.name,
                      style: TextStyle(
                        fontWeight: option.seleccionado
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 16,
                        color: option.seleccionado
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: option.seleccionado
                          ? colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: option.seleccionado
                            ? colorScheme.primary
                            : colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: option.seleccionado
                          ? colorScheme.onPrimary
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: option.seleccionado
                    ? Container(
                        margin: const EdgeInsets.only(top: 12),
                        child: TextFormField(
                          initialValue: option.monto > 0
                              ? option.monto.toString()
                              : '',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: "Dinero recibido",
                            hintText: "0.00",
                            prefixText: "\$",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            setState(() {
                              option.monto = double.tryParse(value) ?? 0;
                            });
                          },
                          validator: (value) {
                            if (option.seleccionado &&
                                (value?.isEmpty ?? true)) {
                              return 'El monto es requerido';
                            }
                            if (option.seleccionado &&
                                (double.tryParse(value!) ?? 0) <= 0) {
                              return 'Ingrese un monto válido';
                            }
                            return null;
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard(ThemeData theme, double totalPagado) {
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.secondaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Pagos',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._getSelectedPayments().map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(option.tipo.name),
                    Text(
                      '\$${option.monto.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pagado:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${totalPagado.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusCard(
    ThemeData theme,
    double total,
    double totalPagado,
    double cambio,
    bool isValid,
  ) {
    final colorScheme = theme.colorScheme;

    return Card(
      color: isValid
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : colorScheme.errorContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Total Orden:', '\$${total.toStringAsFixed(2)}'),
            _buildInfoRow(
              'Total Pagado:',
              '\$${totalPagado.toStringAsFixed(2)}',
            ),
            const Divider(),
            if (totalPagado == total)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Pago Completo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              )
            else if (totalPagado > total)
              _buildInfoRow(
                'Cambio:',
                '\$${cambio.toStringAsFixed(2)}',
                valueStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              )
            else
              _buildInfoRow(
                'Faltante:',
                '\$${cambio.abs().toStringAsFixed(2)}',
                valueStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
            if (!isValid) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: colorScheme.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'El pago no cubre el total de la orden',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

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
}
