import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/Proveedor.dart';
import 'package:compaexpress/services/negocio/negocio_controller.dart';

class ProveedorService {
  static Future<List<Proveedor?>> getAllProveedores() async {
    try {
      final negocio = await NegocioController.getUserInfo();
      final request = ModelQueries.list(
        Proveedor.classType,
        where:
            Proveedor.NEGOCIOID.eq(negocio.negocioId) &
            Proveedor.ISDELETED.eq(false),
      );
      final response = await Amplify.API.query(request: request).response;

      return response.data!.items
          .where((item) => item != null)
          .cast<Proveedor>()
          .toList();
    } catch (e) {
      throw Exception("Error al obtener los proveedores");
    }
  }
}
