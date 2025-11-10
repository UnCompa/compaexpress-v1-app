import 'dart:developer';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/entities/order_item_data.dart';
import 'package:compaexpress/entities/payment_option.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/providers/products_provider.dart';
import 'package:compaexpress/services/caja_service.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/services/order_service.dart';
import 'package:compaexpress/utils/barcode_listener_wrapper.dart';
import 'package:compaexpress/utils/product_quick_selector.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
import 'package:compaexpress/widget/payment_section_widget.dart';
import 'package:compaexpress/widget/ui/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
// ==================== WIDGETS SEPARADOS ====================

// Widget reutilizable para campos de texto decorados
class ThemedTextField extends StatelessWidget {
  final String? initialValue;
  final String labelText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextAlign textAlign;

  const ThemedTextField({
    super.key,
    this.initialValue,
    required this.labelText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.controller,
    this.readOnly = false,
    this.suffixIcon,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      textAlign: textAlign,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        suffixIcon: suffixIcon,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(color: colorScheme.onSurface),
    );
  }
}

// Widget para campo de cantidad con botones +/-
class QuantityFieldWithButtons extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final void Function(String) onChanged;
  final String? Function(String?)? validator;

  const QuantityFieldWithButtons({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        _buildIconButton(
          context,
          icon: Icons.remove_circle_outline,
          onPressed: onDecrement,
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ThemedTextField(
            key: ValueKey(quantity),
            initialValue: quantity.toString(),
            labelText: 'Cantidad',
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            validator: validator,
          ),
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          context,
          icon: Icons.add_circle_outline,
          onPressed: onIncrement,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required ColorScheme colorScheme,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: colorScheme.primary,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Widget para dropdown temático
class ThemedDropdown<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const ThemedDropdown({
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: colorScheme.surface,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}

// Widget para mostrar resumen de pago
class PaymentSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const PaymentSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (backgroundColor ?? colorScheme.primaryContainer).withOpacity(
            0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor ?? colorScheme.onPrimaryContainer,
              size: 20,
            ),
            const SizedBox(height: 4),
          ],
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: (textColor ?? colorScheme.onPrimaryContainer).withOpacity(
                0.8,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor ?? colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PÁGINA PRINCIPAL ====================

class VendedorOrderCreatePage extends ConsumerStatefulWidget {
  const VendedorOrderCreatePage({super.key});

  @override
  ConsumerState<VendedorOrderCreatePage> createState() =>
      _VendedorOrderCreatePageState();
}

class _VendedorOrderCreatePageState
    extends ConsumerState<VendedorOrderCreatePage> {
  final GlobalKey<PaymentSectionWidgetState> _paymentKey = GlobalKey();
  bool _isPaymentKeyboardActive = false;
  final _formKey = GlobalKey<FormState>();
  final _orderNumberController = TextEditingController();
  final _scrollController = ScrollController();

  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'Pagada';
  List<PaymentOption> _paymentOptions = TiposPago.values
      .map((tipo) => PaymentOption(tipo: tipo))
      .toList();
  List<Producto> _productos = [];
  final Map<String, List<ProductoPrecios>> _productoPrecios = {};
  final List<OrderItemData> _orderItems = [];
  bool _isLoading = false;
  bool _isLoadingProducts = false;
  bool _isLoadingCaja = false;
  Caja? _caja;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos de caja: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingCaja = false);
    }
  }

  void _addOrderItemSmart(Producto producto, ProductoPrecios? precio) {
    final existingIndex = _orderItems.indexWhere(
      (item) =>
          item.producto.id == producto.id && item.precio?.id == precio?.id,
    );

    if (existingIndex != -1) {
      final existingItem = _orderItems[existingIndex];
      final newQuantity = existingItem.quantity + 1;

      final quantityWithPrice = precio != null
          ? newQuantity * precio.quantity
          : newQuantity;

      if (quantityWithPrice > producto.stock) {
        _showSnackBar(
          'Stock insuficiente. Solo hay ${producto.stock} unidades disponibles',
          isError: true,
        );
        return;
      }

      setState(() {
        _orderItems[existingIndex] = existingItem.copyWith(
          quantity: newQuantity,
        );
      });

      _showSnackBar('Cantidad actualizada para ${producto.nombre}');
    } else {
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

      _showSnackBar('${producto.nombre} agregado a la orden');
    }

    _validatePagoVsOrden();
  }

  void _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = DateFormat('yyyyMMddHHmm').format(now);
    _orderNumberController.text = 'ORD-$timestamp';
  }

  Future<void> _loadProducts() async {
    if (_productosLoaded) return;

    setState(() => _isLoadingProducts = true);
    try {
      final userData = await NegocioService.getCurrentUserInfo();

      final request = ModelQueries.list(
        Producto.classType,
        where: Producto.NEGOCIOID
            .eq(userData.negocioId)
            .and(Producto.STOCK.gt(0)),
        limit: 50,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final productos = response.data!.items.whereType<Producto>().toList();

        if (mounted) {
          setState(() {
            _productos = productos;
            _productosLoaded = true;
          });
        }

        _loadPreciosAsync(productos);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error al cargar productos: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _loadPreciosAsync(List<Producto> productos) async {
    final preciosMap = <String, List<ProductoPrecios>>{};

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

      if (mounted) {
        setState(() {
          _productoPrecios.addAll(preciosMap);
        });
      }

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

    final quantityWithPrice = item.precio != null
        ? newQuantity * item.precio!.quantity
        : newQuantity;

    if (quantityWithPrice > item.producto.stock) {
      _showSnackBar(
        'Stock insuficiente. Solo hay ${item.producto.stock} unidades disponibles',
        isError: true,
      );
      return;
    }

    setState(() {
      _orderItems[index] = item.copyWith(quantity: newQuantity);
    });
    _validatePagoVsOrden();
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
      log("GUARDANDO ORDEN");
      setState(() => _isLoading = true);
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
    } catch (e) {
      debugPrint('Error al guardar orden: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        delayMillis: 500,
        cameraFace: CameraFace.back,
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
          _showSnackBar('Producto ${producto.nombre} sin stock', isError: true);
          return;
        }

        if (!_productoPrecios.containsKey(producto.id)) {
          await _loadPreciosForProduct(producto.id);
        }

        final precios = _productoPrecios[producto.id] ?? [];
        final precioSeleccionado = precios.isNotEmpty ? precios.first : null;

        _addOrderItemSmart(producto, precioSeleccionado);
      } else {
        _showSnackBar('Producto no encontrado', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error al obtener producto: $e', isError: true);
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

      if (mounted) {
        setState(() {
          _productoPrecios[productoId] =
              precioResponse.data?.items
                  .whereType<ProductoPrecios>()
                  .toList() ??
              [];
        });
      }
    } catch (e) {
      debugPrint('Error cargando precios para producto $productoId: $e');
    }
  }

  void _onBarcodeScannedFromUSB(String barcode) async {
    await _getProductByBarCode(barcode);
    log('Obteniendo producto por código: $barcode');
    if (mounted) FocusScope.of(context).nextFocus();
  }

  void _togglePaymentMode() {
    log('Toggle payment mode - Current state: $_isPaymentKeyboardActive');

    if (_isPaymentKeyboardActive) {
      // Si está activo, desactivarlo
      _paymentKey.currentState?.handleEscape();
    } else {
      // Si está inactivo, activarlo
      _paymentKey.currentState?.activateQuickKeyboard();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        duration: Duration(seconds: isError ? 2 : 1),
      ),
    );
  }

  double _getTotalPagos() {
    return _paymentOptions
        .where((option) => option.seleccionado)
        .fold(0, (total, option) => total + option.monto);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BarcodeListenerWrapper(
      contextName: 'create_order',
      allowKeyboardInput: _isPaymentKeyboardActive,
      onBarcodeScanned: _onBarcodeScannedFromUSB,
      onKeyPress: (key) {
        _paymentKey.currentState?.handleKeyPress(key);
      },
      onEnterPressed: () {
        _paymentKey.currentState?.handleEnter();
      },
      onEscapePressed: () {
        _paymentKey.currentState?.handleEscape();
      },
      onBackspacePressed: () {
        _paymentKey.currentState?.handleBackspace();
      },
      enabled: !_isLoading,
      onF2Pressed: _togglePaymentMode,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Orden'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
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
                    child: ElevatedButton.icon(
                      onPressed: _validatePagoVsOrden() ? _saveOrder : null,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                        disabledBackgroundColor:
                            colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
        body: _isLoadingProducts || _isLoadingCaja
            ? _buildLoadingSection(colorScheme)
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoSection(theme),
                      const SizedBox(height: 16),
                      _buildCompleteItemsSection(),
                      const SizedBox(height: 16),
                      PaymentSectionWidget(
                        key: _paymentKey,
                        totalAmount: _calculateTotal(),
                        initialBalance: _caja?.saldoInicial,
                        paymentOptions: _paymentOptions,
                        onPaymentChanged: (updatedOptions) {
                          setState(() {
                            _paymentOptions = updatedOptions;
                          });
                        },
                        onPaymentComplete: () {
                          if (_validatePagoVsOrden()) {
                            _saveOrder();
                          }
                        },
                        // Opcionales:
                        title: 'Resumen y Pago',
                        balanceLabel: 'Saldo en caja:',
                        totalLabel: 'Total Orden:',
                        showBalance: true,
                        enableQuickKeyboard: true, // ¡Nueva funcionalidad!
                        onRequestFocus: () {
                          setState(() => _isPaymentKeyboardActive = true);
                        },
                        onReleaseFocus: () {
                          setState(() => _isPaymentKeyboardActive = false);
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _scanBarcode,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          tooltip: 'Escanear código',
          child: const Icon(Icons.qr_code_scanner),
        ),
      ),
    );
  }

  Widget _buildLoadingSection(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.scrim.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLoadingIndicator(color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                _isLoadingProducts
                    ? 'Cargando productos...'
                    : 'Cargando caja...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme) {
    final colorScheme = theme.colorScheme;

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
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _orderNumberController,
              prefixIcon: Icons.numbers,
              labelText: 'Número de Orden',
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
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ThemedDropdown<String>(
              value: _selectedStatus,
              labelText: 'Estado',
              items: _statusOptions
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
          ],
        ),
      ),
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
          onProductSelected: (invoiceItem, orderItem) {
            _addOrderItemSmart(invoiceItem.producto, orderItem.precio);
          },
        ),
        const SizedBox(height: 16),
        _buildItemsSection(),
      ],
    );
  }

  Widget _buildItemsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_orderItems.length} ítems',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _orderItems.isEmpty
                ? _buildEmptyItemsState(colorScheme)
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _orderItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _buildOrderItemCard(index, theme, colorScheme),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyItemsState(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No hay productos seleccionados',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Usa el selector rápido de arriba o el botón de escáner',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(
    int index,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final item = _orderItems[index];
    final precios = _productoPrecios[item.producto.id] ?? [];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 768;
          return isDesktop
              ? _buildDesktopLayout(item, precios, index, theme, colorScheme)
              : _buildMobileLayout(item, precios, index, theme, colorScheme);
        },
      ),
    );
  }

  Widget _buildDesktopLayout(
    OrderItemData item,
    List<ProductoPrecios> precios,
    int index,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Row(
            children: [
              Expanded(
                child: _buildProductoDropdown(item, index, theme, colorScheme),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPrecioDropdown(
                  item,
                  precios,
                  index,
                  theme,
                  colorScheme,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: QuantityFieldWithButtons(
                  quantity: item.quantity,
                  onDecrement: () => _updateItemQuantity(index, -1),
                  onIncrement: () => _updateItemQuantity(index, 1),
                  onChanged: (value) {
                    final quantity = int.tryParse(value) ?? 1;
                    final change = quantity - item.quantity;
                    if (change != 0) _updateItemQuantity(index, change);
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
              const SizedBox(width: 12),
              Expanded(child: _buildIvaField(item, index)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildTotalAndActions(item, index, colorScheme),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    OrderItemData item,
    List<ProductoPrecios> precios,
    int index,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        _buildProductoDropdown(item, index, theme, colorScheme),
        const SizedBox(height: 12),
        _buildPrecioDropdown(item, precios, index, theme, colorScheme),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: QuantityFieldWithButtons(
                quantity: item.quantity,
                onDecrement: () => _updateItemQuantity(index, -1),
                onIncrement: () => _updateItemQuantity(index, 1),
                onChanged: (value) {
                  final quantity = int.tryParse(value) ?? 1;
                  final change = quantity - item.quantity;
                  if (change != 0) _updateItemQuantity(index, change);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _buildIvaField(item, index)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(flex: 2, child: _buildTotalQuantity(item, colorScheme)),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _buildTotalSection(item, colorScheme)),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () => _removeOrderItem(index),
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            tooltip: 'Eliminar',
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.errorContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductoDropdown(
    OrderItemData item,
    int index,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final selectedProducto = item.producto;

    return ThemedDropdown<Producto>(
      value: selectedProducto,
      labelText: 'Producto',
      items: _productos.map((Producto producto) {
        return DropdownMenuItem<Producto>(
          value: producto,
          child: Text(
            "${producto.nombre} - S: ${producto.stock}",
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    OrderItemData item,
    List<ProductoPrecios> precios,
    int index,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ThemedDropdown<ProductoPrecios>(
      value: item.precio,
      labelText: 'Precio',
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

  Widget _buildIvaField(OrderItemData item, int index) {
    return ThemedTextField(
      initialValue: item.tax.toString(),
      labelText: 'IVA (%)',
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

  Widget _buildTotalAndActions(
    OrderItemData item,
    int index,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTotalQuantity(item, colorScheme)),
            const SizedBox(width: 8),
            Expanded(child: _buildTotalSection(item, colorScheme)),
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
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSection(OrderItemData item, ColorScheme colorScheme) {
    return PaymentSummaryCard(
      title: 'Total',
      amount: '\$${item.total.toStringAsFixed(2)}',
      backgroundColor: colorScheme.primaryContainer,
      textColor: colorScheme.onPrimaryContainer,
      icon: Icons.attach_money,
    );
  }

  Widget _buildTotalQuantity(OrderItemData item, ColorScheme colorScheme) {
    final quantityTotal = item.quantity * item.precio!.quantity;
    return PaymentSummaryCard(
      title: 'Cantidad total',
      amount: 'x${quantityTotal.toStringAsFixed(0)}',
      backgroundColor: colorScheme.secondaryContainer,
      textColor: colorScheme.onSecondaryContainer,
      icon: Icons.inventory_2_outlined,
    );
  }
}
