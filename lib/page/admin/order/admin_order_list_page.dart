import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/admin/sellers/user_list_admin_page.dart';
import 'package:compaexpress/page/vendedor/order/vendedor_order_create_page.dart';
import 'package:compaexpress/page/vendedor/order/vendedor_order_detail_page.dart';
import 'package:compaexpress/providers/order_provider.dart';
import 'package:compaexpress/services/auditoria_service.dart';
import 'package:compaexpress/services/caja_service.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/services/user_service.dart';
import 'package:compaexpress/utils/fecha_ecuador.dart';
import 'package:compaexpress/views/filter_data.dart';
import 'package:compaexpress/views/pagination.dart';
import 'package:compaexpress/widget/print_order_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
// Provider para el rol del usuario
final userRoleProvider = FutureProvider<String>((ref) async {
  return await UserService.getRolUser();
});

class AdminOrderListScreen extends ConsumerStatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  ConsumerState<AdminOrderListScreen> createState() =>
      _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends ConsumerState<AdminOrderListScreen> {
  FilterValues currentFilters = FilterValues();

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales
    Future.microtask(() {
      ref.read(orderProvider.notifier).loadOrders();
    });
  }

  void _handleFilterChange(String sellerEmail, String registrationDate) {
    final sellers = ref.read(sellersProvider).value ?? [];

    String? targetSellerId;
    if (sellerEmail.trim().isNotEmpty) {
      final seller = sellers.firstWhere(
        (s) => s.email.toLowerCase() == sellerEmail.toLowerCase(),
        orElse: () => User(
          id: '',
          email: '',
          username: '',
          status: '',
          createdAt: DateTime.now(),
          enabled: false,
        ),
      );
      if (seller.id.isNotEmpty) {
        targetSellerId = seller.id;
      }
    }

    ref
        .read(filterProvider.notifier)
        .setSellerFilter(sellerEmail.trim().isEmpty ? null : targetSellerId);
    ref
        .read(filterProvider.notifier)
        .setDateFilter(
          registrationDate.trim().isEmpty ? null : registrationDate,
        );
  }

  Future<void> _deleteOrder(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de eliminar la orden ${order.orderNumber}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final roleUser = await ref.read(userRoleProvider.future);

      if (roleUser != 'admin') {
        throw Exception('Solo los administradores pueden eliminar órdenes');
      }

      final caja = await CajaService.getCurrentCaja(forceRefresh: true);
      if (!caja.isActive) {
        throw Exception('La caja no está activa');
      }
      final userData = await NegocioService.getCurrentUserInfo();

      // Cargar ítems de la orden
      final itemRequest = ModelQueries.list(
        OrderItem.classType,
        where: OrderItem.ORDERID.eq(order.id),
      );
      final itemResponse = await Amplify.API
          .query(request: itemRequest)
          .response;

      if (itemResponse.data == null) {
        throw Exception('Error al cargar ítems de la orden');
      }

      final items = itemResponse.data!.items.whereType<OrderItem>().toList();

      // Marcar ítems como eliminados y ajustar stock
      for (var item in items) {
        final updatedItem = item.copyWith(isDeleted: true);
        final updateItemRequest = ModelMutations.update(updatedItem);
        final itemUpdateResponse = await Amplify.API
            .mutate(request: updateItemRequest)
            .response;

        if (itemUpdateResponse.data == null) {
          throw Exception('Error al marcar ítem como eliminado');
        }

        // Obtener producto y actualizar stock
        final productRequest = ModelQueries.get(
          Producto.classType,
          ProductoModelIdentifier(id: item.productoID),
        );
        final productResponse = await Amplify.API
            .query(request: productRequest)
            .response;
        final producto = productResponse.data;

        if (producto != null) {
          final priceRequest = ModelQueries.get(
            ProductoPrecios.classType,
            ProductoPreciosModelIdentifier(id: item.precioID!),
          );
          final precioResponse = await Amplify.API
              .query(request: priceRequest)
              .response;

          final int unidadesVendidas =
              item.quantity * precioResponse.data!.quantity;
          final updatedProduct = producto.copyWith(
            stock: producto.stock + unidadesVendidas,
          );
          final updateProductRequest = ModelMutations.update(updatedProduct);
          await Amplify.API.mutate(request: updateProductRequest).response;
        }
      }

      // Marcar orden como eliminada
      final updatedOrder = order.copyWith(isDeleted: true);
      final updateOrderRequest = ModelMutations.update(updatedOrder);
      await Amplify.API.mutate(request: updateOrderRequest).response;

      // Actualizar saldo de la caja
      final cajaActualizada = caja.copyWith(
        saldoInicial: caja.saldoInicial - order.orderReceivedTotal,
      );
      final updateCajaRequest = ModelMutations.update(cajaActualizada);
      await Amplify.API.mutate(request: updateCajaRequest).response;

      // Registrar movimiento de caja
      final movement = CajaMovimiento(
        cajaID: caja.id,
        tipo: 'EGRESO',
        origen: 'ANULACION_ORDEN',
        monto: order.orderReceivedTotal,
        negocioID: userData.negocioId,
        descripcion: 'Anulación de orden ID: ${order.id}',
        isDeleted: false,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
      );
      final createMovementRequest = ModelMutations.create(movement);
      await Amplify.API.mutate(request: createMovementRequest).response;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orden eliminada correctamente')),
        );
      }

      // Recargar órdenes
      ref.read(orderProvider.notifier).loadOrders();

      // Crear auditoría de forma asíncrona
      unawaited(
        AuditoriaService.createAuditoria(
          userId: userData.userId,
          grupo: 'FACTURACION',
          accion: 'ELIMINAR',
          entidad: 'INVOICE',
          entidadId: order.id,
          descripcion: 'Eliminación de orden ${order.orderNumber}',
          negocioId: userData.negocioId,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar orden: $e')));
      }
    }
  }

  Color _getStatusBadgeColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pagada':
        return Colors.green[600]!;
      case 'pendiente':
        return Colors.orange[600]!;
      case 'vencida':
        return Colors.red[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final paginatedOrders = ref.watch(paginatedFilteredOrdersProvider);
    final totalPages = ref.watch(totalPagesProvider);
    final sellersAsync = ref.watch(sellersProvider);
    final userRoleAsync = ref.watch(userRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () => ref.read(orderProvider.notifier).loadOrders(),
          ),
        ],
      ),
      body: _buildBody(
        orderState: orderState,
        paginatedOrders: paginatedOrders,
        totalPages: totalPages,
        sellersAsync: sellersAsync,
        userRoleAsync: userRoleAsync,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VendedorOrderCreatePage(),
            ),
          );
          if (result == true) {
            ref.read(orderProvider.notifier).loadOrders();
          }
        },
        tooltip: 'Nueva Orden',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody({
    required OrderState orderState,
    required List<Order> paginatedOrders,
    required int totalPages,
    required AsyncValue<List<User>> sellersAsync,
    required AsyncValue<String> userRoleAsync,
  }) {
    if (orderState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLoadingIndicator(),
            SizedBox(height: 16),
            Text('Cargando órdenes...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (orderState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 12),
            Text(
              'Error al cargar órdenes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                orderState.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(orderProvider.notifier).loadOrders(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (orderState.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No hay órdenes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea una nueva orden con el botón +',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        PaginationWidget(
          currentPage: orderState.currentPage,
          totalItems: ref.watch(filteredOrdersProvider).length,
          itemsPerPage: orderState.itemsPerPage,
          onPageChanged: (page) =>
              ref.read(orderProvider.notifier).setPage(page),
          isLoading: orderState.isLoading,
        ),
        sellersAsync.when(
          data: (sellers) => GenericFilterWidget(
            filterFields: [
              FilterBuilder.dropdown(
                key: 'vendedor',
                label: 'Vendedor',
                options: sellers.map((e) => e.email).toList(),
                icon: Icons.check_circle_outline,
              ),
              FilterBuilder.singleDate(
                key: 'fechaRegistro',
                label: 'Fecha de Registro',
                icon: Icons.event,
              ),
            ],
            filterValues: currentFilters,
            onFiltersChanged: (newFilterValues) {
              setState(() {
                currentFilters = newFilterValues;
                _handleFilterChange(
                  currentFilters.values['vendedor'] ?? '',
                  currentFilters.values['fechaRegistro']?.toString() ?? '',
                );
              });
            },
            onClearFilters: () {
              setState(() {
                currentFilters = FilterValues();
                ref.read(filterProvider.notifier).clearFilters();
              });
            },
            title: 'Filtros',
            initiallyExpanded: false,
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(orderProvider.notifier).loadOrders(),
            child: paginatedOrders.isEmpty
                ? _buildEmptyFilteredState()
                : ListView.builder(
                    itemCount: paginatedOrders.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      return _buildOrderCard(
                        paginatedOrders[index],
                        userRoleAsync.value,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFilteredState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No hay resultados',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta ajustar los filtros',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, String? roleUser) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.add_box, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Orden #${order.orderNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      order.orderStatus ?? 'Sin estado',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: _getStatusBadgeColor(order.orderStatus),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fecha: ${FechaEcuador.formatearDesdeTemporal(order.orderDate.toString(), conHora: true)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    '\$${order.orderReceivedTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (roleUser == 'admin')
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailScreen(order: order),
                          ),
                        ).then((result) {
                          if (result == true) {
                            ref.read(orderProvider.notifier).loadOrders();
                          }
                        });
                      },
                      icon: const Icon(Icons.remove_red_eye, size: 16),
                      label: const Text('Ver más'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[600],
                        side: BorderSide(color: Colors.blue[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  PrintOrderButton(order: order),
                  if (roleUser == 'admin')
                    OutlinedButton.icon(
                      onPressed: () => _deleteOrder(order),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Eliminar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[600],
                        side: BorderSide(color: Colors.red[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
