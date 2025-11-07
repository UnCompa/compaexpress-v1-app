import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isEnabled = true,
    this.layoutType = OptionTileLayout.adaptive,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isEnabled;
  final OptionTileLayout layoutType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // Detectar si está en un grid o lista basado en el ancho disponible
    return LayoutBuilder(
      builder: (context, constraints) {
        final isGridLayout = _shouldUseGridLayout(constraints);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEnabled
                  ? [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ]
                  : [Colors.grey[200]!, Colors.grey[300]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isEnabled
                    ? Colors.black12
                    : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isEnabled
                  ? primaryColor.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? onTap : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: isGridLayout
                    ? _buildGridLayout(primaryColor)
                    : _buildListLayout(primaryColor),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _shouldUseGridLayout(BoxConstraints constraints) {
    switch (layoutType) {
      case OptionTileLayout.grid:
        return true;
      case OptionTileLayout.list:
        return false;
      case OptionTileLayout.adaptive:
        // Si el ancho es menor a 250px, probablemente está en un grid compacto
        return constraints.maxWidth < 300;
    }
  }

  Widget _buildGridLayout(Color primaryColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icono
        AnimatedScale(
          scale: isEnabled ? 1.0 : 0.9,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEnabled
                  ? primaryColor.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isEnabled ? primaryColor : Colors.grey[400],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Título
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isEnabled ? Colors.black87 : Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),

        // Subtítulo
        Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: isEnabled ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildListLayout(Color primaryColor) {
    return Row(
      children: [
        // Icono
        AnimatedScale(
          scale: isEnabled ? 1.0 : 0.9,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEnabled
                  ? primaryColor.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: isEnabled ? primaryColor : Colors.grey[400],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Contenido
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? Colors.black87 : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),

        // Flecha
        AnimatedOpacity(
          opacity: isEnabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isEnabled ? primaryColor : Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

enum OptionTileLayout {
  adaptive, // Se adapta automáticamente según el espacio disponible
  grid, // Siempre usa layout de grid (vertical)
  list, // Siempre usa layout de lista (horizontal)
}

class MenuOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  final VoidCallback? customAction;

  const MenuOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.route,
    this.customAction,
  });
}
