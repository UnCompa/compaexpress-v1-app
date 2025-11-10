import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Reemplazo directo de CircularProgressIndicator.
/// Soporta value, valueColor, color y strokeWidth.
class AppLoadingIndicator extends StatelessWidget {
  final double? value;
  final Animation<Color?>? valueColor;
  final Color? color;
  final double strokeWidth;

  const AppLoadingIndicator({
    super.key,
    this.value,
    this.valueColor,
    this.color,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    // Si hay valor de progreso usamos el nativo; si no, el animado.
    if (value != null) {
      return CircularProgressIndicator(
        value: value,
        valueColor: valueColor,
        backgroundColor: color,
        strokeWidth: strokeWidth,
      );
    }

    final effectiveColor =
        valueColor?.value ?? color ?? Theme.of(context).colorScheme.primary;

    return SpinKitWave(
      size: 24 + strokeWidth * 2,
      itemBuilder: (_, __) => DecoratedBox(
        decoration: BoxDecoration(
          color: effectiveColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
