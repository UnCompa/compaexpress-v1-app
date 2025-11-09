import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Estado para las categorías
class CategoriesState {
  final List<Categoria> categorias;
  final Map<String, List<Categoria>> subcategoriasPorPadre;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final DateTime? lastUpdated;

  CategoriesState({
    this.categorias = const [],
    this.subcategoriasPorPadre = const {},
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.lastUpdated,
  });

  CategoriesState copyWith({
    List<Categoria>? categorias,
    Map<String, List<Categoria>>? subcategoriasPorPadre,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    DateTime? lastUpdated,
  }) {
    return CategoriesState(
      categorias: categorias ?? this.categorias,
      subcategoriasPorPadre:
          subcategoriasPorPadre ?? this.subcategoriasPorPadre,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Obtiene categorías principales (sin padre)
  List<Categoria> get categoriasRaiz {
    return categorias
        .where((cat) => cat.parentCategoriaID == null && !cat.isDeleted)
        .toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));
  }

  /// Obtiene todas las subcategorías de una categoría
  List<Categoria> getSubcategorias(String parentId) {
    return subcategoriasPorPadre[parentId] ?? [];
  }

  /// Verifica si una categoría tiene subcategorías
  bool hasSubcategorias(String categoriaId) {
    final subs = subcategoriasPorPadre[categoriaId];
    return subs != null && subs.isNotEmpty;
  }

  /// Obtiene el nombre de una categoría por ID
  String getCategoryName(String? categoryId) {
    if (categoryId == null) return 'Sin categoría';
    try {
      final categoria = categorias.firstWhere((cat) => cat.id == categoryId);
      return categoria.nombre;
    } catch (e) {
      return 'Categoría no encontrada';
    }
  }

  /// Filtra categorías por búsqueda
  List<Categoria> searchCategorias(String query) {
    if (query.isEmpty) return categorias;

    final queryLower = query.toLowerCase();
    return categorias
        .where(
          (cat) =>
              !cat.isDeleted && cat.nombre.toLowerCase().contains(queryLower),
        )
        .toList();
  }

  /// Obtiene el path completo de una categoría (ej: "Electrónica > Computadoras > Laptops")
  String getCategoryPath(String categoriaId) {
    final path = <String>[];
    String? currentId = categoriaId;

    while (currentId != null) {
      try {
        final cat = categorias.firstWhere((c) => c.id == currentId);
        path.insert(0, cat.nombre);
        currentId = cat.parentCategoriaID;
      } catch (e) {
        break;
      }
    }

    return path.join(' > ');
  }
}

/// Provider principal de categorías
class CategoriesProvider extends StateNotifier<CategoriesState> {
  StreamSubscription<GraphQLResponse<Categoria>>? _onCreateSubscription;
  StreamSubscription<GraphQLResponse<Categoria>>? _onUpdateSubscription;
  StreamSubscription<GraphQLResponse<Categoria>>? _onDeleteSubscription;
  String? _negocioId;

  CategoriesProvider() : super(CategoriesState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadCategorias();
    _setupSubscriptions();
  }

