// lib/services/product/product_controller.dart
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/product/product_manager.dart';
import 'package:compaexpress/services/product/product_service.dart';

class ProductController {
  static final ProductManager _manager = getProductManager();

  static Future<void> save(Producto producto) => _manager.saveData(producto);

  static Future<Producto?> saveAndReturn(Producto producto) =>
      _manager.saveDataReturned(producto);

  static Future<Producto?> getById(String id) => _manager.getData(id);

  static Future<bool> existsByName(String name) =>
      _manager.productExistsByName(name);
  static Future<bool> barCodeUsed(String barCode) =>
      _manager.productBarCodeUsed(barCode);
  static Future<Map<String, bool>> validateProductNameAndBarCode(name, barCode) =>
      _manager.validateProductNameAndBarCode(name, barCode);
}
