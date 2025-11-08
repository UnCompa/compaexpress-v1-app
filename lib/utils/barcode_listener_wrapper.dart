import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Callback para manejar teclas individuales (para pago rápido)
typedef KeyPressCallback = void Function(String key);

/// Widget wrapper mejorado que coordina lectura de códigos de barras
/// con el sistema de pago rápido
class BarcodeListenerWrapper extends StatefulWidget {
  final Widget child;
  final Function(String)? onBarcodeScanned;
  final KeyPressCallback? onKeyPress; // Para números individuales
  final VoidCallback? onEnterPressed;
  final VoidCallback? onEscapePressed;
  final VoidCallback? onBackspacePressed;
  final VoidCallback? onF2Pressed; // Nuevo: para cambiar de modo
  final String? contextName;
  final bool enabled;
  final bool allowKeyboardInput; // Control de entrada de teclado individual

  const BarcodeListenerWrapper({
    super.key,
    required this.child,
    this.onBarcodeScanned,
    this.onKeyPress,
    this.onEnterPressed,
    this.onEscapePressed,
    this.onBackspacePressed,
    this.onF2Pressed,
    this.contextName,
    this.enabled = true,
    this.allowKeyboardInput = false,
  });

  @override
  State<BarcodeListenerWrapper> createState() => _BarcodeListenerWrapperState();
}

class _BarcodeListenerWrapperState extends State<BarcodeListenerWrapper> {
  bool _isVisible = false;
  DateTime? _lastScanTime;
  String? _lastBarcode;
  final FocusNode _focusNode = FocusNode();

  // Buffer para rastrear secuencias de teclas y detectar scans en progreso
  final List<_KeyPress> _keyBuffer = [];
  DateTime? _lastKeyTime;
  static const int _scanTimeoutMs = 100; // Tiempo entre teclas de un scan
  bool _isScanningBarcode = false; // Flag para detectar si estamos en medio de un scan
  
  // Contador de teclas rápidas consecutivas
  int _rapidKeyCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final wasVisible = _isVisible;
    _isVisible = info.visibleFraction > 0.5;

