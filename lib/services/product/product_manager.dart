import 'package:compaexpress/models/ModelProvider.dart';

abstract class ProductManager {
  Future<void> saveData(Producto data);
  Future<Producto?> saveDataReturned(Producto data);
  Future<Producto?> getData(String id);
  Future<bool> productExistsByName(String name);
  Future<bool> productBarCodeUsed(String barCode);
  Future<Map<String, bool>> validateProductNameAndBarCode(String name,String barCode);
}
