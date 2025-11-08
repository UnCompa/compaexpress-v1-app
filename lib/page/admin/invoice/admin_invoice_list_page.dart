import 'dart:async';
import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/admin/invoice/invoice_details_page.dart';
import 'package:compaexpress/page/superadmin/user/user_list_superadmin_page.dart';
import 'package:compaexpress/page/vendedor/invoice/vendedor_invoice_create_page.dart';
import 'package:compaexpress/services/auditoria_service.dart';
import 'package:compaexpress/services/caja_service.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/services/user_service.dart';
import 'package:compaexpress/utils/get_image_for_bucker.dart';
import 'package:compaexpress/utils/get_token.dart';
import 'package:compaexpress/views/filter_data.dart';
import 'package:compaexpress/views/pagination.dart';
import 'package:compaexpress/widget/print_invoice_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminInvoiceListPage extends StatefulWidget {
  const AdminInvoiceListPage({super.key});

  @override
  State<AdminInvoiceListPage> createState() => _AdminInvoiceListPageState();
}

class _AdminInvoiceListPageState extends State<AdminInvoiceListPage> {
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _roleUser = '';
  int currentPage = 1;
  int itemsPerPage = 4;
  List<Invoice> paginatedInvoices = [];
  FilterValues currentFilters = FilterValues();
  List<User> vendedores = [];
  bool isGeneratePdf = false;
  String _negocioID = "";

  // Subscription variables
  SubscriptionStatus prevSubscriptionStatus = SubscriptionStatus.disconnected;
  StreamSubscription<GraphQLResponse<Invoice>>? onCreateInvoiceSubscription;
  StreamSubscription<GraphQLResponse<Invoice>>? onUpdateInvoiceSubscription;
  StreamSubscription<GraphQLResponse<Invoice>>? onDeleteInvoiceSubscription;

  @override
  void initState() {
    super.initState();
    Amplify.Hub.listen(HubChannel.Api, (ApiHubEvent event) {
      if (event is SubscriptionHubEvent) {
        _handleSubscriptionEvent(event);
      }
    });
    _initializeData();
    _subscribeToInvoiceChanges();
  }

  @override
  void dispose() {
    // Cancelar todas las subscripciones
    onCreateInvoiceSubscription?.cancel();
    onUpdateInvoiceSubscription?.cancel();
    onDeleteInvoiceSubscription?.cancel();
    super.dispose();
  }

  void _handleSubscriptionEvent(SubscriptionHubEvent event) {
    switch (event.status) {
      case SubscriptionStatus.connecting:
        safePrint('Reconnecting to invoice subscriptions...');
        break;
      case SubscriptionStatus.connected:
        if (prevSubscriptionStatus == SubscriptionStatus.connecting ||
            prevSubscriptionStatus == SubscriptionStatus.disconnected) {
          safePrint('Invoice subscriptions reconnected, refreshing data...');
          _loadInvoices(); // Sincronizar datos
        }
        break;
      case SubscriptionStatus.failed:
        safePrint('Invoice subscription failed, attempting to reconnect...');
        // Intentar reconectar después de un delay
        Future.delayed(Duration(seconds: 5), () {
          if (mounted) {
            _subscribeToInvoiceChanges();
          }
        });
        break;
      default:
        break;
    }
    prevSubscriptionStatus = event.status;
  }

