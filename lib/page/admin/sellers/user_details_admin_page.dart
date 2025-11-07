import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/admin/sellers/user_list_admin_page.dart';
import 'package:compaexpress/services/negocio/negocio_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // Simulación de obtención de datos (reemplaza con tu lógica de Amplify o API)
  void _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      // Obtener información del negocio
      final negocio = await NegocioController.getUserInfo();
      final negocioId = negocio.negocioId;

      // Consultar facturas filtradas por negocioID, sellerID y isDeleted: false
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

      // Consultar órdenes filtradas por negocioID, sellerID y isDeleted: false
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

      // Obtener ítems de facturas
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
          //'invoiceType': invoice.invoiceType,
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

      // Obtener ítems de órdenes
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
          //'orderType': order.orderType,
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

      // Actualizar el estado con los datos obtenidos
      setState(() {
        invoices = fetchedInvoices;
        orders = fetchedOrders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Manejo de errores
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del usuario: ${widget.user.email}'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Facturas'),
            Tab(text: 'Órdenes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildInvoiceList(), _buildOrderList()],
      ),
    );
  }

  Widget _buildInvoiceList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Cargando....',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    if (invoices.isEmpty) {
      return const Center(
        child: Text(
          'No hay facturas para este usuario.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return _buildItemCard(
          context,
          item: invoice,
          type: 'Factura',
          number: invoice['invoiceNumber'],
          date: invoice['invoiceDate'],
          total: invoice['invoiceReceivedTotal'],
          status: invoice['invoiceStatus'],
          items: invoice['invoiceItems'],
          color: Colors.blue[50]!,
          icon: Icons.receipt,
        );
      },
    );
  }

  Widget _buildOrderList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Cargando....',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No hay órdenes para este usuario.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildItemCard(
          context,
          item: order,
          type: 'Orden',
          number: order['orderNumber'],
          date: order['orderDate'],
          total: order['orderReceivedTotal'],
          status: order['orderStatus'],
          items: order['orderItems'],
          color: Colors.green[50]!,
          icon: Icons.shopping_cart,
        );
      },
    );
  }

  // Método común para construir tarjetas de facturas y órdenes
  Widget _buildItemCard(
    BuildContext context, {
    required Map<String, dynamic> item,
    required String type,
    required String number,
    required String date,
    required num total,
    required String status,
    required List<dynamic> items,
    required Color color,
    required IconData icon,
  }) {
    // Formatear la fecha
    final DateTime parsedDate = DateTime.parse(date);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);

    // Mapear estados a colores
    final Map<String, Color> statusColors = {
      'PENDIENTE': Colors.orange,
      'COMPLETADA': Colors.green,
      'CANCELADA': Colors.red,
      // Agrega más estados según sea necesario
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blue[800], size: 30),
        title: Text(
          '$type #$number',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Fecha: $formattedDate'),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Text('Estado: $status'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColors[status] ?? Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalles de los ítems:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...items.map<Widget>(
                  (item) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    title: Text('Producto ID: ${item['productoID']}'),
                    subtitle: Text(
                      'Cantidad: ${item['quantity']} - Total: \$${item['total'].toStringAsFixed(2)}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
