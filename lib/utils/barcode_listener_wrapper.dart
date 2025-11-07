import 'package:compaexpress/services/barcode_listener_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Widget wrapper que activa/desactiva el listener de códigos de barras
/// basado en la visibilidad de la pantalla
class BarcodeListenerWrapper extends StatefulWidget {
  final Widget child;
  final Function(String) onBarcodeScanned;
  final String? contextName;
  final bool enabled;

  const BarcodeListenerWrapper({
    super.key,
    required this.child,
    required this.onBarcodeScanned,
    this.contextName,
    this.enabled = true,
  });

  @override
  State<BarcodeListenerWrapper> createState() => _BarcodeListenerWrapperState();
}

class _BarcodeListenerWrapperState extends State<BarcodeListenerWrapper> {
  final BarcodeListenerService _barcodeService = BarcodeListenerService();
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _registerCallback();
    }
  }

  @override
  void didUpdateWidget(BarcodeListenerWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _registerCallback();
      } else {
        _unregisterCallback();
      }
    }
  }

  @override
  void dispose() {
    _unregisterCallback();
    super.dispose();
  }

  void _registerCallback() {
    if (_isVisible) {
      _barcodeService.registerCallback(
        widget.onBarcodeScanned,
        context: widget.contextName,
      );
    }
  }

  void _unregisterCallback() {
    _barcodeService.unregisterCallback(context: widget.contextName);
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final wasVisible = _isVisible;
    _isVisible = info.visibleFraction > 0.5;

    if (_isVisible && !wasVisible && widget.enabled) {
      // La pantalla se hizo visible, registrar callback
      _registerCallback();
    } else if (!_isVisible && wasVisible) {
      // La pantalla se ocultó, desregistrar callback
      _unregisterCallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.contextName ?? 'barcode_listener_${widget.hashCode}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: BarcodeKeyboardListener(
        onBarcodeScanned: (barcode) {
          if (widget.enabled && _isVisible) {
            _barcodeService.onBarcodeScanned(barcode);
          }
        },
        child: widget.child,
      ),
    );
  }
}
