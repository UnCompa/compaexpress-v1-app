import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/Caja.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:flutter/material.dart';

// Clase para manejar la caché
class CacheEntry<T> {
  final T data;
  final DateTime expiryTime;

  CacheEntry(this.data, this.expiryTime);

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

class CajaService {
  // Cache en memoria
  static CacheEntry<Caja>? _cajaCache;
  // Duración de la caché (por ejemplo, 5 minutos)
  static const cacheDuration = Duration(minutes: 5);

  static Future<Caja> getCurrentCaja({bool forceRefresh = false}) async {
    try {
      // Verificar si hay datos en caché y no están expirados, salvo que se solicite refrescar
      if (!forceRefresh && _cajaCache != null && !_cajaCache!.isExpired) {
        debugPrint('Caja obtenida desde caché: ${_cajaCache!.data}');
        return _cajaCache!.data;
      }

      // Obtener datos desde la API
      final negocioInfo = await NegocioService.getCurrentUserInfo();
      final request = ModelQueries.list(
        Caja.classType,
        where:
            Caja.NEGOCIOID.eq(negocioInfo.negocioId) & Caja.ISDELETED.eq(false),
      );
      final response = await Amplify.API.query(request: request).response;
      final List<Caja?>? cajas = response.data?.items;

      if (cajas == null || cajas.isEmpty) {
        debugPrint('No se encontraron cajas para el negocio.');
        throw Exception('No se encontraron cajas para el negocio.');
      }

      final List<Caja> cajasNotNullable = cajas.whereType<Caja>().toList();

      if (cajasNotNullable.isEmpty) {
        debugPrint(
          'No se encontraron cajas válidas para el negocio después de filtrar nulos.',
        );
        throw Exception('No se encontraron cajas válidas para el negocio.');
      }

      cajasNotNullable.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final newestCaja = cajasNotNullable.first;

      // Guardar en caché con tiempo de expiración
      _cajaCache = CacheEntry(newestCaja, DateTime.now().add(cacheDuration));

      debugPrint('Caja obtenida desde API y guardada en caché: $newestCaja');
      return newestCaja;
    } catch (e) {
      debugPrint('Error al obtener caja: $e');
      // Si hay un error, intentar devolver la caché si existe y no está expirada
      if (_cajaCache != null && !_cajaCache!.isExpired) {
        debugPrint(
          'Devolviendo caja desde caché debido a error: ${_cajaCache!.data}',
        );
        return _cajaCache!.data;
      }
      rethrow;
    }
  }

  // Método para invalidar la caché manualmente si es necesario
  static void invalidateCache() {
    _cajaCache = null;
    debugPrint('Caché de caja invalidada.');
  }

  static void updateCache(Caja updatedCaja) {
    _cajaCache = CacheEntry(updatedCaja, DateTime.now().add(cacheDuration));
    debugPrint('Caché actualizada con caja: $updatedCaja');
  }
}
