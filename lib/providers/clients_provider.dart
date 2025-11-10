import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Estado para manejar la UI
class ClientsState {
  final List<Client> clients;
  final bool isLoading;
  final String? error;

  const ClientsState({
    this.clients = const [],
    this.isLoading = false,
    this.error,
  });

  ClientsState copyWith({
    List<Client>? clients,
    bool? isLoading,
    String? error,
  }) {
    return ClientsState(
      clients: clients ?? this.clients,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier para manejar el estado y operaciones CRUD
class ClientsNotifier extends StateNotifier<ClientsState> {
  ClientsNotifier() : super(const ClientsState()) {
    loadClients();
  }

  // CREATE - Crear un nuevo cliente
  Future<Client?> createClient({
    required String negocioID,
    required String nombres,
    required String apellidos,
    String? identificacion,
    String? email,
    String? phone,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final newClient = Client(
        negocioID: negocioID,
        nombres: nombres,
        apellidos: apellidos,
        identificacion: identificacion,
        email: email,
        phone: phone,
        isDeleted: false,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
      );

      final request = ModelMutations.create(newClient);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.data != null) {
        // Actualizar la lista local
        final updatedClients = [...state.clients, response.data!];
        state = state.copyWith(clients: updatedClients, isLoading: false);
        return response.data;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al crear cliente: ${response.errors}',
        );
        return null;
      }
    } catch (e) {
      String errorMessage;
      if (e is AmplifyException) {
        errorMessage = e.message;
      } else {
        errorMessage = e.toString();
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al crear cliente: $errorMessage',
      );
      return null;
    }
  }

  //READ - Obtener clientes

  Future<void> loadClients() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final query = ModelQueries.list(
        Client.classType,
        where: Client.ISDELETED.ne(true),
      );

      final result = await Amplify.API.query(request: query).response;
      final data = result.data?.items ?? [];

      // Filtrar nulls
      final clients = data.whereType<Client>().toList();

      state = state.copyWith(clients: clients, isLoading: false);
    } catch (e) {
      String errorMessage;
      if (e is AmplifyException) {
        errorMessage = e.message;
      } else {
        errorMessage = e.toString();
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar clientes: $errorMessage',
      );
    }
  }

  // READ - Obtener todos los clientes de un negocio
  Future<void> fetchClients(String negocioID) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final query = ModelQueries.list(
        Client.classType,
        where: Client.NEGOCIOID.eq(negocioID).and(Client.ISDELETED.ne(true)),
      );

      final result = await Amplify.API.query(request: query).response;
      final data = result.data?.items ?? [];

      // Filtrar nulls
      final clients = data.whereType<Client>().toList();

      state = state.copyWith(clients: clients, isLoading: false);
    } catch (e) {
      String errorMessage;
      if (e is AmplifyException) {
        errorMessage = e.message;
      } else {
        errorMessage = e.toString();
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar clientes: $errorMessage',
      );
    }
  }

  // READ - Buscar cliente por identificación
  Future<Client?> fetchClientByIdentificacion(String identificacion) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final query = ModelQueries.list(
        Client.classType,
        where: Client.IDENTIFICACION
            .eq(identificacion)
            .and(Client.ISDELETED.ne(true)),
      );

      final result = await Amplify.API.query(request: query).response;
      final data = result.data?.items ?? [];
      final clients = data.whereType<Client>().toList();

      state = state.copyWith(isLoading: false);

      return clients.isNotEmpty ? clients.first : null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al buscar cliente: $e',
      );
      return null;
    }
  }

  // READ - Obtener un cliente por ID
  Future<Client?> fetchClientById(String clientId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final query = ModelQueries.get(
        Client.classType,
        ClientModelIdentifier(id: clientId),
      );

      final result = await Amplify.API.query(request: query).response;

      state = state.copyWith(isLoading: false);

      return result.data;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al obtener cliente: $e',
      );
      return null;
    }
  }

  // UPDATE - Actualizar un cliente
  Future<Client?> updateClient(Client client) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final request = ModelMutations.update(client);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.data != null) {
        // Actualizar en la lista local
        final updatedClients = state.clients.map((c) {
          return c.id == client.id ? response.data! : c;
        }).toList();

        state = state.copyWith(clients: updatedClients, isLoading: false);
        return response.data;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al actualizar cliente: ${response.errors}',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al actualizar cliente: $e',
      );
      return null;
    }
  }

  // DELETE - Soft delete (marcar como eliminado)
  Future<bool> deleteClient(Client client) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final deletedClient = client.copyWith(isDeleted: true);
      final request = ModelMutations.update(deletedClient);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.data != null) {
        // Remover de la lista local
        final updatedClients = state.clients
            .where((c) => c.id != client.id)
            .toList();

        state = state.copyWith(clients: updatedClients, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al eliminar cliente: ${response.errors}',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al eliminar cliente: $e',
      );
      return false;
    }
  }

  // DELETE - Hard delete (eliminar permanentemente)
  Future<bool> permanentDeleteClient(Client client) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final request = ModelMutations.delete(client);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.data != null) {
        // Remover de la lista local
        final updatedClients = state.clients
            .where((c) => c.id != client.id)
            .toList();

        state = state.copyWith(clients: updatedClients, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error:
              'Error al eliminar cliente permanentemente: ${response.errors}',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al eliminar cliente: $e',
      );
      return false;
    }
  }

  // Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider principal
final clientsProvider = StateNotifierProvider<ClientsNotifier, ClientsState>(
  (ref) => ClientsNotifier(),
);

// Provider para obtener clientes por negocio
final clientsByNegocioProvider = FutureProvider.family<List<Client>, String>((
  ref,
  negocioID,
) async {
  final notifier = ref.read(clientsProvider.notifier);
  await notifier.fetchClients(negocioID);
  return ref.read(clientsProvider).clients;
});

// Provider para buscar cliente por identificación
final clientByIdentificacionProvider = FutureProvider.family<Client?, String>((
  ref,
  identificacion,
) async {
  final notifier = ref.read(clientsProvider.notifier);
  return await notifier.fetchClientByIdentificacion(identificacion);
});
