import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:compaexpress/models/Categoria.dart';
import 'package:compaexpress/models/Producto.dart';
import 'package:compaexpress/models/ProductoPrecios.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/utils/get_image_for_bucker.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
import 'package:flutter/material.dart';

class VendedorViewProductsScreen extends StatefulWidget {
  const VendedorViewProductsScreen({super.key});

  @override
  _VendedorViewProductsScreenState createState() =>
      _VendedorViewProductsScreenState();
}

class _VendedorViewProductsScreenState
    extends State<VendedorViewProductsScreen> {
  List<Producto> _allProducts = [];
  List<Producto> _filteredProducts = [];

  SubscriptionStatus prevSubscriptionStatus = SubscriptionStatus.disconnected;
  StreamSubscription<GraphQLResponse<Producto>>? onCreateSubscription;
  StreamSubscription<GraphQLResponse<Producto>>? onUpdateSubscription;

  List<Categoria> _categories = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  String _negocioID = "";
  bool _isLoading = true;
  String _sortBy = 'nombre'; // nombre, precio, stock

  @override
  void initState() {
    super.initState();
    Amplify.Hub.listen(HubChannel.Api, (ApiHubEvent event) {
      if (event is SubscriptionHubEvent) {
        if (prevSubscriptionStatus == SubscriptionStatus.connecting &&
            event.status == SubscriptionStatus.connected) {
          _getProductosByNegocio();
        }
        prevSubscriptionStatus = event.status;
      }
    });
    _initializeData();
    _searchController.addListener(_filterProducts);
    subscribe();
  }

  void subscribe() {
    // Suscripción para onCreate
    final subscriptionRequest = ModelSubscriptions.onCreate(Producto.classType);
    onCreateSubscription = Amplify.API
        .subscribe(
          subscriptionRequest,
          onEstablished: () => safePrint('Subscription on Created established'),
        )
        .listen(
          (event) {
            if (event.data != null) {
              safePrint('Data Event: ${event.data}');
              // MEJORA 1: Verificar que el producto pertenece al negocio actual
              if (event.data!.negocioID == _negocioID) {
                setState(() {
                  _allProducts.add(event.data!);
                  _filterProducts(); // MEJORA 2: Aplicar filtros después de agregar
                });

                // MEJORA 3: Mostrar notificación opcional
                _showProductAddedNotification(event.data!);
              }
            }
          },
          onError: (Object e) =>
              safePrint('Error in onCreate subscription: $e'),
        );

    // Suscripción para onUpdate
    final subscriptionRequestUpdated = ModelSubscriptions.onUpdate(
      Producto.classType,
    );
    onUpdateSubscription = Amplify.API
        .subscribe(
          subscriptionRequestUpdated,
          onEstablished: () => safePrint('Subscription on Updated established'),
        )
        .listen(
          (event) {
            if (event.data != null) {
              safePrint('Data Event: ${event.data}');
              // MEJORA 4: Verificar que el producto pertenece al negocio actual
              if (event.data!.negocioID == _negocioID) {
                setState(() {
                  final index = _allProducts.indexWhere(
                    (p) => p.id == event.data!.id,
                  );
                  if (index != -1) {
                    _allProducts[index] = event.data!;
                  } else {
                    _allProducts.add(event.data!);
                  }
                  _filterProducts(); // MEJORA 5: Aplicar filtros después de actualizar
                });

                // MEJORA 6: Mostrar notificación opcional
                _showProductUpdatedNotification(event.data!);
              }
            }
          },
          onError: (Object e) =>
              safePrint('Error in onUpdate subscription: $e'),
        );
  }

  void _showProductAddedNotification(Producto product) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nuevo producto agregado: ${product.nombre}'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Ver',
            textColor: Colors.white,
            onPressed: () {
              // Navegar al producto o hacer scroll hasta él
            },
          ),
        ),
      );
    }
  }

  void _showProductUpdatedNotification(Producto product) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto actualizado: ${product.nombre}'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    onCreateSubscription?.cancel();
    onUpdateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await Future.wait([_getProductosByNegocio(), _getCategorias()]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getProductosByNegocio() async {
    try {
      final info = await NegocioService.getCurrentUserInfo();
      final negocioId = info.negocioId;
      _negocioID = negocioId;

      final request = ModelQueries.list(
        Producto.classType,
        where: Producto.NEGOCIOID.eq(negocioId) & Producto.ISDELETED.eq(false),
      );

      final response = await Amplify.API.query(request: request).response;
      print("DATA $response");
      if (response.data != null) {
        final products = response.data!.items.whereType<Producto>().toList();

        setState(() {
          _allProducts = products;
          _filteredProducts = List.from(products);
          _sortProducts();
        });
      } else if (response.errors.isNotEmpty) {
        print('Query failed: ${response.errors}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al recuperar los productos")),
      );
    }
  }

  Future<void> _getCategorias() async {
    try {
      final negocioInfo = await NegocioService.getCurrentUserInfo();
      final request = ModelQueries.list(
        Categoria.classType,
        where:
            Categoria.NEGOCIOID.eq(negocioInfo.negocioId) &
            Categoria.ISDELETED.eq(false),
      );
      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final categories = response.data!.items.whereType<Categoria>().toList();

        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al recuperar las categorias")),
      );
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        // Verificar que no esté eliminado
        if (product.isDeleted == true) return false;

        final matchesName = product.nombre.toLowerCase().contains(query);
        final matchesBarcode = product.barCode.toLowerCase().contains(query);
        final matchesCategory =
            _selectedCategoryId == null ||
            product.categoriaID == _selectedCategoryId;

        return (matchesName || matchesBarcode) && matchesCategory;
      }).toList();

      _sortProducts();
    });
  }

  void _sortProducts() {
    _filteredProducts.sort((a, b) {
      switch (_sortBy) {
        case 'stock':
          return a.stock.compareTo(b.stock);
        case 'favorito':
          if (a.favorito == b.favorito) return 0;
          return a.favorito ? -1 : 1;
        case 'nombre':
        default:
          return a.nombre.compareTo(b.nombre);
      }
    });
  }

  String _getCategoryName(String? categoryId) {
    if (categoryId == null) return 'Sin categoría';

    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Categoria(
        nombre: 'Sin categoría',
        id: '',
        negocioID: '',
        isDeleted: false,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
      ),
    );

    return category.nombre;
  }

  Color _getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
  }

  Widget _buildStockChip(int stock) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStockColor(stock).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStockColor(stock), width: 1),
      ),
      child: Text(
        'Stock: $stock',
        style: TextStyle(
          color: _getStockColor(stock),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _changedFavoriteProduct(Producto product) async {
    try {
      final model = product.copyWith(favorito: !product.favorito);
      final request = ModelMutations.update(model);
      final response = await Amplify.API.mutate(request: request).response;
      if (!response.hasErrors) {
        _getProductosByNegocio();
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Cambio exitoso")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ocurrio un error al cambiar a favorito"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _initializeData();
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortProducts();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'nombre', child: Text('Ordenar por Nombre')),
              PopupMenuItem(
                value: 'favorito',
                child: Text('Ordenar por Favorito'),
              ),
              PopupMenuItem(value: 'stock', child: Text('Ordenar por Stock')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: AppLoadingIndicator())
          : Column(
              children: [
                // Filtros y búsqueda
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Barra de búsqueda
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar...',
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Filtro por categoría
                      DropdownButtonFormField<String?>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'Filtrar por categoría',
                          prefixIcon: Icon(Icons.filter_list),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Todas las categorías'),
                          ),
                          ..._categories.map((categoria) {
                            return DropdownMenuItem<String?>(
                              value: categoria.id,
                              child: Text(categoria.nombre),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                            _filterProducts();
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Contador de productos
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${_filteredProducts.length} productos encontrados',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      Spacer(),
                      Text(
                        'Ordenado por $_sortBy',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Lista de productos
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No se encontraron productos',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (_searchController.text.isNotEmpty ||
                                  _selectedCategoryId != null)
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _selectedCategoryId = null;
                                      _filterProducts();
                                    });
                                  },
                                  child: Text('Limpiar filtros'),
                                ),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final crossAxisCount = width > 1000 ? 2 : 1;
                            final childAspectRatio = width > 600 ? 2.4 : 1.5;
                            return GridView.builder(
                              padding: EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: childAspectRatio,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                return _buildProductCard(product);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildProductCard(Producto product) {
    return FutureBuilder<List<ProductoPrecios>>(
      future: _getProductoPrecios(product.id),
      builder: (context, snapshot) {
        List<ProductoPrecios> precios = [];
        if (snapshot.hasData) {
          precios = snapshot.data!.where((p) => !p.isDeleted).toList();
        }

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con imagen y nombre
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Miniatura de la primera imagen (si existe)
                      if (product.productoImages != null &&
                          product.productoImages!.isNotEmpty)
                        FutureBuilder<List<String>>(
                          future: GetImageFromBucket.getSignedImageUrls(
                            s3Keys: [product.productoImages!.first],
                            expiresIn: Duration(minutes: 30),
                          ),
                          builder: (context, imageSnapshot) {
                            if (imageSnapshot.hasData &&
                                imageSnapshot.data!.isNotEmpty) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: buildCachedImage(
                                  imageSnapshot.data!.first,
                                  primaryBlue: Colors.blue,
                                  lightBlue: Colors.lightBlue,
                                ),
                              );
                            }
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.image,
                                color: Colors.grey[600],
                                size: 30,
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.image,
                            color: Colors.grey[600],
                            size: 30,
                          ),
                        ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  product.nombre,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                            if (product.barCode.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'Código: ${product.barCode}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Botón de favorito más pequeño y visible
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: product.favorito
                                  ? Colors.yellow[700]!.withValues(alpha: 0.15)
                                  : Colors.grey[300]!.withValues(alpha: 0.8),
                              border: Border.all(
                                color: product.favorito
                                    ? Colors.yellow[800]!
                                    : Colors.grey[400]!,
                                width: 1.5,
                              ),
                            ),
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              product.favorito ? Icons.star : Icons.star_border,
                              color: product.favorito
                                  ? Colors.yellow[800]
                                  : Colors.grey[600],
                              size: 18,
                            ),
                          ),
                          SizedBox(height: 4),
                          _buildStockChip(product.stock),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Descripción (si existe)
                  if (product.descripcion.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        product.descripcion,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // Información adicional
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      // Precios
                      if (snapshot.connectionState == ConnectionState.waiting)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Cargando precios...',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        )
                      else if (precios.isNotEmpty)
                        ...precios.take(2).map((precio) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${precio.nombre}: \$${precio.precio.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          );
                        })
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Sin precios',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      // Categoría
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getCategoryName(product.categoriaID),
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Estado
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: product.estado == 'activo'
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.estado?.toUpperCase() ?? 'N/A',
                          style: TextStyle(
                            color: product.estado == 'activo'
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Footer con fecha y acción
                  Row(
                    children: [
                      Text(
                        'Actualizado: ${product.updatedAt.getDateTimeInUtc().day}/${product.updatedAt.getDateTimeInUtc().month}/${product.updatedAt.getDateTimeInUtc().year}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<ProductoPrecios>> _getProductoPrecios(String productId) async {
    try {
      final request = ModelQueries.list(
        ProductoPrecios.classType,
        where: ProductoPrecios.PRODUCTOID
            .eq(productId)
            .and(ProductoPrecios.ISDELETED.eq(false)),
      );
      final response = await Amplify.API.query(request: request).response;
      return response.data?.items.whereType<ProductoPrecios>().toList() ?? [];
    } catch (e) {
      print('Error fetching product prices: $e');
      return [];
    }
  }

  Widget buildCachedImage(
    String imageUrl, {
    required Color primaryBlue,
    required Color lightBlue,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: lightBlue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: AppLoadingIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: lightBlue.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_rounded, color: primaryBlue, size: 40),
            SizedBox(height: 8),
            Text(
              'Error al cargar',
              style: TextStyle(color: primaryBlue, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
