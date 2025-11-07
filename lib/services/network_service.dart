import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkService {
  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      debugPrint("Resultado de conectividad: $connectivityResult");
      // Maneja el caso de una lista
      return connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile);
    } catch (e) {
      debugPrint("Error verificando conexión: $e");
      return false;
    }
  }
}
