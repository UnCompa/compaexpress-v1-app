import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/Auditoria.dart';

class AuditoriaService {
  static Future<void> createAuditoria({
    required String userId,
    required String grupo,
    required String accion,
    required String entidad,
    String? entidadId,
    String? descripcion,
    required String negocioId,
  }) async {
    try {
      final auditoria = Auditoria(
        userId: userId,
        grupo: grupo,
        accion: accion,
        entidad: entidad,
        entidadId: entidadId,
        descripcion: descripcion,
        fecha: TemporalDateTime(DateTime.now()),
        negocioID: negocioId,
      );

      final request = ModelMutations.create(auditoria);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.data == null) {
        throw Exception('Error al crear auditoría: ${response.errors}');
      }
    } catch (e) {
      throw Exception('Error al crear auditoría: $e');
    }
  }

  // Obtener una auditoría por ID
  static Future<Auditoria?> getAuditoria(String id) async {
    try {
      final request = ModelQueries.get(Auditoria.classType, AuditoriaModelIdentifier(id: id));
      final response = await Amplify.API.query(request: request).response;

      return response.data;
    } catch (e) {
      throw Exception('Error al obtener auditoría: $e');
    }
  }

  // Listar auditorías por negocioID
  static Future<List<Auditoria>> listAuditoriasByNegocio(String negocioId) async {
    try {
      final request = ModelQueries.list(
        Auditoria.classType,
        where: Auditoria.NEGOCIOID.eq(negocioId),
      );
      final response = await Amplify.API.query(request: request).response;

      return response.data?.items
              .cast<Auditoria>()
              .whereType<Auditoria>()
              .toList() ??
          [];
    } catch (e) {
      throw Exception('Error al listar auditorías: $e');
    }
  }

  // Listar todas las auditorías (con paginación opcional)
  static Future<List<Auditoria>> listAuditorias({
    String? nextToken,
    int? limit,
  }) async {
    try {
      final request = ModelQueries.list(Auditoria.classType, limit: limit);
      final response = await Amplify.API.query(request: request).response;

      return response.data?.items
              .cast<Auditoria>()
              .whereType<Auditoria>()
              .toList() ??
          [];
    } catch (e) {
      throw Exception('Error al listar auditorías: $e');
    }
  }
}
