import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TextField especializado para códigos de barras
/// Incluye indicador visual cuando recibe un código del scanner USB
class BarcodeTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData prefixIcon;
  final String? suffixText;
  final String? Function(String?)? validator;
  final VoidCallback? onManualScan;
  final int? maxLength;
  final bool showScanAnimation;

  const BarcodeTextField({
    super.key,
    required this.controller,
    this.labelText = 'Código de Barras',
    this.hintText = 'Ej: 2500000004957',
    this.prefixIcon = Icons.barcode_reader,
    this.suffixText = 'código',
    this.validator,
    this.onManualScan,
    this.maxLength = 15,
    this.showScanAnimation = true,
  });

  @override
  State<BarcodeTextField> createState() => _BarcodeTextFieldState();
}

class _BarcodeTextFieldState extends State<BarcodeTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.grey[900],
      end: Colors.green,
    ).animate(_animationController);

    // Escuchar cambios en el controller para detectar escaneos
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.showScanAnimation && widget.controller.text.isNotEmpty) {
      _triggerScanAnimation();
    }
  }

  void _triggerScanAnimation() {
    if (!_isScanning) {
      setState(() => _isScanning = true);
      _animationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _animationController.reverse().then((_) {
              if (mounted) {
                setState(() => _isScanning = false);
              }
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  hintText: widget.hintText,
                  labelStyle: const TextStyle(color: Colors.blue),
                  prefixIcon: Icon(
                    widget.prefixIcon,
                    color: _isScanning ? Colors.green : Colors.blueAccent,
                  ),
                  suffixText: widget.suffixText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _colorAnimation.value ?? Colors.grey[800]!,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _colorAnimation.value ?? Colors.grey[900]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isScanning ? Colors.green : Colors.blue,
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[600]!, width: 2.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterText: widget.maxLength != null ? null : '',
                ),
                maxLength: widget.maxLength,
                validator: widget.validator,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            if (widget.onManualScan != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: widget.onManualScan,
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Escanear con cámara',
                color: Colors.blue,
              ),
            ],
          ],
        );
      },
    );
  }
}
