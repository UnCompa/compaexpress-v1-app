import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/services/product/product_controller.dart';
import 'package:compaexpress/services/product/product_service.dart';
import 'package:compaexpress/services/proveedor/proveedor_service.dart';
import 'package:compaexpress/utils/barcode_listener_wrapper.dart';
import 'package:compaexpress/widget/ui/barcode_field.dart';
import 'package:compaexpress/widget/ui/custom_buttons.dart';
import 'package:compaexpress/widget/ui/custom_dropdown.dart';
// Importar los widgets personalizados
import 'package:compaexpress/widget/ui/custom_text_field.dart';
import 'package:compaexpress/widget/ui/image_picker_section.dart';
import 'package:compaexpress/widget/ui/price_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:uuid/uuid.dart';

class AdminCreateInventoryProduct extends StatefulWidget {
  final String negocioID;

  const AdminCreateInventoryProduct({super.key, required this.negocioID});

  @override
  State<AdminCreateInventoryProduct> createState() =>
      _AdminCreateInventoryProductState();
}

class _AdminCreateInventoryProductState
    extends State<AdminCreateInventoryProduct> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nombreController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _tipoCompraController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _stockController = TextEditingController();
  final _barCodeController = TextEditingController();

  // Estados de carga
  bool _isLoading = false;
  bool _isLoadingCategorias = true;
  bool _isLoadingProveedores = true;
  bool _isUploadingImages = false;
  bool _isFavorite = false;

  // Datos
  List<Categoria> _categorias = [];
  List<Categoria> _categoriasFiltradas = [];
  Categoria? _categoriaSeleccionada;
  List<Proveedor> _proveedores = [];
  Proveedor? _proveedorSeleccionado;
  List<File> _imagenesSeleccionadas = [];
  final ImagePicker _picker = ImagePicker();

  // Estado del producto
  String _estadoSeleccionado = 'activo';
  final List<String> _estadosDisponibles = ['activo', 'inactivo', 'agotado'];

  // Precios
  final List<Map<String, TextEditingController>> _preciosControllers = [];

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _cargarProveedores();
    _agregarPrecio();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioCompraController.dispose();
    _tipoCompraController.dispose();
    _descripcionController.dispose();
    _stockController.dispose();
    _barCodeController.dispose();
    for (var precio in _preciosControllers) {
      precio['nombre']!.dispose();
      precio['precio']!.dispose();
      precio['cantidad']!.dispose();
    }
    super.dispose();
  }

  // ========== MÉTODOS DE CARGA DE DATOS ==========

  Future<void> _cargarCategorias() async {
    try {
      final negocioInfo = await NegocioService.getCurrentUserInfo();
      final request = ModelQueries.list(
        Categoria.classType,
        where: Categoria.NEGOCIOID.eq(negocioInfo.negocioId),
      );
      final response = await Amplify.API.query(request: request).response;
      if (response.data?.items != null) {
        setState(() {
          _categorias = response.data!.items.whereType<Categoria>().toList();
          _categoriasFiltradas = _categorias;
          _isLoadingCategorias = false;
        });
      }
    } catch (e) {
      safePrint('Error cargando categorías: $e');
      setState(() => _isLoadingCategorias = false);
      _mostrarError('Error al cargar las categorías');
    }
  }

  Future<void> _cargarProveedores() async {
    try {
      final proveedores = await ProveedorService.getAllProveedores();
      setState(() {
        _proveedores = proveedores.whereType<Proveedor>().toList();
        _isLoadingProveedores = false;
      });
    } catch (e) {
      safePrint('Error cargando los proveedores: $e');
      setState(() => _isLoadingProveedores = false);
      _mostrarError('Error al cargar los proveedores');
    }
  }

  // ========== MANEJO DE CÓDIGO DE BARRAS ==========

  /// Callback para cuando se escanea un código con el lector USB
  void _onBarcodeScannedFromUSB(String barcode) {
    setState(() {
      _barCodeController.text = barcode;
    });

    // Mostrar feedback visual
    _mostrarExito('Código escaneado: $barcode');

    // Auto-focus en el siguiente campo (opcional)
    FocusScope.of(context).nextFocus();
  }

  /// Escanear código con cámara (método manual)
  Future<void> _scanBarcodeWithCamera(BuildContext context) async {
    try {
      final result = await SimpleBarcodeScanner.scanBarcode(
        context,
        barcodeAppBar: const BarcodeAppBar(
          appBarTitle: 'Escanear Código de Barras',
          centerTitle: false,
          enableBackButton: true,
          backButtonIcon: Icon(Icons.arrow_back_ios),
        ),
        isShowFlashIcon: true,
        delayMillis: 1000,
        cameraFace: CameraFace.back,
      );
      if (result != null && result != '-1') {
        setState(() {
          _barCodeController.text = result;
        });
      }
    } catch (e) {
      safePrint('Error al escanear: $e');
      _mostrarError('Error al escanear código de barras');
    }
  }

  // ========== MÉTODOS DE GESTIÓN DE IMÁGENES ==========

  Future<void> _seleccionarImagenes() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final imagenesAUsar = images.take(5).toList();
        setState(() {
          _imagenesSeleccionadas = imagenesAUsar
              .map((xfile) => File(xfile.path))
              .toList();
        });
      }
    } catch (e) {
      safePrint('Error seleccionando imágenes: $e');
      _mostrarError('Error al seleccionar las imágenes');
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && _imagenesSeleccionadas.length < 5) {
        setState(() {
          _imagenesSeleccionadas.add(File(image.path));
        });
      }
    } catch (e) {
      safePrint('Error tomando foto: $e');
      _mostrarError('Error al tomar la foto');
    }
  }

  void _eliminarImagen(int index) {
    setState(() {
      _imagenesSeleccionadas.removeAt(index);
    });
  }

  Future<List<String>> _subirImagenes() async {
    if (_imagenesSeleccionadas.isEmpty) return [];

    setState(() => _isUploadingImages = true);

    List<String> uploadedKeys = [];
    const uuid = Uuid();

    try {
      for (var file in _imagenesSeleccionadas) {
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
      _mostrarError('Error al subir las imágenes');
      return [];
    } finally {
      setState(() => _isUploadingImages = false);
    }

    return uploadedKeys;
  }

  // ========== MÉTODOS DE GESTIÓN DE PRECIOS ==========

  void _agregarPrecio() {
    setState(() {
      _preciosControllers.add({
        'nombre': TextEditingController(),
        'precio': TextEditingController(),
        'cantidad': TextEditingController(),
      });
    });
  }

  void _eliminarPrecio(int index) {
    setState(() {
      _preciosControllers[index]['nombre']!.dispose();
      _preciosControllers[index]['precio']!.dispose();
      _preciosControllers[index]['cantidad']!.dispose();
      _preciosControllers.removeAt(index);
    });
  }

  // ========== MÉTODOS DE CREACIÓN DE PRODUCTO ==========

  Future<void> _crearProducto() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_validarFormulario()) return;

    // Validaciones remotas
    final validation = await ProductController.validateProductNameAndBarCode(
      _nombreController.text.toLowerCase(),
      _barCodeController.text.toLowerCase(),
    );

    if (validation['nameExists']!) {
      _mostrarError('Ya existe un producto con ese nombre.');
      return;
    }
    if (validation['barCodeExists']!) {
      _mostrarError('Ya existe un producto con ese código de barras.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Subir imágenes
      List<String> imageKeys = [];
      if (_imagenesSeleccionadas.isNotEmpty) {
        imageKeys = await _subirImagenes();
        if (imageKeys.isEmpty) {
          _mostrarError('Error al subir imágenes.');
          return;
        }
      }

      // Crear producto
      final now = TemporalDateTime.now();
      final producto = Producto(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text,
        stock: int.parse(_stockController.text),
        negocioID: widget.negocioID,
        categoriaID: _categoriaSeleccionada!.id,
        estado: _estadoSeleccionado,
        productoImages: imageKeys.isEmpty ? null : imageKeys,
        barCode: _barCodeController.text.trim(),
        isDeleted: false,
        tipo: _tipoCompraController.text,
        favorito: _isFavorite,
        proveedorID: _proveedorSeleccionado!.id,
        precioCompra: double.parse(_precioCompraController.text),
        createdAt: now,
        updatedAt: now,
      );

      final dataManager = getProductManager();
      final createdProducto = await dataManager.saveDataReturned(producto);

      // Crear precios en lote
      await _crearPrecios(createdProducto!.id, now);

      _mostrarExito('Producto y precios creados exitosamente');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      _handleError(
        'Error de conexión. Verifica tu internet e intenta de nuevo.',
        e,
      );
    } catch (e) {
      _handleError('Error inesperado. Intenta de nuevo.', e);
    }
  }

  Future<void> _crearPrecios(String productoID, TemporalDateTime now) async {
    final precioRequests = _preciosControllers.map((precio) {
      final productoPrecio = ProductoPrecios(
        nombre: precio['nombre']!.text.trim(),
        precio: double.parse(precio['precio']!.text),
        negocioID: widget.negocioID,
        productoID: productoID,
        quantity: int.parse(precio['cantidad']!.text),
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );
      return ModelMutations.create(productoPrecio);
    }).toList();

    final responses = await Future.wait(
      precioRequests.map(
        (request) => Amplify.API.mutate(request: request).response,
      ),
    );

    for (var response in responses) {
      if (response.data == null) {
        _mostrarError('Error al crear un precio. Intenta de nuevo.');
        return;
      }
    }
  }

  bool _validarFormulario() {
    if (_categoriaSeleccionada == null) {
      _mostrarError('Por favor selecciona una categoría');
      return false;
    }

    if (_proveedorSeleccionado == null) {
      _mostrarError('Por favor selecciona un proveedor');
      return false;
    }

    for (var precio in _preciosControllers) {
      if (precio['nombre']!.text.trim().isEmpty ||
          precio['cantidad']!.text.trim().isEmpty ||
          precio['precio']!.text.trim().isEmpty) {
        _mostrarError('Todos los campos de precios deben estar completos');
        return false;
      }

      final valorPrecio = double.tryParse(precio['precio']!.text);
      if (valorPrecio == null || valorPrecio <= 0) {
        _mostrarError('Todos los precios deben ser válidos y mayores a 0');
        return false;
      }

      final valorCantidad = double.tryParse(precio['cantidad']!.text);
      if (valorCantidad == null || valorCantidad <= 0) {
        _mostrarError('Todas las cantidades deben ser válidas y mayores a 0');
        return false;
      }
    }

    return true;
  }

  // ========== MÉTODOS DE UTILIDAD ==========

  void _handleError(String message, dynamic error) {
    safePrint('Error: $error');
    _mostrarError(message);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ========== BUILD ==========

  @override
  Widget build(BuildContext context) {
    return BarcodeListenerWrapper(
      contextName: 'create_product',
      onBarcodeScanned: _onBarcodeScannedFromUSB,
      enabled: !_isLoading && !_isUploadingImages,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Producto'),
          actions: [
            FavoriteToggleButton(
              isFavorite: _isFavorite,
              onToggle: () => setState(() => _isFavorite = !_isFavorite),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicador de lector USB activo
                _buildUSBReaderIndicator(),

                const SizedBox(height: 16),

                // Nombre del producto
                CustomTextField(
                  controller: _nombreController,
                  labelText: "Nombre del Producto *",
                  prefixIcon: Icons.shopping_bag,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    if (value.trim().length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Precio compra y Tipo
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _precioCompraController,
                        labelText: "Precio compra",
                        prefixIcon: Icons.money_off,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El precio de compra es obligatorio';
                          }
                          final precio = double.tryParse(value);
                          if (precio == null || precio <= 0) {
                            return 'El precio debe ser mayor a 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _tipoCompraController,
                        labelText: "Tipo *",
                        hintText: "Ej: XL, Normal",
                        prefixIcon: Icons.type_specimen_outlined,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: [LengthLimitingTextInputFormatter(12)],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El tipo es obligatorio';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Descripción
                CustomTextField(
                  controller: _descripcionController,
                  labelText: "Descripción",
                  hintText: 'Describe las características del producto',
                  prefixIcon: Icons.description,
                  maxLines: 3,
                  maxLength: 150,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    if (value.trim().length < 5) {
                      return 'La descripción debe tener al menos 5 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Categoría
                CustomDropdownField<Categoria>(
                  value: _categoriaSeleccionada,
                  labelText: "Categoría *",
                  prefixIcon: Icons.category,
                  hintText: 'Selecciona una categoría',
                  items: _categoriasFiltradas,
                  itemLabel: (categoria) => categoria.nombre,
                  isLoading: _isLoadingCategorias,
                  onChanged: (value) =>
                      setState(() => _categoriaSeleccionada = value),
                  validator: (value) {
                    if (value == null) return 'Selecciona una categoría';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Proveedor
                CustomDropdownField<Proveedor>(
                  value: _proveedorSeleccionado,
                  labelText: "Proveedor *",
                  prefixIcon: Icons.car_rental,
                  hintText: 'Selecciona un Proveedor',
                  items: _proveedores,
                  itemLabel: (proveedor) => proveedor.nombre,
                  isLoading: _isLoadingProveedores,
                  onChanged: (value) =>
                      setState(() => _proveedorSeleccionado = value),
                  validator: (value) {
                    if (value == null) return 'Selecciona un proveedor';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Sección de Precios
                PriceSectionWidget(
                  preciosControllers: _preciosControllers,
                  onAddPrice: _agregarPrecio,
                  onDeletePrice: _eliminarPrecio,
                ),

                const SizedBox(height: 16),

                // Código de Barras con soporte USB y cámara
                BarcodeTextField(
                  controller: _barCodeController,
                  onManualScan: () => _scanBarcodeWithCamera(context),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El código de barras es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Stock
                CustomTextField(
                  controller: _stockController,
                  labelText: 'Stock *',
                  hintText: 'Ej: 10',
                  prefixIcon: Icons.inventory,
                  suffixText: 'unidades',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El stock es obligatorio';
                    }
                    final stock = int.tryParse(value);
                    if (stock == null || stock < 0) {
                      return 'El stock no puede ser negativo';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Estado
                CustomDropdownField<String>(
                  value: _estadoSeleccionado,
                  labelText: 'Estado *',
                  prefixIcon: Icons.toggle_on,
                  hintText: 'Selecciona el estado',
                  items: _estadosDisponibles,
                  itemLabel: (estado) => estado.toUpperCase(),
                  onChanged: (value) =>
                      setState(() => _estadoSeleccionado = value!),
                ),

                const SizedBox(height: 24),

                // Sección de Imágenes
                ImagePickerSection(
                  imagenesSeleccionadas: _imagenesSeleccionadas,
                  onSelectFromGallery: _seleccionarImagenes,
                  onTakePhoto: _tomarFoto,
                  onDeleteImage: _eliminarImagen,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),

                // Botón Crear
                PrimaryButton(
                  onPressed: _crearProducto,
                  text: 'Crear Producto',
                  isLoading: _isLoading || _isUploadingImages,
                  loadingText: _isUploadingImages
                      ? 'Subiendo imágenes...'
                      : 'Creando producto...',
                ),

                const SizedBox(height: 12),

                // Botón Cancelar
                SecondaryButton(
                  onPressed: () => Navigator.of(context).pop(),
                  text: 'Cancelar',
                  isLoading: _isLoading || _isUploadingImages,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUSBReaderIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.usb, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Lector USB activo - Escanea un código de barras',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
