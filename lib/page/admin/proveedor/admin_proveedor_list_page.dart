import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/admin/proveedor/admin_proveedor_form_page.dart';
import 'package:compaexpress/providers/proveedor_provider.dart';
import 'package:compaexpress/views/pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

class AdminProveedorListPage extends ConsumerStatefulWidget {
  const AdminProveedorListPage({super.key});

  @override
  ConsumerState<AdminProveedorListPage> createState() =>
      _AdminProveedorListPageState();
}

class _AdminProveedorListPageState
    extends ConsumerState<AdminProveedorListPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncList = ref.watch(filteredProveedoresProvider);
    final proveedorState = ref.watch(proveedorProvider);

    // Paginación
    final page = ref.watch(currentPageProvider);
    final perPage = ref.watch(itemsPerPageProvider);
    final paginated = PaginationWidget.paginateList<Proveedor>(
      asyncList,
      page,
      perPage,
    );

    // Escuchar cambios de estado para mostrar notificaciones
    ref.listen<ProveedorState>(proveedorProvider, (previous, next) {
      if (next.successMessage != null) {
        _showSuccessToast(context, next.successMessage!);
        ref.read(proveedorProvider.notifier).clearMessages();
      }
      if (next.error != null) {
        _showErrorToast(context, next.error!);
        ref.read(proveedorProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: _buildAppBar(theme, proveedorState),
      body: Column(
        children: [
          _buildSearchHeader(theme),
          _buildStatsBanner(theme, asyncList.length),
          Expanded(child: _buildBody(paginated, theme, proveedorState)),
        ],
      ),
      floatingActionButton: _buildFAB(theme),
      bottomNavigationBar: _buildPagination(page, asyncList.length, perPage),
    );
  }

  /* ---------------- AppBar ---------------- */

  PreferredSizeWidget _buildAppBar(ThemeData theme, ProveedorState state) {
    return AppBar(
      elevation: 0,
      title: Text(
        'Gestión de Proveedores',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (state.isLoading)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(proveedorProvider.notifier).refresh(),
            tooltip: 'Actualizar',
          ),
        IconButton(
          icon: const Icon(Icons.filter_list_rounded),
          onPressed: () => _showFilterDialog(),
          tooltip: 'Filtros',
        ),
      ],
    );
  }

  /* ---------------- Search Header ---------------- */

  Widget _buildSearchHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (q) {
          ref.read(searchQueryProvider.notifier).state = q;
          ref.read(currentPageProvider.notifier).state = 1; // Reset a página 1
        },
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText:
              'Buscar por nombre o ciudad...', // TODO: agregar teléfono o email cuando estén en el modelo
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.primary,
          ),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchCtrl.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  /* ---------------- Stats Banner ---------------- */

  Widget _buildStatsBanner(ThemeData theme, int totalCount) {
    final query = ref.watch(searchQueryProvider);
    final isFiltered = query.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Row(
        children: [
          Icon(
            isFiltered ? Icons.filter_alt_rounded : Icons.inventory_2_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            isFiltered
                ? '$totalCount resultado${totalCount != 1 ? 's' : ''} encontrado${totalCount != 1 ? 's' : ''}'
                : '$totalCount proveedor${totalCount != 1 ? 'es' : ''} registrado${totalCount != 1 ? 's' : ''}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /* ---------------- Body ---------------- */

  Widget _buildBody(
    List<Proveedor> list,
    ThemeData theme,
    ProveedorState state,
  ) {
    if (state.isLoading && list.isEmpty) {
      return _buildLoadingShimmer(theme);
    }

    if (state.error != null && list.isEmpty) {
      return _buildErrorView(theme, state.error!);
    }

    if (list.isEmpty) {
      return _buildEmptyView(theme);
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildProveedorCard(list[index], theme),
              ),
            ),
          );
        },
      ),
    );
  }

  /* ---------------- Loading Shimmer ---------------- */

  Widget _buildLoadingShimmer(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: theme.colorScheme.surfaceContainerHighest,
            highlightColor: theme.colorScheme.surface,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              title: Container(
                height: 16,
                width: double.infinity,
                color: Colors.white,
              ),
              subtitle: Container(
                height: 12,
                width: 150,
                color: Colors.white,
                margin: const EdgeInsets.only(top: 8),
              ),
            ),
          ),
        );
      },
    );
  }

  /* ---------------- Error View ---------------- */

  Widget _buildErrorView(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar proveedores',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.read(proveedorProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------------- Empty View ---------------- */

  Widget _buildEmptyView(ThemeData theme) {
    final query = ref.watch(searchQueryProvider);
    final isSearching = query.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.inventory_2_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching
                  ? 'No se encontraron resultados'
                  : 'No hay proveedores registrados',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? 'Intenta con otros términos de búsqueda'
                  : 'Comienza agregando tu primer proveedor',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (!isSearching) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _addProveedor(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Agregar Proveedor'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /* ---------------- Proveedor Card ---------------- */

  Widget _buildProveedorCard(Proveedor proveedor, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _editProveedor(proveedor),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proveedor.nombre ?? 'Sin nombre',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              proveedor.ciudad ?? 'Sin ciudad',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () => _editProveedor(proveedor),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_rounded,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () => _deleteProveedor(proveedor),
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                ],
              ),
              // TODO: Descomentar cuando telefono y email estén en el modelo
              // if (proveedor.telefono != null ||
              //     proveedor.email != null) ...[
              //   const SizedBox(height: 12),
              //   const Divider(),
              //   const SizedBox(height: 12),
              //   Row(
              //     children: [
              //       if (proveedor.telefono != null) ...[
              //         Icon(
              //           Icons.phone_rounded,
              //           size: 16,
              //           color: theme.colorScheme.primary,
              //         ),
              //         const SizedBox(width: 6),
              //         Expanded(
              //           child: Text(
              //             proveedor.telefono!,
              //             style: theme.textTheme.bodySmall,
              //           ),
              //         ),
              //       ],
              //       if (proveedor.email != null) ...[
              //         if (proveedor.telefono != null)
              //           const SizedBox(width: 16),
              //         Icon(
              //           Icons.email_rounded,
              //           size: 16,
              //           color: theme.colorScheme.primary,
              //         ),
              //         const SizedBox(width: 6),
              //         Expanded(
              //           child: Text(
              //             proveedor.email!,
              //             style: theme.textTheme.bodySmall,
              //             overflow: TextOverflow.ellipsis,
              //           ),
              //         ),
              //       ],
              //     ],
              //   ),
              // ],
            ],
          ),
        ),
      ),
    );
  }

  /* ---------------- FAB ---------------- */

  Widget _buildFAB(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => _addProveedor(context),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Nuevo Proveedor'),
      elevation: 4,
    );
  }

  /* ---------------- Pagination ---------------- */

  Widget _buildPagination(int page, int totalItems, int perPage) {
    if (totalItems == 0) return const SizedBox.shrink();

    return PaginationWidget(
      currentPage: page,
      totalItems: totalItems,
      itemsPerPage: perPage,
      onPageChanged: (p) => ref.read(currentPageProvider.notifier).state = p,
    );
  }

  /* ---------------- Actions ---------------- */

  Future<void> _addProveedor(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProveedorFormPage()),
    );

    if (result == true && mounted) {
      ref.read(proveedorProvider.notifier).refresh();
    }
  }

  Future<void> _editProveedor(Proveedor proveedor) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProveedorFormPage(proveedor: proveedor),
      ),
    );

    if (result == true && mounted) {
      ref.read(proveedorProvider.notifier).refresh();
    }
  }

  Future<void> _deleteProveedor(Proveedor proveedor) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_rounded,
          color: theme.colorScheme.error,
          size: 48,
        ),
        title: const Text('¿Eliminar proveedor?'),
        content: Text(
          'Se eliminará "${proveedor.nombre}". Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(proveedorProvider.notifier).softDelete(proveedor);
    }
  }

  void _showFilterDialog() {
    // Implementar diálogo de filtros personalizados
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: const Text('Funcionalidad de filtros en desarrollo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /* ---------------- Toasts ---------------- */

  void _showSuccessToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topRight,
      icon: const Icon(Icons.check_circle_rounded),
    );
  }

  void _showErrorToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.topRight,
      icon: const Icon(Icons.error_rounded),
    );
  }
}
