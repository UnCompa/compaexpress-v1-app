import 'package:compaexpress/models/SesionDispositivo.dart';

class DeviceAccessResult {
  final bool success;
  final String? errorMessage;
  final SesionDispositivo? session;
  final String? deviceType;
  final int? maxDevices;
  final bool isExpired;

  DeviceAccessResult._({
    required this.success,
    this.errorMessage,
    this.session,
    this.deviceType,
    this.maxDevices,
    this.isExpired = false,
  });

  factory DeviceAccessResult.success(SesionDispositivo session) {
    return DeviceAccessResult._(success: true, session: session);
  }

  factory DeviceAccessResult.limitReached(String deviceType, int maxDevices) {
    return DeviceAccessResult._(
      success: false,
      errorMessage:
          'Límite de dispositivos $deviceType alcanzado ($maxDevices)',
      deviceType: deviceType,
      maxDevices: maxDevices,
    );
  }

  factory DeviceAccessResult.expired() {
    return DeviceAccessResult._(
      success: false,
      errorMessage: 'La vigencia del negocio ha expirado',
      isExpired: true,
    );
  }

  factory DeviceAccessResult.error(String message) {
    return DeviceAccessResult._(success: false, errorMessage: message);
  }

  @override
  String toString() {
    return 'DeviceAccessResult(success: $success, '
        'errorMessage: ${errorMessage ?? 'none'}, '
        'session: ${session != null ? 'SesionDispositivo(id: ${session!.id})' : 'none'}, '
        'deviceType: ${deviceType ?? 'none'}, '
        'maxDevices: ${maxDevices ?? 'none'}, '
        'isExpired: $isExpired)';
  }
}
