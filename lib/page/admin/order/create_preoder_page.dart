import 'package:compaexpress/entities/order_item_data.dart';
import 'package:compaexpress/entities/payment_option.dart';
import 'package:compaexpress/entities/preorder.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/providers/preorders_provider.dart';
import 'package:compaexpress/providers/products_provider.dart';
import 'package:compaexpress/utils/product_quick_selector.dart';
import 'package:compaexpress/widget/ui/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
class CreatePreorderPage extends ConsumerStatefulWidget {
  const CreatePreorderPage({super.key});

  @override
  ConsumerState<CreatePreorderPage> createState() => _CreatePreorderPageState();
}

class _CreatePreorderPageState extends ConsumerState<CreatePreorderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<OrderItemData> _orderItems = [];
  final List<PaymentOption> _paymentOptions = TiposPago.values
      .map((tipo) => PaymentOption(tipo: tipo))
      .toList();
  bool _isSaving = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _savePreorder() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(
        'Por favor completa todos los campos requeridos',
        isError: true,
      );
      return;
    }

    if (_orderItems.isEmpty) {
      _showSnackBar('Agrega al menos un producto a la preorden', isError: true);
      return;
    }

    if (!_validatePagoVsOrden()) {
      _showSnackBar(
        'El pago total debe cubrir el total de la orden',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final preorderItems = _orderItems
          .map(
            (item) => PreorderItem(
              producto: item.producto,
              quantity: item.quantity,
              precio: item.precio,
              tax: item.tax.toDouble(),
              subtotal: item.subtotal,
              total: item.total,
            ),
          )
          .toList();

      await ref
          .read(preordersProvider.notifier)
          .addPreorder(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            orderItems: preorderItems,
            paymentOptions: _paymentOptions,
            totalOrden: _calculateTotal(),
            totalPago: _getTotalPagos(),
            cambio: _getTotalPagos() - _calculateTotal(),
            orderStatus: 'Pagada',
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Preorden "${_nameController.text.trim()}" guardada exitosamente',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e, stack) {
      print(e);
      print(stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _addOrderItemSmart(Producto producto, ProductoPrecios? precio) {
    if (precio == null) {
      _showSnackBar(
        'Debe seleccionar un precio para este producto',
        isError: true,
      );
      return;
    }

    final existingIndex = _orderItems.indexWhere(
      (item) => item.producto.id == producto.id && item.precio?.id == precio.id,
    );

    if (existingIndex != -1) {
      final existingItem = _orderItems[existingIndex];
      final newQuantity = existingItem.quantity + 1;

      final quantityWithPrice = newQuantity * precio.quantity;

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

      _showSnackBar('Cantidad actualizada: ${producto.nombre}');
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

      _showSnackBar('${producto.nombre} agregado');
    }

    // Auto-scroll to items section
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
  }

  void _removeOrderItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
    _showSnackBar('Producto eliminado');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        duration: Duration(seconds: isError ? 2 : 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double _calculateTotal() {
    return _orderItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double _getTotalPagos() {
    return _paymentOptions
        .where((option) => option.seleccionado)
        .fold(0, (total, option) => total + option.monto);
  }

  bool _validatePagoVsOrden() {
    final total = _calculateTotal();
    final totalPagado = _getTotalPagos();
    return totalPagado >= total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Preorden'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: AppLoadingIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: _savePreorder,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Header Information Card
            _buildHeaderCard(theme, colorScheme),

            const SizedBox(height: 24),

            // Product Quick Selector
            _buildProductSelectorCard(theme, colorScheme, productsState),

            const SizedBox(height: 24),

            // Selected Products
            if (_orderItems.isNotEmpty) ...[
              _buildSelectedProductsCard(theme, colorScheme),
              const SizedBox(height: 24),
            ],

            // Payment Methods
            _buildPaymentMethodsCard(theme, colorScheme),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(colorScheme),

            const SizedBox(height: 16),

            // Info Note
            _buildInfoNote(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bookmark_add,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información de Preorden',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Define los detalles básicos',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            CustomTextField(
              labelText: "Nombre de la preorden",
              prefixIcon: Icons.tag,
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                if (value.trim().length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isSaving,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              controller: _descriptionController,
              prefixIcon: Icons.notes,
              labelText: "Descripción (opcional)",
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isSaving,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelectorCard(
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic productsState,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_basket, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Agregar Productos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ProductQuickSelector(
              productos: productsState.productos,
              preciosLoaded: productsState.preciosLoaded,
              productoPrecios: productsState.productoPrecios,
              onProductSelected: (invoiceItem, orderItem) {
                _addOrderItemSmart(invoiceItem.producto, orderItem.precio);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedProductsCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Productos Seleccionados',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
            const SizedBox(height: 16),
            AnimationLimiter(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orderItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 300),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildProductItem(index, theme, colorScheme),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Divider(),
            _buildTotalSummary(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(
    int index,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final item = _orderItems[index];
    final productsState = ref.watch(productsProvider);
    final precios = productsState.productoPrecios[item.producto.id] ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Determinar si es móvil (< 600px) o desktop
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return _buildMobileProductItem(
              item,
              index,
              productsState,
              precios,
              colorScheme,
            );
          } else {
            return _buildDesktopProductItem(
              item,
              index,
              productsState,
              precios,
              colorScheme,
            );
          }
        },
      ),
    );
  }

  Widget _buildMobileProductItem(
    OrderItemData item,
    int index,
    dynamic productsState,
    List<ProductoPrecios> precios,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        // Product Dropdown
        _buildProductDropdown(item, index, productsState, colorScheme),
        const SizedBox(height: 12),

        // Price Dropdown
        _buildPriceDropdown(item, index, precios, colorScheme),
        const SizedBox(height: 12),

        // Quantity Control
        _buildQuantityControl(item, index, colorScheme),
        const SizedBox(height: 12),

        // Tax and Total in Row
        Row(
          children: [
            Expanded(child: _buildTaxField(item, index, colorScheme)),
            const SizedBox(width: 12),
            Expanded(child: _buildItemTotal(item, colorScheme)),
          ],
        ),
        const SizedBox(height: 12),

        // Remove Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _removeOrderItem(index),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Eliminar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopProductItem(
    OrderItemData item,
    int index,
    dynamic productsState,
    List<ProductoPrecios> precios,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        // First Row: Product and Price
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildProductDropdown(
                item,
                index,
                productsState,
                colorScheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildPriceDropdown(item, index, precios, colorScheme),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Second Row: Quantity, Tax, Total, and Delete
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildQuantityControl(item, index, colorScheme),
            ),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: _buildTaxField(item, index, colorScheme)),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: _buildItemTotal(item, colorScheme)),
            const SizedBox(width: 12),
            SizedBox(
              width: 48,
              height: 56,
              child: IconButton(
                onPressed: () => _removeOrderItem(index),
                icon: const Icon(Icons.delete_outline),
                color: colorScheme.error,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductDropdown(
    OrderItemData item,
    int index,
    dynamic productsState,
    ColorScheme colorScheme,
  ) {
    return DropdownButtonFormField<Producto>(
      value: item.producto,
      decoration: InputDecoration(
        labelText: 'Producto',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
      ),
      items: productsState.productos.map<DropdownMenuItem<Producto>>((
        producto,
      ) {
        return DropdownMenuItem<Producto>(
          value: producto,
          child: Text(
            '${producto.nombre} (Stock: ${producto.stock})',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (producto) {
        if (producto != null) {
          final nuevosPrecios =
              productsState.productoPrecios[producto.id] ?? [];
          final precioSeleccionado = nuevosPrecios.isNotEmpty
              ? nuevosPrecios[0]
              : null;
          setState(() {
            _orderItems[index] = item.copyWith(
              producto: producto,
              precio: precioSeleccionado,
            );
          });
        }
      },
    );
  }

  Widget _buildPriceDropdown(
    OrderItemData item,
    int index,
    List<ProductoPrecios> precios,
    ColorScheme colorScheme,
  ) {
    return DropdownButtonFormField<ProductoPrecios>(
      value: item.precio,
      decoration: InputDecoration(
        labelText: 'Precio',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
      ),
      items: precios.map<DropdownMenuItem<ProductoPrecios>>((precio) {
        return DropdownMenuItem<ProductoPrecios>(
          value: precio,
          child: Text(
            '${precio.nombre}: \$${precio.precio.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (precio) {
        setState(() {
          _orderItems[index] = item.copyWith(precio: precio);
        });
      },
      validator: (value) => value == null ? 'Requerido' : null,
    );
  }

  Widget _buildQuantityControl(
    OrderItemData item,
    int index,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _updateItemQuantity(index, -1),
          icon: const Icon(Icons.remove_circle_outline),
          color: colorScheme.primary,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            key: ValueKey('qty_$index'),
            initialValue: item.quantity.toString(),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Cant.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            onChanged: (value) {
              final quantity = int.tryParse(value) ?? 1;
              final change = quantity - item.quantity;
              if (change != 0) _updateItemQuantity(index, change);
            },
          ),
        ),
        IconButton(
          onPressed: () => _updateItemQuantity(index, 1),
          icon: const Icon(Icons.add_circle_outline),
          color: colorScheme.primary,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaxField(
    OrderItemData item,
    int index,
    ColorScheme colorScheme,
  ) {
    return TextFormField(
      key: ValueKey('tax_$index'),
      initialValue: item.tax.toString(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'IVA %',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
      ),
      onChanged: (value) {
        final tax = int.tryParse(value) ?? 0;
        setState(() {
          _orderItems[index] = item.copyWith(tax: tax);
        });
      },
    );
  }

  Widget _buildItemTotal(OrderItemData item, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Total',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${item.total.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary(ThemeData theme, ColorScheme colorScheme) {
    final total = _calculateTotal();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total de Productos',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '\$${total.toStringAsFixed(2)}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsCard(ThemeData theme, ColorScheme colorScheme) {
    final totalOrden = _calculateTotal();
    final totalPago = _getTotalPagos();
    final cambio = totalPago - totalOrden;
    final isValid = _validatePagoVsOrden();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Métodos de Pago',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: _paymentOptions.map((option) {
                return CheckboxListTile(
                  title: Text(option.tipo.name),
                  value: option.seleccionado,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onChanged: (value) {
                    setState(() {
                      option.seleccionado = value ?? false;
                      if (!option.seleccionado) option.monto = 0.0;
                    });
                  },
                  subtitle: option.seleccionado
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TextFormField(
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Monto',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            initialValue: option.monto > 0
                                ? option.monto.toStringAsFixed(2)
                                : '',
                            onChanged: (value) {
                              setState(() {
                                option.monto = double.tryParse(value) ?? 0.0;
                              });
                            },
                          ),
                        )
                      : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildPaymentSummaryRow(
              'Total Orden',
              totalOrden,
              colorScheme,
              isPrimary: true,
            ),
            const SizedBox(height: 8),
            _buildPaymentSummaryRow('Total Pagado', totalPago, colorScheme),
            const SizedBox(height: 8),
            _buildPaymentSummaryRow(
              'Cambio',
              cambio,
              colorScheme,
              color: isValid ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryRow(
    String label,
    double amount,
    ColorScheme colorScheme, {
    bool isPrimary = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
            fontSize: isPrimary ? 16 : 14,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isPrimary ? 18 : 16,
            color: color ?? (isPrimary ? colorScheme.primary : null),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _savePreorder,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: AppLoadingIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Guardando...' : 'Guardar Preorden'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoNote(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Las preórdenes te permiten guardar configuraciones de órdenes frecuentes para reutilizarlas rápidamente.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
