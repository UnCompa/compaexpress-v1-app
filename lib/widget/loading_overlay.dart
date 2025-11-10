import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class LoadingOverlay extends StatelessWidget {
  final String caption;
  const LoadingOverlay({super.key, this.caption = 'Espere un momento'});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFadingCube(color: colorScheme.primary, size: 48),
            const SizedBox(height: 32),
            Shimmer.fromColors(
              baseColor: colorScheme.onSurface.withOpacity(.6),
              highlightColor: colorScheme.onSurface.withOpacity(.9),
              period: const Duration(milliseconds: 1500),
              child: Text(
                caption,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
