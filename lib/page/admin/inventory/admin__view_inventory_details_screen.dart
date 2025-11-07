import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/product/product_controller.dart';
import 'package:compaexpress/services/proveedor/proveedor_service.dart';
import 'package:compaexpress/utils/get_image_for_bucker.dart';
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

  // Paleta de colores azules
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color secondaryBlue = Color(0xFF42A5F5);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkBlue = Color(0xFF0D47A1);
  //static const Color accentBlue = Color(0xFF2196F3);
  static const Color backgroundBlue = Color(0xFFF8FBFF);

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
      // Filtrar solo claves relativas
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
            backgroundColor: Colors.red[600],
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

        // Filtrar categorías duplicadas por ID
        final uniqueCategories = <String, Categoria>{};
        for (var category in categories) {
          uniqueCategories[category.id] = category;
        }

        setState(() {
          _categories = uniqueCategories.values.toList();
        });

        // Validar que el valor seleccionado existe en las categorías
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
        'cantidad':
            TextEditingController(), // Agregar controlador para cantidad
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
              ), // Agregar cantidad
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
          backgroundColor: Colors.red[600],
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
            backgroundColor: Colors.red[600],
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
            backgroundColor: Colors.red[600],
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
            backgroundColor: Colors.red[600],
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
    if (stock == 0) return Colors.red[600]!;
    if (stock <= 5) return Colors.orange[600]!;
    return Colors.green[600]!;
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
      return; // evita continuar
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
      return; // evita continuar
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
                .map((image) => image.toString()) // Convertir a String
                .toList() ??
            []),
        ...uploadedImageKeys.map((key) => key.toString()), // Convertir a String
      }.toList(); // Convertir a List<String>
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
        productoImages: uniqueImages, // Asegúrate de pasar solo imágenes únicas
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
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Producto y precios actualizados exitosamente'),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      setState(() {
        _isEditing = false;
        _imagenesSeleccionadas.clear();
        //widget.product.productoImages = uniqueImages;
      });

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Error al actualizar: $e')),
            ],
          ),
          backgroundColor: Colors.red[600],
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
            Icon(Icons.warning_amber_rounded, color: Colors.red[600], size: 28),
            SizedBox(width: 8),
            Text('Confirmar eliminación'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar este producto? Esta acción no se puede deshacer.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
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
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Producto eliminado exitosamente'),
              ],
            ),
            backgroundColor: Colors.green[600],
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
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Error al eliminar el producto: $e')),
            ],
          ),
          backgroundColor: Colors.red[600],
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
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: primaryBlue),
      prefixIcon: Icon(prefixIcon, color: primaryBlue),
      suffixText: suffixText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryBlue, width: 2.5),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red[600]!, width: 2.5),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: _isEditing ? Colors.white : lightBlue.withOpacity(0.3),
      enabled: _isEditing,
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    IconData? titleIcon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, lightBlue.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: lightBlue.withOpacity(0.3), width: 1),
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
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(titleIcon, color: primaryBlue, size: 20),
                  ),
                  SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Producto' : 'Detalles del Producto',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryBlue, secondaryBlue],
            ),
          ),
        ),
        actions: [
          if (!_isEditing) ...[
            Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Icon(
                Icons.star,
                color: _isFavorite ? Colors.yellow : Colors.grey[50],
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                icon: Icon(Icons.edit_rounded),
                tooltip: 'Editar',
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: _deleteProduct,
                icon: Icon(Icons.delete_rounded, color: Colors.red[300]),
                tooltip: 'Eliminar',
              ),
            ),
          ] else ...[
            Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
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
            ),
            Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: _updateProduct,
                icon: Icon(Icons.save_rounded, color: Colors.green[300]),
                tooltip: 'Guardar',
              ),
            ),
            if (_isFavorite) ...[
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _isFavorite = false;
                    });
                  },
                  icon: Icon(Icons.star, color: Colors.yellow[700]),
                  tooltip: "Favorito",
                ),
              ),
            ] else
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _isFavorite = true;
                    });
                  },
                  icon: Icon(Icons.star, color: Colors.grey[100]),
                  tooltip: "Favorito",
                ),
              ),
          ],
        ],
      ),
      body: _isLoading
          ? Container(
              color: backgroundBlue,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Procesando...',
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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
                          const Text(
                            'Imágenes del Producto',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

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
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading || _isLoadingImages
                                        ? null
                                        : _tomarFoto,
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('Cámara'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 12),

                          // Indicador de carga
                          if (_isLoadingImages)
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: lightBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryBlue,
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
                                  color: lightBlue.withOpacity(0.3),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: isNetworkImage
                                                ? buildCachedImage(
                                                    _signedImageUrls[index],
                                                    primaryBlue: primaryBlue,
                                                    lightBlue: lightBlue,
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
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
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
                                color: lightBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: lightBlue.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_rounded,
                                    color: primaryBlue,
                                    size: 48,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Sin imágenes disponibles\n(Máximo 5 imágenes)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
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
                                  gradient: LinearGradient(
                                    colors: [
                                      _getStockColor(
                                        widget.product.stock,
                                      ).withOpacity(0.1),
                                      _getStockColor(
                                        widget.product.stock,
                                      ).withOpacity(0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStockColor(widget.product.stock),
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
                                      style: TextStyle(
                                        color: _getStockColor(
                                          widget.product.stock,
                                        ),
                                        fontSize: 14,
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
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _barCodeController,
                                  decoration: _buildInputDecoration(
                                    labelText: 'Código de barras',
                                    prefixIcon: Icons.qr_code_scanner_rounded,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'El código es requerido';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              if (_isEditing)
                                IconButton(
                                  onPressed: () async {
                                    await _scanBarcode(context);
                                  },
                                  icon: const Icon(Icons.qr_code_scanner),
                                  tooltip: 'Escanear código de barras',
                                ),
                            ],
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
                                // Determinar si usar diseño de columna para pantallas pequeñas
                                bool isSmallScreen = constraints.maxWidth < 600;

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
                                          color: lightBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: lightBlue.withOpacity(0.3),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.1,
                                              ),
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
                                                          labelText: 'Cantidad',
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
                                                        color: Colors.red
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
                                                              Colors.red[600],
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
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Botón Eliminar
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.red
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
                                                        color: Colors.red[600],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      );
                                    }),
                                    const SizedBox(height: 12),
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
                                          backgroundColor: secondaryBlue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                color: lightBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: lightBlue.withOpacity(0.3),
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
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(
                                                  0.1,
                                                ),
                                                spreadRadius: 1,
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                            border: Border.all(
                                              color: primaryBlue.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Nombre con ícono
                                              Flexible(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.price_change,
                                                      color: primaryBlue,
                                                      size: 22,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        precio.nombre,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: darkBlue,
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
                                                          primaryBlue,
                                                          secondaryBlue,
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      "P: \$${precio.precio.toStringAsFixed(2)}",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
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
                                                          primaryBlue,
                                                          secondaryBlue,
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      "C: ${precio.quantity}",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
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
                                                color: primaryBlue,
                                                size: 32,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Sin precios disponibles',
                                                style: TextStyle(
                                                  color: primaryBlue,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
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
                            dropdownColor: Colors.white,
                            items: _categories.map((categoria) {
                              return DropdownMenuItem<String>(
                                value: categoria.id,
                                child: Text(
                                  categoria.nombre,
                                  style: TextStyle(color: darkBlue),
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
                              // Validar que el valor existe en la lista
                              if (!_categories.any((cat) => cat.id == value)) {
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
                            dropdownColor: Colors.white,
                            items: _proveedores.map((proveedor) {
                              return DropdownMenuItem<String>(
                                value: proveedor.id,
                                child: Text(
                                  proveedor.nombre,
                                  style: TextStyle(color: darkBlue),
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
                              // Validar que el valor existe en la lista
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
                            dropdownColor: Colors.white,
                            items: const [
                              DropdownMenuItem(
                                value: 'activo',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.green,
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
                                      color: Colors.red,
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
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primaryBlue, secondaryBlue],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _updateProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Guardar Cambios',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildCachedImage(
    String imageUrl, {
    required Color primaryBlue,
    required Color lightBlue,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: lightBlue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: lightBlue.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_rounded, color: primaryBlue, size: 40),
            SizedBox(height: 8),
            Text(
              'Error al cargar',
              style: TextStyle(color: primaryBlue, fontSize: 12),
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
