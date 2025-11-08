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
  late Animation<Color?>? _colorAnimation;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _colorAnimation = null;

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

      // Animación de color usando el tema
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      _colorAnimation = ColorTween(
        begin: colorScheme.outline,
        end: colorScheme.tertiary, // Verde de éxito del tema
      ).animate(_animationController);

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  hintText: widget.hintText,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: _isScanning
                        ? colorScheme.tertiary
                        : colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    widget.prefixIcon,
                    color: _isScanning
                        ? colorScheme.tertiary
                        : colorScheme.primary,
                  ),
                  suffixText: widget.suffixText,
                  suffixStyle: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _colorAnimation?.value ?? colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _colorAnimation?.value ?? colorScheme.outline,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isScanning
                          ? colorScheme.tertiary
                          : colorScheme.primary,
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withOpacity(0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterStyle: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  counterText: widget.maxLength != null ? null : '',
                ),
                maxLength: widget.maxLength,
                validator: widget.validator,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                cursorColor: colorScheme.primary,
                cursorWidth: 2.0,
              ),
            ),
            if (widget.onManualScan != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: widget.onManualScan,
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Escanear con cámara',
                color: colorScheme.primary,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
