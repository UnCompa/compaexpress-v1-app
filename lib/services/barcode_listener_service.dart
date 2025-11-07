import 'package:flutter/foundation.dart';

/// Servicio global para manejar eventos de lectores de código de barras USB
/// Permite registrar callbacks que se ejecutarán cuando se detecte un código
class BarcodeListenerService extends ChangeNotifier {
  static final BarcodeListenerService _instance =
      BarcodeListenerService._internal();

  factory BarcodeListenerService() {
    return _instance;
  }

  BarcodeListenerService._internal();

  // Callback actual que se ejecutará cuando se escanee un código
  Function(String)? _currentCallback;

  // Identificador del contexto actual (para debugging)
  String? _currentContext;

  // Último código escaneado (para evitar duplicados)
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  // Tiempo mínimo entre escaneos del mismo código (en milisegundos)
  static const int _debounceTime = 500;

  /// Registra un callback para recibir códigos de barras
  /// [callback] función que recibirá el código escaneado
  /// [context] identificador del contexto (útil para debugging)
  void registerCallback(Function(String) callback, {String? context}) {
    _currentCallback = callback;
    _currentContext = context;
    if (kDebugMode) {
      print('📱 Barcode listener registrado: ${context ?? "sin contexto"}');
    }
  }

  /// Desregistra el callback actual
  void unregisterCallback({String? context}) {
    if (_currentContext == context || context == null) {
      _currentCallback = null;
      _currentContext = null;
      if (kDebugMode) {
        print(
          '📱 Barcode listener desregistrado: ${context ?? "sin contexto"}',
        );
      }
    }
  }

  /// Procesa un código de barras escaneado
  /// Incluye lógica de debounce para evitar escaneos duplicados
  void onBarcodeScanned(String barcode) {
    // Validar que el código no esté vacío
    if (barcode.trim().isEmpty) return;

    // Debounce: evitar procesar el mismo código muy rápidamente
    final now = DateTime.now();
    if (_lastScannedCode == barcode && _lastScanTime != null) {
      final diff = now.difference(_lastScanTime!).inMilliseconds;
      if (diff < _debounceTime) {
        if (kDebugMode) {
          print('⚠️ Código duplicado ignorado (debounce): $barcode');
        }
        return;
      }
    }

    // Actualizar último código escaneado
    _lastScannedCode = barcode;
    _lastScanTime = now;

    // Ejecutar callback si existe
    if (_currentCallback != null) {
      if (kDebugMode) {
        print(
          '✅ Código escaneado: $barcode en contexto: ${_currentContext ?? "sin contexto"}',
        );
      }
      _currentCallback!(barcode);
    } else {
      if (kDebugMode) {
        print('⚠️ Código escaneado pero no hay callback registrado: $barcode');
      }
    }

    // Notificar a los listeners
    notifyListeners();
  }

  /// Limpia el último código escaneado (útil después de procesar)
  void clearLastScanned() {
    _lastScannedCode = null;
    _lastScanTime = null;
  }

  /// Obtiene el callback actual (para verificación)
  bool get hasActiveCallback => _currentCallback != null;

  /// Obtiene el contexto actual
  String? get currentContext => _currentContext;
}
