import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/product/product_controller.dart';
import 'package:compaexpress/services/proveedor/proveedor_service.dart';
import 'package:compaexpress/utils/barcode_listener_wrapper.dart';
import 'package:compaexpress/utils/get_image_for_bucker.dart';
import 'package:compaexpress/widget/ui/barcode_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:uuid/uuid.dart';

class AdminViewInventoryDetailsScreen extends StatefulWidget {
  final Producto product;
  final String negocioID;

  const AdminViewInventoryDetailsScreen({
    super.key,
    required this.product,
    required this.negocioID,
  });

  @override
  _AdminViewInventoryDetailsScreenState createState() =>
      _AdminViewInventoryDetailsScreenState();
}

class _AdminViewInventoryDetailsScreenState
    extends State<AdminViewInventoryDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _tipoController = TextEditingController();
  final _barCodeController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _stockController = TextEditingController();
  List<Map<String, TextEditingController>> _preciosControllers = [];
  List<String> _signedImageUrls = [];
  List<Categoria> _categories = [];
  List<Proveedor> _proveedores = [];
  List<ProductoPrecios> _productoPrecios = [];
  String? _selectedCategoryId;
  String? _selectedProveedorId;
  String? _selectedEstado;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isLoadingImages = true;
  bool _isFavorite = false;

  List<File> _imagenesSeleccionadas = [];
  final ImagePicker _picker = ImagePicker();

  // Eliminados colores hardcodeados - ahora usan el tema

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadProductData();
  }

  void _loadProductData() {
    _nombreController.text = widget.product.nombre;
    _precioCompraController.text = widget.product.precioCompra.toString();
    _tipoController.text = widget.product.tipo;
    _descripcionController.text = widget.product.descripcion;
    _stockController.text = widget.product.stock.toString();
    _selectedEstado = widget.product.estado ?? 'activo';
    _barCodeController.text = widget.product.barCode;
    _selectedCategoryId = widget.product.categoriaID;
    _selectedProveedorId = widget.product.proveedorID;
    _isFavorite = widget.product.favorito;
  }

  Future<void> _initializeData() async {
    await _getCategorias();
    await _cargarProveedores();
    await _getProductoPrecios();
    setState(() {
      _isLoadingImages = true;
    });
    if (widget.product.productoImages != null &&
        widget.product.productoImages!.isNotEmpty) {
      final s3Keys = widget.product.productoImages!
          .where((image) => !image.startsWith('https://'))
          .toList();
      final urls = await GetImageFromBucket.getSignedImageUrls(
        s3Keys: s3Keys.isNotEmpty ? s3Keys : widget.product.productoImages!,
        expiresIn: Duration(minutes: 30),
      );
      if (urls.isEmpty && s3Keys.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudieron cargar las imágenes'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      setState(() {
        _signedImageUrls = urls;
        _isLoadingImages = false;
      });
    } else {
      setState(() {
        _isLoadingImages = false;
      });
    }
  }

  Future<void> _getCategorias() async {
    try {
      final request = ModelQueries.list(
        Categoria.classType,
        where: Categoria.NEGOCIOID
            .eq(widget.product.negocioID)
            .and(Categoria.ISDELETED.eq(false)),
      );
      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final categories = response.data!.items.whereType<Categoria>().toList();

        final uniqueCategories = <String, Categoria>{};
        for (var category in categories) {
          uniqueCategories[category.id] = category;
        }

        setState(() {
          _categories = uniqueCategories.values.toList();
        });

        if (_selectedCategoryId != null &&
            !_categories.any((cat) => cat.id == _selectedCategoryId)) {
          setState(() {
            _selectedCategoryId = null;
          });
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _cargarProveedores() async {
    try {
      final proveedores = await ProveedorService.getAllProveedores();
      final proveedoresList = proveedores.whereType<Proveedor>().toList();

      final uniqueProveedores = <String, Proveedor>{};
      for (var proveedor in proveedoresList) {
        uniqueProveedores[proveedor.id] = proveedor;
      }

      setState(() {
        _proveedores = uniqueProveedores.values.toList();
      });

      if (_selectedProveedorId != null &&
          !_proveedores.any((prov) => prov.id == _selectedProveedorId)) {
        setState(() {
          _selectedProveedorId = null;
        });
      }
    } catch (e) {
      safePrint('Error cargando los proveedores: $e');
    }
  }

  void _agregarPrecio() {
    setState(() {
      _preciosControllers.add({
        'id': TextEditingController(),
        'nombre': TextEditingController(),
        'precio': TextEditingController(),
        'cantidad': TextEditingController(),
      });
    });
  }

  Future<void> _getProductoPrecios() async {
    try {
      final request = ModelQueries.list(
        ProductoPrecios.classType,
        where: ProductoPrecios.PRODUCTOID
            .eq(widget.product.id)
            .and(ProductoPrecios.ISDELETED.eq(false)),
      );
      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final precios = response.data!.items
            .whereType<ProductoPrecios>()
            .toList();
        setState(() {
          _productoPrecios = precios;
          _preciosControllers = precios.map((precio) {
            return {
              'id': TextEditingController(text: precio.id),
              'nombre': TextEditingController(text: precio.nombre),
              'precio': TextEditingController(text: precio.precio.toString()),
              'cantidad': TextEditingController(
                text: precio.quantity.toString(),
              ),
            };
          }).toList();
          if (_preciosControllers.isEmpty) {
            _agregarPrecio();
          }
        });
      }
    } catch (e) {
      print('Error fetching product prices: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los precios'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _seleccionarImagenes() async {
    try {
      final int remainingSlots =
          5 - (_signedImageUrls.length + _imagenesSeleccionadas.length);
      if (remainingSlots <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No puedes agregar más de 5 imágenes'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final imagenesAUsar = images.take(remainingSlots).toList();
        setState(() {
          _imagenesSeleccionadas = [
            ..._imagenesSeleccionadas,
            ...imagenesAUsar.map((xfile) => File(xfile.path)),
          ];
        });
      }
    } catch (e) {
      safePrint('Error seleccionando imágenes: $e');
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final int remainingSlots =
          5 - (_signedImageUrls.length + _imagenesSeleccionadas.length);
      if (remainingSlots <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No puedes agregar más de 5 imágenes'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagenesSeleccionadas.add(File(image.path));
        });
      }
    } catch (e) {
      safePrint('Error tomando foto: $e');
    }
  }

  Future<void> _eliminarImagen(int index, bool isNetworkImage) async {
    if (isNetworkImage) {
      final imageKey = widget.product.productoImages![index];
      try {
        Amplify.Storage.remove(path: StoragePath.fromString(imageKey));
        safePrint('Imagen eliminada del bucket: $imageKey');
      } catch (e) {
        safePrint('Error eliminando imagen del bucket: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar imagen: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
      setState(() {
        _signedImageUrls.removeAt(index);
        widget.product.productoImages!.removeAt(index);
      });
    } else {
      setState(() {
        _imagenesSeleccionadas.removeAt(index - _signedImageUrls.length);
      });
    }
  }

  Future<List<String>> _subirImagenes() async {
    if (_imagenesSeleccionadas.isEmpty) {
      return [];
    }

    List<String> uploadedKeys = [];
    const uuid = Uuid();

    try {
      for (int i = 0; i < _imagenesSeleccionadas.length; i++) {
        final file = _imagenesSeleccionadas[i];
        final extension = file.path.split('.').last.toLowerCase();
        final keyPath = 'productos/${uuid.v4()}.$extension';

        final uploadResult = await Amplify.Storage.uploadFile(
          localFile: AWSFile.fromPath(file.path),
          path: StoragePath.fromString(keyPath),
          options: const StorageUploadFileOptions(
            metadata: {'tipo': 'producto_imagen'},
          ),
        ).result;

        uploadedKeys.add(uploadResult.uploadedItem.path);
        safePrint('Imagen subida: ${uploadResult.uploadedItem.path}');
      }
    } catch (e) {
      safePrint('Error subiendo imágenes: $e');
      return [];
    }

    return uploadedKeys;
  }

  void _eliminarPrecio(int index) {
    setState(() {
      _preciosControllers[index]['id']!.dispose();
      _preciosControllers[index]['nombre']!.dispose();
      _preciosControllers[index]['precio']!.dispose();
      _preciosControllers[index]['cantidad']!.dispose();
      _preciosControllers.removeAt(index);
    });
  }

  Color _getStockColor(int stock) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (stock == 0) return colorScheme.error;
    if (stock <= 5) return colorScheme.tertiary; // Naranja del tema
    return colorScheme.primary; // Verde del tema
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    final exists = await ProductController.existsByName(_nombreController.text);
    if (exists && _nombreController.text != widget.product.nombre) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Nombre duplicado'),
          content: const Text('Ya existe un producto con ese nombre.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    final existsBarCode = await ProductController.barCodeUsed(
      _barCodeController.text,
    );
    if (existsBarCode && _barCodeController.text != widget.product.barCode) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Código de barra duplicado'),
          content: const Text(
            'Ya existe un producto con ese código de barras.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      // Subir imágenes nuevas
      final uploadedImageKeys = await _subirImagenes();

      debugPrint("IMAGEN SUBIDAS $uploadedImageKeys");
      debugPrint("IMAGENES ACTUALES ${widget.product.productoImages}");
      final uniqueImages = {
        ...(widget.product.productoImages
                ?.where((image) => !image.startsWith('https://'))
                .map((image) => image.toString())
                .toList() ??
            []),
        ...uploadedImageKeys.map((key) => key.toString()),
      }.toList();
      debugPrint("IMAGENES LUEGO $uniqueImages");

      // Actualizar el producto
      final updatedProduct = widget.product.copyWith(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text,
        stock: int.parse(_stockController.text),
        estado: _selectedEstado,
        categoriaID: _selectedCategoryId,
        precioCompra: double.tryParse(_precioCompraController.text),
        proveedorID: _selectedProveedorId,
        barCode: _barCodeController.text.trim(),
        favorito: _isFavorite,
        productoImages: uniqueImages,
        createdAt: widget.product.createdAt,
        updatedAt: TemporalDateTime(DateTime.now()),
      );
      debugPrint('Producto actualizado: $updatedProduct');

      final productRequest = ModelMutations.update(updatedProduct);
      final productResponse = await Amplify.API
          .mutate(request: productRequest)
          .response;
      debugPrint('Producto actualizado: $productResponse');
      if (productResponse.data == null) {
        throw Exception(
          'Error al actualizar el producto: ${productResponse.errors}',
        );
      }

      // Validar precios
      for (var precio in _preciosControllers) {
        if (precio['nombre']!.text.trim().isEmpty ||
            precio['cantidad']!.text.trim().isEmpty ||
            precio['precio']!.text.trim().isEmpty) {
          throw Exception('Todos los campos de precios deben estar completos');
        }
        final valorPrecio = double.tryParse(precio['precio']!.text);
        if (valorPrecio == null || valorPrecio <= 0) {
          throw Exception('Todos los precios deben ser válidos y mayores a 0');
        }
      }

      // Actualizar o crear precios
      for (var precio in _preciosControllers) {
        final precioId = precio['id']!.text;
        final productoPrecio = ProductoPrecios(
          id: precioId.isNotEmpty ? precioId : null,
          nombre: precio['nombre']!.text.trim(),
          precio: double.parse(precio['precio']!.text),
          negocioID: widget.negocioID,
          productoID: widget.product.id,
          isDeleted: false,
          quantity: int.parse(precio['cantidad']!.text),
          createdAt: TemporalDateTime.now(),
          updatedAt: TemporalDateTime.now(),
        );

        debugPrint('Agregando o Actualizando precio: $productoPrecio');

        final precioRequest = precioId.isNotEmpty
            ? ModelMutations.update(productoPrecio)
            : ModelMutations.create(productoPrecio);
        final precioResponse = await Amplify.API
            .mutate(request: precioRequest)
            .response;

        if (precioResponse.data == null) {
          throw Exception(
            'Error al guardar el precio: ${precioResponse.errors}',
          );
        }
      }

      // Eliminar precios que ya no están en la lista
      for (var precioExistente in _productoPrecios) {
        if (!_preciosControllers.any(
          (p) => p['id']!.text == precioExistente.id,
        )) {
          final deleteRequest = ModelMutations.delete(
            precioExistente.copyWith(isDeleted: true),
          );
          final deleteResponse = await Amplify.API
              .mutate(request: deleteRequest)
              .response;
          if (deleteResponse.data == null) {
            throw Exception(
              'Error al eliminar el precio: ${deleteResponse.errors}',
            );
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              SizedBox(width: 8),
              Text('Producto y precios actualizados exitosamente'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      setState(() {
        _isEditing = false;
        _imagenesSeleccionadas.clear();
      });

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Theme.of(context).colorScheme.onError),
              SizedBox(width: 8),
              Expanded(child: Text('Error al actualizar: $e')),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 28,
            ),
            SizedBox(width: 8),
            Text('Confirmar eliminación'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar este producto? Esta acción no se puede deshacer.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.6),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = ModelMutations.delete(widget.product);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.data != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                SizedBox(width: 8),
                Text('Producto eliminado exitosamente'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.of(context).pop(true);
      } else {
        throw Exception('Error al eliminar el producto');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Theme.of(context).colorScheme.onError),
              SizedBox(width: 8),
              Expanded(child: Text('Error al eliminar el producto: $e')),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scanBarcode(BuildContext context) async {
    try {
      final result = await SimpleBarcodeScanner.scanBarcode(
        context,
        barcodeAppBar: const BarcodeAppBar(
          appBarTitle: 'Escanear Código de Barras',
          centerTitle: true,
          enableBackButton: true,
          backButtonIcon: Icon(Icons.arrow_back_ios),
        ),
        isShowFlashIcon: true,
        cameraFace: CameraFace.back,
        cancelButtonText: "Cancelar",
      );
      if (result != null && result != '-1') {
        _barCodeController.text = result;
      }
    } catch (e) {
      safePrint('Error al escanear: $e');
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? suffixText,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: labelText,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: _isEditing
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSurface.withOpacity(0.6),
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: _isEditing
            ? colorScheme.primary
            : colorScheme.onSurface.withOpacity(0.4),
      ),
      suffixText: suffixText,
      suffixStyle: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      filled: true,
      fillColor: _isEditing
          ? theme.scaffoldBackgroundColor
          : colorScheme.surfaceContainerHighest.withOpacity(0.5),
      enabled: _isEditing,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.outline, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 2.5),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.error, width: 2.5),
        borderRadius: BorderRadius.circular(12),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.onSurface.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    IconData? titleIcon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (titleIcon != null) ...[
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      titleIcon,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  void _onBarcodeScanned(String barcode) {
    if (!_isEditing) return;
    setState(() {
      _barCodeController.text = barcode;
    });
    FocusScope.of(context).nextFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BarcodeListenerWrapper(
      onBarcodeScanned: _onBarcodeScanned,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Editar Producto' : 'Detalles del Producto',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimary,
            ),
          ),
          elevation: 0,
          actions: [
            if (!_isEditing) ...[
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: _isFavorite
                      ? colorScheme.tertiary
                      : colorScheme.onPrimary.withOpacity(0.7),
                ),
                onPressed: null,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                icon: Icon(Icons.edit_rounded),
                tooltip: 'Editar',
              ),
              IconButton(
                onPressed: _deleteProduct,
                icon: Icon(Icons.delete_rounded),
                tooltip: 'Eliminar',
              ),
            ] else ...[
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _loadProductData();
                    _getProductoPrecios();
                  });
                },
                icon: Icon(Icons.close_rounded),
                tooltip: 'Cancelar',
              ),
              IconButton(
                onPressed: _updateProduct,
                icon: Icon(Icons.save_rounded),
                tooltip: 'Guardar',
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
                icon: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite
                      ? colorScheme.tertiary
                      : colorScheme.onPrimary,
                ),
                tooltip: "Favorito",
              ),
            ],
          ],
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Procesando...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card para imágenes e información general
                      _buildSectionCard(
                        title: 'Información General',
                        titleIcon: Icons.info_outline_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Imágenes del Producto',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),

                            // Botones para agregar imágenes
                            if (_isEditing)
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isLoading || _isLoadingImages
                                          ? null
                                          : _seleccionarImagenes,
                                      icon: const Icon(Icons.photo_library),
                                      label: const Text('Galería'),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isLoading || _isLoadingImages
                                          ? null
                                          : _tomarFoto,
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text('Cámara'),
                                    ),
                                  ),
                                ],
                              ),

                            SizedBox(height: 12),

                            // Indicador de carga
                            if (_isLoadingImages)
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest.withOpacity(
                                    0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary,
                                    ),
                                  ),
                                ),
                              )
                            // Vista previa de imágenes
                            else if (_signedImageUrls.isNotEmpty ||
                                _imagenesSeleccionadas.isNotEmpty)
                              Container(
                                height: 220,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        _signedImageUrls.length +
                                        _imagenesSeleccionadas.length,
                                    itemBuilder: (context, index) {
                                      bool isNetworkImage =
                                          index < _signedImageUrls.length;
                                      return Container(
                                        margin: const EdgeInsets.all(8),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: isNetworkImage
                                                  ? buildCachedImage(
                                                      _signedImageUrls[index],
                                                      colorScheme: colorScheme,
                                                    )
                                                  : Image.file(
                                                      _imagenesSeleccionadas[index -
                                                          _signedImageUrls
                                                              .length],
                                                      width: 200,
                                                      height: 200,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                            if (_isEditing)
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: GestureDetector(
                                                  onTap: () => _eliminarImagen(
                                                    index,
                                                    isNetworkImage,
                                                  ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: colorScheme.error,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.close,
                                                      color:
                                                          colorScheme.onError,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest.withOpacity(
                                    0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_rounded,
                                      color: colorScheme.primary,
                                      size: 48,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Sin imágenes disponibles\n(Máximo 5 imágenes)',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                            // Indicador de stock (visible solo en modo no edición)
                            if (!_isEditing)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStockColor(
                                      widget.product.stock,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _getStockColor(
                                        widget.product.stock,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inventory_2_rounded,
                                        color: _getStockColor(
                                          widget.product.stock,
                                        ),
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Stock: ${widget.product.stock}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: _getStockColor(
                                                widget.product.stock,
                                              ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (!_isEditing) SizedBox(height: 20),
                            // Campo nombre
                            TextFormField(
                              controller: _nombreController,
                              decoration: _buildInputDecoration(
                                labelText: 'Nombre del producto',
                                prefixIcon: Icons.label_rounded,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El nombre es requerido';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            // Campo descripción
                            TextFormField(
                              controller: _descripcionController,
                              decoration: _buildInputDecoration(
                                labelText: 'Descripción',
                                prefixIcon: Icons.description_rounded,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'La descripción es requerida';
                                }
                                return null;
                              },
                              maxLines: 3,
                            ),
                            SizedBox(height: 16),
                            // Campo código de barras
                            BarcodeTextField(
                              controller: _barCodeController,
                              onManualScan: () => _scanBarcode(context),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El código de barras es obligatorio';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _precioCompraController,
                              decoration: _buildInputDecoration(
                                labelText: 'Precio de compra',
                                prefixIcon: Icons.attach_money,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El precio es requerido';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _tipoController,
                              decoration: _buildInputDecoration(
                                labelText: 'Tipo',
                                prefixIcon: Icons.type_specimen,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El tipo es requerido';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      // Card de precios y stock
                      _buildSectionCard(
                        title: 'Precios y Stock',
                        titleIcon: Icons.attach_money_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lista de precios
                            if (_isEditing)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  bool isSmallScreen =
                                      constraints.maxWidth < 600;

                                  return Column(
                                    children: [
                                      ..._preciosControllers.asMap().entries.map((
                                        entry,
                                      ) {
                                        int index = entry.key;
                                        var controllers = entry.value;
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: colorScheme.surfaceContainerHighest
                                                .withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: colorScheme.outline
                                                  .withOpacity(0.3),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colorScheme.shadow
                                                    .withOpacity(0.1),
                                                spreadRadius: 1,
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: isSmallScreen
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Campo Nombre
                                                    TextFormField(
                                                      controller:
                                                          controllers['nombre'],
                                                      decoration:
                                                          _buildInputDecoration(
                                                            labelText:
                                                                'Nombre del Precio',
                                                            prefixIcon: Icons
                                                                .label_rounded,
                                                          ),
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value
                                                                .trim()
                                                                .isEmpty) {
                                                          return 'El nombre es obligatorio';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    const SizedBox(height: 12),
                                                    // Campo Cantidad
                                                    TextFormField(
                                                      controller:
                                                          controllers['cantidad'],
                                                      decoration:
                                                          _buildInputDecoration(
                                                            labelText:
                                                                'Cantidad',
                                                            prefixIcon:
                                                                Icons.add_box,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value
                                                                .trim()
                                                                .isEmpty) {
                                                          return 'La cantidad es obligatoria';
                                                        }
                                                        final cantidad =
                                                            double.tryParse(
                                                              value,
                                                            );
                                                        if (cantidad == null) {
                                                          return 'Ingresa una cantidad válida';
                                                        }
                                                        if (cantidad <= 0) {
                                                          return 'La cantidad debe ser mayor a 0';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    const SizedBox(height: 12),
                                                    // Campo Precio
                                                    TextFormField(
                                                      controller:
                                                          controllers['precio'],
                                                      decoration:
                                                          _buildInputDecoration(
                                                            labelText: 'Precio',
                                                            prefixIcon: Icons
                                                                .attach_money_rounded,
                                                            suffixText: 'USD',
                                                          ),
                                                      keyboardType:
                                                          const TextInputType.numberWithOptions(
                                                            decimal: true,
                                                          ),
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value
                                                                .trim()
                                                                .isEmpty) {
                                                          return 'El precio es obligatorio';
                                                        }
                                                        final precio =
                                                            double.tryParse(
                                                              value,
                                                            );
                                                        if (precio == null) {
                                                          return 'Ingresa un precio válido';
                                                        }
                                                        if (precio <= 0) {
                                                          return 'El precio debe ser mayor a 0';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    const SizedBox(height: 12),
                                                    // Botón Eliminar
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: colorScheme
                                                              .error
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: IconButton(
                                                          onPressed:
                                                              _preciosControllers
                                                                      .length >
                                                                  1
                                                              ? () =>
                                                                    _eliminarPrecio(
                                                                      index,
                                                                    )
                                                              : null,
                                                          icon: Icon(
                                                            Icons
                                                                .delete_rounded,
                                                            color: colorScheme
                                                                .error,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    // Campo Nombre
                                                    Expanded(
                                                      flex: 2,
                                                      child: TextFormField(
                                                        controller:
                                                            controllers['nombre'],
                                                        decoration:
                                                            _buildInputDecoration(
                                                              labelText:
                                                                  'Nombre del Precio',
                                                              prefixIcon: Icons
                                                                  .label_rounded,
                                                            ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value
                                                                  .trim()
                                                                  .isEmpty) {
                                                            return 'El nombre es obligatorio';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    // Campo Cantidad
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            controllers['cantidad'],
                                                        decoration:
                                                            _buildInputDecoration(
                                                              labelText:
                                                                  'Cantidad',
                                                              prefixIcon:
                                                                  Icons.add_box,
                                                            ),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value
                                                                  .trim()
                                                                  .isEmpty) {
                                                            return 'La cantidad es obligatoria';
                                                          }
                                                          final cantidad =
                                                              double.tryParse(
                                                                value,
                                                              );
                                                          if (cantidad ==
                                                              null) {
                                                            return 'Ingresa una cantidad válida';
                                                          }
                                                          if (cantidad <= 0) {
                                                            return 'La cantidad debe ser mayor a 0';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    // Campo Precio
                                                    Expanded(
                                                      flex: 2,
                                                      child: TextFormField(
                                                        controller:
                                                            controllers['precio'],
                                                        decoration:
                                                            _buildInputDecoration(
                                                              labelText:
                                                                  'Precio',
                                                              prefixIcon: Icons
                                                                  .attach_money_rounded,
                                                              suffixText: 'USD',
                                                            ),
                                                        keyboardType:
                                                            const TextInputType.numberWithOptions(
                                                              decimal: true,
                                                            ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value
                                                                  .trim()
                                                                  .isEmpty) {
                                                            return 'El precio es obligatorio';
                                                          }
                                                          final precio =
                                                              double.tryParse(
                                                                value,
                                                              );
                                                          if (precio == null) {
                                                            return 'Ingresa un precio válido';
                                                          }
                                                          if (precio <= 0) {
                                                            return 'El precio debe ser mayor a 0';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // Botón Eliminar
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: colorScheme.error
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: IconButton(
                                                        onPressed:
                                                            _preciosControllers
                                                                    .length >
                                                                1
                                                            ? () =>
                                                                  _eliminarPrecio(
                                                                    index,
                                                                  )
                                                            : null,
                                                        icon: Icon(
                                                          Icons.delete_rounded,
                                                          color:
                                                              colorScheme.error,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        );
                                      }),
                                      SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: _agregarPrecio,
                                          icon: const Icon(
                                            Icons.add_rounded,
                                            size: 20,
                                          ),
                                          label: const Text(
                                            'Agregar otro precio',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              )
                            else
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest.withOpacity(
                                    0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _productoPrecios.isNotEmpty
                                      ? _productoPrecios.map((precio) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: colorScheme.surface,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: colorScheme.shadow
                                                      .withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: colorScheme.outline
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Nombre con ícono
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.price_change,
                                                        color:
                                                            colorScheme.primary,
                                                        size: 22,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Text(
                                                          precio.nombre,
                                                          style: theme
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: colorScheme
                                                                    .onSurface,
                                                              ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Precio y cantidad
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            colorScheme.primary,
                                                            colorScheme
                                                                .primaryContainer,
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        "P: \$${precio.precio.toStringAsFixed(2)}",
                                                        style: theme
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: colorScheme
                                                                  .onPrimary,
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            colorScheme.primary,
                                                            colorScheme
                                                                .primaryContainer,
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        "C: ${precio.quantity}",
                                                        style: theme
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: colorScheme
                                                                  .onPrimary,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList()
                                      : [
                                          Center(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.price_change_outlined,
                                                  color: colorScheme.primary,
                                                  size: 32,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Sin precios disponibles',
                                                  style: theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        color: colorScheme
                                                            .onSurface,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                ),
                              ),
                            SizedBox(height: 20),
                            // Campo stock
                            TextFormField(
                              controller: _stockController,
                              decoration: _buildInputDecoration(
                                labelText: 'Stock',
                                prefixIcon: Icons.inventory_2_rounded,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El stock es requerido';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Ingresa un stock válido';
                                }
                                if (int.parse(value) < 0) {
                                  return 'El stock no puede ser negativo';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      // Card de clasificación
                      _buildSectionCard(
                        title: 'Clasificación',
                        titleIcon: Icons.category_rounded,
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedCategoryId,
                              decoration: _buildInputDecoration(
                                labelText: 'Categoría',
                                prefixIcon: Icons.category_rounded,
                              ),
                              items: _categories.map((categoria) {
                                return DropdownMenuItem<String>(
                                  value: categoria.id,
                                  child: Text(
                                    categoria.nombre,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: _isEditing
                                  ? (value) {
                                      setState(() {
                                        _selectedCategoryId = value;
                                      });
                                    }
                                  : null,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor selecciona una categoría';
                                }
                                if (!_categories.any(
                                  (cat) => cat.id == value,
                                )) {
                                  return 'Categoría no válida';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedProveedorId,
                              decoration: _buildInputDecoration(
                                labelText: 'Proveedor',
                                prefixIcon: Icons.car_rental,
                              ),
                              items: _proveedores.map((proveedor) {
                                return DropdownMenuItem<String>(
                                  value: proveedor.id,
                                  child: Text(
                                    proveedor.nombre,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: _isEditing
                                  ? (value) {
                                      setState(() {
                                        _selectedProveedorId = value;
                                      });
                                    }
                                  : null,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor selecciona un proveedor';
                                }
                                if (!_proveedores.any(
                                  (prov) => prov.id == value,
                                )) {
                                  return 'Proveedor no válido';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedEstado,
                              decoration: _buildInputDecoration(
                                labelText: 'Estado',
                                prefixIcon: Icons.toggle_on_rounded,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'activo',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: colorScheme.primary,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Activo'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'inactivo',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.cancel_rounded,
                                        color: colorScheme.error,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Inactivo'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: _isEditing
                                  ? (value) {
                                      setState(() {
                                        _selectedEstado = value;
                                      });
                                    }
                                  : null,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor selecciona un estado';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      // Botón de guardar cambios (visible en modo edición)
                      if (_isEditing) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _updateProduct,
                            icon: const Icon(Icons.save_rounded),
                            label: Text(
                              'Guardar Cambios',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget buildCachedImage(String imageUrl, {required ColorScheme colorScheme}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_rounded,
              color: colorScheme.primary,
              size: 40,
            ),
            SizedBox(height: 8),
            Text(
              'Error al cargar',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _stockController.dispose();
    _barCodeController.dispose();
    for (var precio in _preciosControllers) {
      precio['id']!.dispose();
      precio['nombre']!.dispose();
      precio['precio']!.dispose();
    }
    super.dispose();
  }
}
