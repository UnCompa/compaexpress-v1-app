import 'package:compaexpress/entities/preorder.dart';
import 'package:compaexpress/providers/preorders_provider.dart';
import 'package:compaexpress/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PreordersPage extends ConsumerStatefulWidget {
  const PreordersPage({super.key});

  @override
  ConsumerState<PreordersPage> createState() => _PreordersPageState();
}

class _PreordersPageState extends ConsumerState<PreordersPage> {
  String _searchQuery = '';
  final _searchController = TextEditingController();
  String? _creatingOrderId;
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Preorder> _getFilteredPreorders(List<Preorder> preorders) {
    if (_searchQuery.isEmpty) return preorders;

    return preorders.where((preorder) {
      final nameLower = preorder.name.toLowerCase();
      final descLower = preorder.description.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();

      return nameLower.contains(queryLower) || descLower.contains(queryLower);
    }).toList();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String id,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Preorden'),
        content: Text('¿Está seguro de eliminar "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(preordersProvider.notifier).removePreorder(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preorden "$name" eliminada'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = DateFormat('yyyyMMddHHmm').format(now);
    return 'ORD-$timestamp';
  }

  Future<void> _createOrder(BuildContext context, Preorder preorder) async {
    setState(() {
      _creatingOrderId = preorder.id;
    });
    final orderNumber = _generateOrderNumber();
    final selectDate = DateTime.now();

    try {
      await ref
          .read(preordersProvider.notifier)
          .createOrderFromPreorder(
            context,
            null,
            preorder.id,
            orderNumber,
            selectDate,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Orden creada exitosamente: $orderNumber'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: 'Ver',
              textColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                // Navegar a la orden creada si es necesario
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear orden: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final preordersState = ref.watch(preordersProvider);
    final filteredPreorders = _getFilteredPreorders(preordersState.preorders);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preórdenes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () {
              ref.read(preordersProvider.notifier).loadPreorders();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar preórdenes...',
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Estadísticas rápidas
          if (preordersState.preorders.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.list_alt,
                      label: 'Total',
                      value: '${preordersState.preorders.length}',
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.search,
                      label: 'Filtrados',
                      value: '${filteredPreorders.length}',
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.attach_money,
                      label: 'Total \$',
                      value:
                          NumberFormat.currency(
                            symbol: '\$',
                            decimalDigits: 0,
                          ).format(
                            preordersState.preorders.fold<double>(
                              0,
                              (sum, p) => sum + p.totalOrden,
                            ),
                          ),
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),

          // Lista de preórdenes
          Expanded(
            child: preordersState.isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando preórdenes...',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : preordersState.isError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar preórdenes',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          preordersState.errorMessage ?? 'Error desconocido',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () {
                            ref
                                .read(preordersProvider.notifier)
                                .loadPreorders();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : filteredPreorders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty
                              ? Icons.shopping_bag_outlined
                              : Icons.search_off,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No hay preórdenes guardadas'
                              : 'No se encontraron resultados',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Crea una nueva preorden para comenzar'
                              : 'Intenta con otro término de búsqueda',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPreorders.length,
                    itemBuilder: (context, index) {
                      final preorder = filteredPreorders[index];
                      final isCreatingOrder = _creatingOrderId == preorder.id;
                      return _PreorderCard(
                        preorder: preorder,
                        onCreateOrder: () => _createOrder(context, preorder),
                        onDelete: () =>
                            _confirmDelete(context, preorder.id, preorder.name),
                        onView: () => _showPreorderDetails(context, preorder),
                        isCreatingOrder: isCreatingOrder,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a la pantalla de crear preorden
          Navigator.pushNamed(context, Routes.preordersCreate);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Preorden'),
      ),
    );
  }

  void _showPreorderDetails(BuildContext context, Preorder preorder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PreorderDetailsSheet(preorder: preorder),
    );
  }
}

// Widget para tarjetas de estadísticas
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
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
      ),
    );
  }
}

// Widget para cada tarjeta de preorden
class _PreorderCard extends StatelessWidget {
  final Preorder preorder;
  final VoidCallback onCreateOrder;
  final VoidCallback onDelete;
  final VoidCallback onView;
  final bool isCreatingOrder;

  const _PreorderCard({
    required this.preorder,
    required this.onCreateOrder,
    required this.onDelete,
    required this.onView,
    required this.isCreatingOrder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isCreatingOrder ? null : onView,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.bookmark,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preorder.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (preorder.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            preorder.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    onPressed: onDelete,
                    tooltip: 'Eliminar',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Información de items
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${preorder.orderItems.length} productos',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${preorder.totalOrden.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Métodos de pago
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: preorder.paymentOptions.where((p) => p.seleccionado).map((
                  payment,
                ) {
                  return Chip(
                    avatar: Icon(
                      Icons.payment,
                      size: 16,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    label: Text(
                      '${payment.tipo.name}: \$${payment.monto.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    backgroundColor: colorScheme.secondaryContainer,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Botón de crear orden
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onCreateOrder,
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Crear Orden'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (isCreatingOrder)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(
                        0.7,
                      ), // Fondo semitransparente
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sheet de detalles de preorden
class _PreorderDetailsSheet extends StatelessWidget {
  final Preorder preorder;

  const _PreorderDetailsSheet({required this.preorder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        preorder.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 24),

              // Contenido
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Descripción
                    if (preorder.description.isNotEmpty) ...[
                      Text(
                        'Descripción',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        preorder.description,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Items
                    Text(
                      'Productos (${preorder.orderItems.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...preorder.orderItems.map((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(item.producto.nombre),
                          subtitle: Text(
                            'Precio: \$${item.precio?.precio.toStringAsFixed(2)} | '
                            'IVA: \$${item.tax.toStringAsFixed(2)}',
                          ),
                          trailing: Text(
                            '\$${item.total.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Pagos
                    Text(
                      'Métodos de Pago',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...preorder.paymentOptions.where((p) => p.seleccionado).map(
                      (payment) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.payment,
                              color: colorScheme.secondary,
                            ),
                            title: Text(payment.tipo.name),
                            trailing: Text(
                              '\$${payment.monto.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Resumen
                    Card(
                      color: colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _SummaryRow(
                              'Total Orden:',
                              '\$${preorder.totalOrden.toStringAsFixed(2)}',
                              theme,
                            ),
                            const SizedBox(height: 8),
                            _SummaryRow(
                              'Total Pago:',
                              '\$${preorder.totalPago.toStringAsFixed(2)}',
                              theme,
                            ),
                            const Divider(height: 24),
                            _SummaryRow(
                              'Cambio:',
                              '\$${preorder.cambio.toStringAsFixed(2)}',
                              theme,
                              isHighlight: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool isHighlight;

  const _SummaryRow(
    this.label,
    this.value,
    this.theme, {
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlight ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