  void _subscribeToInvoiceChanges() {
    // Suscripción para onCreate - cuando se crea una factura
    final createSubscriptionRequest = ModelSubscriptions.onCreate(
      Invoice.classType,
    );
    onCreateInvoiceSubscription = Amplify.API
        .subscribe(
          createSubscriptionRequest,
          onEstablished: () =>
              safePrint('Invoice onCreate subscription established'),
        )
        .listen(
          (event) {
            if (event.data != null && mounted) {
              final newInvoice = event.data!;
              safePrint('New invoice created: ${newInvoice.invoiceNumber}');

              // Verificar que pertenece al negocio actual
              if (newInvoice.negocioID == _negocioID &&
                  !newInvoice.isDeleted!) {
                setState(() {
                  // Agregar al inicio de la lista (más reciente primero)
                  _invoices.insert(0, newInvoice);
                  _applyCurrentFilters();
                });

                _showInvoiceNotification(
                  'Nueva factura creada: #${newInvoice.invoiceNumber}',
                  Colors.green,
                );
              }
            }
          },
          onError: (Object e) =>
              safePrint('Error in invoice onCreate subscription: $e'),
        );

    // Suscripción para onUpdate - cuando se actualiza una factura
    final updateSubscriptionRequest = ModelSubscriptions.onUpdate(
      Invoice.classType,
    );
    onUpdateInvoiceSubscription = Amplify.API
        .subscribe(
          updateSubscriptionRequest,
          onEstablished: () =>
              safePrint('Invoice onUpdate subscription established'),
        )
        .listen(
          (event) {
            if (event.data != null && mounted) {
              final updatedInvoice = event.data!;
              safePrint('Invoice updated: ${updatedInvoice.invoiceNumber}');

              // Verificar que pertenece al negocio actual
              if (updatedInvoice.negocioID == _negocioID) {
                setState(() {
                  final index = _invoices.indexWhere(
                    (i) => i.id == updatedInvoice.id,
                  );
                  if (index != -1) {
                    if (updatedInvoice.isDeleted!) {
                      // Si se marcó como eliminada, removerla de la lista
                      _invoices.removeAt(index);
                    } else {
                      // Actualizar la factura existente
                      _invoices[index] = updatedInvoice;
                    }
                  } else if (!updatedInvoice.isDeleted!) {
                    // Si no existe y no está eliminada, agregarla
                    _invoices.insert(0, updatedInvoice);
                  }

                  // Reordenar por fecha (más reciente primero)
                  _invoices.sort(
                    (a, b) => b.invoiceDate.compareTo(a.invoiceDate),
                  );
                  _applyCurrentFilters();
                });

                _showInvoiceNotification(
                  updatedInvoice.isDeleted!
                      ? 'Factura eliminada: #${updatedInvoice.invoiceNumber}'
                      : 'Factura actualizada: #${updatedInvoice.invoiceNumber}',
                  updatedInvoice.isDeleted! ? Colors.red : Colors.blue,
                );
              }
            }
          },
          onError: (Object e) =>
              safePrint('Error in invoice onUpdate subscription: $e'),
        );

    // Suscripción para onDelete - cuando se elimina una factura (opcional)
    final deleteSubscriptionRequest = ModelSubscriptions.onDelete(
      Invoice.classType,
    );
    onDeleteInvoiceSubscription = Amplify.API
        .subscribe(
          deleteSubscriptionRequest,
          onEstablished: () =>
              safePrint('Invoice onDelete subscription established'),
        )
        .listen(
          (event) {
            if (event.data != null && mounted) {
              final deletedInvoice = event.data!;
              safePrint('Invoice deleted: ${deletedInvoice.invoiceNumber}');

              setState(() {
                _invoices.removeWhere((i) => i.id == deletedInvoice.id);
                _applyCurrentFilters();
              });

              _showInvoiceNotification(
                'Factura eliminada: #${deletedInvoice.invoiceNumber}',
                Colors.red,
              );
            }
          },
          onError: (Object e) =>
              safePrint('Error in invoice onDelete subscription: $e'),
        );
  }

