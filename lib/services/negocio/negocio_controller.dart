// services/negocio/negocio_controller.dart
import 'package:compaexpress/entities/user_info.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/negocio/negocio_manager.dart';
import 'package:compaexpress/services/negocio/negocio_service.dart';

class NegocioController {
  static final NegocioManager _manager = getNegocioManager();

  /// Obtiene un negocio por ID
  static Future<Negocio?> getById(String id) => _manager.getNegocioById(id);

  /// Obtiene todos los negocios (si el usuario tiene permisos)
  static Future<List<Negocio>> getAll() => _manager.getAllNegocios();

  /// Crea un nuevo negocio (si el usuario tiene permisos)
  static Future<Negocio> create(Negocio negocio) =>
      _manager.createNegocio(negocio);

  /// Actualiza un negocio existente
  static Future<Negocio> update(Negocio negocio) =>
      _manager.updateNegocio(negocio);

  /// Elimina un negocio por ID
  static Future<bool> delete(String id) => _manager.deleteNegocio(id);

  /// Devuelve info del usuario actual
  static Future<UserInfo> getUserInfo() => _manager.getCurrentUserInfo();

  /// Verifica permisos de operación (read, update, etc.)
  static Future<bool> hasPermission(String op) => _manager.hasPermission(op);
}
