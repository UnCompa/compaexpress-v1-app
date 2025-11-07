import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:compaexpress/entities/invoice_item_data.dart';
import 'package:compaexpress/entities/order_item_data.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/utils/get_image_for_bucker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Singleton para manejar el cache de imágenes
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  static const String _cacheKey = 'product_images_cache';
  static const Duration _cacheExpiration = Duration(hours: 24);

  Map<String, String> _memoryCache = {};
  Map<String, DateTime> _cacheTimestamps = {};

  Future<Map<String, String>> getImageUrls(List<String> imageKeys) async {
    final prefs = await SharedPreferences.getInstance();

    if (_memoryCache.isEmpty) {
      await _loadFromPersistentCache(prefs);
    }

    List<String> keysToLoad = [];
    Map<String, String> result = {};

    for (String key in imageKeys) {
      if (_memoryCache.containsKey(key) && !_isCacheExpired(key)) {
        result[key] = _memoryCache[key]!;
      } else {
        keysToLoad.add(key);
      }
    }

    if (keysToLoad.isNotEmpty) {
      try {
        List<String> newUrls = await GetImageFromBucket.getSignedImageUrls(
          s3Keys: keysToLoad,
        );

        for (int i = 0; i < keysToLoad.length && i < newUrls.length; i++) {
          _memoryCache[keysToLoad[i]] = newUrls[i];
          _cacheTimestamps[keysToLoad[i]] = DateTime.now();
          result[keysToLoad[i]] = newUrls[i];
        }

        await _saveToPersistentCache(prefs);
      } catch (e) {
        print('Error cargando nuevas imágenes: $e');
      }
    }

    return result;
  }

  bool _isCacheExpired(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > _cacheExpiration;
  }

  Future<void> _loadFromPersistentCache(SharedPreferences prefs) async {
    try {
      final cacheData = prefs.getString(_cacheKey);
      final timestampsData = prefs.getString('${_cacheKey}_timestamps');

      if (cacheData != null && timestampsData != null) {
        final Map<String, dynamic> cache = json.decode(cacheData);
        final Map<String, dynamic> timestamps = json.decode(timestampsData);

        _memoryCache = Map<String, String>.from(cache);
        _cacheTimestamps = timestamps.map(
          (key, value) => MapEntry(key, DateTime.parse(value as String)),
        );
      }
    } catch (e) {
      print('Error cargando cache persistente: $e');
      _memoryCache.clear();
      _cacheTimestamps.clear();
    }
  }

  Future<void> _saveToPersistentCache(SharedPreferences prefs) async {
    try {
      final timestampsJson = _cacheTimestamps.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      );

      await prefs.setString(_cacheKey, json.encode(_memoryCache));
      await prefs.setString(
        '${_cacheKey}_timestamps',
        json.encode(timestampsJson),
      );
    } catch (e) {
      print('Error guardando cache persistente: $e');
    }
  }

  Future<void> cleanExpiredCache() async {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) > _cacheExpiration)
        .map((entry) => entry.key)
        .toList();

    for (String key in expiredKeys) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await _saveToPersistentCache(prefs);
    }
  }

  Future<void> preloadImages(
    List<String> imageKeys, {
    int batchSize = 10,
  }) async {
    for (int i = 0; i < imageKeys.length; i += batchSize) {
      final end = (i + batchSize < imageKeys.length)
          ? i + batchSize
          : imageKeys.length;
      final batch = imageKeys.sublist(i, end);
      await getImageUrls(batch);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}

class ProductQuickSelector extends StatefulWidget {
  final List<Producto> productos;
  final Map<String, List<ProductoPrecios>> productoPrecios;
  final Function(InvoiceItemData invoiceItem, OrderItemData orderItem)
  onProductSelected;

  const ProductQuickSelector({
    super.key,
    required this.productos,
    required this.productoPrecios,
    required this.onProductSelected,
  });

  @override
  State<ProductQuickSelector> createState() => _ProductQuickSelectorState();
}

class _ProductQuickSelectorState extends State<ProductQuickSelector>
    with SingleTickerProviderStateMixin {
  final ImageCacheManager _cacheManager = ImageCacheManager();
  final Map<String, String> _productImages = {};
  bool _loadingImages = false;
  final TextEditingController _searchController = TextEditingController();
  List<Producto> _filteredProducts = [];
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.productos;

    // Configurar animación de expansión/colapso
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    _cacheManager.cleanExpiredCache();
    _loadProductImages();
  }

  Future<void> _loadProductImages() async {
    setState(() {
      _loadingImages = true;
    });

    try {
      List<String> visibleImageKeys = _getVisibleProductImageKeys();
      List<String> allImageKeys = _getAllProductImageKeys();

      if (visibleImageKeys.isNotEmpty) {
        Map<String, String> visibleImages = await _cacheManager.getImageUrls(
          visibleImageKeys,
        );
        if (mounted) {
          setState(() {
            _productImages.addAll(visibleImages);
          });
        }
      }

      List<String> remainingKeys = allImageKeys
          .where((key) => !visibleImageKeys.contains(key))
          .toList();

      if (remainingKeys.isNotEmpty) {
        _preloadRemainingImages(remainingKeys);
      }
    } catch (e) {
      print('Error cargando imágenes: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loadingImages = false;
        });
      }
    }
  }

  List<String> _getVisibleProductImageKeys() {
    const int visibleCount = 12;

    return _filteredProducts
        .take(visibleCount)
        .where((p) => p.productoImages != null && p.productoImages!.isNotEmpty)
        .map((p) => p.productoImages!.first)
        .toList();
  }

  List<String> _getAllProductImageKeys() {
    return widget.productos
        .where((p) => p.productoImages != null && p.productoImages!.isNotEmpty)
        .map((p) => p.productoImages!.first)
        .toList();
  }

  Future<void> _preloadRemainingImages(List<String> imageKeys) async {
    try {
      Map<String, String> remainingImages = await _cacheManager.getImageUrls(
        imageKeys,
      );
      if (mounted) {
        setState(() {
          _productImages.addAll(remainingImages);
        });
      }
    } catch (e) {
      print('Error precargando imágenes restantes: $e');
    }
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = widget.productos;
      } else {
        _filteredProducts = widget.productos
            .where(
              (producto) =>
                  producto.nombre.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });

    _loadFilteredProductImages();
  }

  Future<void> _loadFilteredProductImages() async {
    List<String> filteredImageKeys = _filteredProducts
        .where((p) => p.productoImages != null && p.productoImages!.isNotEmpty)
        .map((p) => p.productoImages!.first)
        .where((key) => !_productImages.containsKey(key))
        .toList();

    if (filteredImageKeys.isNotEmpty) {
      try {
        Map<String, String> filteredImages = await _cacheManager.getImageUrls(
          filteredImageKeys,
        );
        if (mounted) {
          setState(() {
            _productImages.addAll(filteredImages);
          });
        }
      } catch (e) {
        print('Error cargando imágenes filtradas: $e');
      }
    }
  }

  void _selectProduct(Producto producto) {
    final precios = widget.productoPrecios[producto.id] ?? [];
    final precioSeleccionado = precios.isNotEmpty ? precios.first : null;

    if (precioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay precios configurados para ${producto.nombre}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final invoiceItem = InvoiceItemData(
      producto: producto,
      precio: precioSeleccionado,
      quantity: 1,
      tax: 0,
    );
    final orderItem = OrderItemData(
      producto: producto,
      precio: precioSeleccionado,
      quantity: 1,
      tax: 0,
    );

    widget.onProductSelected(invoiceItem, orderItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.nombre} agregado correctamente'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 200).floor().clamp(2, 6);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header colapsable
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flash_on,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Selector Rápido de Productos',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_loadingImages)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Contenido expandible
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buscador
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 400),
                    child: SlideAnimation(
                      verticalOffset: 20,
                      child: FadeInAnimation(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Buscar producto...',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: colorScheme.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                          ),
                          onChanged: _filterProducts,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid de productos
                  _filteredProducts.isEmpty
                      ? AnimationConfiguration.synchronized(
                          duration: const Duration(milliseconds: 400),
                          child: FadeInAnimation(
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: colorScheme.outline,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No se encontraron productos',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 400,
                          child: AnimationLimiter(
                            child: MasonryGridView.count(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final producto = _filteredProducts[index];
                                final imageKey = producto.productoImages?.first;
                                final imageUrl = imageKey != null
                                    ? _productImages[imageKey]
                                    : null;

                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration: const Duration(milliseconds: 500),
                                  columnCount: crossAxisCount,
                                  child: ScaleAnimation(
                                    child: FadeInAnimation(
                                      child: _buildProductCard(
                                        producto,
                                        imageUrl,
                                        theme,
                                        colorScheme,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    Producto producto,
    String? imageUrl,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final hasStock = producto.stock > 0;
    final precios = widget.productoPrecios[producto.id] ?? [];
    final hasPrice = precios.isNotEmpty;
    final isAvailable = hasStock && hasPrice;

    return Material(
      elevation: isAvailable ? 2 : 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isAvailable ? () => _selectProduct(producto) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isAvailable
                  ? colorScheme.outline.withOpacity(0.3)
                  : colorScheme.error.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isAvailable
                ? colorScheme.surface
                : colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen del producto
              Hero(
                tag: 'product_${producto.id}',
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 300),
                            placeholder: (context, url) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_not_supported,
                              size: 32,
                              color: colorScheme.outline,
                            ),
                          ),
                        )
                      : Icon(Icons.image, size: 32, color: colorScheme.outline),
                ),
              ),

              // Información del producto
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isAvailable
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Stock
                    Row(
                      children: [
                        Icon(
                          hasStock ? Icons.check_circle : Icons.cancel,
                          color: hasStock
                              ? colorScheme.primary
                              : colorScheme.error,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stock: ${producto.stock}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: hasStock
                                ? colorScheme.primary
                                : colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Precio
                    if (hasPrice)
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: colorScheme.secondary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${precios.first.precio.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    if (!hasPrice)
                      Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: colorScheme.error,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sin precio',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Badge de estado
              if (!isAvailable)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      !hasStock ? 'Sin stock' : 'Sin precio',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _expandController.dispose();
    super.dispose();
  }
}