  void _showInvoiceNotification(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _applyCurrentFilters() {
    // Aplicar filtros actuales después de cambios en tiempo real
    if (currentFilters.values.isNotEmpty) {
      _filterInvoices(
        currentFilters.values['vendedor'] ?? '',
        currentFilters.values['fechaRegistro']?.toString() ?? '',
      );
    } else {
      _updatePageItems();
    }
  }

  Future<void> _initializeData() async {
    await Future.wait([_loadInvoices(), _getRoleUser(), _fetchSellers()]);
  }

  Future<void> _fetchSellers() async {
    try {
      final info = await NegocioService.getCurrentUserInfo();
      final negocioId = info.negocioId;
      _negocioID = negocioId;
      var token = await GetToken.getIdTokenSimple();
      if (token == null) {
        print('No se pudo obtener el token');
        return;
      }
      print(token.raw);
      final String apiUrl = dotenv.env['API_URL'] ?? 'URL no encontrada';
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

  void _filterInvoices(String sellerEmail, String registrationDate) {
    String? targetSellerId;
    bool filterBySeller = sellerEmail.isNotEmpty;
    bool filterByDate = registrationDate.isNotEmpty;
    // Si no hay ningún filtro, restaurar la lista original y salir
    if (!filterBySeller && !filterByDate) {
      setState(() {
        paginatedInvoices = List.from(
          _invoices,
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
            paginatedInvoices = [];
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
    final newOrdersFilter = _invoices.where((order) {
      // Lógica de filtrado
      bool matchesSeller = true;
      if (filterBySeller) {
        matchesSeller =
            targetSellerId != null &&
            order.sellerID.toLowerCase() == targetSellerId.toLowerCase();
      }

      bool matchesDate = true;
      if (filterByDate) {
        final DateTime invoiceDate = order.invoiceDate.getDateTimeInUtc();
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
      return false;
    }).toList();

    debugPrint("La data filtrada ${newOrdersFilter.length}");

    if (newOrdersFilter.isEmpty &&
        sellerEmail.isEmpty &&
        registrationDate.isEmpty) {
      _updatePageItems();
    }
    setState(() {
      paginatedInvoices = newOrdersFilter;
    });
  }

  void _updatePageItems() {
    paginatedInvoices = PaginationWidget.paginateList(
      _invoices,
      currentPage,
      itemsPerPage,
    );
  }

  void _onPageChanged(int newPage) {
    if (newPage < 1 ||
        newPage > (_invoices.length / itemsPerPage).ceil() ||
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

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final negocio = await NegocioService.getCurrentUserInfo();
      final request = ModelQueries.list(
        Invoice.classType,
        where:
            Invoice.ISDELETED.eq(false) &
            Invoice.NEGOCIOID.eq(negocio.negocioId),
      );
      final response = await Amplify.API.query(request: request).response;
      final invoiceResponse = response.data!.items
          .whereType<Invoice>()
          .toList();

      setState(() {
        _invoices = invoiceResponse;
        _invoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
        _updatePageItems(); // Actualizar la lista paginada después de cargar facturas
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
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

  Future<void> _deleteInvoice(Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de eliminar la factura ${invoice.invoiceNumber}? Esta acción no se puede deshacer.',
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
        throw Exception('Solo los administradores pueden eliminar facturas');
      }

      // Obtener caja y usuario
      final caja = await CajaService.getCurrentCaja();
      if (!caja.isActive) {
        throw Exception('La caja no está activa');
      }
      final userData = await NegocioService.getCurrentUserInfo();

      // Cargar ítems de la factura
      final itemRequest = ModelQueries.list(
        InvoiceItem.classType,
        where: InvoiceItem.INVOICEID.eq(invoice.id),
      );
      final itemResponse = await Amplify.API
          .query(request: itemRequest)
          .response;
      if (itemResponse.data == null) {
        throw Exception('Error al cargar ítems de la factura');
      }
      final items = itemResponse.data!.items.whereType<InvoiceItem>().toList();

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

      // Marcar factura como eliminada
      final updatedInvoice = invoice.copyWith(isDeleted: true);
      final updateInvoiceRequest = ModelMutations.update(updatedInvoice);
      final invoiceResponse = await Amplify.API
          .mutate(request: updateInvoiceRequest)
          .response;
      if (invoiceResponse.data == null) {
        throw Exception(
          'Error al marcar factura como eliminada: ${invoiceResponse.errors}',
        );
      }

      // Actualizar saldo de la caja
      final cajaActualizada = caja.copyWith(
        saldoInicial: caja.saldoInicial - invoice.invoiceReceivedTotal,
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
        origen: 'ANULACION_FACTURA',
        monto: invoice.invoiceReceivedTotal,
        negocioID: userData.negocioId,
        descripcion: 'Anulación de factura ID: ${invoice.id}',
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
        const SnackBar(content: Text('Factura eliminada correctamente')),
      );
      _loadInvoices();
      unawaited(
        _createAuditoriaAsync(
          userId: userData.userId,
          invoice: invoice,
          negocioId: userData.negocioId,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar factura: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createAuditoriaAsync({
    required String userId,
    required Invoice invoice,
    required String negocioId,
  }) async {
    try {
      await AuditoriaService.createAuditoria(
        userId: userId,
        grupo: 'FACTURACION',
        accion: 'ELIMINAR',
        entidad: 'INVOICE',
        entidadId: invoice.id,
        descripcion: 'Eliminación de factura ${invoice.invoiceNumber}',
        negocioId: negocioId,
      );
    } catch (e) {
      print('Error al crear auditoría (segundo plano): $e');
    }
  }

  Future<String?> _generatePDF(Invoice invoice) async {
    try {
      setState(() {
        isGeneratePdf = true;
      });
      final negocio = await NegocioService.getNegocioById(invoice.negocioID);
      if (negocio == null) throw Exception('Negocio no encontrado');

      // Obtener los ítems de la factura
      final itemRequest = ModelQueries.list(
        InvoiceItem.classType,
        where: InvoiceItem.INVOICEID.eq(invoice.id),
      );
      final itemResponse = await Amplify.API
          .query(request: itemRequest)
          .response;
      if (itemResponse.data == null) throw Exception('Error al cargar ítems');

      // Obtener los IDs de los productos de los ítems
      final productoIds = itemResponse.data!.items
          .whereType<InvoiceItem>()
          .map((item) => item.productoID)
          .toSet()
          .toList();

      // Consultar los productos en paralelo
      final productoResponses = await Future.wait(
        productoIds.map(
          (id) => Amplify.API
              .query(
                request: ModelQueries.get(
                  Producto.classType,
                  ProductoModelIdentifier(id: id),
                ),
              )
              .response,
        ),
      );

      // Crear un mapa de productos para acceso rápido
      final productoMap = <String, String>{};
      for (var i = 0; i < productoIds.length; i++) {
        final response = productoResponses[i];
        final producto = response.data;
        productoMap[productoIds[i]] = producto != null
            ? producto.nombre
            : 'Producto no encontrado';
      }

      // Mapear los ítems de la factura
      final invoiceItemsData = itemResponse.data!.items
          .whereType<InvoiceItem>()
          .map((item) {
            final productoNombre =
                productoMap[item.productoID] ?? 'Producto no encontrado';
            return {
              'productoNombre': productoNombre,
              'quantity': item.quantity,
              'subtotal': item.subtotal,
              'total': item.total,
            };
          })
          .toList();

      final lambdaInput = {
        'invoice': {
          'id': invoice.id,
          'invoiceNumber': invoice.invoiceNumber,
          'invoiceDate': invoice.invoiceDate.toString(),
          'invoiceTotal': invoice.invoiceReceivedTotal,
        },
        'invoiceItems': invoiceItemsData,
        'negocio': {
          'id': negocio.id,
          'nombre': negocio.nombre,
          'representante': negocio.representate,
          'ruc': negocio.ruc,
          'telefono': negocio.telefono,
          'correoElectronico': negocio.correoElectronico,
          'pais': negocio.pais,
          'provincia': negocio.provincia,
          'ciudad': negocio.ciudad,
          'movilAccess': negocio.movilAccess,
          'pcAccess': negocio.pcAccess,
          'direccion': negocio.direccion,
          'logo': negocio.logo,
          'isDeleted': negocio.isDeleted,
          'createdAt': negocio.createdAt.toString(),
          'updatedAt': negocio.updatedAt.toString(),
        },
      };

      debugPrint("DATA SEND: $lambdaInput");
      final token = await GetToken.getIdTokenSimple();
      if (token == null) throw Exception('No se pudo obtener el token');
      final String apiUrl = dotenv.env['API_URL'] ?? 'URL no encontrada';
      final lambdaResponse = await http.post(
        Uri.parse('$apiUrl/generate-invoice-pdf'),
        body: Uint8List.fromList(jsonEncode(lambdaInput).codeUnits),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token.raw,
        },
      );

      final pdfUrl = jsonDecode(lambdaResponse.body)['pdfUrl'];
      debugPrint("PDF URL: $pdfUrl");
      final urlFirmada = await GetImageFromBucket.getSignedImageUrls(
        s3Keys: [pdfUrl],
      );
      setState(() {
        isGeneratePdf = false;
      });
      debugPrint("PDF URL FIRMADA: ${urlFirmada.first}");
      // Abrir el PDF con url_launcher
      final pdfUri = Uri.parse(urlFirmada.first);
      if (await canLaunchUrl(pdfUri)) {
        await launchUrl(pdfUri, mode: LaunchMode.platformDefault);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generado y abierto exitosamente')),
        );
      } else {
        throw Exception('No se pudo abrir el PDF');
      }

      return urlFirmada.first;
    } catch (e) {
      setState(() {
        isGeneratePdf = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar o abrir PDF: $e')),
      );
      return null;
    }
  }

  Future<void> _printPDF(String? pdfUrl) async {
    print("IMPRIMIENDO PDF");
    print(pdfUrl);
    if (pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay PDF disponible para imprimir')),
      );
      return;
    }

    try {
      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el PDF')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al imprimir: $e')));
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
        title: const Text('Facturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _loadInvoices,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VendedorCreateInvoiceScreen(),
            ),
          );
          if (result == true) {
            _loadInvoices();
          }
        },
        tooltip: 'Nueva Factura',
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
            Text('Cargando facturas...', style: TextStyle(fontSize: 16)),
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
              'Error al cargar facturas',
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
              onPressed: _loadInvoices,
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

    if (_invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No hay facturas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea una nueva factura con el botón +',
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
          totalItems: _invoices.length,
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
              _filterInvoices(
                currentFilters.values['vendedor'] ?? '',
                currentFilters.values['fechaRegistro']?.toString() ?? '',
              );
              debugPrint('Filtros Actualizados: ${currentFilters.values}');
              // Aquí podrías disparar tu lógica de filtrado de datos
            });
          },
          onClearFilters: () {
            currentFilters = FilterValues();
            _updatePageItems();
          },
          title: 'Filtros',
          initiallyExpanded: false,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadInvoices,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: paginatedInvoices.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final invoice = paginatedInvoices[index];
                return _buildInvoiceCard(invoice);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
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
              builder: (context) => InvoiceDetailScreen(invoice: invoice),
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
                  Expanded(
                    child: Text(
                      'Factura #${invoice.invoiceNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      invoice.invoiceStatus ?? 'Sin estado',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: _getStatusBadgeColor(
                      invoice.invoiceStatus,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fecha: ${dateFormat.format(invoice.invoiceDate.getDateTimeInUtc())}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    '\$${invoice.invoiceReceivedTotal.toStringAsFixed(2)}',
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
                    /* OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InvoiceEditScreen(invoice: invoice),
                          ),
                        ).then((result) {
                          if (result == true) {
                            _loadInvoices();
                          }
                        });
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[600],
                        side: BorderSide(color: Colors.blue[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ), */
                    if (_roleUser == 'admin')
                      OutlinedButton.icon(
                        onPressed: () => _deleteInvoice(invoice),
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
                  PrintInvoiceButton(invoice: invoice),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final pdfUrl = await _generatePDF(invoice);
                      if (pdfUrl != null) {
                        setState(() {}); // Actualizar UI si es necesario
                      }
                    },

                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: Text(
                      !isGeneratePdf ? 'Generar PDF' : 'Generando PDF...',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: !isGeneratePdf
                          ? Colors.blue[600]
                          : Colors.blue[100],
                      side: BorderSide(color: Colors.blue[600]!),
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
