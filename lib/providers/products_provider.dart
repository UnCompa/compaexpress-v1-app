import 'dart:async';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Estado compuesto para mantener productos, precios y flags
class ProductsState {
  final List<Producto> productos;
  final Map<String, List<ProductoPrecios>> productoPrecios;
  final Map<String, Categoria> categorias;
  final bool isLoading;
  final bool productosLoaded;
  final bool categoriasLoaded;
  final bool
  preciosLoaded; // NUEVO: flag para saber si los precios terminaron de cargar
  final double
  preciosLoadProgress; // NUEVO: progreso de carga de precios (0.0 a 1.0)
  final String? error;
  final DateTime? lastUpdated;

  ProductsState({
    this.productos = const [],
    this.productoPrecios = const {},
    this.categorias = const {},
    this.isLoading = false,
    this.productosLoaded = false,
    this.categoriasLoaded = false,
    this.preciosLoaded = false,
    this.preciosLoadProgress = 0.0,
    this.error,
    this.lastUpdated,
  });

  ProductsState copyWith({
    List<Producto>? productos,
    Map<String, List<ProductoPrecios>>? productoPrecios,
    Map<String, Categoria>? categorias,
    bool? isLoading,
    bool? productosLoaded,
    bool? categoriasLoaded,
    bool? preciosLoaded,
    double? preciosLoadProgress,
    String? error,
    DateTime? lastUpdated,
  }) {
    return ProductsState(
      productos: productos ?? this.productos,
      productoPrecios: productoPrecios ?? this.productoPrecios,
      categorias: categorias ?? this.categorias,
      isLoading: isLoading ?? this.isLoading,
      productosLoaded: productosLoaded ?? this.productosLoaded,
      categoriasLoaded: categoriasLoaded ?? this.categoriasLoaded,
      preciosLoaded: preciosLoaded ?? this.preciosLoaded,
      preciosLoadProgress: preciosLoadProgress ?? this.preciosLoadProgress,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Obtiene los precios de un producto específico de forma segura
  List<ProductoPrecios> getPreciosForProducto(String productoId) {
    return productoPrecios[productoId] ?? [];
  }

  /// Obtiene el primer precio disponible de forma segura
  ProductoPrecios? getFirstPrecio(String productoId) {
    final precios = productoPrecios[productoId];
    return (precios != null && precios.isNotEmpty) ? precios.first : null;
  }

  /// Verifica si un producto tiene precios disponibles
  bool hasPrecios(String productoId) {
    final precios = productoPrecios[productoId];
    return precios != null && precios.isNotEmpty;
  }

  /// Obtiene el nombre de una categoría
  String getCategoryName(String? categoryId) {
    if (categoryId == null) return 'Sin categoría';
    return categorias[categoryId]?.nombre ?? 'Sin categoría';
  }

  /// Filtra productos por búsqueda y categoría
  List<Producto> filterProducts({
    String? searchQuery,
    String? categoryId,
    bool? onlyFavorites,
    bool? onlyLowStock,
  }) {
    return productos.where((product) {
      if (product.isDeleted == true) return false;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesName = product.nombre.toLowerCase().contains(query);
        final matchesBarcode = product.barCode.toLowerCase().contains(query);
        if (!matchesName && !matchesBarcode) return false;
      }

      if (categoryId != null && product.categoriaID != categoryId) {
        return false;
      }

      if (onlyFavorites == true && !product.favorito) {
        return false;
      }

      if (onlyLowStock == true && product.stock > 5) {
        return false;
      }

      return true;
    }).toList();
  }
}

/// Provider principal
class ProductsProvider extends StateNotifier<ProductsState> {
  StreamSubscription<GraphQLResponse<Producto>>? _onCreateSubscription;
  StreamSubscription<GraphQLResponse<Producto>>? _onUpdateSubscription;
  StreamSubscription<GraphQLResponse<Producto>>? _onDeleteSubscription;
  String? _negocioId;

  ProductsProvider() : super(ProductsState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadProducts();
    await loadCategorias();
    _setupSubscriptions();
  }

  /// Carga inicial de productos
  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (state.productosLoaded && !forceRefresh) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final userData = await NegocioService.getCurrentUserInfo();
      _negocioId = userData.negocioId;

