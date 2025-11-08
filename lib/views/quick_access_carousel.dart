import 'package:flutter/material.dart';

class QuickAccessCarousel extends StatelessWidget {
  const QuickAccessCarousel({
    super.key,
    required this.items,
    this.height = 140,
    this.enableAutoScroll = false,
  });

  final List<QuickAccessItem> items;
  final double height;
  final bool enableAutoScroll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del carrusel usando tema
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.dashboard_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Acceso Rápido',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Carrusel horizontal
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: QuickAccessCarouselCard(
                    icon: item.icon,
                    title: item.title,
                    subtitle: item.subtitle,
                    onTap: item.onTap,
                    isEnabled: item.isEnabled,
                    variant: item.variant,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QuickAccessCarouselCard extends StatelessWidget {
  const QuickAccessCarouselCard({
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderColor, width: 0.8),
        boxShadow: isEnabled && colors.shadowColor != null
            ? [
                BoxShadow(
                  color: colors.shadowColor!,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          splashColor: colors.splashColor,
          highlightColor: colors.highlightColor,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
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
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(icon, size: 18, color: colors.iconColor),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.titleColor,
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
        iconColor: colorScheme.onSurface.withOpacity(0.5),
        titleColor: colorScheme.onSurface.withOpacity(0.5),
        subtitleColor: colorScheme.onSurface.withOpacity(0.4),
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
          shadowColor: baseColor.withOpacity(isDark ? 0.2 : 0.12),
          splashColor: baseColor.withOpacity(isDark ? 0.15 : 0.1),
          highlightColor: baseColor.withOpacity(isDark ? 0.1 : 0.05),
          iconGradientColors: [baseColor, baseColor.withOpacity(0.9)],
          iconShadowColor: baseColor.withOpacity(isDark ? 0.3 : 0.25),
          iconColor: colorScheme.onPrimary,
          titleColor: isDark ? colorScheme.onPrimaryContainer : baseColor,
          subtitleColor: baseColor,
        );

      case QuickAccessVariant.accent:
        final baseColor = colorScheme.secondary;
        return _QuickAccessColors(
          gradientColors: [
            baseColor.withOpacity(isDark ? 0.15 : 0.08),
            baseColor.withOpacity(isDark ? 0.08 : 0.03),
          ],
          borderColor: baseColor.withOpacity(isDark ? 0.4 : 0.3),
          shadowColor: baseColor.withOpacity(isDark ? 0.2 : 0.12),
          splashColor: baseColor.withOpacity(isDark ? 0.15 : 0.1),
          highlightColor: baseColor.withOpacity(isDark ? 0.1 : 0.05),
          iconGradientColors: [baseColor, baseColor.withOpacity(0.9)],
          iconShadowColor: baseColor.withOpacity(isDark ? 0.3 : 0.25),
          iconColor: colorScheme.onSecondary,
          titleColor: isDark ? colorScheme.onSecondaryContainer : baseColor,
          subtitleColor: baseColor,
        );

      case QuickAccessVariant.light:
        final baseColor = colorScheme.surfaceContainerHighest;
        return _QuickAccessColors(
          gradientColors: [
            baseColor.withOpacity(isDark ? 0.3 : 0.5),
            baseColor.withOpacity(isDark ? 0.2 : 0.3),
          ],
          borderColor: colorScheme.outline.withOpacity(isDark ? 0.4 : 0.3),
          shadowColor: colorScheme.shadow.withOpacity(isDark ? 0.08 : 0.06),
          splashColor: colorScheme.surfaceTint.withOpacity(0.08),
          highlightColor: colorScheme.surfaceTint.withOpacity(0.04),
          iconGradientColors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
          iconShadowColor: colorScheme.primary.withOpacity(
            isDark ? 0.25 : 0.15,
          ),
          iconColor: colorScheme.onPrimary,
          titleColor: colorScheme.onSurface,
          subtitleColor: colorScheme.onSurfaceVariant,
        );
    }
  }
}

// Modelo de datos para los elementos del carrusel
class QuickAccessItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isEnabled;
  final QuickAccessVariant variant;

  QuickAccessItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isEnabled = true,
    this.variant = QuickAccessVariant.primary,
  });
}

enum QuickAccessVariant { primary, accent, light }

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
