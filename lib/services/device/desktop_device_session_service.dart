import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/entities/device_access_result.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/device/device_session_manager.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

class DesktopDeviceSessionService implements DeviceSessionManager {
  static const int SESSION_TIMEOUT_HOURS = 24;

  /// Verifica la vigencia del negocio
  static Future<bool> checkNegocioVigencia(Negocio negocio) async {
    if (negocio.duration == null) return true; // Sin límite de duración

    final createdAt = negocio.createdAt;

    final now = DateTime.now();
    final createdDate = createdAt.getDateTimeInUtc();
    final expiryDate = createdDate.add(Duration(days: negocio.duration!));

    return now.isBefore(expiryDate);
  }

  /// Obtiene información del dispositivo actual
  /// Obtiene información detallada del dispositivo para un mejor control y seguimiento.
  @override
  Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final uuid = Uuid(); // Para generar IDs únicos
    String deviceId = '';
    String deviceType = '';
    String deviceDescription = '';
    String osVersion = '';
    String appVersion = '';
    String networkStatus = '';

    try {
      // Obtener información de la aplicación
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';

      // Obtener estado de la red
      final connectivityResults = await Connectivity().checkConnectivity();
      networkStatus = _mapConnectivityResults(connectivityResults);

      if (UniversalPlatform.isWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        // Generar un deviceId único y persistente basado en browser info
        deviceId = _generateUniqueDeviceId(
          '${webInfo.browserName}_${webInfo.userAgent}',
          uuid,
        );
        deviceType = 'WEB';
        deviceDescription =
            '${webInfo.browserName} on ${webInfo.platform ?? 'Unknown'}';
        osVersion = webInfo.platform ?? 'Unknown';
      } else if (UniversalPlatform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = _generateUniqueDeviceId(androidInfo.id, uuid);
        deviceType = 'MOBILE';
        deviceDescription = '${androidInfo.brand} ${androidInfo.model}';
        osVersion = androidInfo.version.release;
      } else if (UniversalPlatform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = _generateUniqueDeviceId(
          iosInfo.identifierForVendor ?? 'unknown_ios',
          uuid,
        );
        deviceType = 'MOBILE';
        deviceDescription = '${iosInfo.name} ${iosInfo.model}';
        osVersion = iosInfo.systemVersion;
      } else if (UniversalPlatform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceId = _generateUniqueDeviceId(windowsInfo.deviceId, uuid);
        deviceType = 'DESKTOP';
        deviceDescription = 'Windows ${windowsInfo.productName}';
        osVersion = windowsInfo.releaseId;
      } else if (UniversalPlatform.isMacOS) {
        final macOsInfo = await deviceInfo.macOsInfo;
        deviceId = _generateUniqueDeviceId(
          macOsInfo.systemGUID ?? 'unknown_macos',
          uuid,
        );
        deviceType = 'DESKTOP';
        deviceDescription = 'macOS ${macOsInfo.model}';
        osVersion = macOsInfo.osRelease;
      } else if (UniversalPlatform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        deviceId = _generateUniqueDeviceId(
          linuxInfo.machineId ?? 'unknown_linux',
          uuid,
        );
        deviceType = 'DESKTOP';
        deviceDescription = 'Linux ${linuxInfo.prettyName}';
        osVersion = linuxInfo.version ?? 'Unknown';
      } else {
        // Fallback para plataformas no soportadas
        deviceId = _generateUniqueDeviceId(
          'unknown_${DateTime.now().millisecondsSinceEpoch}',
          uuid,
        );
        deviceType = 'UNKNOWN';
        deviceDescription = 'Dispositivo desconocido';
        osVersion = 'Unknown';
      }
    } catch (e, stackTrace) {
      // Mejor manejo de errores con stack trace para depuración
      safePrint('Error obteniendo info del dispositivo: $e\n$stackTrace');
      deviceId = _generateUniqueDeviceId(
        'error_${DateTime.now().millisecondsSinceEpoch}',
        uuid,
      );
      deviceType = UniversalPlatform.isWeb ? 'WEB' : 'UNKNOWN';
      deviceDescription = 'Dispositivo desconocido';
      osVersion = 'Unknown';
      networkStatus = 'Unknown';
    }

