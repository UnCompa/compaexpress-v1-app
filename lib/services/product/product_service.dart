import 'package:compaexpress/services/product/desktop_product_service.dart';
//import 'package:compaexpress/services/product/mobile_product_service.dart';
import 'package:compaexpress/services/product/product_manager.dart';

ProductManager getProductManager() {
  //if (isMobile) return MobileProductService();
  return DesktopProductService();
}
