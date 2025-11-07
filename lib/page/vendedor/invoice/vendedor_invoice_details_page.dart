import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/utils/get_image_for_bucker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VendedorInvoiceDetailScreen extends StatefulWidget {
  final Invoice invoice;

  const VendedorInvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<VendedorInvoiceDetailScreen> createState() => _VendedorInvoiceDetailScreenState();
}

class _VendedorInvoiceDetailScreenState extends State<VendedorInvoiceDetailScreen> {
  List<InvoiceItem> _invoiceItems = [];
  final Map<String, Producto> _productCache = {};
  bool _isLoading = true;
  String _errorMessage = '';
  String? imageUrl;
  @override
  void initState() {
    super.initState();
    _loadInvoiceDetails();
  }

  Future<void> _loadInvoiceDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Cargar los items de la factura
      final itemsRequest = ModelQueries.list(
        InvoiceItem.classType,
        where: InvoiceItem.INVOICEID.eq(widget.invoice.id),
      );
      final itemsResponse = await Amplify.API
          .query(request: itemsRequest)
          .response;

      if (itemsResponse.data != null) {
        final imageUrlFirmada = await GetImageFromBucket.getSignedImageUrls(
          s3Keys: [widget.invoice.invoiceImages!.first],
        );
        imageUrl = imageUrlFirmada.first;
        final items = itemsResponse.data!.items
            .whereType<InvoiceItem>()
            .toList();

        // Cargar productos para cada item
        for (final item in items) {
          if (!_productCache.containsKey(item.productoID)) {
            try {
              final productRequest = ModelQueries.get(
                Producto.classType,
                ProductoModelIdentifier(id: item.productoID),
              );

              final productResponse = await Amplify.API
                  .query(request: productRequest)
                  .response;

              if (productResponse.data != null) {
                _productCache[item.productoID] = productResponse.data!;
              } else {
                print('Producto no encontrado para ID: ${item.productoID}');
              }
            } catch (e) {
              print('Error al cargar producto ${item.productoID}: $e');
              // Continuar con el siguiente producto en lugar de fallar completamente
            }
          }
        }

        setState(() {
          _invoiceItems = items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No se pudieron cargar los detalles de la factura';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los detalles: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: Text(
          'Factura #${widget.invoice.invoiceNumber}',
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
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando detalles...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
          ? Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadInvoiceDetails,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(
                        'Reintentar',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con información principal
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1565C0).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Factura',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '#${widget.invoice.invoiceNumber}',
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.attach_money_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '\$${widget.invoice.invoiceReceivedTotal.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comprobante',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1565C0),
                            ),
                          ),
                          if (imageUrl != null)
                            Image.network(imageUrl!, width: 250, height: 250),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1565C0,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_rounded,
                                  color: Color(0xFF1565C0),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Productos',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1565C0),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1565C0,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_invoiceItems.length} items',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1565C0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_invoiceItems.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No hay productos en esta factura',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _invoiceItems.length,
                            separatorBuilder: (context, index) => Divider(
                              color: Colors.grey[200],
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                            ),
                            itemBuilder: (context, index) {
                              final item = _invoiceItems[index];
                              final producto = _productCache[item.productoID];
                              final productName =
                                  producto?.nombre ?? 'Producto desconocido';
                              final subtotal = _calculateItemSubtotal(
                                item,
                                producto,
                              );

                              return Container(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: producto == null
                                            ? Colors.orange.withOpacity(0.1)
                                            : const Color(
                                                0xFF1565C0,
                                              ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        producto == null
                                            ? Icons.warning_rounded
                                            : Icons.shopping_bag_rounded,
                                        color: producto == null
                                            ? Colors.orange[600]
                                            : const Color(0xFF1565C0),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            productName,
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (producto == null)
                                            Text(
                                              'Producto no disponible',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: Colors.orange[600],
                                                fontStyle: FontStyle.italic,
                                              ),
                                            )
                                          else
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.numbers_rounded,
                                                  size: 16,
                                                  color: Colors.grey[500],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Cantidad: ${item.quantity}',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${subtotal.toStringAsFixed(2)}',
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1565C0),
                                          ),
                                        ),
                                        if (producto != null)
                                          Text(
                                            '\$${(producto.precioCompra).toStringAsFixed(2)} c/u',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Método helper para calcular el subtotal de un item
  double _calculateItemSubtotal(InvoiceItem item, Producto? producto) {
    // Prioridad: usar item.subtotal si existe
    return item.subtotal;
  }
}
