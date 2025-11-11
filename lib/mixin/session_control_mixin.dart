import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/page/auth/login_page.dart';
import 'package:compaexpress/services/device/device_session_controller.dart';
import 'package:compaexpress/services/negocio/negocio_controller.dart';
import 'package:compaexpress/utils/navigation_utils.dart';
import 'package:flutter/material.dart';

/// Mixin optimizado que proporciona control automático de sesiones y vigencia
/// Úsalo en cualquier página que requiera verificación de sesión
mixin SessionControlMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  Timer? _sessionKeepAliveTimer;
  Timer? _vigenciaCheckTimer;
  bool _isSessionActive = false;

  // Cache para evitar consultas repetidas
  static String? _cachedNegocioId;
  static String? _cachedUserId;
  static dynamic _cachedNegocio;
  static DateTime? _cacheExpiry;
  static DateTime? _lastVigenciaCheck;
  static bool? _lastVigenciaResult;

  // Duración del cache (5 minutos)
  static const Duration _cacheDuration = Duration(minutes: 5);
  static const Duration _vigenciaCheckInterval = Duration(
    minutes: 30,
  ); // Reducido de 1 hora
  static const Duration _keepAliveInterval = Duration(
    minutes: 3,
  ); // Reducido de 5 minutos

  // Controla si hay operaciones en curso para evitar llamadas concurrentes
  static bool _isInitializing = false;
  static bool _isCheckingVigencia = false;

  /// Override este método si necesitas lógica personalizada cuando la sesión expire
  Future<void> onSessionExpired(String reason) async {
    await _performLogout(reason);
  }

  /// Override este método si necesitas lógica personalizada cuando la vigencia expire
  Future<void> onVigenciaExpired() async {
    await _showVigenciaExpiredDialog();
  }

  /// Inicializa el control de sesión de forma optimizada
  /// Llama esto en initState() de tu widget
  Future<bool> initializeSessionControl() async {
    // Evitar inicializaciones concurrentes
    if (_isInitializing) {
      // Esperar a que termine la inicialización en curso
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _isSessionActive;
    }

    _isInitializing = true;

    try {
      // 1. Verificar cache primero
      if (_isCacheValid() && _cachedNegocio != null) {
        debugPrint('Usando datos cached para inicialización');

        // Solo verificar vigencia si ha pasado tiempo suficiente
        if (_shouldCheckVigencia()) {
          final vigenciaValid = await _quickVigenciaCheck();
          if (!vigenciaValid) {
            _isInitializing = false;
            return false;
          }
        }

        _startSessionTimers();
        _isSessionActive = true;
        _isInitializing = false;
        return true;
      }

      // 2. Cargar datos frescos si no hay cache válido
      final userInfo = await _getCachedUserInfo();
      if (userInfo == null) {
        await onSessionExpired('No se pudo obtener información del usuario');
        _isInitializing = false;
        return false;
      }

      final negocio = await _getCachedNegocio(userInfo.negocioId);
      if (negocio == null) {
        await onSessionExpired('No se pudo cargar información del negocio');
        _isInitializing = false;
        return false;
      }

      // 3. Verificar acceso (esto incluye vigencia)
      final accessResult = await DeviceSessionController.checkAccess(
        negocio,
        userInfo.userId,
      );

      if (!accessResult.success) {
        if (accessResult.isExpired) {
          await onVigenciaExpired();
        } else {
          await onSessionExpired(
            accessResult.errorMessage ?? 'Error de acceso',
          );
        }
        _isInitializing = false;
        return false;
      }

      // 4. Cache del resultado de vigencia
      _lastVigenciaCheck = DateTime.now();
      _lastVigenciaResult = true;

      // 5. Inicializar timers
      _startSessionTimers();
      _isSessionActive = true;
      _isInitializing = false;
      return true;
    } catch (e) {
      debugPrint('Error en initializeSessionControl: $e');
      await onSessionExpired('Error al inicializar sesión: $e');
      _isInitializing = false;
      return false;
    }
  }

  /// Obtiene información del usuario con cache
  Future<({String negocioId, String userId})?> _getCachedUserInfo() async {
    try {
      // Si tenemos cache válido, usarlo
      if (_isCacheValid() &&
          _cachedNegocioId != null &&
          _cachedUserId != null) {
        return (negocioId: _cachedNegocioId!, userId: _cachedUserId!);
      }

      // Cargar datos frescos
      final userInfo = await NegocioController.getUserInfo();

      // Actualizar cache
      _cachedNegocioId = userInfo.negocioId;
      _cachedUserId = userInfo.userId;
      _cacheExpiry = DateTime.now().add(_cacheDuration);

      return (negocioId: userInfo.negocioId, userId: userInfo.userId);
    } catch (e) {
      debugPrint('Error obteniendo info de usuario: $e');
      return null;
    }
  }

  /// Obtiene negocio con cache
  Future<dynamic> _getCachedNegocio(String negocioId) async {
    try {
      // Si tenemos cache válido y es el mismo negocio, usarlo
      if (_isCacheValid() &&
          _cachedNegocio != null &&
          _cachedNegocioId == negocioId) {
        return _cachedNegocio;
      }

      // Cargar datos frescos
      final negocio = await NegocioController.getById(negocioId);

      if (negocio != null) {
        // Actualizar cache
        _cachedNegocio = negocio;
        _cachedNegocioId = negocioId;
        _cacheExpiry = DateTime.now().add(_cacheDuration);
      }

      return negocio;
    } catch (e) {
      debugPrint('Error obteniendo negocio: $e');
      return null;
    }
  }

  /// Verifica si el cache es válido
  bool _isCacheValid() {
    return _cacheExpiry != null && DateTime.now().isBefore(_cacheExpiry!);
  }

  /// Determina si se debe verificar la vigencia
  bool _shouldCheckVigencia() {
    if (_lastVigenciaCheck == null) return true;

    final timeSinceLastCheck = DateTime.now().difference(_lastVigenciaCheck!);
    return timeSinceLastCheck >= _vigenciaCheckInterval;
  }

  /// Verificación rápida de vigencia usando cache
  Future<bool> _quickVigenciaCheck() async {
    if (_isCheckingVigencia) return _lastVigenciaResult ?? false;

    _isCheckingVigencia = true;

    try {
      if (_cachedNegocio != null && _cachedUserId != null) {
        final isValid = await DeviceSessionController.checkAccess(
          _cachedNegocio!,
          _cachedUserId!,
        );

        _lastVigenciaCheck = DateTime.now();
        _lastVigenciaResult = isValid.success;

        if (!isValid.success) {
          if (isValid.isExpired) {
            await onVigenciaExpired();
          } else {
            await onSessionExpired(isValid.errorMessage ?? 'Error de acceso');
          }
        }

        _isCheckingVigencia = false;
        return isValid.success;
      }

      _isCheckingVigencia = false;
      return false;
    } catch (e) {
      debugPrint('Error en verificación rápida de vigencia: $e');
      _isCheckingVigencia = false;
      return false;
    }
  }

  /// Inicia los timers optimizados para mantener la sesión
  void _startSessionTimers() {
    // Cancelar timers existentes
    _sessionKeepAliveTimer?.cancel();
    _vigenciaCheckTimer?.cancel();

    // Timer optimizado para mantener la sesión activa
    _sessionKeepAliveTimer = Timer.periodic(_keepAliveInterval, (_) async {
      if (_isSessionActive) {
        try {
          await DeviceSessionController.keepAlive();
        } catch (e) {
          debugPrint('Error en keep alive: $e');
          // Solo cerrar sesión si es un error crítico
          if (e.toString().contains('unauthorized') ||
              e.toString().contains('forbidden')) {
            await onSessionExpired('Sesión no autorizada: $e');
          }
        }
      }
    });

    // Timer optimizado para verificar vigencia
    _vigenciaCheckTimer = Timer.periodic(_vigenciaCheckInterval, (_) async {
      if (_isSessionActive && _shouldCheckVigencia()) {
        await _quickVigenciaCheck();
      }
    });
  }

  /// Verifica la vigencia del negocio (versión optimizada)
  Future<void> _checkVigencia() async {
    if (!_shouldCheckVigencia()) {
      return; // No necesita verificación aún
    }

    await _quickVigenciaCheck();
  }

  /// Muestra el diálogo de vigencia expirada
  Future<void> _showVigenciaExpiredDialog() async {
    if (!mounted) return;

    // Evitar múltiples diálogos
    if (ModalRoute.of(context)?.isCurrent != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Vigencia Expirada'),
          content: const Text(
            'La vigencia de su negocio ha expirado. '
            'Contacte al administrador para renovar el servicio.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout('Vigencia expirada');
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      ),
    );
  }

  /// Realiza el logout optimizado y navega a la pantalla de login
  Future<void> _performLogout(String reason) async {
    if (!_isSessionActive) return; // Ya se cerró la sesión

    try {
      _isSessionActive = false;

      // Limpiar cache
      _clearCache();

      // Cerrar sesión en paralelo
      final futures = <Future>[
        DeviceSessionController.closeSession().catchError((e) {
          debugPrint('Error cerrando sesión del dispositivo: $e');
        }),
        Amplify.Auth.signOut().catchError((e) {
          debugPrint('Error cerrando sesión de Amplify: $e');
        }),
      ];

      // Esperar máximo 5 segundos para el logout
      await Future.wait(futures).timeout(const Duration(seconds: 5));

      if (mounted) {
        await pushWrapped(context, const LoginScreen());
      }
    } catch (e) {
      debugPrint('Error durante logout: $e');
      if (mounted) {

        await pushWrapped(context, const LoginScreen());
      }
    }
  }

  /// Limpia el cache estático
  static void _clearCache() {
    _cachedNegocioId = null;
    _cachedUserId = null;
    _cachedNegocio = null;
    _cacheExpiry = null;
    _lastVigenciaCheck = null;
    _lastVigenciaResult = null;
  }

  /// Limpia los recursos de la sesión
  /// Llama esto en dispose() de tu widget
  void disposeSessionControl() {
    _isSessionActive = false;
    _sessionKeepAliveTimer?.cancel();
    _vigenciaCheckTimer?.cancel();
    _sessionKeepAliveTimer = null;
    _vigenciaCheckTimer = null;
  }

  /// Maneja los cambios en el ciclo de vida de la app de forma optimizada
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!_isSessionActive) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // Verificación ligera al volver a la app
        if (_shouldCheckVigencia()) {
          _quickVigenciaCheck().catchError((e) {
            debugPrint('Error al verificar vigencia en resume: $e');
          });
        } else {
          // Solo keep alive si la vigencia está cached como válida
          DeviceSessionController.keepAlive().catchError((e) {
            debugPrint('Error en keep alive durante resume: $e');
          });
        }
        break;
      case AppLifecycleState.paused:
        // No hacer nada especial al pausar
        break;
      case AppLifecycleState.detached:
        // Cerrar sesión al cerrar la app (sin esperar)
        DeviceSessionController.closeSession().catchError((e) {
          debugPrint('Error cerrando sesión en detached: $e');
        });
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // No hacer nada en estos estados
        break;
    }
  }

  /// Obtiene el estado actual de la sesión
  bool get isSessionActive => _isSessionActive;

  /// Fuerza una verificación de sesión (limpia cache primero)
  Future<bool> refreshSession() async {
    _clearCache();
    return await initializeSessionControl();
  }

  /// Método para limpiar cache manualmente si es necesario
  static void clearStaticCache() {
    _clearCache();
  }

  /// Obtiene información sobre el estado del cache (para debugging)
  static Map<String, dynamic> getCacheInfo() {
    return {
      'hasValidCache':
          _cacheExpiry != null && DateTime.now().isBefore(_cacheExpiry!),
      'cacheExpiry': _cacheExpiry?.toIso8601String(),
      'lastVigenciaCheck': _lastVigenciaCheck?.toIso8601String(),
      'lastVigenciaResult': _lastVigenciaResult,
      'cachedNegocioId': _cachedNegocioId,
      'cachedUserId': _cachedUserId,
    };
  }
}
