import 'package:flutter/material.dart';

class QuickAccessButton extends StatelessWidget {
  const QuickAccessButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isEnabled = true,
    this.variant = QuickAccessVariant.primary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isEnabled;
  final QuickAccessVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(context, variant, isEnabled);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderColor, width: 1),
        boxShadow: isEnabled && colors.shadowColor != null
            ? [
                BoxShadow(
                  color: colors.shadowColor!,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: colors.splashColor,
          highlightColor: colors.highlightColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors.iconGradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: isEnabled && colors.iconShadowColor != null
                        ? [
                            BoxShadow(
                              color: colors.iconShadowColor!,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(icon, size: 20, color: colors.iconColor),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.titleColor,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.subtitleColor,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _QuickAccessColors _getColors(
    BuildContext context,
    QuickAccessVariant variant,
    bool enabled,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (!enabled) {
      return _QuickAccessColors(
        gradientColors: [
          theme.disabledColor.withOpacity(0.1),
          theme.disabledColor.withOpacity(0.05),
        ],
        borderColor: theme.disabledColor,
        shadowColor: null,
        splashColor: theme.disabledColor.withOpacity(0.1),
        highlightColor: theme.disabledColor.withOpacity(0.05),
        iconGradientColors: [
          theme.disabledColor,
          theme.disabledColor.withOpacity(0.7),
        ],
        iconShadowColor: null,
        iconColor: theme.colorScheme.onSurface.withOpacity(0.5),
        titleColor: theme.colorScheme.onSurface.withOpacity(0.5),
        subtitleColor: theme.colorScheme.onSurface.withOpacity(0.4),
      );
    }

    switch (variant) {
      case QuickAccessVariant.primary:
        final baseColor = colorScheme.primary;
        return _QuickAccessColors(
          gradientColors: [
            baseColor.withOpacity(isDark ? 0.15 : 0.08),
            baseColor.withOpacity(isDark ? 0.08 : 0.03),
          ],
          borderColor: baseColor.withOpacity(isDark ? 0.4 : 0.3),
          shadowColor: baseColor.withOpacity(isDark ? 0.2 : 0.15),
          splashColor: baseColor.withOpacity(isDark ? 0.15 : 0.1),
          highlightColor: baseColor.withOpacity(isDark ? 0.1 : 0.05),
          iconGradientColors: [baseColor, baseColor.withOpacity(0.9)],
          iconShadowColor: baseColor.withOpacity(isDark ? 0.4 : 0.3),
          iconColor: colorScheme.onPrimary,
          titleColor: isDark
              ? colorScheme.onPrimaryContainer
              : colorScheme.primary,
          subtitleColor: colorScheme.primary,
        );

      case QuickAccessVariant.accent:
        final baseColor = colorScheme.secondary;
        return _QuickAccessColors(
          gradientColors: [
            baseColor.withOpacity(isDark ? 0.15 : 0.08),
            baseColor.withOpacity(isDark ? 0.08 : 0.03),
          ],
          borderColor: baseColor.withOpacity(isDark ? 0.4 : 0.3),
          shadowColor: baseColor.withOpacity(isDark ? 0.2 : 0.15),
          splashColor: baseColor.withOpacity(isDark ? 0.15 : 0.1),
          highlightColor: baseColor.withOpacity(isDark ? 0.1 : 0.05),
          iconGradientColors: [baseColor, baseColor.withOpacity(0.9)],
          iconShadowColor: baseColor.withOpacity(isDark ? 0.4 : 0.3),
          iconColor: colorScheme.onSecondary,
          titleColor: isDark
              ? colorScheme.onSecondaryContainer
              : colorScheme.secondary,
          subtitleColor: colorScheme.secondary,
        );

      case QuickAccessVariant.light:
        final baseColor = colorScheme.surfaceContainerHighest;
        return _QuickAccessColors(
          gradientColors: [
            baseColor.withOpacity(isDark ? 0.3 : 0.5),
            baseColor.withOpacity(isDark ? 0.2 : 0.3),
          ],
          borderColor: colorScheme.outline.withOpacity(isDark ? 0.4 : 0.3),
          shadowColor: colorScheme.shadow.withOpacity(isDark ? 0.1 : 0.08),
          splashColor: colorScheme.surfaceTint.withOpacity(0.08),
          highlightColor: colorScheme.surfaceTint.withOpacity(0.04),
          iconGradientColors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
          iconShadowColor: colorScheme.primary.withOpacity(isDark ? 0.3 : 0.2),
          iconColor: colorScheme.onPrimary,
          titleColor: colorScheme.onSurface,
          subtitleColor: colorScheme.onSurfaceVariant,
        );
    }
  }
}

enum QuickAccessVariant {
  primary, // Usa colorScheme.primary
  accent, // Usa colorScheme.secondary
  light, // Usa colores de superficie
}

class _QuickAccessColors {
  final List<Color> gradientColors;
  final Color borderColor;
  final Color? shadowColor;
  final Color splashColor;
  final Color highlightColor;
  final List<Color> iconGradientColors;
  final Color? iconShadowColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;

  _QuickAccessColors({
    required this.gradientColors,
    required this.borderColor,
    required this.shadowColor,
    required this.splashColor,
    required this.highlightColor,
    required this.iconGradientColors,
    required this.iconShadowColor,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
  });
}