    return {
      'deviceId': deviceId,
      'deviceType': deviceType,
      'deviceDescription': deviceDescription,
      'osVersion': osVersion,
      'appVersion': appVersion,
      'networkStatus': networkStatus,
    };
  }

  /// Genera un ID único para el dispositivo basado en la información proporcionada.
  static String _generateUniqueDeviceId(String baseId, Uuid uuid) {
    // Combinar baseId con un UUID para garantizar unicidad
    return uuid.v5(Uuid.NAMESPACE_OID, baseId);
  }

  /// Mapea el resultado de conectividad a una cadena legible.
  static String _mapConnectivityResults(List<ConnectivityResult> results) {
    // Priorizar conexiones: WiFi > Ethernet > Mobile > None > Unknown
    if (results.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Mobile';
    } else if (results.contains(ConnectivityResult.none)) {
      return 'None';
    }
    return 'Unknown';
  }

  /// Verifica si el dispositivo puede conectarse

  // Método principal corregido
  @override
  Future<DeviceAccessResult> checkDeviceAccess(
    Negocio negocio,
    String userId,
  ) async {
    try {
      // 1. Verificar vigencia del negocio
      if (!await checkNegocioVigencia(negocio)) {
        return DeviceAccessResult.expired();
      }

      // 2. Obtener información del dispositivo
      final deviceInfo = await getDeviceInfo();
      safePrint('Información del dispositivo: $deviceInfo');
      final deviceType = deviceInfo['deviceType'] ?? 'UNKNOWN';
      final deviceId = deviceInfo['deviceId'] ?? '';
      final deviceDescription =
          deviceInfo['deviceDescription'] ?? 'Dispositivo desconocido';

      if (deviceId.isEmpty) {
        safePrint('Error: deviceId no válido');
        return DeviceAccessResult.error(
          'No se pudo obtener un ID de dispositivo válido',
        );
      }

      // 3. CORREGIDO: Limpiar y obtener sesión válida del dispositivo
      final existingSession = await _getOrCleanupDeviceSession(
        negocio.id,
        deviceId,
        userId,
      );
      safePrint(
        'Sesión después de limpieza: ${existingSession?.toString() ?? "ninguna"}',
      );

      if (existingSession != null) {
        // Actualizar última actividad
        await _updateSessionActivity(existingSession);
        safePrint('Reutilizando sesión existente: ${existingSession.id}');
        return DeviceAccessResult.success(existingSession);
      }

      // 4. Verificar límites de dispositivos (solo si no hay sesión existente)
      final activeSessions = await _getActiveSessions(negocio.id, deviceType);
      safePrint('Sesiones activas ($deviceType): ${activeSessions.length}');
      final maxDevices = deviceType == 'DESKTOP'
          ? negocio.pcAccess
          : negocio.movilAccess;
      safePrint(
        'Máximo de dispositivos permitido ($deviceType): ${maxDevices ?? "sin límite"}',
      );

      if (maxDevices != null && activeSessions.length >= maxDevices) {
        return DeviceAccessResult.limitReached(deviceType, maxDevices);
      }

      // 5. Crear nueva sesión
      final newSession = await _createSession(
        negocio.id,
        userId,
        deviceId,
        deviceType,
        deviceDescription,
      );

      safePrint('Nueva sesión creada: ${newSession.id}');
      return DeviceAccessResult.success(newSession);
    } catch (e, stackTrace) {
      safePrint('Error verificando acceso del dispositivo: $e\n$stackTrace');
      return DeviceAccessResult.error(e.toString());
    }
  }

  // NUEVO: Método que limpia y retorna la sesión válida del dispositivo
  /// NUEVO: Método que limpia y retorna la sesión válida del dispositivo
  static Future<SesionDispositivo?> _getOrCleanupDeviceSession(
    String negocioId,
    String deviceId,
    String userId,
  ) async {
    try {
      // Obtener TODAS las sesiones de este dispositivo específico
      final request = ModelQueries.list(
        SesionDispositivo.classType,
        where:
            SesionDispositivo.NEGOCIOID.eq(negocioId) &
            SesionDispositivo.DEVICEID.eq(deviceId),
      );

      final response = await Amplify.API.query(request: request).response;
      final allSessions =
          response.data?.items.whereType<SesionDispositivo>().toList() ?? [];

      safePrint(
        'Total sesiones encontradas para dispositivo $deviceId: ${allSessions.length}',
      );

      if (allSessions.isEmpty) {
        return null;
      }

      final now = DateTime.now();
      SesionDispositivo? validSession;
      List<String> sessionsToDeactivate = [];

      // Analizar todas las sesiones del dispositivo
      for (final session in allSessions) {
        final lastActivity = session.lastActivity.getDateTimeInUtc();
        final hoursSinceActivity = now.difference(lastActivity).inHours;

        safePrint(
          'Analizando sesión ${session.id}: activa=${session.isActive}, horas=$hoursSinceActivity',
        );

        if (session.isActive && hoursSinceActivity <= SESSION_TIMEOUT_HOURS) {
          // Sesión activa y válida
          if (validSession == null ||
              lastActivity.isAfter(
                validSession.lastActivity.getDateTimeInUtc(),
              )) {
            // Si ya teníamos una sesión válida, marcar la anterior para desactivar
            if (validSession != null) {
              sessionsToDeactivate.add(validSession.id);
            }
            validSession = session;
          } else {
            // Esta sesión es más antigua, desactivar
            sessionsToDeactivate.add(session.id);
          }
        } else {
          // Sesión inactiva o expirada, marcar para desactivar
          if (session.isActive) {
            // Solo si está marcada como activa
            sessionsToDeactivate.add(session.id);
          }
        }
      }

      // Desactivar sesiones duplicadas/expiradas
      for (final sessionId in sessionsToDeactivate) {
        await _deactivateSession(sessionId);
        safePrint('Sesión desactivada: $sessionId');
      }

      // Si encontramos una sesión válida, verificar que el userId coincida
      if (validSession != null && validSession.userId != userId) {
        safePrint('Usuario diferente en sesión existente, desactivando');
        await _deactivateSession(validSession.id);
        return null;
      }

      if (validSession != null) {
        safePrint('Sesión válida encontrada: ${validSession.id}');
      }

      return validSession;
    } catch (e, stackTrace) {
      safePrint('Error en _getOrCleanupDeviceSession: $e\n$stackTrace');
      return null;
    }
  }

  /// MEJORADO: Método _getActiveSession simplificado (ya no se usa en checkDeviceAccess)
  static Future<SesionDispositivo?> _getActiveSession(
    String negocioId,
    String deviceId,
  ) async {
    try {
      final request = ModelQueries.list(
        SesionDispositivo.classType,
        where:
            SesionDispositivo.NEGOCIOID.eq(negocioId) &
            SesionDispositivo.DEVICEID.eq(deviceId) &
            SesionDispositivo.ISACTIVE.eq(true),
        limit: 1,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.hasErrors) {
        safePrint('Errores en consulta de sesión activa: ${response.errors}');
        return null;
      }

      final session = response.data?.items
          .whereType<SesionDispositivo>()
          .firstOrNull;
      if (session == null) return null;

      // Verificar si la sesión no ha expirado
      final lastActivity = session.lastActivity.getDateTimeInUtc();
      final now = DateTime.now();
      final hoursSinceActivity = now.difference(lastActivity).inHours;

      if (hoursSinceActivity > SESSION_TIMEOUT_HOURS) {
        safePrint('Sesión expirada, desactivando: ${session.id}');
        await _deactivateSession(session.id);
        return null;
      }

      return session;
    } catch (e) {
      safePrint('Error obteniendo sesión activa: $e');
      return null;
    }
  }

  /// NUEVO: Método para reactivar una sesión inactiva
  static Future<SesionDispositivo?> _reactivateSession(
    SesionDispositivo session,
  ) async {
    try {
      final reactivatedSession = session.copyWith(
        isActive: true,
        lastActivity: TemporalDateTime.now(),
      );

      final request = ModelMutations.update(reactivatedSession);
      final response = await Amplify.API.mutate(request: request).response;

      return response.data;
    } catch (e) {
      safePrint('Error reactivando sesión: $e');
      return null;
    }
  }

  static Future<void> cleanupAllDuplicateSessions(String negocioId) async {
    try {
      final request = ModelQueries.list(
        SesionDispositivo.classType,
        where: SesionDispositivo.NEGOCIOID.eq(negocioId),
      );

      final response = await Amplify.API.query(request: request).response;
      final sessions =
          response.data?.items.whereType<SesionDispositivo>().toList() ?? [];

      // Agrupar por deviceId
      final sessionsByDevice = <String, List<SesionDispositivo>>{};
      for (final session in sessions) {
        sessionsByDevice.putIfAbsent(session.deviceId, () => []).add(session);
      }

      int cleanedSessions = 0;
      final now = DateTime.now();

      // Limpiar cada dispositivo
      for (final entry in sessionsByDevice.entries) {
        final deviceSessions = entry.value;
        if (deviceSessions.length <= 1) continue;

        // Ordenar por última actividad (más reciente primero)
        deviceSessions.sort(
          (a, b) => b.lastActivity.getDateTimeInUtc().compareTo(
            a.lastActivity.getDateTimeInUtc(),
          ),
        );

        SesionDispositivo? validSession;
        for (final session in deviceSessions) {
          final lastActivity = session.lastActivity.getDateTimeInUtc();
          final hoursSinceActivity = now.difference(lastActivity).inHours;

          if (session.isActive &&
              hoursSinceActivity <= SESSION_TIMEOUT_HOURS &&
              validSession == null) {
            // Esta es la sesión válida más reciente
            validSession = session;
          } else {
            // Desactivar esta sesión (duplicada o expirada)
            await _deactivateSession(session.id);
            cleanedSessions++;
          }
        }
      }

      safePrint(
        'Limpieza completada: $cleanedSessions sesiones duplicadas eliminadas',
      );
    } catch (e) {
      safePrint('Error en limpieza general: $e');
    }
  }

  /// Obtiene todas las sesiones activas por tipo de dispositivo
  static Future<List<SesionDispositivo>> _getActiveSessions(
    String negocioId,
    String deviceType,
  ) async {
    try {
      // Crear la solicitud con filtros usando QueryPredicate
      final request = ModelQueries.list(
        SesionDispositivo.classType,
        where:
            SesionDispositivo.NEGOCIOID.eq(negocioId) &
            SesionDispositivo.DEVICETYPE.eq(deviceType) &
            SesionDispositivo.ISACTIVE.eq(true),
      );

      // Ejecutar la consulta con Amplify.API
      final response = await Amplify.API.query(request: request).response;

      // Obtener los ítems de la respuesta
      final items = response.data?.items;
      if (items == null) {
        safePrint('errors: ${response.errors}');
        return const [];
      }

      // Convertir los ítems a una lista de SesionDispositivo, filtrando posibles nulos
      List<SesionDispositivo> activeSessions = items
          .whereType<SesionDispositivo>()
          .toList();

      // Procesar las sesiones para verificar si han expirado
      List<SesionDispositivo> validSessions = [];
      final now = DateTime.now();
      for (final session in activeSessions) {
        final lastActivity = session.lastActivity.getDateTimeInUtc();
        final hoursSinceActivity = now.difference(lastActivity).inHours;
        if (hoursSinceActivity > SESSION_TIMEOUT_HOURS) {
          await _deactivateSession(session.id); // Desactivar sesión expirada
        } else {
          validSessions.add(session); // Agregar sesión válida
        }
      }

      return validSessions;
    } catch (e) {
      safePrint('Error obteniendo sesiones activas: $e');
      return const [];
    }
  }

  /// Crea una nueva sesión
  static Future<SesionDispositivo> _createSession(
    String negocioId,
    String userId,
    String deviceId,
    String deviceType,
    String deviceInfo,
  ) async {
    final session = SesionDispositivo(
      negocioId: negocioId,
      userId: userId,
      deviceId: deviceId,
      deviceType: deviceType,
      deviceInfo: deviceInfo,
      isActive: true,
      lastActivity: TemporalDateTime.now(),
      createdAt: TemporalDateTime.now(),
      updatedAt: TemporalDateTime.now(),
    );

    final request = ModelMutations.create(session);
    final response = await Amplify.API.mutate(request: request).response;

    if (response.data != null) {
      return response.data!;
    } else {
      throw Exception('Error creando sesión: ${response.errors}');
    }
  }

  /// Actualiza la última actividad de una sesión
  static Future<void> _updateSessionActivity(SesionDispositivo session) async {
    try {
      final updatedSession = session.copyWith(
        lastActivity: TemporalDateTime.now(),
      );

      final request = ModelMutations.update(updatedSession);
      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      safePrint('Error actualizando actividad de sesión: $e');
    }
  }

  /// Desactiva una sesión
  static Future<void> _deactivateSession(String sessionId) async {
    try {
      // Primero obtener la sesión
      final getRequest = ModelQueries.get(
        SesionDispositivo.classType,
        SesionDispositivoModelIdentifier(id: sessionId),
      );
      final getResponse = await Amplify.API.query(request: getRequest).response;

      if (getResponse.data != null) {
        final session = getResponse.data!.copyWith(isActive: false);
        final updateRequest = ModelMutations.delete(session);
        await Amplify.API.mutate(request: updateRequest).response;
      }
    } catch (e) {
      safePrint('Error desactivando sesión: $e');
    }
  }

  /// Cierra la sesión del dispositivo actual
  @override
  Future<void> closeCurrentSession() async {
    try {
      final deviceInfo = await getDeviceInfo();
      print("== INFORMACION DISPOSITIVO");
      print(deviceInfo);
      final user = await Amplify.Auth.getCurrentUser();
      final userInfo = await NegocioService.getCurrentUserInfo();
      final negocioId = userInfo.negocioId;

      final session = await _getActiveSession(
        negocioId,
        deviceInfo['deviceId']!,
      );
      print("== INFORMACION SESSION");
      print(session);
      if (session != null) {
        print("== CERRANDO SESSION");
        await _deactivateSession(session.id);
      }
    } catch (e) {
      safePrint('Error cerrando sesión actual: $e');
    }
  }

  /// Mantiene la sesión activa (llamar periódicamente)
  @override
  Future<void> keepSessionAlive() async {
    try {
      final deviceInfo = await getDeviceInfo();
      final userInfo = await NegocioService.getCurrentUserInfo();
      final negocioId = userInfo.negocioId;

      final session = await _getActiveSession(
        negocioId,
        deviceInfo['deviceId']!,
      );
      if (session != null) {
        await _updateSessionActivity(session);
      }
    } catch (e) {
      safePrint('Error manteniendo sesión activa: $e');
    }
  }

  /// Obtiene todas las sesiones activas para un negocio
  @override
  Future<List<SesionDispositivo?>> getActiveSessions(String negocioId) async {
    try {
      final request = ModelQueries.list(
        SesionDispositivo.classType,
        where: SesionDispositivo.NEGOCIOID
            .eq(negocioId)
            .and(SesionDispositivo.ISACTIVE.eq(true)),
      );
      final response = await Amplify.API.query(request: request).response;

      final sessions = response.data?.items;
      if (sessions == null) {
        safePrint('Errores: ${response.errors}');
        return const [];
      }

      List<SesionDispositivo?> activeSessions = [];
      final now = DateTime.now();

      for (final session in sessions) {
        if (session == null) continue;
        final lastActivity = session.lastActivity.getDateTimeInUtc();
        final hoursSinceActivity = now.difference(lastActivity).inHours;

        if (hoursSinceActivity > SESSION_TIMEOUT_HOURS) {
          // Desactivar sesión expirada
          await _deactivateSession(session.id);
        } else {
          activeSessions.add(session);
        }
      }

      return activeSessions;
    } on ApiException catch (e) {
      safePrint('Consulta de sesiones fallida: $e');
      return const [];
    }
  }

  /// Cierra una sesión específica
  @override
  Future<void> closeSpecificSession(String sessionId) async {
    try {
      final getRequest = ModelQueries.get(
        SesionDispositivo.classType,
        SesionDispositivoModelIdentifier(id: sessionId),
      );
      final getResponse = await Amplify.API.query(request: getRequest).response;

      final session = getResponse.data;
      if (session == null) {
        safePrint('Errores: ${getResponse.errors}');
        throw Exception('Sesión no encontrada');
      }

      if (!session.isActive) {
        return;
      }

      final updatedSession = session.copyWith(isActive: false);
      final updateRequest = ModelMutations.update(updatedSession);
      final updateResponse = await Amplify.API
          .mutate(request: updateRequest)
          .response;

      if (updateResponse.data == null) {
        safePrint('Errores al actualizar: ${updateResponse.errors}');
        throw Exception('Error al cerrar la sesión');
      }
    } on ApiException catch (e) {
      safePrint('Cierre de sesión fallido: $e');
      rethrow;
    }
  }

  /// Obtiene información de los dispositivos conectados para un negocio
  /// Obtiene información de los dispositivos conectados para un negocio
  @override
  Future<Map<String, dynamic>> getConnectedDevicesInfo(String negocioId) async {
    try {
      final request = ModelQueries.list(
        SesionDispositivo.classType,
        where: SesionDispositivo.NEGOCIOID
            .eq(negocioId)
            .and(SesionDispositivo.ISACTIVE.eq(true)),
      );
      final response = await Amplify.API.query(request: request).response;

      final sessions = response.data?.items;
      if (sessions == null) {
        safePrint('Errores: ${response.errors}');
        return {'devices': [], 'total': 0};
      }

      List<Map<String, dynamic>> connectedDevices = [];
      final now = DateTime.now();

      for (final session in sessions) {
        if (session == null) continue;
        final lastActivity = session.lastActivity.getDateTimeInUtc();
        final hoursSinceActivity = now.difference(lastActivity).inHours;

        if (hoursSinceActivity > SESSION_TIMEOUT_HOURS) {
          // Desactivar sesión expirada
          await _deactivateSession(session.id);
          continue;
        }

        // Intentar obtener el nombre del usuario (si tienes un método para esto)
        String userName = session.userId;
        try {
          final userInfo = await NegocioService.getCurrentUserInfo();
          userName =
              userInfo.userId ?? session.userId; // Ajusta según tu modelo
        } catch (e) {
          safePrint(
            'Error obteniendo nombre de usuario para ${session.userId}: $e',
          );
        }

        connectedDevices.add({
          'sessionId': session.id,
          'deviceType': session.deviceType.toLowerCase(),
          'deviceName': session.deviceInfo ?? 'Dispositivo desconocido',
          'userName': userName,
          'lastAccess': session.lastActivity
              .getDateTimeInUtc()
              .toLocal()
              .toString()
              .substring(0, 16),
        });
      }

      return {'devices': connectedDevices, 'total': connectedDevices.length};
    } on ApiException catch (e) {
      safePrint('Consulta de dispositivos conectados fallida: $e');
      return {'devices': [], 'total': 0};
    }
  }
}
