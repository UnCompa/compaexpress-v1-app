import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/Producto.dart';
import 'package:compaexpress/services/product/product_manager.dart';

class MobileProductService implements ProductManager {
  @override
  Future<Producto?> getData(String id) async {
    final results = await Amplify.DataStore.query(
      Producto.classType,
      where: Producto.ID.eq(id),
    );
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<void> saveData(Producto data) async {
    await Amplify.DataStore.save(data);
  }

  @override
  Future<Producto?> saveDataReturned(Producto data) async {
    safePrint("Guardando producto - MOBILE");
    await Amplify.DataStore.save(data);
    final results = await Amplify.DataStore.query(
      Producto.classType,
      where: Producto.ID.eq(data.id),
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  @override
  Future<bool> productExistsByName(String name) async {
    try {
      final results = await Amplify.DataStore.query(
        Producto.classType,
        where: Producto.NOMBRE.eq(name),
      );
      if (results.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception("No se pudo realizar la busqueda del producto: $e");
    }
  }
  
  @override
  Future<bool> productBarCodeUsed(String barCode) async {
    try {
      final results = await Amplify.DataStore.query(
        Producto.classType,
        where: Producto.BARCODE.eq(barCode),
      );
      if (results.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception("No se pudo realizar la busqueda del producto: $e");
    }
  }
  
  @override
  Future<Map<String, bool>> validateProductNameAndBarCode(String name, String barCode) {
    // TODO: implement validateProductNameAndBarCode
    throw UnimplementedError();
  }
}
