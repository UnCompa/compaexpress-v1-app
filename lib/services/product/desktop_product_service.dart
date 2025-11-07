import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/Producto.dart';
import 'package:compaexpress/services/product/product_manager.dart';
import 'package:flutter/material.dart';

class DesktopProductService implements ProductManager {
  @override
  Future<Producto?> getData(String id) async {
    final request = ModelQueries.list(
      Producto.classType,
      where: Producto.ID.eq(id),
    );
    final results = await Amplify.API.query(request: request).response;
    return results.data!.items.isNotEmpty ? results.data!.items.first : null;
  }

  @override
  Future<void> saveData(Producto data) async {
    final productoRequest = ModelMutations.create(data);
    await Amplify.API.mutate(request: productoRequest).response;
  }

  @override
  Future<Producto?> saveDataReturned(Producto data) async {
    try {
      safePrint("Guardando producto - Desktop");
      final productoRequest = ModelMutations.create(data);
      final productoResponse = await Amplify.API
          .mutate(request: productoRequest)
          .response;
      debugPrint("GUARDADO - $productoResponse");
      final createdProducto = productoResponse.data;
      return createdProducto;
    } catch (e) {
      throw Exception("No se pudo guardar el producto");
    }
  }

  @override
  Future<bool> productExistsByName(String name) async {
    try {
      final request = ModelQueries.list(
        Producto.classType,
        where: Producto.NOMBRE.eq(name),
      );
      final response = await Amplify.API.query(request: request).response;
      if (response.data!.items.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception("No se pudo realizar la busqueda del producto");
    }
  }

  @override
  Future<bool> productBarCodeUsed(String barCode) async {
    try {
      final request = ModelQueries.list(
        Producto.classType,
        where: Producto.BARCODE.eq(barCode),
      );

      final response = await Amplify.API.query(request: request).response;
      if (response.data!.items.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception("No se pudo realizar la busqueda del producto: $e");
    }
  }

  @override
  Future<Map<String, bool>> validateProductNameAndBarCode(
    String name,
    String barCode,
  ) async {
    // Consulta única para verificar ambos
    bool nameExists = false;
    bool barCodeExists = false;
    final requestForName = ModelQueries.list(
      Producto.classType,
      where: Producto.NOMBRE.eq(name),
    );
    final requestForBarCode = ModelQueries.list(
      Producto.classType,
      where: Producto.BARCODE.eq(barCode),
    );

    final futures = await Future.wait([
      Amplify.API.query(request: requestForName).response,
      Amplify.API.query(request: requestForBarCode).response,
    ]);

    final nameExistsResult = futures[0];
    if (nameExistsResult.data!.items.isNotEmpty) {
      nameExists = true;
    }
    final barCodeExistsResult = futures[1];
    if (barCodeExistsResult.data!.items.isNotEmpty) {
      barCodeExists = true;
    }

    return {'nameExists': nameExists, 'barCodeExists': barCodeExists};
  }
}
