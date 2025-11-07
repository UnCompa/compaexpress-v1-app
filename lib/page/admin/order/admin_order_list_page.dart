import 'dart:async';
import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/superadmin/user/user_list_superadmin_page.dart';
import 'package:compaexpress/page/vendedor/order/vendedor_order_create_page.dart';
import 'package:compaexpress/page/vendedor/order/vendedor_order_detail_page.dart';
import 'package:compaexpress/services/auditoria_service.dart';
import 'package:compaexpress/services/caja_service.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/services/user_service.dart';
import 'package:compaexpress/utils/get_token.dart';
import 'package:compaexpress/views/filter_data.dart';
import 'package:compaexpress/views/pagination.dart';
import 'package:compaexpress/widget/print_order_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _roleUser = '';
  int currentPage = 1;
  List<User> vendedores = [];
  int itemsPerPage = 4;
  List<Order> paginatedOrders = [];
  FilterValues currentFilters = FilterValues();
  @override
  void initState() {
    super.initState();
    currentFilters = FilterValues();
    _fetchSellers();
    _loadOrders();
    _getRoleUser();
  }

  Future<void> _fetchSellers() async {
    try {
      final info = await NegocioService.getCurrentUserInfo();
      final negocioId = info.negocioId;
      var token = await GetToken.getIdTokenSimple();
      if (token == null) {
        print('No se pudo obtener el token');
        return;
      }
      //print(token.raw);
      final String apiUrl = dotenv.env['API_URL'] ?? 'URL no encontrada';
      print(apiUrl);
      
      final response = await http.get(
        Uri.parse('$apiUrl/users?negocioId=$negocioId&groupName=vendedor'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": token.raw,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final usersResponse = UsersResponse.fromJson(jsonData);
        debugPrint(usersResponse.users.toString());
        setState(() {
          vendedores = usersResponse.users;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar usuarios: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar usuarios: $e';
      });
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final negocio = await NegocioService.getCurrentUserInfo();
      final request = ModelQueries.list(
        Order.classType,
        where: Order.ISDELETED.eq(false) & Order.NEGOCIOID.eq(negocio.negocioId),
      );
      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        setState(() {
          _orders = response.data!.items.whereType<Order>().toList();
          _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar órdenes: ${response.errors}';
        });
      }
      _updatePageItems();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getRoleUser() async {
    final roleUser = await UserService.getRolUser();
    setState(() {
      _roleUser = roleUser;
    });
  }

  void _filterOrders(String sellerEmail, String registrationDate) {
    debugPrint("ANTES DE FILTRAR: $paginatedOrders");

    String? targetSellerId;
    bool filterBySeller = sellerEmail.trim().isNotEmpty;
    bool filterByDate = registrationDate.trim().isNotEmpty;

    // Si no hay ningún filtro, restaurar la lista original y salir
    if (!filterBySeller && !filterByDate) {
      setState(() {
        paginatedOrders = List.from(
          _orders,
        ); // Restaurar desde la fuente original
        _updatePageItems();
      });
      debugPrint("No hay filtros aplicados, se restauró la lista original.");
      return;
    }

    // Buscar vendedor si se proporcionó correo
    if (filterBySeller) {
      final coincidencias = vendedores.where(
        (seller) => seller.email.toLowerCase() == sellerEmail.toLowerCase(),
      );

      if (coincidencias.isNotEmpty) {
        targetSellerId = coincidencias.first.id;
        debugPrint("VENDEDOR ID: $targetSellerId");
      } else {
        debugPrint(
          'No se encontró ningún vendedor con el correo: $sellerEmail',
        );
        // Si el vendedor no existe, y solo se filtra por vendedor, la lista debe estar vacía
        if (!filterByDate) {
          setState(() {
            paginatedOrders = [];
            _updatePageItems();
          });
          return;
        }
      }
    }

    // Convertir fecha a formato yyyy-MM-dd si viene como DateTime
    String? formattedDate;
    if (filterByDate) {
      try {
        final DateTime parsed = DateTime.parse(registrationDate);
        formattedDate =
            "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
      } catch (e) {
        formattedDate = registrationDate; // ya viene como string
      }
    }

    final newOrdersFilter = _orders.where((order) {
      // Lógica de filtrado
      bool matchesSeller = true;
      if (filterBySeller) {
        matchesSeller =
            targetSellerId != null &&
            order.sellerID.toLowerCase() == targetSellerId.toLowerCase();
      }

      bool matchesDate = true;
      if (filterByDate) {
        final DateTime invoiceDate = order.orderDate.getDateTimeInUtc();
        final formattedInvoiceDate =
            "${invoiceDate.year}-${invoiceDate.month.toString().padLeft(2, '0')}-${invoiceDate.day.toString().padLeft(2, '0')}";
        matchesDate = formattedInvoiceDate == formattedDate;
      }

      // Combinar los filtros con AND para que se cumplan ambos o uno de ellos si solo ese está activo
      if (filterBySeller && filterByDate) {
        return matchesSeller && matchesDate;
      } else if (filterBySeller) {
        return matchesSeller;
      } else if (filterByDate) {
        return matchesDate;
      }
      return false; // Esto no debería alcanzarse si la lógica inicial funciona
    }).toList();

    debugPrint("La data filtrada ${newOrdersFilter.length}");

    if(newOrdersFilter.isEmpty && sellerEmail.isEmpty && registrationDate.isEmpty) {
      _updatePageItems();
    }
    setState(() {
      paginatedOrders = newOrdersFilter;
    });
  }

  void _onPageChanged(int newPage) {
    if (newPage < 1 ||
        newPage > (_orders.length / itemsPerPage).ceil() ||
        _isLoading) {
      return; // Evita cambios de página inválidos o mientras carga
    }

    setState(() {
      _isLoading =
          true; // Opcional: para indicar que está "cargando" la nueva página
    });

    setState(() {
      currentPage = newPage;
      _updatePageItems();
      _isLoading = false;
    });
  }

  void _updatePageItems() {
    paginatedOrders = PaginationWidget.paginateList(
      _orders,
      currentPage,
      itemsPerPage,
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

    setState(() => _isLoading = true);
    try {
      // Verificar permisos
      if (_roleUser != 'admin') {
        throw Exception('Solo los administradores pueden eliminar órdenes');
      }

      // Obtener caja y usuario
      final caja = await CajaService.getCurrentCaja();
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
        final itemResponse = await Amplify.API
            .mutate(request: updateItemRequest)
            .response;
        if (itemResponse.data == null) {
          throw Exception(
            'Error al marcar ítem como eliminado: ${itemResponse.errors}',
          );
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
          // Obtener precio usado
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
          final productUpdateResponse = await Amplify.API
              .mutate(request: updateProductRequest)
              .response;
          if (productUpdateResponse.data == null) {
            throw Exception(
              'Error al actualizar stock: ${productUpdateResponse.errors}',
            );
          }
        }
      }

      // Marcar orden como eliminada
      final updatedOrder = order.copyWith(isDeleted: true);
      final updateOrderRequest = ModelMutations.update(updatedOrder);
      final orderResponse = await Amplify.API
          .mutate(request: updateOrderRequest)
          .response;
      if (orderResponse.data == null) {
        throw Exception(
          'Error al marcar orden como eliminada: ${orderResponse.errors}',
        );
      }

      // Actualizar saldo de la caja
      final cajaActualizada = caja.copyWith(
        saldoInicial: caja.saldoInicial - order.orderReceivedTotal,
      );
      final updateCajaRequest = ModelMutations.update(cajaActualizada);
      final cajaResponse = await Amplify.API
          .mutate(request: updateCajaRequest)
          .response;
      if (cajaResponse.data == null) {
        throw Exception('Error al actualizar caja: ${cajaResponse.errors}');
      }

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
      final movementResponse = await Amplify.API
          .mutate(request: createMovementRequest)
          .response;
      if (movementResponse.data == null) {
        throw Exception(
          'Error al crear movimiento de caja: ${movementResponse.errors}',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Orden eliminada correctamente')),
      );
      _loadOrders();
      unawaited(
        _createAuditoriaAsync(
          userId: userData.userId,
          order: order,
          negocioId: userData.negocioId,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar orden: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _createAuditoriaAsync({
    required String userId,
    required Order order,
    required String negocioId,
  }) async {
    try {
      await AuditoriaService.createAuditoria(
        userId: userId,
        grupo: 'FACTURACION',
        accion: 'ELIMINAR',
        entidad: 'INVOICE',
        entidadId: order.id,
        descripcion: 'Eliminación de orden ${order.orderNumber}',
        negocioId: negocioId,
      );
    } catch (e) {
      print('Error al crear auditoría (segundo plano): $e');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VendedorOrderCreatePage()),
          );
          if (result == true) {
            _loadOrders();
          }
        },
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        tooltip: 'Nueva Orden',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando órdenes...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
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
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
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

    if (_orders.isEmpty) {
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
          currentPage: currentPage,
          totalItems: _orders.length,
          itemsPerPage: itemsPerPage,
          onPageChanged: _onPageChanged,
          isLoading: _isLoading,
        ),
        GenericFilterWidget(
          filterFields: [
            FilterBuilder.dropdown(
              key: 'vendedor',
              label: 'Vendedor',
              options: vendedores.map((e) => e.email).toList(),
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
              _filterOrders(
                currentFilters.values['vendedor'] ?? '',
                currentFilters.values['fechaRegistro']?.toString() ?? '',
              );
              print('Filtros Actualizados: ${currentFilters.values}');
              // Aquí podrías disparar tu lógica de filtrado de datos
            });
          },
          onClearFilters: () {
            print('Filtros Limpiados');
            currentFilters = FilterValues();
            _updatePageItems();
          },
          title: 'Filtros',
          initiallyExpanded: false,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView.builder(
              itemCount: paginatedOrders.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final order = paginatedOrders[index];
                return _buildOrderCard(order);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    final dateFormat = DateFormat('dd/MM/yyyy');
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
                  SizedBox(width: 8),
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
                    'Fecha: ${dateFormat.format(DateTime.parse(order.orderDate.toString()))}',
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
                  if (_roleUser == 'admin')
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
                            _loadOrders();
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
                  if (_roleUser == 'admin')
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
