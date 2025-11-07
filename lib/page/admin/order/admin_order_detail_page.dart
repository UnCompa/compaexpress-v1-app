import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/entities/order_with_product.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: Text(
          'Detalles de Orden #${order.orderNumber}',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<OrderItemWithProduct>>(
        future: _fetchOrderItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFE57373),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar los datos',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF757575),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          final orderItems = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.receipt_long,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Orden #${order.orderNumber}',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusText(order.orderStatus),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información de la Orden',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Order Information Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información de la Orden',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Fecha',
                          dateFormat.format(
                            DateTime.parse(order.orderDate.toString()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.info_outline,
                          'Estado',
                          _getStatusText(order.orderStatus),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.attach_money,
                          'Total',
                          '\$${order.orderReceivedTotal.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Order Items Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.shopping_cart,
                              color: Color(0xFF1565C0),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ítems de la Orden',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1565C0),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1565C0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${orderItems.length} items',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1565C0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (orderItems.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 48,
                                  color: Color(0xFFBDBDBD),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No hay ítems en esta orden',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: const Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: orderItems.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: Color(0xFFE0E0E0),
                            ),
                            itemBuilder: (context, index) {
                              final item = orderItems[index];
                              return _buildOrderItem(item);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1565C0)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF424242),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? const Color(0xFF2E7D32) : const Color(0xFF1565C0),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(OrderItemWithProduct item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF1565C0),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Producto: ${item.producto!.nombre}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Cantidad: ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    Text(
                      '${item.orderItem.quantity}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Subtotal: ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    Text(
                      '\$${item.orderItem.subtotal.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF424242),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.orderItem.total.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    if (status == null || status.isEmpty) {
      return 'Sin estado';
    }
    return status;
  }

  Future<List<OrderItemWithProduct>> _fetchOrderItems() async {
    // Consultar los OrderItem
    final request = ModelQueries.list(
      OrderItem.classType,
      where: OrderItem.ORDERID.eq(order.id),
    );
    final response = await Amplify.API.query(request: request).response;
    final orderItems =
        response.data?.items.whereType<OrderItem>().toList() ?? [];

    // Obtener todos los productoID únicos
    final productoIds = orderItems
        .map((item) => item.productoID)
        .whereType<String>()
        .toSet();

    // Consultar todos los Productos
    final productRequest = ModelQueries.list(Producto.classType);
    final productResponse = await Amplify.API
        .query(request: productRequest)
        .response;
    final products =
        productResponse.data?.items
            .whereType<Producto>()
            .where((product) => productoIds.contains(product.id))
            .toList() ??
        [];

    // Crear un mapa de Productos por ID
    final productMap = {for (var p in products) p.id: p};

    // Combinar OrderItem con su Producto
    final List<OrderItemWithProduct> orderItemsWithProduct = orderItems.map((
      orderItem,
    ) {
      return OrderItemWithProduct(
        orderItem: orderItem,
        producto: productMap[orderItem.productoID],
      );
    }).toList();

    return orderItemsWithProduct;
  }
}
