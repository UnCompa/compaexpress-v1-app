import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:flutter/material.dart';

/* ---------------  importación condicional --------------- */
import 'package:bitsdojo_window/bitsdojo_window.dart'
    if (dart.library.html) '';

/* ------------------------------------------------------- */

/// Devuelve `true` sólo en Windows/Linux/macOS
bool get _isDesktop {
  if (kIsWeb) return false;
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

/* ------------------------------------------------------- */

class CustomWindowTitleBar extends StatelessWidget {
  final String? title;
  final Widget child;

  const CustomWindowTitleBar({
    super.key,
    this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    /* ----------  web / móvil: sin barra nativa  ---------- */
    if (!_isDesktop) return child;

    /* ----------  desktop: barra arrastrable  ------------- */
    final theme = Theme.of(context);

    return Column(
      children: [
        WindowTitleBarBox(
          child: Container(
            color: theme.colorScheme.primary,
            child: Row(
              children: [
                Expanded(
                  child: MoveWindow(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Text(
                        title ?? 'CompaExpress',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: theme.colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ),
                const WindowButtons(),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/* ------------------------------------------------------- */

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        MinimizeWindowButton(
          colors: WindowButtonColors(
            iconNormal: theme.colorScheme.onPrimary,
            mouseOver: theme.colorScheme.surface.withOpacity(0.2),
            mouseDown: theme.colorScheme.surface.withOpacity(0.3),
          ),
        ),
        MaximizeWindowButton(
          colors: WindowButtonColors(
            iconNormal: theme.colorScheme.onPrimary,
            mouseOver: theme.colorScheme.surface.withOpacity(0.2),
            mouseDown: theme.colorScheme.surface.withOpacity(0.3),
          ),
        ),
        CloseWindowButton(
          colors: WindowButtonColors(
            iconNormal: theme.colorScheme.onPrimary,
            mouseOver: Colors.redAccent,
            mouseDown: Colors.red,
          ),
        ),
      ],
    );
  }
}