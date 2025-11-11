import 'package:cached_network_image/cached_network_image.dart';
import 'package:compaexpress/models/Producto.dart';
import 'package:compaexpress/models/ProductoPrecios.dart';
import 'package:compaexpress/page/admin/inventory/admin__view_inventory_details_screen.dart';
import 'package:compaexpress/page/admin/inventory/admin_create_inventory_product.dart';
import 'package:compaexpress/providers/products_provider.dart';
import 'package:compaexpress/routes/routes.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/utils/get_image_for_bucker.dart';
import 'package:compaexpress/widget/custom_wrapper_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';

class AdminViewInventoryScreen extends ConsumerStatefulWidget {
  const AdminViewInventoryScreen({super.key});

  @override
  ConsumerState<AdminViewInventoryScreen> createState() =>
      _AdminViewInventoryScreenState();
}

class _AdminViewInventoryScreenState
    extends ConsumerState<AdminViewInventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  String _negocioID = "";
  String _sortBy = 'nombre';
  bool _onlyFavorites = false;
  bool _onlyLowStock = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeData() async {
    final info = await NegocioService.getCurrentUserInfo();
    setState(() {
      _negocioID = info.negocioId;
    });
  }

  void _onSearchChanged() {
    setState(() {}); // Trigger rebuild to apply filters
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<Producto> _getFilteredAndSortedProducts() {
    final productsState = ref.watch(productsProvider);

    var filtered = productsState.filterProducts(
      searchQuery: _searchController.text,
      categoryId: _selectedCategoryId,
      onlyFavorites: _onlyFavorites,
      onlyLowStock: _onlyLowStock,
    );

    // Ordenar
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'stock':
          return a.stock.compareTo(b.stock);
        case 'favorito':
          if (a.favorito == b.favorito) return 0;
          return a.favorito ? -1 : 1;
        case 'nombre':
        default:
          return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
      }
    });

    return filtered;
  }

  Color _getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsState = ref.watch(productsProvider);
    final filteredProducts = _getFilteredAndSortedProducts();
    final lowStockCount = ref.watch(lowStockProductsProvider).length;
    final outOfStockCount = ref.watch(outOfStockProductsProvider).length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Gestionar Inventario',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          // Indicador de alertas de stock
          if (lowStockCount > 0 || outOfStockCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Badge(
                  label: Text('${lowStockCount + outOfStockCount}'),
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: Icon(Icons.warning_amber_rounded),
                    onPressed: () {
                      _showStockAlertsDialog(context, theme);
                    },
                    tooltip: 'Alertas de stock',
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: () {
              ref
                  .read(productsProvider.notifier)
                  .loadProducts(forceRefresh: true);
            },
            tooltip: 'Refrescar',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.sort_rounded),
            tooltip: 'Ordenar',
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'nombre',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 20),
                    SizedBox(width: 12),
                    Text('Por Nombre'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'favorito',
                child: Row(
                  children: [
                    Icon(Icons.star, size: 20),
                    SizedBox(width: 12),
                    Text('Por Favorito'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'stock',
                child: Row(
                  children: [
                    Icon(Icons.inventory_2, size: 20),
                    SizedBox(width: 12),
                    Text('Por Stock'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: productsState.isLoading && !productsState.productosLoaded
          ? _buildLoadingState(theme)
          : Column(
              children: [
                // Filtros y búsqueda con mejor diseño
                _buildFiltersSection(theme, productsState),

                // Chips de filtrado rápido
                _buildQuickFilters(theme),

                // Estadísticas rápidas
                _buildStatsBar(
                  theme,
                  filteredProducts.length,
                  productsState.productos.length,
                ),

                // Lista de productos con animaciones
                Expanded(
                  child: filteredProducts.isEmpty
                      ? _buildEmptyState(theme)
                      : _buildProductsList(filteredProducts, theme),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            CustomWrapperPage(
              builder: (_) =>
                  AdminCreateInventoryProduct(negocioID: _negocioID),
            ),
          );
          if (result == true) {
            ref
                .read(productsProvider.notifier)
                .loadProducts(forceRefresh: true);
          }
        },
        icon: Icon(Icons.add_rounded),
        label: Text('Crear Producto'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: theme.colorScheme.surfaceContainerHighest,
          highlightColor: theme.colorScheme.surface,
          child: Card(
            margin: EdgeInsets.only(bottom: 12),
            child: Container(
              height: 120,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Container(height: 14, width: 150, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFiltersSection(ThemeData theme, ProductsState productsState) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Botón categorías con mejor diseño
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.adminViewCategorias);
              },
              icon: Icon(Icons.category_rounded),
              label: Text('Gestionar Categorías'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Barra de búsqueda mejorada
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o código...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Filtro por categoría mejorado
          DropdownButtonFormField<String?>(
            value: _selectedCategoryId,
            decoration: InputDecoration(
              labelText: 'Categoría',
              prefixIcon: Icon(
                Icons.filter_list_rounded,
                color: theme.colorScheme.primary,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text('Todas las categorías'),
              ),
              ...productsState.categorias.values.map((categoria) {
                return DropdownMenuItem<String?>(
                  value: categoria.id,
                  child: Text(categoria.nombre),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters(ThemeData theme) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: Text('Favoritos'),
            avatar: Icon(
              _onlyFavorites ? Icons.star : Icons.star_border,
              size: 18,
            ),
            selected: _onlyFavorites,
            onSelected: (value) {
              setState(() {
                _onlyFavorites = value;
              });
            },
            selectedColor: theme.colorScheme.primaryContainer,
            checkmarkColor: theme.colorScheme.primary,
          ),
          SizedBox(width: 8),
          FilterChip(
            label: Text('Stock Bajo'),
            avatar: Icon(Icons.warning_amber_rounded, size: 18),
            selected: _onlyLowStock,
            onSelected: (value) {
              setState(() {
                _onlyLowStock = value;
              });
            },
            selectedColor: Colors.orange.shade100,
            checkmarkColor: Colors.orange.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(ThemeData theme, int filteredCount, int totalCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 1),
          bottom: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_rounded,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 8),
          Text(
            '$filteredCount de $totalCount productos',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Spacer(),
          Text(
            'Por: $_sortBy',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: theme.colorScheme.outline,
          ),
          SizedBox(height: 24),
          Text(
            'No se encontraron productos',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Intenta ajustar los filtros',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (_searchController.text.isNotEmpty ||
              _selectedCategoryId != null ||
              _onlyFavorites ||
              _onlyLowStock)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedCategoryId = null;
                    _onlyFavorites = false;
                    _onlyLowStock = false;
                  });
                },
                icon: Icon(Icons.clear_all_rounded),
                label: Text('Limpiar filtros'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<Producto> products, ThemeData theme) {
    return AnimationLimiter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width > 1000 ? 2 : 1;

          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: width > 1000 ? 2.4 : 1.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: crossAxisCount,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: _buildProductCard(products[index], theme),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Producto product, ThemeData theme) {
    final productsState = ref.watch(productsProvider);
    final precios = productsState.getPreciosForProducto(product.id);

    return Card(
      elevation: 2,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push(
            CustomWrapperPage(
              builder: (_) => AdminViewInventoryDetailsScreen(
                product: product,
                negocioID: _negocioID,
              ),
            ),
          );
          if (result == true) {
            ref
                .read(productsProvider.notifier)
                .loadProducts(forceRefresh: true);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con imagen y nombre
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del producto
                  _buildProductImage(product, theme),
                  SizedBox(width: 12),

                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nombre,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.barCode.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.qr_code_2_rounded,
                                  size: 14,
                                  color: theme.colorScheme.outline,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  product.barCode,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Botón de favorito y stock
                  Column(
                    children: [
                      _buildFavoriteButton(product, theme),
                      SizedBox(height: 8),
                      _buildStockBadge(product.stock, theme),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Descripción
              if (product.descripcion.isNotEmpty)
                Text(
                  product.descripcion,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              Spacer(),

              // Tags y precios
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Precios
                  if (precios.isNotEmpty)
                    ...precios
                        .take(2)
                        .map((precio) => _buildPriceChip(precio, theme))
                  else
                    Chip(
                      label: Text('Sin precios'),
                      avatar: Icon(Icons.error_outline, size: 16),
                      backgroundColor: theme.colorScheme.errorContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),

                  // Categoría
                  Chip(
                    label: Text(
                      productsState.getCategoryName(product.categoriaID),
                    ),
                    avatar: Icon(Icons.category_rounded, size: 16),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontSize: 12,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),

                  // Estado
                  Chip(
                    label: Text(product.estado?.toUpperCase() ?? 'N/A'),
                    avatar: Icon(
                      product.estado == 'activo'
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 16,
                    ),
                    backgroundColor: product.estado == 'activo'
                        ? theme.colorScheme.tertiaryContainer
                        : theme.colorScheme.errorContainer,
                    labelStyle: TextStyle(
                      color: product.estado == 'activo'
                          ? theme.colorScheme.onTertiaryContainer
                          : theme.colorScheme.onErrorContainer,
                      fontSize: 12,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Producto product, ThemeData theme) {
    if (product.productoImages != null && product.productoImages!.isNotEmpty) {
      return FutureBuilder<List<String>>(
        future: GetImageFromBucket.getSignedImageUrls(
          s3Keys: [product.productoImages!.first],
          expiresIn: Duration(minutes: 30),
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: snapshot.data!.first,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: theme.colorScheme.surfaceContainerHighest,
                  highlightColor: theme.colorScheme.surface,
                  child: Container(width: 70, height: 70, color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            );
          }
          return _buildPlaceholderImage(theme);
        },
      );
    }
    return _buildPlaceholderImage(theme);
  }

  Widget _buildPlaceholderImage(ThemeData theme) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image_rounded,
        color: theme.colorScheme.outline,
        size: 32,
      ),
    );
  }

  Widget _buildFavoriteButton(Producto product, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: product.favorito
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
      ),
      child: IconButton(
        icon: Icon(
          product.favorito ? Icons.star_rounded : Icons.star_border_rounded,
        ),
        onPressed: () async {
          final success = await ref
              .read(productsProvider.notifier)
              .toggleFavorite(product.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success ? 'Favorito actualizado' : 'Error al actualizar',
                ),
                backgroundColor: success ? Colors.green : Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        color: product.favorito
            ? theme.colorScheme.primary
            : theme.colorScheme.outline,
        iconSize: 20,
        padding: EdgeInsets.all(8),
        constraints: BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  Widget _buildStockBadge(int stock, ThemeData theme) {
    final color = _getStockColor(stock);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        '$stock',
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriceChip(ProductoPrecios precio, ThemeData theme) {
    return Chip(
      label: Text('${precio.nombre}: \$${precio.precio.toStringAsFixed(2)}'),
      avatar: Icon(Icons.attach_money_rounded, size: 16),
      backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
      labelStyle: TextStyle(
        color: theme.colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  void _showStockAlertsDialog(BuildContext context, ThemeData theme) {
    final lowStock = ref.read(lowStockProductsProvider);
    final outOfStock = ref.read(outOfStockProductsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Alertas de Stock'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (outOfStock.isNotEmpty) ...[
                Text(
                  'Sin Stock (${outOfStock.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ...outOfStock
                    .take(5)
                    .map(
                      (p) => ListTile(
                        dense: true,
                        leading: Icon(Icons.error, color: Colors.red, size: 20),
                        title: Text(p.nombre),
                        subtitle: Text('Stock: ${p.stock}'),
                      ),
                    ),
                if (outOfStock.length > 5)
                  Text('... y ${outOfStock.length - 5} más'),
                SizedBox(height: 16),
              ],
              if (lowStock.isNotEmpty) ...[
                Text(
                  'Stock Bajo (${lowStock.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ...lowStock
                    .take(5)
                    .map(
                      (p) => ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.warning,
                          color: Colors.orange,
                          size: 20,
                        ),
                        title: Text(p.nombre),
                        subtitle: Text('Stock: ${p.stock}'),
                      ),
                    ),
                if (lowStock.length > 5)
                  Text('... y ${lowStock.length - 5} más'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
