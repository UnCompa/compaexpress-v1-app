import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

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
    if (totalItems == 0) return const SizedBox.shrink();

    final isMobile = MediaQuery.of(context).size.width < 600;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final buttonSize = isMobile ? 32.0 : 40.0;
    final fontSize = isMobile ? 12.0 * textScaleFactor : 14.0 * textScaleFactor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Información de página
          Flexible(
            child: Text(
              'Página $currentPage de $totalPages ($totalItems elementos)',
              style: TextStyle(
                fontSize: fontSize,
                color: theme.colorScheme.onSurface,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Controles de navegación
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador de carga
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),

              // Primera página
              _buildIconButton(
                icon: Icons.first_page,
                onPressed: (!hasPreviousPage || isLoading)
                    ? null
                    : () => onPageChanged(1),
                tooltip: 'Primera página',
                size: buttonSize,
              ),

              // Página anterior
              _buildIconButton(
                icon: Icons.chevron_left,
                onPressed: (!hasPreviousPage || isLoading)
                    ? null
                    : () => onPageChanged(currentPage - 1),
                tooltip: 'Página anterior',
                size: buttonSize,
              ),

              // Páginas numeradas
              if (!isMobile) ..._buildPageNumbers(context, fontSize, isMobile),

              // Página siguiente
              _buildIconButton(
                icon: Icons.chevron_right,
                onPressed: (!hasNextPage || isLoading)
                    ? null
                    : () => onPageChanged(currentPage + 1),
                tooltip: 'Página siguiente',
                size: buttonSize,
              ),

              // Última página
              _buildIconButton(
                icon: Icons.last_page,
                onPressed: (!hasNextPage || isLoading)
                    ? null
                    : () => onPageChanged(totalPages),
                tooltip: 'Última página',
                size: buttonSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    required double size,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: size * 0.6,
              color: onPressed == null ? Colors.grey[400] : Colors.blue[600],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers(
    BuildContext context,
    double fontSize,
    bool isMobile,
  ) {
    List<Widget> pageButtons = [];
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (currentPage + 2).clamp(1, totalPages);

    // Mostrar menos páginas en móviles
    if (isMobile) {
      startPage = (currentPage - 1).clamp(1, totalPages);
      endPage = (currentPage + 1).clamp(1, totalPages);
    }

    // Ajustar el rango para mostrar siempre 5 páginas en escritorio o 3 en móvil
    if (endPage - startPage < (isMobile ? 2 : 4)) {
      if (startPage == 1) {
        endPage = (startPage + (isMobile ? 2 : 4)).clamp(1, totalPages);
      } else if (endPage == totalPages) {
        startPage = (endPage - (isMobile ? 2 : 4)).clamp(1, totalPages);
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : () => onPageChanged(i),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: isMobile ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: i == currentPage ? Colors.blue[600] : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: i == currentPage
                      ? Colors.blue[600]!
                      : Colors.grey[300]!,
                ),
              ),
              child: Text(
                '$i',
                style: TextStyle(
                  color: i == currentPage ? Colors.white : Colors.grey[700],
                  fontSize: fontSize,
                  fontWeight: i == currentPage
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return pageButtons;
  }
}
