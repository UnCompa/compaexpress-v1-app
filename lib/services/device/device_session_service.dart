// services/device/device_session_service.dart
import 'package:compaexpress/services/device/desktop_device_session_service.dart';
import 'package:compaexpress/services/device/device_session_manager.dart';
import 'package:compaexpress/utils/platform_avalible.dart';

DeviceSessionManager getDeviceSessionManager() {
  //if (isMobile) return MobileDeviceSessionService();
  if (isDesktop || isMobile) return DesktopDeviceSessionService();
  throw UnsupportedError("Plataforma no soportada para sesión de dispositivos");
}
