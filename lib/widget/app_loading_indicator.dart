import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

    return Center(
      child: SpinKitFadingCircle(
        size: 16 + strokeWidth * 2,
        itemBuilder: (_, __) => DecoratedBox(
          decoration: BoxDecoration(
            color: effectiveColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
