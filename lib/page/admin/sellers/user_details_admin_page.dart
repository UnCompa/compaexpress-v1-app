import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/admin/sellers/user_list_admin_page.dart';
import 'package:compaexpress/services/negocio/negocio_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class UserDetailsAdminPage extends StatefulWidget {
  final User user;
  const UserDetailsAdminPage({super.key, required this.user});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailsAdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> invoices = [];
  List<Map<String, dynamic>> orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final negocio = await NegocioController.getUserInfo();
      final negocioId = negocio.negocioId;

      final invoiceRequest = ModelQueries.list(
        Invoice.classType,
        where: Invoice.NEGOCIOID
            .eq(negocioId)
            .and(Invoice.SELLERID.eq(widget.user.id))
            .and(Invoice.ISDELETED.eq(false)),
      );
      final invoiceResponse = await Amplify.API
          .query(request: invoiceRequest)
          .response;

      final orderRequest = ModelQueries.list(
        Order.classType,
        where: Order.NEGOCIOID
            .eq(negocioId)
            .and(Order.SELLERID.eq(widget.user.id))
            .and(Order.ISDELETED.eq(false)),
      );
      final orderResponse = await Amplify.API
          .query(request: orderRequest)
          .response;

      final List<Map<String, dynamic>> fetchedInvoices = [];
      for (final invoice in invoiceResponse.data!.items) {
        final request = ModelQueries.list(
          InvoiceItem.classType,
          where: InvoiceItem.INVOICEID.eq(invoice!.id),
        );
        final invoiceItems = await Amplify.API.query(request: request).response;
        fetchedInvoices.add({
          'id': invoice.id,
          'sellerID': invoice.sellerID,
          'invoiceNumber': invoice.invoiceNumber,
          'invoiceDate': invoice.invoiceDate.toString(),
          'invoiceReceivedTotal': invoice.invoiceReceivedTotal,
          'invoiceReturnedTotal': invoice.invoiceReturnedTotal,
          'invoiceStatus': invoice.invoiceStatus,
          'invoiceItems': invoiceItems.data!.items
              .map(
                (item) => {
                  'id': item!.id,
                  'productoID': item.productoID,
                  'quantity': item.quantity,
                  'subtotal': item.subtotal,
                  'total': item.total,
                },
              )
              .toList(),
        });
      }

      final List<Map<String, dynamic>> fetchedOrders = [];
      for (final order in orderResponse.data!.items) {
        final request = ModelQueries.list(
          OrderItem.classType,
          where: OrderItem.ORDERID.eq(order!.id),
        );
        final orderItems = await Amplify.API.query(request: request).response;
        fetchedOrders.add({
          'id': order.id,
          'sellerID': order.sellerID,
          'orderNumber': order.orderNumber,
          'orderDate': order.orderDate.toString(),
          'orderReceivedTotal': order.orderReceivedTotal,
          'orderReturnedTotal': order.orderReturnedTotal,
          'orderStatus': order.orderStatus,
          'orderItems': orderItems.data!.items
              .map(
                (item) => {
                  'id': item!.id,
                  'productoID': item.productoID,
                  'quantity': item.quantity,
                  'subtotal': item.subtotal,
                  'total': item.total,
                },
              )
              .toList(),
        });
      }

      setState(() {
        invoices = fetchedInvoices;
        orders = fetchedOrders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Error al cargar datos: $e'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles del usuario ${widget.user.email}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: colorScheme.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.onPrimary,
              indicatorWeight: 3,
              labelColor: colorScheme.onPrimary,
              unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7),
              labelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.titleSmall,
              tabs: const [
                Tab(
                  icon: Icon(Icons.receipt_long, size: 20),
                  text: 'Facturas',
                ),
                Tab(
                  icon: Icon(Icons.shopping_bag, size: 20),
                  text: 'Órdenes',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInvoiceList(),
          _buildOrderList(),
        ],
      ),
    );
  }

  Widget _buildInvoiceList() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }
    
    if (invoices.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No hay facturas',
        subtitle: 'Este usuario aún no tiene facturas registradas.',
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildItemCard(
                  context,
                  item: invoice,
                  type: 'Factura',
                  number: invoice['invoiceNumber'],
                  date: invoice['invoiceDate'],
                  total: invoice['invoiceReceivedTotal'],
                  status: invoice['invoiceStatus'],
                  items: invoice['invoiceItems'],
                  icon: Icons.receipt_long,
                  isPrimary: true,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderList() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }
    
    if (orders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'No hay órdenes',
        subtitle: 'Este usuario aún no tiene órdenes registradas.',
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildItemCard(
                  context,
                  item: order,
                  type: 'Orden',
                  number: order['orderNumber'],
                  date: order['orderDate'],
                  total: order['orderReceivedTotal'],
                  status: order['orderStatus'],
                  items: order['orderItems'],
                  icon: Icons.shopping_bag,
                  isPrimary: false,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context, {
    required Map<String, dynamic> item,
    required String type,
    required String number,
    required String date,
    required num total,
    required String status,
    required List<dynamic> items,
    required IconData icon,
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final DateTime parsedDate = DateTime.parse(date);
    final String formattedDate = DateFormat('dd MMM yyyy', 'es').format(parsedDate);

    final statusInfo = _getStatusInfo(status, colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Theme(
        data: theme.copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isPrimary ? colorScheme.primary : colorScheme.secondary)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isPrimary ? colorScheme.primary : colorScheme.secondary,
              size: 24,
            ),
          ),
          title: Text(
            '$type #$number',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo['color'],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusInfo['icon'],
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Productos (${items.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...items.map<Widget>(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.shopping_basket,
                              size: 20,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID: ${item['productoID']}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cantidad: ${item['quantity']}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${item['total'].toStringAsFixed(2)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
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

  Map<String, dynamic> _getStatusInfo(String status, ColorScheme colorScheme) {
    switch (status.toUpperCase()) {
      case 'PENDIENTE':
        return {
          'color': Colors.orange.shade600,
          'icon': Icons.pending,
        };
      case 'COMPLETADA':
      case 'COMPLETADO':
        return {
          'color': Colors.green.shade600,
          'icon': Icons.check_circle,
        };
      case 'CANCELADA':
      case 'CANCELADO':
        return {
          'color': Colors.red.shade600,
          'icon': Icons.cancel,
        };
      default:
        return {
          'color': Colors.grey.shade600,
          'icon': Icons.info,
        };
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: colorScheme.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          highlightColor: colorScheme.surface,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}