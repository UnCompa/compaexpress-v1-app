import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static Future<List<String>> subirImagenes(List<File> imagenesSeleccionadas) async {
    if (imagenesSeleccionadas.isEmpty) {
      return [];
    }

    List<String> uploadedKeys = [];
    const uuid = Uuid();

    try {
      for (int i = 0; i < imagenesSeleccionadas.length; i++) {
        final file = imagenesSeleccionadas[i];
        final extension = file.path.split('.').last.toLowerCase();
        final keyPath = 'productos/${uuid.v4()}.$extension';

        final uploadResult = await Amplify.Storage.uploadFile(
          localFile: AWSFile.fromPath(file.path),
          path: StoragePath.fromString(keyPath),
          options: const StorageUploadFileOptions(
            metadata: {'tipo': 'producto_imagen'},
          ),
        ).result;

        uploadedKeys.add(uploadResult.uploadedItem.path);
        safePrint('Imagen subida: ${uploadResult.uploadedItem.path}');
      }
    } catch (e) {
      safePrint('Error subiendo imágenes: $e');
      return [];
    }

    return uploadedKeys;
  }

  static Future<String> uploadFile(File file, String keyPath) async {
    try {
      final uploadResult = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(file.path),
        path: StoragePath.fromString(keyPath),
        options: const StorageUploadFileOptions(
          metadata: {'tipo': 'producto_imagen'},
        ),
      ).result;

      return uploadResult.uploadedItem.path;
    } catch (e) {
      safePrint('Error subiendo archivo: $e');
      return '';
    }
  }
}