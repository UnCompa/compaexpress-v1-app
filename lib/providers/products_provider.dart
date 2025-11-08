import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Estado compuesto para mantener productos, precios y flags
class ProductsState {
  final List<Producto> productos;
  final Map<String, List<ProductoPrecios>> productoPrecios;
  final bool isLoading;
  final bool productosLoaded;

  ProductsState({
    this.productos = const [],
    this.productoPrecios = const {},
    this.isLoading = false,
    this.productosLoaded = false,
  });

  ProductsState copyWith({
    List<Producto>? productos,
    Map<String, List<ProductoPrecios>>? productoPrecios,
    bool? isLoading,
    bool? productosLoaded,
  }) {
    return ProductsState(
      productos: productos ?? this.productos,
      productoPrecios: productoPrecios ?? this.productoPrecios,
      isLoading: isLoading ?? this.isLoading,
      productosLoaded: productosLoaded ?? this.productosLoaded,
    );
  }
}

/// Provider principal
class ProductsProvider extends StateNotifier<ProductsState> {
  ProductsProvider() : super(ProductsState()) {
    loadProducts();
  }

  /// Carga inicial de productos
  Future<void> loadProducts() async {
    if (state.productosLoaded) return;

    state = state.copyWith(isLoading: true);
    try {
      final userData = await NegocioService.getCurrentUserInfo();

      final request = ModelQueries.list(
        Producto.classType,
        where: Producto.NEGOCIOID
            .eq(userData.negocioId)
            .and(Producto.STOCK.gt(0)),
        limit: 50,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final productos = response.data!.items.whereType<Producto>().toList();

        state = state.copyWith(productos: productos, productosLoaded: true);

        // Cargar precios en segundo plano
        _loadPreciosAsync(productos);
      } else {
        safePrint('Error: ${response.errors.map((e) => e.message).join(", ")}');
      }
    } catch (e) {
      safePrint('Error al cargar productos: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Carga asincrónica de precios en lotes de 5 productos
  Future<void> _loadPreciosAsync(List<Producto> productos) async {
    final preciosMap = <String, List<ProductoPrecios>>{};

    for (int i = 0; i < productos.length; i += 5) {
      final batch = productos.skip(i).take(5);

      await Future.wait(
        batch.map((producto) async {
          try {
            final precioRequest = ModelQueries.list(
              ProductoPrecios.classType,
              where: ProductoPrecios.PRODUCTOID
                  .eq(producto.id)
                  .and(ProductoPrecios.ISDELETED.eq(false)),
            );

            final precioResponse = await Amplify.API
                .query(request: precioRequest)
                .response;

            preciosMap[producto.id] =
                precioResponse.data?.items
                    .whereType<ProductoPrecios>()
                    .toList() ??
                [];
          } catch (e) {
            safePrint('Error cargando precios para ${producto.id}: $e');
          }
        }),
      );

      // Actualizar parcialmente el estado (manteniendo los precios existentes)
      state = state.copyWith(
        productoPrecios: {...state.productoPrecios, ...preciosMap},
      );

      // Pequeña pausa entre lotes
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}

/// Definición del provider
final productsProvider = StateNotifierProvider<ProductsProvider, ProductsState>(
  (ref) {
    return ProductsProvider();
  },
);
