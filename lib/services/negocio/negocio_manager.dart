// services/negocio/negocio_manager.dart
import 'package:compaexpress/entities/user_info.dart';
import 'package:compaexpress/models/ModelProvider.dart';

abstract class NegocioManager {
  Future<Negocio?> getNegocioById(String id);
  Future<List<Negocio>> getAllNegocios();
  Future<Negocio> createNegocio(Negocio negocio);
  Future<Negocio> updateNegocio(Negocio negocio);
  Future<bool> deleteNegocio(String id);
  Future<UserInfo> getCurrentUserInfo();
  Future<bool> hasPermission(String operation);
}
