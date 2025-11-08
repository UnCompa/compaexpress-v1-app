import 'package:compaexpress/entities/order_item_data.dart';
import 'package:compaexpress/entities/payment_option.dart';
import 'package:compaexpress/entities/preorder.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/providers/preorders_provider.dart';
import 'package:compaexpress/providers/products_provider.dart';
import 'package:compaexpress/utils/product_quick_selector.dart';
import 'package:compaexpress/widget/ui/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {

      final preorderItems = _orderItems.map((item) => PreorderItem(
        producto: item.producto,
        quantity: item.quantity,
        precio: item.precio,
        tax: item.tax.toDouble(),
        subtotal: item.subtotal,
        total: item.total,
      )).toList();

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
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
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
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Guardar',
              onPressed: _savePreorder,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Información del header
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                                'Guardar Orden como Preorden',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Podrás reutilizarla más tarde',
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

                    // Campo de nombre
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

                    // Campo de descripción
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
            ),

            const SizedBox(height: 24),

            // Vista previa de la orden actual
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orden Actual',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Aquí mostrarías un resumen de la orden actual
                    // Por ahora, mostraremos un mensaje informativo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.secondary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Se guardará la orden actual con todos sus productos y métodos de pago',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ProductQuickSelector(
                      productos: productsState.productos,
                      productoPrecios: productsState.productoPrecios,
                      onProductSelected: (invoiceItem, orderItem) {
                        _addOrderItemSmart(
                          invoiceItem.producto,
                          orderItem.precio,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Estadísticas rápidas (placeholder)
                    Row(
                      children: [
                        Expanded(
                          child: _InfoChip(
                            icon: Icons.shopping_cart,
                            label: 'Productos',
                            value: _orderItems.length.toString(),
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoChip(
                            icon: Icons.attach_money,
                            label: 'Total',
                            value: '\$${_orderItems.fold(0.0, (sum, item) => sum + item.total).toStringAsFixed(2)}',
                            color: colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Métodos de pago
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Métodos de Pago',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: _paymentOptions.map((option) {
                        return CheckboxListTile(
                          title: Text(option.tipo.name),
                          value: option.seleccionado,
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
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: 'Monto',
                                      prefixIcon: Icon(Icons.attach_money),
                                      border: OutlineInputBorder(),
                                    ),
                                    initialValue: option.monto > 0
                                        ? option.monto.toStringAsFixed(2)
                                        : '',
                                    onChanged: (value) {
                                      setState(() {
                                        option.monto =
                                            double.tryParse(value) ?? 0.0;
                                      });
                                    },
                                  ),
                                )
                              : null,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Divider(),
                    ListTile(
                      title: Text('Total Pagado'),
                      trailing: Text(
                        '\$${_getTotalPagos().toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text('Total Orden'),
                      trailing: Text(
                        '\$${_calculateTotal().toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text('Cambio'),
                      trailing: Text(
                        '\$${(_getTotalPagos() - _calculateTotal()).toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _validatePagoVsOrden()
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botones de acción
            Row(
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
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nota informativa
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Las preórdenes te permiten guardar órdenes frecuentes y reutilizarlas rápidamente en el futuro.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
