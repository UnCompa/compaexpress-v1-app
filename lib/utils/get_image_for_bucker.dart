import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

class GetImageFromBucket {
  /// Obtiene URLs firmadas para una lista de claves de S3.
  /// [s3Keys]: Lista de claves de S3 para las imágenes.
  /// [expiresIn]: Duración de validez de las URLs firmadas (por defecto, 60 minutos).
  /// Devuelve una lista de URLs firmadas o una lista vacía si ocurre un error.
  static Future<List<String>> getSignedImageUrls({
    required List<String> s3Keys,
    Duration expiresIn = const Duration(minutes: 60),
  })async {
    try {
      List<String> signedUrls = [];

      // Iterar sobre cada clave de S3
      for (String key in s3Keys){
        final result = await Amplify.Storage.getUrl(
          path: StoragePath.fromString(key),
          options: StorageGetUrlOptions(
            pluginOptions: S3GetUrlPluginOptions(
              validateObjectExistence: true,
              expiresIn: Duration(days: 1),
            ),
          ),
        ).result;

        signedUrls.add(result.url.toString());
      }

      return signedUrls;
    } catch (e){
      print('Error al obtener URLs firmadas: $e');
      return [];
    }
  }
}
