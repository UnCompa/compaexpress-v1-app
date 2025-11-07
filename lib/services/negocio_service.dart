import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/entities/user_info.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/ModelProvider.dart';

class NegocioService {
  // Variable estática para el caché
  static UserInfo? _cachedUserInfo;
  // Timestamp del último caché
  static DateTime? _cacheTimestamp;
  // Duración del caché (ejemplo: 5 minutos)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Obtiene un negocio por su ID
  ///
  /// [id] ID del negocio a buscar
  ///
  /// Returns [Negocio] o null si no se encuentra
  static Future<Negocio?> getNegocioById(String id) async {
    try {
      final request = ModelQueries.get(
        Negocio.classType,
        NegocioModelIdentifier(id: id),
      );
      final response = await Amplify.API.query(request: request).response;

      if (response.hasErrors) {
        safePrint('Error al obtener negocio: ${response.errors}');
        throw Exception('Error al obtener el negocio: ${response.errors}');
      }

      return response.data;
    } on ApiException catch (e) {
      safePrint('Error de API al obtener negocio: $e');
      throw Exception('No se pudo obtener el negocio con ID: $id');
    } catch (e) {
      safePrint('Error inesperado al obtener negocio: $e');
      throw Exception('Error inesperado al obtener el negocio');
    }
  }

  /// Obtiene la información del usuario actual incluyendo sus grupos
  ///
  /// Returns [UserInfo] con la información del usuario
  static Future<UserInfo> getCurrentUserInfo() async {
    // Verificar si hay caché válido
    if (_cachedUserInfo != null &&
        _cacheTimestamp != null &&
        DateTime.now().difference(_cacheTimestamp!) < _cacheDuration) {
      return _cachedUserInfo!;
    }

    try {
      final authUser = await Amplify.Auth.getCurrentUser();
      final authSession =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;

      // Extraer grupos del token de acceso
      final groups = _extractUserGroups(authSession);
      // Obtener email si está disponible
      String? email;
      String? negocioId;
      try {
        final attributes = await Amplify.Auth.fetchUserAttributes();
        email = attributes
            .firstWhere(
              (attr) => attr.userAttributeKey == CognitoUserAttributeKey.email,
            )
            .value;
        negocioId = attributes
            .firstWhere(
              (attr) =>
                  attr.userAttributeKey ==
                  CognitoUserAttributeKey.custom("negocioId"),
            )
            .value;
      } catch (e) {
        safePrint('No se pudo obtener el email del usuario: $e');
      }

      // Guardar en caché
      _cachedUserInfo = UserInfo(
        userId: authUser.userId,
        username: authUser.username,
        email: email,
        groups: groups,
        negocioId: negocioId.toString(),
      );
      _cacheTimestamp = DateTime.now();

      return _cachedUserInfo!;
    } on AuthException catch (e) {
      safePrint('Error de autenticación: $e');
      throw Exception(
        'No se pudo obtener la información del usuario: ${e.message}',
      );
    } catch (e) {
      safePrint('Error inesperado al obtener usuario: $e');
      throw Exception('Error inesperado al obtener información del usuario');
    }
  }

  /// Limpia el caché manualmente si es necesario
  static void clearCache() {
    _cachedUserInfo = null;
    _cacheTimestamp = null;
  }

  /// Extrae los grupos del usuario desde el token de acceso de Cognito
  ///
  /// [authSession] Sesión de autenticación de Cognito
  ///
  /// Returns [List<String>] Lista de grupos del usuario
  static List<String> _extractUserGroups(CognitoAuthSession authSession) {
    try {
      final idToken = authSession.userPoolTokensResult.value.idToken;
      final decodedToken = JwtDecoder.decode(idToken.raw);
      final List<dynamic> groupsData = decodedToken['cognito:groups'] ?? [];

      // Los grupos están en 'cognito:groups' en el payload del token

      return groupsData.cast<String>();
    } catch (e) {
      safePrint('Error al extraer grupos del usuario: $e');
      return [];
    }
  }

  /// Verifica si el usuario actual tiene permisos para una operación específica
  ///
  /// [operation] Operación a verificar ('read', 'update', 'create', 'delete')
  ///
  /// Returns [bool] true si tiene permisos, false si no
  static Future<bool> hasPermission(String operation) async {
    try {
      final userInfo = await getCurrentUserInfo();
      final userGroups = userInfo.groups;

      // Lógica de permisos basada en el esquema @auth
      if (userGroups.contains('superadmin')) {
        return true; // Superadmin tiene todos los permisos
      }

      if (userGroups.contains('admin')) {
        return ['read', 'update'].contains(operation);
      }

      if (userGroups.contains('vendedor')) {
        return operation == 'read';
      }

      return false; // Sin permisos por defecto
    } catch (e) {
      safePrint('Error al verificar permisos: $e');
      return false;
    }
  }

