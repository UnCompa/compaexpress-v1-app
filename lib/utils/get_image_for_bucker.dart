import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

class GetImageFromBucket {
  /// Obtiene URLs firmadas para una lista de claves de S3.
  static Future<List<String>> getSignedImageUrls({
    required List<String> s3Keys,
    Duration expiresIn = const Duration(minutes: 60),
  }) async {
    try {
      final List<String> signedUrls = [];

      for (final key in s3Keys) {
        final url = await _getSingleSignedUrl(key, expiresIn);
        if (url.isNotEmpty) signedUrls.add(url);
      }

      return signedUrls;
    } catch (e) {
      print('Error al obtener URLs firmadas: $e');
      return [];
    }
  }

  /// Obtiene una única URL firmada para una clave de S3.
  /// [s3Key]: clave completa del objeto en S3.
  /// [expiresIn]: duración de validez de la URL (por defecto 60 min).
  /// Devuelve la URL firmada o string vacío si falla.
  static Future<String> getSingleSignedImageUrl(
    String s3Key, {
    Duration expiresIn = const Duration(minutes: 60),
  }) async {
    try {
      return await _getSingleSignedUrl(s3Key, expiresIn);
    } catch (e) {
      print('Error al obtener URL firmada para $s3Key: $e');
      return '';
    }
  }

  // Helper común para ambos métodos
  static Future<String> _getSingleSignedUrl(
    String key,
    Duration expiresIn,
  ) async {
    final result = await Amplify.Storage.getUrl(
      path: StoragePath.fromString(key),
      options: StorageGetUrlOptions(
        pluginOptions: S3GetUrlPluginOptions(
          validateObjectExistence: true,
          expiresIn: expiresIn,
        ),
      ),
    ).result;
    return result.url.toString();
  }
}