  /// Carga todas las categorías
  Future<void> loadCategorias({bool forceRefresh = false}) async {
    if (state.isLoading && !forceRefresh) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final userData = await NegocioService.getCurrentUserInfo();
      _negocioId = userData.negocioId;

      final request = ModelQueries.list(
        Categoria.classType,
        where: Categoria.NEGOCIOID
            .eq(userData.negocioId)
            .and(Categoria.ISDELETED.eq(false)),
        limit: 1000,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final categorias = response.data!.items.whereType<Categoria>().toList();

        // Organizar subcategorías por padre
        final subcategoriasPorPadre = _organizarSubcategorias(categorias);

        state = state.copyWith(
          categorias: categorias,
          subcategoriasPorPadre: subcategoriasPorPadre,
          lastUpdated: DateTime.now(),
        );

        safePrint('✅ Categorías cargadas: ${categorias.length}');
      } else {
        state = state.copyWith(
          error:
              'Error al cargar categorías: ${response.errors.map((e) => e.message).join(", ")}',
        );
        safePrint(
          '❌ Error: ${response.errors.map((e) => e.message).join(", ")}',
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Error al cargar categorías: $e');
      safePrint('❌ Error al cargar categorías: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Organiza las subcategorías por su padre
  Map<String, List<Categoria>> _organizarSubcategorias(
    List<Categoria> categorias,
  ) {
    final Map<String, List<Categoria>> mapa = {};

    for (var categoria in categorias) {
      if (categoria.parentCategoriaID != null) {
        if (!mapa.containsKey(categoria.parentCategoriaID)) {
          mapa[categoria.parentCategoriaID!] = [];
        }
        mapa[categoria.parentCategoriaID!]!.add(categoria);
      }
    }

    // Ordenar cada lista de subcategorías
    for (var key in mapa.keys) {
      mapa[key]!.sort((a, b) => a.nombre.compareTo(b.nombre));
    }

    return mapa;
  }

  /// Crea una nueva categoría
  Future<bool> createCategoria({
    required String nombre,
    String? parentCategoriaID,
  }) async {
    try {
      final userData = await NegocioService.getCurrentUserInfo();

      final newCategoria = Categoria(
        nombre: nombre.trim(),
        parentCategoriaID: parentCategoriaID,
        negocioID: userData.negocioId,
        isDeleted: false,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
      );

      final request = ModelMutations.create(newCategoria);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        safePrint('❌ Error creando categoría: ${response.errors}');
        return false;
      }

      safePrint('✅ Categoría creada: ${newCategoria.nombre}');
      return true;
    } catch (e) {
      safePrint('❌ Error creando categoría: $e');
      return false;
    }
  }

  /// Actualiza una categoría existente
  Future<bool> updateCategoria({
    required Categoria categoria,
    String? nuevoNombre,
    String? nuevoParentId,
  }) async {
    try {
      final updatedCategoria = categoria.copyWith(
        nombre: nuevoNombre ?? categoria.nombre,
        parentCategoriaID: nuevoParentId ?? categoria.parentCategoriaID,
        updatedAt: TemporalDateTime.now(),
      );

      final request = ModelMutations.update(updatedCategoria);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        safePrint('❌ Error actualizando categoría: ${response.errors}');
        return false;
      }

      safePrint('✅ Categoría actualizada: ${updatedCategoria.nombre}');
      return true;
    } catch (e) {
      safePrint('❌ Error actualizando categoría: $e');
      return false;
    }
  }

  /// Elimina una categoría (soft delete)
  Future<bool> deleteCategoria(Categoria categoria) async {
    try {
      // Verificar si tiene subcategorías
      if (state.hasSubcategorias(categoria.id)) {
        safePrint('⚠️ No se puede eliminar: tiene subcategorías');
        return false;
      }

      final deletedCategoria = categoria.copyWith(
        isDeleted: true,
        updatedAt: TemporalDateTime.now(),
      );

      final request = ModelMutations.update(deletedCategoria);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        safePrint('❌ Error eliminando categoría: ${response.errors}');
        return false;
      }

      safePrint('✅ Categoría eliminada: ${categoria.nombre}');
      return true;
    } catch (e) {
      safePrint('❌ Error eliminando categoría: $e');
      return false;
    }
  }

  /// Configura suscripciones en tiempo real
  void _setupSubscriptions() {
    // onCreate
    final onCreateRequest = ModelSubscriptions.onCreate(Categoria.classType);
    _onCreateSubscription = Amplify.API
        .subscribe(
          onCreateRequest,
          onEstablished: () =>
              safePrint('📡 onCreate subscription established'),
        )
        .listen((event) {
          if (event.data != null && event.data!.negocioID == _negocioId) {
            _handleCategoriaCreated(event.data!);
          }
        }, onError: (e) => safePrint('❌ onCreate error: $e'));

    // onUpdate
    final onUpdateRequest = ModelSubscriptions.onUpdate(Categoria.classType);
    _onUpdateSubscription = Amplify.API
        .subscribe(
          onUpdateRequest,
          onEstablished: () =>
              safePrint('📡 onUpdate subscription established'),
        )
        .listen((event) {
          if (event.data != null && event.data!.negocioID == _negocioId) {
            _handleCategoriaUpdated(event.data!);
          }
        }, onError: (e) => safePrint('❌ onUpdate error: $e'));

    // onDelete
    final onDeleteRequest = ModelSubscriptions.onDelete(Categoria.classType);
    _onDeleteSubscription = Amplify.API
        .subscribe(
          onDeleteRequest,
          onEstablished: () =>
              safePrint('📡 onDelete subscription established'),
        )
        .listen((event) {
          if (event.data != null && event.data!.negocioID == _negocioId) {
            _handleCategoriaDeleted(event.data!);
          }
        }, onError: (e) => safePrint('❌ onDelete error: $e'));
  }

  void _handleCategoriaCreated(Categoria categoria) {
    final updatedCategorias = [...state.categorias, categoria];
    final subcategorias = _organizarSubcategorias(updatedCategorias);

    state = state.copyWith(
      categorias: updatedCategorias,
      subcategoriasPorPadre: subcategorias,
    );
  }

  void _handleCategoriaUpdated(Categoria categoria) {
    final updatedCategorias = state.categorias.map((c) {
      return c.id == categoria.id ? categoria : c;
    }).toList();

    final subcategorias = _organizarSubcategorias(updatedCategorias);

    state = state.copyWith(
      categorias: updatedCategorias,
      subcategoriasPorPadre: subcategorias,
    );
  }

  void _handleCategoriaDeleted(Categoria categoria) {
    final updatedCategorias = state.categorias
        .where((c) => c.id != categoria.id)
        .toList();

    final subcategorias = _organizarSubcategorias(updatedCategorias);

    state = state.copyWith(
      categorias: updatedCategorias,
      subcategoriasPorPadre: subcategorias,
    );
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

/// Provider principal
final categoriesProvider =
    StateNotifierProvider<CategoriesProvider, CategoriesState>(
      (ref) => CategoriesProvider(),
    );

/// Provider para categorías raíz
final rootCategoriesProvider = Provider<List<Categoria>>((ref) {
  final state = ref.watch(categoriesProvider);
  return state.categoriasRaiz;
});

/// Provider para categorías disponibles como padre (excluye una específica)
final availableParentCategoriesProvider =
    Provider.family<List<Categoria>, String?>((ref, excludeId) {
      final state = ref.watch(categoriesProvider);

      if (excludeId == null) {
        return state.categorias.where((cat) => !cat.isDeleted).toList();
      }

      return state.categorias
          .where((cat) => cat.id != excludeId && !cat.isDeleted)
          .toList();
    });

/// Provider para obtener subcategorías de una categoría
final subcategoriasProvider = Provider.family<List<Categoria>, String>((
  ref,
  parentId,
) {
  final state = ref.watch(categoriesProvider);
  return state.getSubcategorias(parentId);
});