  /// Obtiene todos los negocios (solo para usuarios con permisos de lectura)
  ///
  /// Returns [List<Negocio>] Lista de todos los negocios
  static Future<List<Negocio>> getAllNegocios() async {
    try {
      // Verificar permisos antes de la consulta
      final canRead = await hasPermission('read');
      if (!canRead) {
        throw Exception('No tienes permisos para leer negocios');
      }

      final request = ModelQueries.list(Negocio.classType);
      final response = await Amplify.API.query(request: request).response;

      if (response.hasErrors) {
        safePrint('Error al obtener negocios: ${response.errors}');
        throw Exception(
          'Error al obtener la lista de negocios: ${response.errors}',
        );
      }

      return response.data?.items.whereType<Negocio>().toList() ?? [];
    } on ApiException catch (e) {
      safePrint('Error de API al obtener negocios: $e');
      throw Exception('No se pudieron obtener los negocios');
    } catch (e) {
      safePrint('Error al obtener negocios: $e');
      rethrow;
    }
  }

  /// Actualiza un negocio (solo para admin y superadmin)
  ///
  /// [negocio] Objeto Negocio con los campos actualizados
  ///
  /// Returns [Negocio] El negocio actualizado
  static Future<Negocio> updateNegocio(Negocio negocio) async {
    try {
      // Verificar permisos antes de la actualización
      final canUpdate = await hasPermission('update');
      if (!canUpdate) {
        throw Exception('No tienes permisos para actualizar negocios');
      }

      final request = ModelMutations.update(negocio);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        safePrint('Error al actualizar negocio: ${response.errors}');
        throw Exception('Error al actualizar el negocio: ${response.errors}');
      }

      if (response.data == null) {
        throw Exception('No se pudo actualizar el negocio');
      }

      return response.data!;
    } on ApiException catch (e) {
      safePrint('Error de API al actualizar negocio: $e');
      throw Exception('No se pudo actualizar el negocio');
    } catch (e) {
      safePrint('Error al actualizar negocio: $e');
      rethrow;
    }
  }

  /// Crea un nuevo negocio (solo para superadmin)
  ///
  /// [negocio] Objeto Negocio a crear
  ///
  /// Returns [Negocio] El negocio creado
  static Future<Negocio> createNegocio(Negocio negocio) async {
    try {
      // Verificar permisos antes de la creación
      final canCreate = await hasPermission('create');
      if (!canCreate) {
        throw Exception('No tienes permisos para crear negocios');
      }

      final request = ModelMutations.create(negocio);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        safePrint('Error al crear negocio: ${response.errors}');
        throw Exception('Error al crear el negocio: ${response.errors}');
      }

      if (response.data == null) {
        throw Exception('No se pudo crear el negocio');
      }

      return response.data!;
    } on ApiException catch (e) {
      safePrint('Error de API al crear negocio: $e');
      throw Exception('No se pudo crear el negocio');
    } catch (e) {
      safePrint('Error al crear negocio: $e');
      rethrow;
    }
  }

  /// Elimina un negocio (solo para superadmin)
  ///
  /// [id] ID del negocio a eliminar
  ///
  /// Returns [bool] true si se eliminó correctamente
  static Future<bool> deleteNegocio(String id) async {
    try {
      // Verificar permisos antes de la eliminación
      final canDelete = await hasPermission('delete');
      if (!canDelete) {
        throw Exception('No tienes permisos para eliminar negocios');
      }

      // Primero obtener el negocio para eliminarlo
      final negocio = await getNegocioById(id);
      if (negocio == null) {
        throw Exception('El negocio no existe');
      }

      final request = ModelMutations.delete(negocio);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        safePrint('Error al eliminar negocio: ${response.errors}');
        throw Exception('Error al eliminar el negocio: ${response.errors}');
      }

      return response.data != null;
    } on ApiException catch (e) {
      safePrint('Error de API al eliminar negocio: $e');
      throw Exception('No se pudo eliminar el negocio');
    } catch (e) {
      safePrint('Error al eliminar negocio: $e');
      rethrow;
    }
  }
}