      final request = ModelQueries.list(
        Producto.classType,
        where: Producto.NEGOCIOID
            .eq(userData.negocioId)
            .and(Producto.ISDELETED.eq(false)),
        limit: 1000,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final productos = response.data!.items.whereType<Producto>().toList();

        state = state.copyWith(
          productos: productos,
          productosLoaded: true,
          lastUpdated: DateTime.now(),
        );

        // Cargar todos los precios de forma optimizada
        _loadAllPreciosOptimized(productos);
      } else {
        state = state.copyWith(
          error:
              'Error al cargar productos: ${response.errors.map((e) => e.message).join(", ")}',
        );
        safePrint('Error: ${response.errors.map((e) => e.message).join(", ")}');
      }
    } catch (e) {
      state = state.copyWith(error: 'Error al cargar productos: $e');
      safePrint('Error al cargar productos: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Carga de categorías
  Future<void> loadCategorias({bool forceRefresh = false}) async {
    if (state.categoriasLoaded && !forceRefresh) return;

    try {
      final userData = await NegocioService.getCurrentUserInfo();

      final request = ModelQueries.list(
        Categoria.classType,
        where: Categoria.NEGOCIOID
            .eq(userData.negocioId)
            .and(Categoria.ISDELETED.eq(false)),
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final categorias = response.data!.items.whereType<Categoria>().toList();
        final categoriasMap = {for (var cat in categorias) cat.id: cat};

        state = state.copyWith(
          categorias: categoriasMap,
          categoriasLoaded: true,
        );
      }
    } catch (e) {
      safePrint('Error al cargar categorías: $e');
    }
  }

  /// OPTIMIZADO: Carga todos los precios en una sola consulta
  Future<void> _loadAllPreciosOptimized(List<Producto> productos) async {
    if (productos.isEmpty) {
      state = state.copyWith(preciosLoaded: true, preciosLoadProgress: 1.0);
      return;
    }

    try {
      // Cargar TODOS los precios del negocio en una sola query
      final userData = await NegocioService.getCurrentUserInfo();

      final preciosRequest = ModelQueries.list(
        ProductoPrecios.classType,
        where: ProductoPrecios.NEGOCIOID
            .eq(userData.negocioId)
            .and(ProductoPrecios.ISDELETED.eq(false)),
        limit: 5000, // Límite alto para obtener todos los precios
      );

      final preciosResponse = await Amplify.API
          .query(request: preciosRequest)
          .response;

      if (preciosResponse.data != null) {
        // Organizar precios por productoId
        final preciosMap = <String, List<ProductoPrecios>>{};

        for (var precio
            in preciosResponse.data!.items.whereType<ProductoPrecios>()) {
          if (!preciosMap.containsKey(precio.productoID)) {
            preciosMap[precio.productoID] = [];
          }
          preciosMap[precio.productoID]!.add(precio);
        }

        // Actualizar estado con todos los precios
        state = state.copyWith(
          productoPrecios: preciosMap,
          preciosLoaded: true,
          preciosLoadProgress: 1.0,
        );

        safePrint(
          '✅ Precios cargados: ${preciosMap.length} productos con precios',
        );
      } else {
        safePrint('⚠️ No se pudieron cargar los precios');
        state = state.copyWith(preciosLoaded: true, preciosLoadProgress: 1.0);
      }
    } catch (e) {
      safePrint('❌ Error cargando precios: $e');
      // Marcar como cargado incluso con error para no bloquear la UI
      state = state.copyWith(preciosLoaded: true, preciosLoadProgress: 1.0);
    }
  }

  /// ALTERNATIVA: Carga optimizada en lotes paralelos (si la query única falla)
  Future<void> _loadPreciosInParallelBatches(List<Producto> productos) async {
    const int batchSize = 20; // Procesar 20 productos en paralelo
    final preciosMap = <String, List<ProductoPrecios>>{};

    for (int i = 0; i < productos.length; i += batchSize) {
      final batch = productos.skip(i).take(batchSize).toList();

      // Procesar todo el lote en paralelo
      final results = await Future.wait(
        batch.map((producto) => _fetchPreciosForProduct(producto.id)),
      );

      // Agregar resultados al mapa
      for (int j = 0; j < batch.length; j++) {
        preciosMap[batch[j].id] = results[j];
      }

      // Actualizar progreso
      final progress = ((i + batch.length) / productos.length).clamp(0.0, 1.0);
      state = state.copyWith(
        productoPrecios: {...state.productoPrecios, ...preciosMap},
        preciosLoadProgress: progress,
      );
    }

    state = state.copyWith(preciosLoaded: true, preciosLoadProgress: 1.0);
  }

  /// Fetch de precios para un producto individual
  Future<List<ProductoPrecios>> _fetchPreciosForProduct(
    String productoId,
  ) async {
    try {
      final precioRequest = ModelQueries.list(
        ProductoPrecios.classType,
        where: ProductoPrecios.PRODUCTOID
            .eq(productoId)
            .and(ProductoPrecios.ISDELETED.eq(false)),
      );

      final precioResponse = await Amplify.API
          .query(request: precioRequest)
          .response;

      return precioResponse.data?.items.whereType<ProductoPrecios>().toList() ??
          [];
    } catch (e) {
      safePrint('Error cargando precios para $productoId: $e');
      return [];
    }
  }

  /// Configura las suscripciones en tiempo real
  void _setupSubscriptions() {
    // Suscripción onCreate
    final onCreateRequest = ModelSubscriptions.onCreate(Producto.classType);
    _onCreateSubscription = Amplify.API
        .subscribe(
          onCreateRequest,
          onEstablished: () {
            safePrint('onCreate subscription established');
          },
        )
        .listen((event) {
          if (event.data != null && event.data!.negocioID == _negocioId) {
            _handleProductCreated(event.data!);
          }
        }, onError: (e) => safePrint('onCreate error: $e'));

    // Suscripción onUpdate
    final onUpdateRequest = ModelSubscriptions.onUpdate(Producto.classType);
    _onUpdateSubscription = Amplify.API
        .subscribe(
          onUpdateRequest,
          onEstablished: () {
            safePrint('onUpdate subscription established');
          },
        )
        .listen((event) {
          if (event.data != null && event.data!.negocioID == _negocioId) {
            _handleProductUpdated(event.data!);
          }
        }, onError: (e) => safePrint('onUpdate error: $e'));

    // Suscripción onDelete
    final onDeleteRequest = ModelSubscriptions.onDelete(Producto.classType);
    _onDeleteSubscription = Amplify.API
        .subscribe(
          onDeleteRequest,
          onEstablished: () {
            safePrint('onDelete subscription established');
          },
        )
        .listen((event) {
          if (event.data != null && event.data!.negocioID == _negocioId) {
            _handleProductDeleted(event.data!);
          }
        }, onError: (e) => safePrint('onDelete error: $e'));
  }

  void _handleProductCreated(Producto producto) {
    final updatedProducts = [...state.productos, producto];
    state = state.copyWith(productos: updatedProducts);

    // Cargar precios del nuevo producto
    _loadPreciosForProduct(producto.id);
  }

  void _handleProductUpdated(Producto producto) {
    final updatedProducts = state.productos.map((p) {
      return p.id == producto.id ? producto : p;
    }).toList();

    state = state.copyWith(productos: updatedProducts);
  }

  void _handleProductDeleted(Producto producto) {
    final updatedProducts = state.productos
        .where((p) => p.id != producto.id)
        .toList();
    state = state.copyWith(productos: updatedProducts);

    // Limpiar precios del producto eliminado
    final updatedPrecios = Map<String, List<ProductoPrecios>>.from(
      state.productoPrecios,
    );
    updatedPrecios.remove(producto.id);
    state = state.copyWith(productoPrecios: updatedPrecios);
  }

  /// Carga precios de un producto específico
  Future<void> _loadPreciosForProduct(String productoId) async {
    try {
      final precios = await _fetchPreciosForProduct(productoId);

      state = state.copyWith(
        productoPrecios: {...state.productoPrecios, productoId: precios},
      );
    } catch (e) {
      safePrint('Error cargando precios para $productoId: $e');
    }
  }

  /// Actualiza el estado de favorito de un producto
  Future<bool> toggleFavorite(String productoId) async {
    try {
      final producto = state.productos.firstWhere((p) => p.id == productoId);
      final updatedProduct = producto.copyWith(favorito: !producto.favorito);

      final request = ModelMutations.update(updatedProduct);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        safePrint('Error toggling favorite: ${response.errors}');
        return false;
      }

      return true;
    } catch (e) {
      safePrint('Error toggling favorite: $e');
      return false;
    }
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _onCreateSubscription?.cancel();
    _onUpdateSubscription?.cancel();
    _onDeleteSubscription?.cancel();
    super.dispose();
  }
}

/// Definición del provider
final productsProvider = StateNotifierProvider<ProductsProvider, ProductsState>(
  (ref) => ProductsProvider(),
);

/// Provider filtrado para productos favoritos
final favoriteProductsProvider = Provider<List<Producto>>((ref) {
  final state = ref.watch(productsProvider);
  return state.productos.where((p) => p.favorito && !p.isDeleted).toList();
});

/// Provider para productos con stock bajo
final lowStockProductsProvider = Provider<List<Producto>>((ref) {
  final state = ref.watch(productsProvider);
  return state.productos
      .where((p) => p.stock <= 5 && p.stock > 0 && !p.isDeleted)
      .toList();
});

/// Provider para productos sin stock
final outOfStockProductsProvider = Provider<List<Producto>>((ref) {
  final state = ref.watch(productsProvider);
  return state.productos.where((p) => p.stock == 0 && !p.isDeleted).toList();
});
