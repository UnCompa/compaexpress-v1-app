import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:compaexpress/entities/invoice_item_data.dart';
import 'package:compaexpress/entities/order_item_data.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/utils/get_image_for_bucker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Singleton para manejar el cache de imágenes
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  static const String _cacheKey = 'product_images_cache';
  static const Duration _cacheExpiration = Duration(hours: 24);

  Map<String, String> _memoryCache = {};
  Map<String, DateTime> _cacheTimestamps = {};

  // Obtener URLs desde cache o cargar nuevas
  Future<Map<String, String>> getImageUrls(List<String> imageKeys) async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar cache persistente si está vacío el cache en memoria
    if (_memoryCache.isEmpty) {
      await _loadFromPersistentCache(prefs);
    }

    // Filtrar claves que necesitan ser actualizadas
    List<String> keysToLoad = [];
    Map<String, String> result = {};

    for (String key in imageKeys) {
      if (_memoryCache.containsKey(key) && !_isCacheExpired(key)) {
        result[key] = _memoryCache[key]!;
      } else {
        keysToLoad.add(key);
      }
    }

    // Cargar solo las imágenes que no están en cache o están expiradas
    if (keysToLoad.isNotEmpty) {
      try {
        List<String> newUrls = await GetImageFromBucket.getSignedImageUrls(
          s3Keys: keysToLoad,
        );

        // Actualizar cache con nuevas URLs
        for (int i = 0; i < keysToLoad.length && i < newUrls.length; i++) {
          _memoryCache[keysToLoad[i]] = newUrls[i];
          _cacheTimestamps[keysToLoad[i]] = DateTime.now();
          result[keysToLoad[i]] = newUrls[i];
        }

        // Guardar en cache persistente
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

  // Limpiar cache expirado
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

  // Precarga de imágenes en lotes
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

      // Pequeña pausa para no sobrecargar
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

class _ProductQuickSelectorState extends State<ProductQuickSelector> {
  final ImageCacheManager _cacheManager = ImageCacheManager();
  final Map<String, String> _productImages = {};
  bool _loadingImages = false;
  final TextEditingController _searchController = TextEditingController();
  List<Producto> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.productos;
    _loadProductImages();

    // Limpiar cache expirado al inicializar
    _cacheManager.cleanExpiredCache();
  }

  Future<void> _loadProductImages() async {
    setState(() {
      _loadingImages = true;
    });

    try {
      // Obtener todas las claves de imagen disponibles
      List<String> visibleImageKeys = _getVisibleProductImageKeys();
      List<String> allImageKeys = _getAllProductImageKeys();

      // Cargar primero las imágenes visibles
      if (visibleImageKeys.isNotEmpty) {
        Map<String, String> visibleImages = await _cacheManager.getImageUrls(
          visibleImageKeys,
        );
        setState(() {
          _productImages.addAll(visibleImages);
        });
      }

      // Precargar el resto de imágenes en segundo plano
      List<String> remainingKeys = allImageKeys
          .where((key) => !visibleImageKeys.contains(key))
          .toList();

      if (remainingKeys.isNotEmpty) {
        _preloadRemainingImages(remainingKeys);
      }
    } catch (e) {
      print('Error cargando imágenes: $e');
    } finally {
      setState(() {
        _loadingImages = false;
      });
    }
  }

  // Obtener claves de imágenes para productos visibles (primeros en la lista)
  List<String> _getVisibleProductImageKeys() {
    const int visibleCount = 12; // Aproximadamente lo que se ve en pantalla

    return _filteredProducts
        .take(visibleCount)
        .where((p) => p.productoImages != null && p.productoImages!.isNotEmpty)
        .map((p) => p.productoImages!.first)
        .toList();
  }

  // Obtener todas las claves de imagen
  List<String> _getAllProductImageKeys() {
    return widget.productos
        .where((p) => p.productoImages != null && p.productoImages!.isNotEmpty)
        .map((p) => p.productoImages!.first)
        .toList();
  }

  // Precargar imágenes restantes en segundo plano
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

    // Cargar imágenes de productos filtrados si es necesario
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
          backgroundColor: Colors.orange,
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
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 200).floor().clamp(2, 6);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selector Rápido',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    if (_loadingImages)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    const SizedBox(width: 8),
                    const Icon(Icons.flash_on, color: Colors.amber),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Buscador
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterProducts,
            ),
            const SizedBox(height: 16),

            // Grid de productos
            _filteredProducts.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No se encontraron productos',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: 300,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final producto = _filteredProducts[index];
                        final imageKey = producto.productoImages?.first;
                        final imageUrl = imageKey != null
                            ? _productImages[imageKey]
                            : null;

                        return _buildProductCard(producto, imageUrl);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Producto producto, String? imageUrl) {
    final hasStock = producto.stock > 0;
    final precios = widget.productoPrecios[producto.id] ?? [];
    final hasPrice = precios.isNotEmpty;

    return InkWell(
      onTap: hasStock && hasPrice ? () => _selectProduct(producto) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: hasStock && hasPrice ? Colors.grey[300]! : Colors.red[200]!,
          ),
          borderRadius: BorderRadius.circular(8),
          color: hasStock && hasPrice ? Colors.white : Colors.grey[100],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del producto con hero animation para mejor UX
            Hero(
              tag: 'product_${producto.id}',
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  color: Colors.grey[200],
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 200),
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image_not_supported,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : const Icon(Icons.image, size: 30, color: Colors.grey),
              ),
            ),

            // Información del producto
            Container(
              height: 80,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    producto.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: hasStock && hasPrice ? Colors.black : Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hasStock ? Icons.check_circle : Icons.cancel,
                            color: hasStock ? Colors.green : Colors.red,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Stock: ${producto.stock}',
                            style: TextStyle(
                              fontSize: 12,
                              color: hasStock
                                  ? Colors.green[800]
                                  : Colors.red[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      if (hasPrice)
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: Colors.blue[700],
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '\$${precios.first.precio.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      if (!hasPrice)
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Sin precio',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Indicador de disponibilidad
            if (!hasStock || !hasPrice)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    !hasStock ? 'Sin stock' : 'Sin precio',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
