import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/negocio/negocio_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/* ---------------- State ---------------- */

class ProveedorState {
  final List<Proveedor> items;
  final bool isLoading;
  final bool isProcessing; // Para operaciones CRUD individuales
  final String? error;
  final String? successMessage;

  const ProveedorState({
    this.items = const [],
    this.isLoading = true,
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  ProveedorState copyWith({
    List<Proveedor>? items,
    bool? isLoading,
    bool? isProcessing,
    String? error,
    String? successMessage,
  }) => ProveedorState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    isProcessing: isProcessing ?? this.isProcessing,
    error: error,
    successMessage: successMessage,
  );

  ProveedorState clearMessages() => copyWith(error: null, successMessage: null);
}

/* ---------------- Notifier con CRUD completo ---------------- */

class ProveedorNotifier extends StateNotifier<ProveedorState> {
  ProveedorNotifier() : super(const ProveedorState()) {
    load();
  }

  // READ - Cargar todos los proveedores
  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final negocio = await NegocioController.getUserInfo();
      final req = ModelQueries.list(
        Proveedor.classType,
        where:
            Proveedor.NEGOCIOID.eq(negocio.negocioId) &
            Proveedor.ISDELETED.eq(false),
      );
      final res = await Amplify.API.query(request: req).response;
      final list = res.data?.items.whereType<Proveedor>().toList() ?? [];

      state = state.copyWith(items: list, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        error: 'Error al cargar proveedores: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // CREATE - Crear nuevo proveedor
  Future<bool> create(Proveedor proveedor) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      final negocio = await NegocioController.getUserInfo();
      final newProveedor = proveedor.copyWith(
        negocioID: negocio.negocioId,
        isDeleted: false,
      );

      final req = ModelMutations.create(newProveedor);
      final res = await Amplify.API.mutate(request: req).response;

      if (res.data != null) {
        // Actualización optimista: agregar al estado local
        final updatedList = [...state.items, res.data!];
        state = state.copyWith(
          items: updatedList,
          isProcessing: false,
          successMessage: 'Proveedor creado exitosamente',
        );
        return true;
      } else {
        throw Exception('No se pudo crear el proveedor');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error al crear proveedor: ${e.toString()}',
        isProcessing: false,
      );
      return false;
    }
  }

  // UPDATE - Actualizar proveedor existente
  Future<bool> update(Proveedor proveedor) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      final req = ModelMutations.update(proveedor);
      final res = await Amplify.API.mutate(request: req).response;

      if (res.data != null) {
        // Actualización optimista: actualizar en el estado local
        final updatedList = state.items.map((p) {
          return p.id == proveedor.id ? res.data! : p;
        }).toList();

        state = state.copyWith(
          items: updatedList,
          isProcessing: false,
          successMessage: 'Proveedor actualizado exitosamente',
        );
        return true;
      } else {
        throw Exception('No se pudo actualizar el proveedor');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error al actualizar proveedor: ${e.toString()}',
        isProcessing: false,
      );
      return false;
    }
  }

  // DELETE - Eliminación lógica (soft delete)
  Future<bool> softDelete(Proveedor proveedor) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      final updated = proveedor.copyWith(isDeleted: true);
      final req = ModelMutations.update(updated);
      await Amplify.API.mutate(request: req).response;

      // Actualización optimista: remover del estado local
      final updatedList = state.items
          .where((p) => p.id != proveedor.id)
          .toList();

      state = state.copyWith(
        items: updatedList,
        isProcessing: false,
        successMessage: 'Proveedor eliminado exitosamente',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al eliminar proveedor: ${e.toString()}',
        isProcessing: false,
      );
      return false;
    }
  }

  // DELETE - Eliminación física (hard delete)
  Future<bool> hardDelete(Proveedor proveedor) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      final req = ModelMutations.delete(proveedor);
      await Amplify.API.mutate(request: req).response;

      // Actualización optimista: remover del estado local
      final updatedList = state.items
          .where((p) => p.id != proveedor.id)
          .toList();

      state = state.copyWith(
        items: updatedList,
        isProcessing: false,
        successMessage: 'Proveedor eliminado permanentemente',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Error al eliminar proveedor: ${e.toString()}',
        isProcessing: false,
      );
      return false;
    }
  }

  // Buscar proveedor por ID
  Proveedor? findById(String id) {
    try {
      return state.items.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Limpiar mensajes de error/éxito
  void clearMessages() {
    state = state.clearMessages();
  }

  // Refresh manual
  Future<void> refresh() async {
    await load();
  }
}

/* ---------------- Provider ---------------- */

final proveedorProvider =
    StateNotifierProvider<ProveedorNotifier, ProveedorState>(
      (_) => ProveedorNotifier(),
    );

/* ---------------- Search & Pagination ---------------- */

final searchQueryProvider = StateProvider<String>((_) => '');

final filteredProveedoresProvider = Provider<List<Proveedor>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final list = ref.watch(proveedorProvider).items;

  if (query.isEmpty) return list;

  return list.where((p) {
    final nombre = (p.nombre).toLowerCase();
    final ciudad = (p.ciudad).toLowerCase();

    return nombre.contains(query) || ciudad.contains(query);
  }).toList();
});

// Provider para paginación
final currentPageProvider = StateProvider<int>((_) => 1);

// Provider para items por página (configurable)
final itemsPerPageProvider = StateProvider<int>((_) => 10);
