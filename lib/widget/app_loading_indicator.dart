import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Indicador que sustituye directamente a CircularProgressIndicator
/// sin necesidad de pasar color ni tamaño.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // Hereda el color primario del tema actual
    final color = Theme.of(context).colorScheme.primary;
    return SpinKitWave(
      size: 32,
      itemBuilder: (_, __) => DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
