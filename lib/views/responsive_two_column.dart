import 'package:flutter/material.dart';

class ResponsiveTwoColumn extends StatelessWidget {
  final Widget first;
  final Widget second;
  final double breakpoint;
  final double spacing;

  const ResponsiveTwoColumn({
    super.key,
    required this.first,
    required this.second,
    this.breakpoint = 600, // Puedes cambiar el ancho de corte si deseas
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context){
    return LayoutBuilder(
      builder: (context, constraints){
        final isWide = constraints.maxWidth >= breakpoint;
        if (isWide){
          return Row(
            children: [
              Expanded(child: first),
              SizedBox(width: spacing),
              Expanded(child: second),
            ],
          );
        } else {
          return Column(
            children: [
              first,
              SizedBox(height: spacing),
              second,
            ],
          );
        }
      },
    );
  }
}
