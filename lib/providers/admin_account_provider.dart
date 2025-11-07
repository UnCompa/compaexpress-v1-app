import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/device/device_session_controller.dart';
import 'package:compaexpress/utils/get_image_for_bucker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ========== MODELS ==========
class UserBusinessData {
  final String userName;
  final Negocio? negocio;
  final String? imageUrl;
  final String? errorMessage;

  const UserBusinessData({
    required this.userName,
    this.negocio,
    this.imageUrl,
    this.errorMessage,
  });

  UserBusinessData copyWith({
    String? userName,
    Negocio? negocio,
    String? imageUrl,
    String? errorMessage,
  }) {
    return UserBusinessData(
      userName: userName ?? this.userName,
      negocio: negocio ?? this.negocio,
      imageUrl: imageUrl ?? this.imageUrl,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class VigenciaInfo {
  final DateTime? fechaVencimiento;
  final int diasRestantes;
  final bool vigenciaValida;
  final int? duracionTotal;

  const VigenciaInfo({
    this.fechaVencimiento,
    required this.diasRestantes,
    required this.vigenciaValida,
    this.duracionTotal,
  });

  VigenciaInfo copyWith({
    DateTime? fechaVencimiento,
    int? diasRestantes,
    bool? vigenciaValida,
    int? duracionTotal,
  }) {
    return VigenciaInfo(
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      diasRestantes: diasRestantes ?? this.diasRestantes,
      vigenciaValida: vigenciaValida ?? this.vigenciaValida,
      duracionTotal: duracionTotal ?? this.duracionTotal,
    );
  }
}

class DevicesInfo {
  final int dispositivosConectados;
  final int maxDispositivosMovil;
  final int maxDispositivosPC;

  const DevicesInfo({
    required this.dispositivosConectados,
    required this.maxDispositivosMovil,
    required this.maxDispositivosPC,
  });

  DevicesInfo copyWith({
    int? dispositivosConectados,
    int? maxDispositivosMovil,
    int? maxDispositivosPC,
  }) {
    return DevicesInfo(
      dispositivosConectados:
          dispositivosConectados ?? this.dispositivosConectados,
      maxDispositivosMovil: maxDispositivosMovil ?? this.maxDispositivosMovil,
      maxDispositivosPC: maxDispositivosPC ?? this.maxDispositivosPC,
    );
  }
}

// ========== PROVIDERS ==========

/// Provider para cargar datos del usuario y negocio
final userBusinessProvider = FutureProvider.autoDispose<UserBusinessData>((
  ref,
) async {
  try {
    final user = await Amplify.Auth.getCurrentUser();
    final attributes = await Amplify.Auth.fetchUserAttributes();

    String? negocioId;
    String? userDisplayName;

    for (final attribute in attributes) {
      if (attribute.userAttributeKey.key == 'custom:negocioid') {
        negocioId = attribute.value;
      }
      if (attribute.userAttributeKey.key == 'name' ||
          attribute.userAttributeKey.key == 'preferred_username') {
        userDisplayName = attribute.value;
      }
    }

    userDisplayName ??= user.username;

    if (negocioId == null) {
      return UserBusinessData(
        userName: userDisplayName,
        errorMessage: 'Usuario sin negocio asignado',
      );
    }

    final request = ModelQueries.get(
      Negocio.classType,
      NegocioModelIdentifier(id: negocioId),
    );
    final response = await Amplify.API.query(request: request).response;

    if (response.data == null) {
      return UserBusinessData(
        userName: userDisplayName,
        errorMessage: 'No se pudo cargar la información del negocio',
      );
    }

    String? imageUrl;
    if (response.data!.logo != null && response.data!.logo!.isNotEmpty) {
      final signedImageUrls = await GetImageFromBucket.getSignedImageUrls(
        s3Keys: [response.data!.logo!],
      );
      imageUrl = signedImageUrls.isNotEmpty ? signedImageUrls.first : null;
    }

    return UserBusinessData(
      userName: userDisplayName,
      negocio: response.data,
      imageUrl: imageUrl,
    );
  } catch (e) {
    throw Exception('Error al cargar datos: ${e.toString()}');
  }
});

/// Provider para información de vigencia
final vigenciaInfoProvider = Provider.autoDispose<VigenciaInfo>((ref) {
  final userBusinessAsync = ref.watch(userBusinessProvider);

  return userBusinessAsync.when(
    data: (data) {
      final negocio = data.negocio;
      if (negocio == null || negocio.duration == null) {
        return const VigenciaInfo(diasRestantes: 0, vigenciaValida: false);
      }

      final now = DateTime.now().toUtc();
      final fechaCreacion = negocio.createdAt.getDateTimeInUtc();
      final fechaVencimiento = fechaCreacion.add(
        Duration(days: negocio.duration!),
      );
      final diasRestantes = (fechaVencimiento.difference(now).inSeconds / 86400)
          .ceil();
      final vigenciaValida = fechaVencimiento.isAfter(now);

      return VigenciaInfo(
        fechaVencimiento: fechaVencimiento,
        diasRestantes: diasRestantes,
        vigenciaValida: vigenciaValida,
        duracionTotal: negocio.duration,
      );
    },
    loading: () => const VigenciaInfo(diasRestantes: 0, vigenciaValida: false),
    error: (_, __) =>
        const VigenciaInfo(diasRestantes: 0, vigenciaValida: false),
  );
});

/// Provider para información de dispositivos
final devicesInfoProvider = StreamProvider.autoDispose<DevicesInfo>((
  ref,
) async* {
  final userBusinessAsync = ref.watch(userBusinessProvider);

  await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
    final userBusiness = userBusinessAsync.value;
    final negocio = userBusiness?.negocio;

    if (negocio == null) {
      yield const DevicesInfo(
        dispositivosConectados: 0,
        maxDispositivosMovil: 0,
        maxDispositivosPC: 0,
      );
      continue;
    }

    try {
      final deviceInfo = await DeviceSessionController.getConnectedDevices(
        negocio.id,
      );

      yield DevicesInfo(
        dispositivosConectados: deviceInfo['total'] ?? 0,
        maxDispositivosMovil: negocio.movilAccess ?? 0,
        maxDispositivosPC: negocio.pcAccess ?? 0,
      );
    } catch (e) {
      safePrint('Error cargando información de dispositivos: $e');
      yield DevicesInfo(
        dispositivosConectados: 0,
        maxDispositivosMovil: negocio.movilAccess ?? 0,
        maxDispositivosPC: negocio.pcAccess ?? 0,
      );
    }
  }

  // Emisión inicial inmediata
  final userBusiness = userBusinessAsync.value;
  final negocio = userBusiness?.negocio;

  if (negocio != null) {
    try {
      final deviceInfo = await DeviceSessionController.getConnectedDevices(
        negocio.id,
      );

      yield DevicesInfo(
        dispositivosConectados: deviceInfo['total'] ?? 0,
        maxDispositivosMovil: negocio.movilAccess ?? 0,
        maxDispositivosPC: negocio.pcAccess ?? 0,
      );
    } catch (e) {
      safePrint('Error cargando información de dispositivos: $e');
    }
  }
});
