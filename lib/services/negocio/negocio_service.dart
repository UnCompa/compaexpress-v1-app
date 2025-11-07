import 'package:compaexpress/services/negocio/desktop_negocio_service.dart';
import 'package:compaexpress/services/negocio/negocio_manager.dart';
import 'package:compaexpress/utils/platform_avalible.dart';

NegocioManager getNegocioManager() {
  //print("PLATFORM");
  //print(isMobile);
  //print(isDesktop);
  //if (isMobile) return MobileNegocioService();
  if (isDesktop || isMobile) return DesktopNegocioService();
  
  throw UnsupportedError("Plataforma no soportada para gestión de negocios");
}
