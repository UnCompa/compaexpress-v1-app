// services/device/device_session_manager.dart
import 'package:compaexpress/entities/device_access_result.dart';
import 'package:compaexpress/models/ModelProvider.dart';

abstract class DeviceSessionManager {
  Future<Map<String, String>> getDeviceInfo();
  Future<DeviceAccessResult> checkDeviceAccess(Negocio negocio, String userId);
  Future<void> keepSessionAlive();
  Future<void> closeCurrentSession();
  Future<List<SesionDispositivo?>> getActiveSessions(String negocioId);
  Future<void> closeSpecificSession(String sessionId);
  Future<Map<String, dynamic>> getConnectedDevicesInfo(String negocioId);
}
