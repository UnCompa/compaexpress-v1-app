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
    final colors = _getColors(variant, isEnabled);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderColor, width: 1),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: colors.shadowColor,
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
                // Icono con contenedor destacado más compacto
                Container(
                  padding: const EdgeInsets.all(8),
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
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(icon, size: 20, color: colors.iconColor),
                ),
                const SizedBox(height: 8),

                // Título más compacto
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.titleColor,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),

                // Subtítulo más pequeño
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
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
          shadowColor: const Color(0xFF1976D2).withOpacity(0.15),
          splashColor: const Color(0xFF1976D2).withOpacity(0.1),
          highlightColor: const Color(0xFF1976D2).withOpacity(0.05),
          iconGradientColors: [
            const Color(0xFF1E88E5),
            const Color(0xFF1976D2),
          ],
          iconShadowColor: const Color(0xFF1976D2).withOpacity(0.3),
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
          shadowColor: const Color(0xFF2196F3).withOpacity(0.15),
          splashColor: const Color(0xFF2196F3).withOpacity(0.1),
          highlightColor: const Color(0xFF2196F3).withOpacity(0.05),
          iconGradientColors: [
            const Color(0xFF42A5F5),
            const Color(0xFF2196F3),
          ],
          iconShadowColor: const Color(0xFF2196F3).withOpacity(0.3),
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
          shadowColor: const Color(0xFF2196F3).withOpacity(0.1),
          splashColor: const Color(0xFF2196F3).withOpacity(0.08),
          highlightColor: const Color(0xFF2196F3).withOpacity(0.04),
          iconGradientColors: [
            const Color(0xFF64B5F6),
            const Color(0xFF42A5F5),
          ],
          iconShadowColor: const Color(0xFF2196F3).withOpacity(0.2),
          iconColor: Colors.white,
          titleColor: const Color(0xFF0D47A1),
          subtitleColor: const Color(0xFF1565C0),
        );
    }
  }
}

enum QuickAccessVariant {
  primary, // Azul oscuro y elegante
  accent, // Azul medio vibrante
  light, // Azul claro y suave
}

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
