import 'package:compaexpress/page/admin/categories/admin_categories_form_page.dart';
import 'package:compaexpress/providers/categories_provider.dart';
import 'package:compaexpress/utils/navigation_utils.dart';
import 'package:compaexpress/views/pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

import '../../../models/Categoria.dart';

class AdminCategoriesListPage extends ConsumerStatefulWidget {
  const AdminCategoriesListPage({super.key});

  @override
  ConsumerState<AdminCategoriesListPage> createState() =>
      _AdminCategoriesListPageState();
}

class _AdminCategoriesListPageState
    extends ConsumerState<AdminCategoriesListPage> {
  List<Categoria> paginatedCategorias = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    // El provider carga automáticamente en su initialize
  }

  void _updatePageItems(List<Categoria> categorias) {
    paginatedCategorias = PaginationWidget.paginateList(
      categorias,
      currentPage,
      itemsPerPage,
    );
  }

  void _onPageChanged(int newPage, int totalItems) {
    if (newPage < 1 || newPage > (totalItems / itemsPerPage).ceil()) {
      return;
    }

    setState(() {
      currentPage = newPage;
    });
  }

  List<Categoria> _getFilteredCategorias(List<Categoria> categorias) {
    if (searchQuery.isEmpty) return categorias;

    final queryLower = searchQuery.toLowerCase();
    return categorias
        .where((cat) => cat.nombre.toLowerCase().contains(queryLower))
        .toList();
  }

  void _showSuccessToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle),
    );
  }

  void _showErrorToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      icon: const Icon(Icons.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoriesState = ref.watch(categoriesProvider);

    final filteredCategorias = _getFilteredCategorias(
      categoriesState.categorias,
    );
    _updatePageItems(filteredCategorias);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Categorías',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref
                .read(categoriesProvider.notifier)
                .loadCategorias(forceRefresh: true),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con estadísticas
          _buildStatsHeader(categoriesState, theme, colorScheme),

          // Paginación
          if (!categoriesState.isLoading && filteredCategorias.isNotEmpty)
            PaginationWidget(
              currentPage: currentPage,
              totalItems: filteredCategorias.length,
              itemsPerPage: itemsPerPage,
              onPageChanged: (page) =>
                  _onPageChanged(page, filteredCategorias.length),
              isLoading: false,
            ),

          // Buscador mejorado
          _buildSearchBar(theme, colorScheme),

          // Lista de categorías
          Expanded(
            child: categoriesState.isLoading
                ? _buildLoadingState(colorScheme)
                : categoriesState.error != null
                ? _buildErrorState(categoriesState.error!, theme, colorScheme)
                : paginatedCategorias.isEmpty
                ? _buildEmptyState(theme, colorScheme)
                : _buildCategoriesList(theme, colorScheme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva Categoría'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildStatsHeader(
    CategoriesState state,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final totalCategorias = state.categorias.length;
    final categoriasRaiz = state.categoriasRaiz.length;
    final subcategorias = totalCategorias - categoriasRaiz;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.category_rounded,
            value: totalCategorias.toString(),
            label: 'Total',
            color: colorScheme.primary,
            theme: theme,
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.outline.withOpacity(0.3),
          ),
          _buildStatItem(
            icon: Icons.folder_rounded,
            value: categoriasRaiz.toString(),
            label: 'Principales',
            color: colorScheme.secondary,
            theme: theme,
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.outline.withOpacity(0.3),
          ),
          _buildStatItem(
            icon: Icons.subdirectory_arrow_right_rounded,
            value: subcategorias.toString(),
            label: 'Subcategorías',
            color: colorScheme.tertiary,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar categorías...',
          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                      currentPage = 1;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
            currentPage = 1; // Resetear a primera página
          });
        },
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: colorScheme.surfaceContainerHighest,
          highlightColor: colorScheme.surface,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(
    String error,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar categorías',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(categoriesProvider.notifier)
                  .loadCategorias(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              searchQuery.isEmpty
                  ? 'No hay categorías'
                  : 'No se encontraron categorías',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isEmpty
                  ? 'Comienza creando tu primera categoría'
                  : 'Intenta con otro término de búsqueda',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (searchQuery.isEmpty)
              ElevatedButton.icon(
                onPressed: () => _navigateToForm(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Crear Categoría'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(ThemeData theme, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: () => ref
          .read(categoriesProvider.notifier)
          .loadCategorias(forceRefresh: true),
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: paginatedCategorias.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildCategoriaItem(
                    paginatedCategorias[index],
                    theme,
                    colorScheme,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoriaItem(
    Categoria categoria,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final categoriesState = ref.watch(categoriesProvider);
    final subCategorias = categoriesState.getSubcategorias(categoria.id);
    final hasSubcategorias = subCategorias.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
      ),
      child: hasSubcategorias
          ? ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.folder_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              title: Text(
                categoria.nombre,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${subCategorias.length} subcategoría${subCategorias.length != 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              trailing: _buildActionButtons(categoria, theme, colorScheme),
              children: subCategorias
                  .map(
                    (subCat) =>
                        _buildSubCategoriaItem(subCat, theme, colorScheme),
                  )
                  .toList(),
            )
          : ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoria.parentCategoriaID != null
                      ? colorScheme.secondaryContainer.withOpacity(0.5)
                      : colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  categoria.parentCategoriaID != null
                      ? Icons.subdirectory_arrow_right_rounded
                      : Icons.category_rounded,
                  color: categoria.parentCategoriaID != null
                      ? colorScheme.secondary
                      : colorScheme.primary,
                  size: 24,
                ),
              ),
              title: Text(
                categoria.nombre,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: categoria.parentCategoriaID != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Subcategoría de: ${categoriesState.getCategoryName(categoria.parentCategoriaID)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : null,
              trailing: _buildActionButtons(categoria, theme, colorScheme),
            ),
    );
  }

  Widget _buildActionButtons(
    Categoria categoria,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit_rounded, color: colorScheme.primary),
          onPressed: () => _navigateToForm(categoria: categoria),
          tooltip: 'Editar',
        ),
        IconButton(
          icon: Icon(Icons.delete_rounded, color: colorScheme.error),
          onPressed: () => _showDeleteDialog(categoria, theme, colorScheme),
          tooltip: 'Eliminar',
        ),
      ],
    );
  }

  Widget _buildSubCategoriaItem(
    Categoria subCategoria,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.subdirectory_arrow_right_rounded,
            color: colorScheme.secondary,
            size: 20,
          ),
        ),
        title: Text(
          subCategoria.nombre,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              onPressed: () => _navigateToForm(categoria: subCategoria),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: Icon(
                Icons.delete_rounded,
                size: 20,
                color: colorScheme.error,
              ),
              onPressed: () =>
                  _showDeleteDialog(subCategoria, theme, colorScheme),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm({Categoria? categoria}) async {
    final categoriesState = ref.read(categoriesProvider);
    await pushWrapped(
      context,
      AdminCategoriesFormPage(
        categoria: categoria,
        categoriasDisponibles: categoriesState.categorias,
      ),
    );
  }

  void _showDeleteDialog(
    Categoria categoria,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final categoriesState = ref.read(categoriesProvider);
    final hasSubcategorias = categoriesState.hasSubcategorias(categoria.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              hasSubcategorias ? Icons.warning_rounded : Icons.delete_rounded,
              color: colorScheme.error,
            ),
            const SizedBox(width: 12),
            const Text('Confirmar eliminación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasSubcategorias) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta categoría tiene subcategorías asociadas y no puede ser eliminada.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Text(
                '¿Estás seguro de que deseas eliminar "${categoria.nombre}"?',
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          if (!hasSubcategorias)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteCategoria(categoria);
              },
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: const Text('Eliminar'),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteCategoria(Categoria categoria) async {
    final success = await ref
        .read(categoriesProvider.notifier)
        .deleteCategoria(categoria);

    if (success) {
      _showSuccessToast('Categoría eliminada correctamente');
    } else {
      _showErrorToast('Error al eliminar la categoría');
    }
  }
}
