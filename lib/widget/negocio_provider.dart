import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compaexpress/entities/user_info.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/ModelProvider.dart';
import '../services/negocio_service.dart';

// ============================================
// PROVIDERS BÁSICOS
// ============================================

/// Provider para obtener la información del usuario actual
final currentUserInfoProvider = FutureProvider<UserInfo>((ref) async {
  return await NegocioService.getCurrentUserInfo();
});

/// Provider para verificar si el usuario tiene un permiso específico
final hasPermissionProvider = FutureProvider.family<bool, String>((
  ref,
  operation,
) async {
  return await NegocioService.hasPermission(operation);
});

// ============================================
// PROVIDERS DE NEGOCIOS
// ============================================

/// Provider para obtener todos los negocios
final allNegociosProvider = FutureProvider<List<Negocio>>((ref) async {
  return await NegocioService.getAllNegocios();
});

/// Provider para obtener un negocio por ID
final negocioByIdProvider = FutureProvider.family<Negocio?, String>((
  ref,
  id,
) async {
  return await NegocioService.getNegocioById(id);
});

// ============================================
// STATE NOTIFIER PARA OPERACIONES MUTABLES
// ============================================

/// Estado para las operaciones de negocio
class NegocioState {
  final bool isLoading;
  final String? errorMessage;
  final Negocio? lastCreatedNegocio;
  final Negocio? lastUpdatedNegocio;

  const NegocioState({
    this.isLoading = false,
    this.errorMessage,
    this.lastCreatedNegocio,
    this.lastUpdatedNegocio,
  });

  NegocioState copyWith({
    bool? isLoading,
    String? errorMessage,
    Negocio? lastCreatedNegocio,
    Negocio? lastUpdatedNegocio,
  }) {
    return NegocioState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lastCreatedNegocio: lastCreatedNegocio ?? this.lastCreatedNegocio,
      lastUpdatedNegocio: lastUpdatedNegocio ?? this.lastUpdatedNegocio,
    );
  }
}

/// Notifier para manejar operaciones CRUD de negocios
class NegocioNotifier extends StateNotifier<NegocioState> {
  final Ref ref;

  NegocioNotifier(this.ref) : super(const NegocioState());

  /// Crea un nuevo negocio
  Future<Negocio?> createNegocio(Negocio negocio) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final createdNegocio = await NegocioService.createNegocio(negocio);
      state = state.copyWith(
        isLoading: false,
        lastCreatedNegocio: createdNegocio,
      );

      // Invalida el provider de todos los negocios para refrescar la lista
      ref.invalidate(allNegociosProvider);

      return createdNegocio;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  /// Actualiza un negocio existente
  Future<Negocio?> updateNegocio(Negocio negocio) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedNegocio = await NegocioService.updateNegocio(negocio);
      state = state.copyWith(
        isLoading: false,
        lastUpdatedNegocio: updatedNegocio,
      );

      // Invalida los providers relacionados
      ref.invalidate(allNegociosProvider);
      ref.invalidate(negocioByIdProvider(negocio.id));

      return updatedNegocio;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  /// Elimina un negocio
  Future<bool> deleteNegocio(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await NegocioService.deleteNegocio(id);
      state = state.copyWith(isLoading: false);

      // Invalida los providers relacionados
      ref.invalidate(allNegociosProvider);
      ref.invalidate(negocioByIdProvider(id));

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Limpia el caché del servicio
  void clearCache() {
    NegocioService.clearCache();
    ref.invalidate(currentUserInfoProvider);
  }

  /// Limpia los errores
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider del notifier
final negocioNotifierProvider =
    StateNotifierProvider<NegocioNotifier, NegocioState>((ref) {
      return NegocioNotifier(ref);
    });

// ============================================
// PROVIDERS DERIVADOS ÚTILES
// ============================================

/// Provider para verificar si el usuario es superadmin
final isSuperAdminProvider = FutureProvider<bool>((ref) async {
  final userInfo = await ref.watch(currentUserInfoProvider.future);
  return userInfo.groups.contains('superadmin');
});

/// Provider para verificar si el usuario es admin
final isAdminProvider = FutureProvider<bool>((ref) async {
  final userInfo = await ref.watch(currentUserInfoProvider.future);
  return userInfo.groups.contains('admin') ||
      userInfo.groups.contains('superadmin');
});

/// Provider para verificar si el usuario es vendedor
final isVendedorProvider = FutureProvider<bool>((ref) async {
  final userInfo = await ref.watch(currentUserInfoProvider.future);
  return userInfo.groups.contains('vendedor');
});

/// Provider para obtener el negocio del usuario actual
final currentUserNegocioProvider = FutureProvider<Negocio?>((ref) async {
  final userInfo = await ref.watch(currentUserInfoProvider.future);
  if (userInfo.negocioId.isEmpty) return null;
  return await NegocioService.getNegocioById(userInfo.negocioId);
});
