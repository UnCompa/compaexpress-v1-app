import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int itemsPerPage;
  final Function(int) onPageChanged;
  final bool isLoading;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    this.isLoading = false,
  });

  int get totalPages => (totalItems / itemsPerPage).ceil();
  bool get hasPreviousPage => currentPage > 1;
  bool get hasNextPage => currentPage < totalPages;

  static List<T> paginateList<T>(
    List<T> items,
    int currentPage,
    int itemsPerPage,
  ) {
    if (items.isEmpty || currentPage < 1 || itemsPerPage <= 0) {
      safePrint(
        'Advertencia: No se pueden paginar elementos. Revise los parámetros.',
      );
      return [];
    }

    final int startIndex = (currentPage - 1) * itemsPerPage;
    final int endIndex = startIndex + itemsPerPage;

    if (startIndex >= items.length) {
      safePrint(
        'Advertencia: La página solicitada está fuera del rango de elementos.',
      );
      return [];
    }

    final int actualEndIndex = endIndex > items.length
        ? items.length
        : endIndex;
    return items.sublist(startIndex, actualEndIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (totalItems == 0) return const SizedBox.shrink();

    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 900;
    final buttonSize = isMobile ? 36.0 : 44.0;

    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 300),
      child: SlideAnimation(
        verticalOffset: 20,
        child: FadeInAnimation(
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 16,
              vertical: isMobile ? 8 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 20,
                vertical: isMobile ? 12 : 16,
              ),
              child: isMobile
                  ? _buildMobileLayout(context, colorScheme, buttonSize)
                  : _buildDesktopLayout(
                      context,
                      colorScheme,
                      buttonSize,
                      isTablet,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ColorScheme colorScheme,
    double buttonSize,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Información de página en móvil
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Página $currentPage de $totalPages',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$totalItems elementos',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        // Controles de navegación
        _buildNavigationControls(context, colorScheme, buttonSize, true),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    ColorScheme colorScheme,
    double buttonSize,
    bool isTablet,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Información de página
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Página $currentPage de $totalPages',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mostrando ${_getItemRange()} de $totalItems elementos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Controles de navegación
        _buildNavigationControls(context, colorScheme, buttonSize, false),
      ],
    );
  }

  String _getItemRange() {
    final start = ((currentPage - 1) * itemsPerPage) + 1;
    final end = (currentPage * itemsPerPage).clamp(0, totalItems);
    return '$start-$end';
  }

  Widget _buildNavigationControls(
    BuildContext context,
    ColorScheme colorScheme,
    double buttonSize,
    bool isMobile,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Indicador de carga
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: AppLoadingIndicator(
                strokeWidth: 2.5,
              ),
            ),
          ),

        // Primera página
        _buildNavigationButton(
          context: context,
          icon: Icons.first_page_rounded,
          onPressed: (!hasPreviousPage || isLoading)
              ? null
              : () => onPageChanged(1),
          tooltip: 'Primera página',
          size: buttonSize,
          colorScheme: colorScheme,
        ),

        const SizedBox(width: 4),

        // Página anterior
        _buildNavigationButton(
          context: context,
          icon: Icons.chevron_left_rounded,
          onPressed: (!hasPreviousPage || isLoading)
              ? null
              : () => onPageChanged(currentPage - 1),
          tooltip: 'Página anterior',
          size: buttonSize,
          colorScheme: colorScheme,
        ),

        // Páginas numeradas (solo en desktop)
        if (!isMobile) ...[
          const SizedBox(width: 8),
          ..._buildPageNumbers(context, colorScheme),
          const SizedBox(width: 8),
        ] else
          const SizedBox(width: 4),

        // Página siguiente
        _buildNavigationButton(
          context: context,
          icon: Icons.chevron_right_rounded,
          onPressed: (!hasNextPage || isLoading)
              ? null
              : () => onPageChanged(currentPage + 1),
          tooltip: 'Página siguiente',
          size: buttonSize,
          colorScheme: colorScheme,
        ),

        const SizedBox(width: 4),

        // Última página
        _buildNavigationButton(
          context: context,
          icon: Icons.last_page_rounded,
          onPressed: (!hasNextPage || isLoading)
              ? null
              : () => onPageChanged(totalPages),
          tooltip: 'Última página',
          size: buttonSize,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    required double size,
    required ColorScheme colorScheme,
  }) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isEnabled
                  ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isEnabled
                    ? colorScheme.outline.withOpacity(0.3)
                    : colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Icon(
              icon,
              size: size * 0.5,
              color: isEnabled
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 900;

    List<Widget> pageButtons = [];

    // Ajustar cantidad de páginas según dispositivo
    final maxVisiblePages = isMobile ? 3 : (isTablet ? 5 : 7);
    final halfVisible = maxVisiblePages ~/ 2;

    int startPage = (currentPage - halfVisible).clamp(1, totalPages);
    int endPage = (currentPage + halfVisible).clamp(1, totalPages);

    // Ajustar el rango para mostrar siempre maxVisiblePages
    if (endPage - startPage < maxVisiblePages - 1) {
      if (startPage == 1) {
        endPage = (startPage + maxVisiblePages - 1).clamp(1, totalPages);
      } else if (endPage == totalPages) {
        startPage = (endPage - maxVisiblePages + 1).clamp(1, totalPages);
      }
    }

    // Agregar primera página y separador
    if (startPage > 1) {
      pageButtons.add(_buildPageButton(context, 1, colorScheme));
      if (startPage > 2) {
        pageButtons.add(_buildEllipsis(colorScheme));
      }
    }

    // Agregar páginas numeradas
    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(_buildPageButton(context, i, colorScheme));
    }

    // Agregar separador y última página
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pageButtons.add(_buildEllipsis(colorScheme));
      }
      pageButtons.add(_buildPageButton(context, totalPages, colorScheme));
    }

    return pageButtons;
  }

  Widget _buildPageButton(
    BuildContext context,
    int page,
    ColorScheme colorScheme,
  ) {
    final isCurrent = page == currentPage;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () => onPageChanged(page),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isCurrent
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrent
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.2),
                width: isCurrent ? 1.5 : 1,
              ),
            ),
            child: Text(
              '$page',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isCurrent
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
