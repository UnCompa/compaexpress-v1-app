// services/device/device_session_controller.dart
import 'package:compaexpress/entities/device_access_result.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/device/device_session_manager.dart';
import 'package:compaexpress/services/device/device_session_service.dart';

class DeviceSessionController {
  static final DeviceSessionManager _manager = getDeviceSessionManager();

  static Future<Map<String, String>> getDeviceInfo() =>
      _manager.getDeviceInfo();
  static Future<DeviceAccessResult> checkAccess(
    Negocio negocio,
    String userId,
  ) => _manager.checkDeviceAccess(negocio, userId);
  static Future<void> keepAlive() => _manager.keepSessionAlive();
  static Future<void> closeSession() => _manager.closeCurrentSession();
  static Future<void> closeSpecific(String sessionId) =>
      _manager.closeSpecificSession(sessionId);
  static Future<List<SesionDispositivo?>> getSessions(String negocioId) =>
      _manager.getActiveSessions(negocioId);
  static Future<Map<String, dynamic>> getConnectedDevices(String negocioId) =>
      _manager.getConnectedDevicesInfo(negocioId);
}
  