    if (_isVisible && !wasVisible) {
      // La pantalla se hizo visible, solicitar focus
      Future.microtask(() {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  // Determina si estamos en medio de un scan de código de barras
  bool _isLikelyScanInProgress(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final now = DateTime.now();
    final key = event.logicalKey;

    // Las teclas que forman parte de un código de barras
    final isBarcodeKey =
        (key.keyId >= 0x30 && key.keyId <= 0x39) || // 0-9
        (key.keyId >= 0x60 && key.keyId <= 0x69) || // Numpad 0-9
        (key.keyId >= 0x41 && key.keyId <= 0x5A) || // A-Z
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter;

    if (!isBarcodeKey) {
      _keyBuffer.clear();
      _isScanningBarcode = false;
      _rapidKeyCount = 0;
      return false;
    }

    // MEJORADO: Detectar teclas rápidas consecutivas
    if (_lastKeyTime != null) {
      final timeDiff = now.difference(_lastKeyTime!).inMilliseconds;
      
      if (timeDiff < _scanTimeoutMs) {
        // Tecla muy rápida - incrementar contador
        _rapidKeyCount++;
        
        // Si tenemos 3+ teclas rápidas consecutivas, es definitivamente un scan
        if (_rapidKeyCount >= 3) {
          _isScanningBarcode = true;
          return true;
        }
      } else if (timeDiff > 300) {
        // Tecla lenta - resetear todo (escritura manual)
        _rapidKeyCount = 0;
        _isScanningBarcode = false;
        _keyBuffer.clear();
        return false;
      }
    }

    // CRÍTICO: Solo considerar scan si tenemos evidencia clara
    // (múltiples teclas rápidas Y un buffer significativo)
    if (_keyBuffer.length >= 4 && _rapidKeyCount >= 2) {
      _isScanningBarcode = true;
      return true;
    }

    // Si no hay suficiente evidencia, asumir escritura manual
    return _isScanningBarcode && _rapidKeyCount >= 2;
  }

  // NUEVO: Determina si la tecla debe ser manejada por el wrapper o dejada pasar
  bool _shouldHandleKey(LogicalKeyboardKey key) {
    // F2 siempre se maneja aquí
    if (key == LogicalKeyboardKey.f2) return true;

    // Si el modo de pago está activo, manejar estas teclas:
    if (widget.allowKeyboardInput) {
      return key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.numpadEnter ||
          key == LogicalKeyboardKey.escape ||
          key == LogicalKeyboardKey.backspace ||
          (key.keyId >= 0x60 && key.keyId <= 0x69) || // Numpad 0-9
          (key.keyId >= 0x30 && key.keyId <= 0x39) || // Keyboard 0-9
          key == LogicalKeyboardKey.numpadDecimal ||
          key == LogicalKeyboardKey.period ||
          key == LogicalKeyboardKey.comma ||
          key == LogicalKeyboardKey.numpadComma;
    }

    // Si el modo de pago NO está activo, NO manejar las teclas normales
    // (dejarlas pasar a los TextFields)
    return false;
  }

  void _handleKeyEvent(KeyEvent event) {
    if (!widget.enabled || !_isVisible) return;
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;

    log(
      'Key Event: ${key.keyLabel} (${key.keyId}) - allowKeyboardInput: ${widget.allowKeyboardInput}',
    );

    // F2 siempre se maneja sin importar el modo
    if (key == LogicalKeyboardKey.f2) {
      log('F2 pressed - toggling mode');
      widget.onF2Pressed?.call();
      return;
    }

    // Manejar teclas especiales si está habilitado el input de teclado
    if (widget.allowKeyboardInput) {
      log('Processing key in payment mode');

      // Enter
      if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.numpadEnter) {
        log('Enter pressed');
        widget.onEnterPressed?.call();
        return;
      }
      // Escape
      else if (key == LogicalKeyboardKey.escape) {
        log('Escape pressed');
        widget.onEscapePressed?.call();
        return;
      }
      // Backspace
      else if (key == LogicalKeyboardKey.backspace) {
        log('Backspace pressed');
        widget.onBackspacePressed?.call();
        return;
      }
      // Números del teclado numérico
      else if (key.keyId >= 0x60 && key.keyId <= 0x69) {
        // Numpad 0-9
        final digit = (key.keyId - 0x60).toString();
        log('Numpad digit: $digit');
        widget.onKeyPress?.call(digit);
        return;
      }
      // Números del teclado principal
      else if (key.keyId >= 0x30 && key.keyId <= 0x39) {
        // Keyboard 0-9
        final digit = String.fromCharCode(key.keyId);
        log('Keyboard digit: $digit');
        widget.onKeyPress?.call(digit);
        return;
      }
      // Punto decimal del numpad
      else if (key == LogicalKeyboardKey.numpadDecimal) {
        log('Numpad decimal');
        widget.onKeyPress?.call('.');
        return;
      }
      // Punto decimal del teclado principal
      else if (key == LogicalKeyboardKey.period) {
        log('Keyboard period');
        widget.onKeyPress?.call('.');
        return;
      }
      // Coma (algunos teclados usan coma como decimal)
      else if (key == LogicalKeyboardKey.comma ||
          key == LogicalKeyboardKey.numpadComma) {
        log('Comma/Numpad comma');
        widget.onKeyPress?.call('.');
        return;
      }

      log('Key not handled in payment mode: ${key.keyLabel}');
    }
    // Si no está en modo de input, el BarcodeKeyboardListener manejará el código de barras
    else {
      log('Key will be handled by barcode listener or passed through');
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.contextName ?? 'barcode_listener_${widget.hashCode}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;

          final key = event.logicalKey;
          final now = DateTime.now();

          // Actualizar el buffer ANTES de tomar decisiones
          if (_lastKeyTime != null) {
            final timeDiff = now.difference(_lastKeyTime!).inMilliseconds;
            
            if (timeDiff > _scanTimeoutMs) {
              _keyBuffer.clear();
              
              // Si el tiempo es muy largo, resetear el flag de scanning
              if (timeDiff > 300) {
                _isScanningBarcode = false;
                _rapidKeyCount = 0;
              }
            }
          }
          
          _lastKeyTime = now;
          _keyBuffer.add(_KeyPress(key.keyLabel, now));
          if (_keyBuffer.length > 20) {
            _keyBuffer.removeAt(0);
          }

          // Detectar si estamos en medio de un scan
          final isScanInProgress = _isLikelyScanInProgress(event);

          log(
            'onKeyEvent: ${key.keyLabel} - buffer: ${_keyBuffer.length} - rapidCount: $_rapidKeyCount - isScan: $isScanInProgress - paymentMode: ${widget.allowKeyboardInput}',
          );

          // Las letras A-Z solo se bloquean si hay evidencia FUERTE de scan
          final isAlpha = key.keyId >= 0x41 && key.keyId <= 0x5A;

          // CRÍTICO: Si NO está en modo pago Y detectamos un scan en progreso,
          // SIEMPRE consumir la tecla para evitar que cierre la pantalla
          if (!widget.allowKeyboardInput && isScanInProgress && !isAlpha) {
            log('🛡️ Blocking key from scan to prevent unwanted actions');

            // Si es Enter, asegurarnos de que el scan se complete
            if (key == LogicalKeyboardKey.enter ||
                key == LogicalKeyboardKey.numpadEnter) {
              log('🛡️ Blocking Enter from barcode scan');

              // Limpiar el flag después de un breve delay
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) {
                  setState(() {
                    _isScanningBarcode = false;
                    _rapidKeyCount = 0;
                    _keyBuffer.clear();
                  });
                }
              });
            }

            return KeyEventResult.handled;
          }

          // MEJORADO: Para letras, solo bloquear si hay evidencia MUY fuerte
          if (!widget.allowKeyboardInput && isAlpha && isScanInProgress) {
            // Solo bloquear si tenemos múltiples teclas rápidas consecutivas
            if (_rapidKeyCount >= 3) {
              log('🛡️ Blocking alpha key from rapid scan: ${key.keyLabel}');
              return KeyEventResult.handled;
            } else {
              log('✅ Allowing alpha key (insufficient scan evidence): ${key.keyLabel}');
              _isScanningBarcode = false;
              _rapidKeyCount = 0;
            }
          }

          // Determinar si debemos manejar esta tecla (para modo pago)
          final shouldHandle = _shouldHandleKey(key);

          if (shouldHandle) {
            _handleKeyEvent(event);
            return KeyEventResult.handled;
          }

          // Dejar pasar todas las demás teclas para que los TextFields las manejen
          log('✅ Key passed through: ${key.keyLabel}');
          return KeyEventResult.ignored;
        },
        child: BarcodeKeyboardListener(
          onBarcodeScanned: (barcode) {
            log(
              'Barcode scanned: $barcode - allowKeyboardInput: ${widget.allowKeyboardInput}',
            );

            // Limpiar el buffer y flag después de un scan completo
            _keyBuffer.clear();
            _isScanningBarcode = false;
            _rapidKeyCount = 0;

            // Solo procesar códigos de barras si:
            // 1. Está habilitado
            // 2. Está visible
            // 3. NO está en modo de input de teclado individual
            // 4. El código no está vacío
            if (widget.enabled &&
                _isVisible &&
                !widget.allowKeyboardInput &&
                barcode.trim().isNotEmpty) {
              final now = DateTime.now();

              // Protección contra scans duplicados rápidos
              if (_lastBarcode == barcode &&
                  _lastScanTime != null &&
                  now.difference(_lastScanTime!).inMilliseconds < 500) {
                log('Barcode ignored: duplicate scan too fast');
                return;
              }

              log('✅ Processing barcode: $barcode');
              widget.onBarcodeScanned?.call(barcode);
              _lastBarcode = barcode;
              _lastScanTime = now;
            } else {
              log(
                'Barcode ignored - enabled: ${widget.enabled}, visible: $_isVisible, mode: ${widget.allowKeyboardInput ? "payment" : "scan"}, empty: ${barcode.trim().isEmpty}',
              );
            }
          },
          child: widget.child,
        ),
      ),
    );
  }
}

// Clase helper para rastrear teclas con timestamp
class _KeyPress {
  final String key;
  final DateTime timestamp;
  
  _KeyPress(this.key, this.timestamp);
}