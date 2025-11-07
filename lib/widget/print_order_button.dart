import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/entities/order_with_details.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/providers/printer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrintOrderButton extends ConsumerStatefulWidget {
  final Order order;

  const PrintOrderButton({super.key, required this.order});

  @override
  ConsumerState<PrintOrderButton> createState() => _PrintOrderButtonState();
}

class _PrintOrderButtonState extends ConsumerState<PrintOrderButton> {
  bool _isLoading = false;

  /// Obtiene todos los detalles de la orden con sus productos y precios
  /// VERSIÓN OPTIMIZADA: Carga precios y productos en paralelo
  Future<OrderWithDetails?> getOrderDetails(Order order) async {
    try {
      // 1. Obtener todos los items de la orden
      final itemsResponse = await Amplify.API
          .query(
            request: ModelQueries.list(
              OrderItem.classType,
              where: OrderItem.ORDERID.eq(order.id),
            ),
          )
          .response;

      final orderItems =
          itemsResponse.data?.items
              .whereType<OrderItem>()
              .where((item) => item.isDeleted != true)
              .toList() ??
          [];

      if (orderItems.isEmpty) {
        debugPrint('No se encontraron items para la orden ${order.id}');
        return null;
      }

      debugPrint('📦 Cargando ${orderItems.length} items de la orden...');

      // 2. Crear futures para cargar precios y productos en paralelo
      final List<Future<OrderDetailsWithProductsAndPrice?>> detailsFutures =
          orderItems.map((item) async {
            try {
              // Cargar precio y producto en paralelo
              final results = await Future.wait([
                Amplify.API
                    .query(
                      request: ModelQueries.get(
                        ProductoPrecios.classType,
                        ProductoPreciosModelIdentifier(id: item.precioID ?? ""),
                      ),
                    )
                    .response,
                Amplify.API
                    .query(
                      request: ModelQueries.get(
                        Producto.classType,
                        ProductoModelIdentifier(id: item.productoID),
                      ),
                    )
                    .response,
              ]);

              final price = results[0].data as ProductoPrecios?;
              final product = results[1].data as Producto?;

              if (price == null || product == null) {
                debugPrint(
                  '⚠️ Datos incompletos para item ${item.id}: '
                  'precio=${price != null}, producto=${product != null}',
                );
                return null;
              }

              return OrderDetailsWithProductsAndPrice(
                orderItem: item,
                precios: price,
                productos: product,
              );
            } catch (e) {
              debugPrint('❌ Error procesando item ${item.id}: $e');
              return null;
            }
          }).toList();

      // 3. Esperar a que todos los futures se completen
      final allResults = await Future.wait(detailsFutures);

      // 4. Filtrar los resultados nulos
      final validDetails = allResults
          .whereType<OrderDetailsWithProductsAndPrice>()
          .toList();

      if (validDetails.isEmpty) {
        throw Exception(
          'No se pudieron cargar los detalles de ningún producto',
        );
      }

      debugPrint(
        '✅ Se cargaron ${validDetails.length} de ${orderItems.length} items',
      );

      // 5. Retornar todos los detalles juntos
      return OrderWithDetails(order: order, orderDetails: validDetails);
    } catch (e, stackTrace) {
      debugPrint('Error en getOrderDetails: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Imprime la orden
  Future<void> _printOrder(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final orderDetails = await getOrderDetails(widget.order);

      if (orderDetails == null || orderDetails.orderDetails.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se encontraron detalles para esta orden'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Imprimir
      await ref
          .read(printerProvider.notifier)
          .printOrder(orderDetails, context, ref);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Orden #${widget.order.orderNumber} impresa '
                    '(${orderDetails.orderDetails.length} productos)',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error al imprimir la orden: $e\n$stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error al imprimir',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  e.toString().length > 100
                      ? '${e.toString().substring(0, 97)}...'
                      : e.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _printOrder(context),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : () => _printOrder(context),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isLoading
            ? const SizedBox(
                key: ValueKey('loading'),
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue,
                ),
              )
            : const Icon(Icons.print, key: ValueKey('print'), size: 16),
      ),
      label: Text(_isLoading ? 'Imprimiendo...' : 'Imprimir'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue[600],
        side: BorderSide(color: Colors.blue[600]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
