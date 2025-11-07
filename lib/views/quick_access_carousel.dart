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
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del carrusel (opcional)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.dashboard_rounded,
                  size: 20,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                Text(
                  'Acceso Rápido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
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
                  width: 120, // Ancho fijo para consistencia
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
    final colors = _getColors(variant, isEnabled);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderColor, width: 0.8),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: colors.shadowColor,
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
                // Ícono compacto
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors.iconGradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: isEnabled
                        ? [
                            BoxShadow(
                              color: colors.iconShadowColor,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(icon, size: 18, color: colors.iconColor),
                ),
                const SizedBox(height: 6),

                // Título
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.titleColor,
                  ),
                ),
                const SizedBox(height: 2),

                // Subtítulo
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8,
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

  _QuickAccessColors _getColors(QuickAccessVariant variant, bool enabled) {
    if (!enabled) {
      return _QuickAccessColors(
        gradientColors: [Colors.grey[100]!, Colors.grey[200]!],
        borderColor: Colors.grey[300]!,
        shadowColor: Colors.transparent,
        splashColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        iconGradientColors: [Colors.grey[200]!, Colors.grey[300]!],
        iconShadowColor: Colors.transparent,
        iconColor: Colors.grey[400]!,
        titleColor: Colors.grey[500]!,
        subtitleColor: Colors.grey[400]!,
      );
    }

    switch (variant) {
      case QuickAccessVariant.primary:
        return _QuickAccessColors(
          gradientColors: [
            const Color(0xFF1E88E5).withOpacity(0.08),
            const Color(0xFF1976D2).withOpacity(0.03),
          ],
          borderColor: const Color(0xFF1976D2).withOpacity(0.3),
          shadowColor: const Color(0xFF1976D2).withOpacity(0.12),
          splashColor: const Color(0xFF1976D2).withOpacity(0.1),
          highlightColor: const Color(0xFF1976D2).withOpacity(0.05),
          iconGradientColors: [
            const Color(0xFF1E88E5),
            const Color(0xFF1976D2),
          ],
          iconShadowColor: const Color(0xFF1976D2).withOpacity(0.25),
          iconColor: Colors.white,
          titleColor: const Color(0xFF0D47A1),
          subtitleColor: const Color(0xFF1565C0),
        );

      case QuickAccessVariant.accent:
        return _QuickAccessColors(
          gradientColors: [
            const Color(0xFF42A5F5).withOpacity(0.08),
            const Color(0xFF2196F3).withOpacity(0.03),
          ],
          borderColor: const Color(0xFF2196F3).withOpacity(0.3),
          shadowColor: const Color(0xFF2196F3).withOpacity(0.12),
          splashColor: const Color(0xFF2196F3).withOpacity(0.1),
          highlightColor: const Color(0xFF2196F3).withOpacity(0.05),
          iconGradientColors: [
            const Color(0xFF42A5F5),
            const Color(0xFF2196F3),
          ],
          iconShadowColor: const Color(0xFF2196F3).withOpacity(0.25),
          iconColor: Colors.white,
          titleColor: const Color(0xFF1565C0),
          subtitleColor: const Color(0xFF1976D2),
        );

      case QuickAccessVariant.light:
        return _QuickAccessColors(
          gradientColors: [
            const Color(0xFFE3F2FD),
            const Color(0xFFBBDEFB).withOpacity(0.7),
          ],
          borderColor: const Color(0xFF90CAF9),
          shadowColor: const Color(0xFF2196F3).withOpacity(0.08),
          splashColor: const Color(0xFF2196F3).withOpacity(0.08),
          highlightColor: const Color(0xFF2196F3).withOpacity(0.04),
          iconGradientColors: [
            const Color(0xFF64B5F6),
            const Color(0xFF42A5F5),
          ],
          iconShadowColor: const Color(0xFF2196F3).withOpacity(0.15),
          iconColor: Colors.white,
          titleColor: const Color(0xFF0D47A1),
          subtitleColor: const Color(0xFF1565C0),
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
  final Color shadowColor;
  final Color splashColor;
  final Color highlightColor;
  final List<Color> iconGradientColors;
  final Color iconShadowColor;
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