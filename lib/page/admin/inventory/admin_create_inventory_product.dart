import 'dart:io';
import 'package:compaexpress/widget/app_loading_indicator.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/admin/categories/admin_categories_form_page.dart';
import 'package:compaexpress/page/admin/proveedor/admin_proveedor_form_page.dart';
import 'package:compaexpress/providers/categories_provider.dart';
import 'package:compaexpress/providers/proveedor_provider.dart';
import 'package:compaexpress/services/product/product_controller.dart';
import 'package:compaexpress/services/product/product_service.dart';
import 'package:compaexpress/utils/barcode_listener_wrapper.dart';
import 'package:compaexpress/widget/ui/barcode_field.dart';
import 'package:compaexpress/widget/ui/custom_buttons.dart';
import 'package:compaexpress/widget/ui/custom_text_field.dart';
import 'package:compaexpress/widget/ui/image_picker_section.dart';
import 'package:compaexpress/widget/ui/price_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:searchfield/searchfield.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';

class AdminCreateInventoryProduct extends ConsumerStatefulWidget {
  final String negocioID;

  const AdminCreateInventoryProduct({super.key, required this.negocioID});

  @override
  ConsumerState<AdminCreateInventoryProduct> createState() =>
      _AdminCreateInventoryProductState();
}

class _AdminCreateInventoryProductState
    extends ConsumerState<AdminCreateInventoryProduct>
    with SingleTickerProviderStateMixin {
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
  bool _isUploadingImages = false;
  bool _isFavorite = false;
  bool _isGeneratingDescription = false;

  // Datos
  Categoria? _categoriaSeleccionada;
  Proveedor? _proveedorSeleccionado;
  List<File> _imagenesSeleccionadas = [];
  final ImagePicker _picker = ImagePicker();

  // Estado del producto
  String _estadoSeleccionado = 'activo';
  final List<String> _estadosDisponibles = ['activo', 'inactivo', 'agotado'];

  // Precios
  final List<Map<String, TextEditingController>> _preciosControllers = [];

  // Animation
  late AnimationController _animationController;

  // Focus nodes para mejor navegación
  final _nombreFocusNode = FocusNode();
  final _precioCompraFocusNode = FocusNode();
  final _tipoFocusNode = FocusNode();
  final _descripcionFocusNode = FocusNode();
  final _stockFocusNode = FocusNode();
  final _barcodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _agregarPrecio();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioCompraController.dispose();
    _tipoCompraController.dispose();
    _descripcionController.dispose();
    _stockController.dispose();
    _barCodeController.dispose();
    _nombreFocusNode.dispose();
    _precioCompraFocusNode.dispose();
    _tipoFocusNode.dispose();
    _descripcionFocusNode.dispose();
    _stockFocusNode.dispose();
    _barcodeFocusNode.dispose();
    _animationController.dispose();
    for (var precio in _preciosControllers) {
      precio['nombre']!.dispose();
      precio['precio']!.dispose();
      precio['cantidad']!.dispose();
    }
    super.dispose();
  }

  // ========== GENERACIÓN AUTOMÁTICA DE DESCRIPCIÓN ==========

  Future<void> _generarDescripcion() async {
    if (_nombreController.text.trim().isEmpty) {
      _mostrarToast(
        'Ingresa el nombre del producto primero',
        ToastificationType.warning,
      );
      return;
    }

    setState(() => _isGeneratingDescription = true);

    try {
      // Simular generación (puedes integrar con API de IA si lo deseas)
      await Future.delayed(const Duration(milliseconds: 800));

      final nombre = _nombreController.text.trim();
      final tipo = _tipoCompraController.text.trim();
      final categoria = _categoriaSeleccionada?.nombre ?? '';

      String descripcion = nombre;
      if (tipo.isNotEmpty) descripcion += ' tipo $tipo';
      if (categoria.isNotEmpty) descripcion += ' de categoría $categoria';
      descripcion += '. Producto de alta calidad';

      _descripcionController.text = descripcion;
      _mostrarToast(
        'Descripción generada exitosamente',
        ToastificationType.success,
      );
    } catch (e) {
      _mostrarToast('Error al generar descripción', ToastificationType.error);
    } finally {
      setState(() => _isGeneratingDescription = false);
    }
  }

  // ========== MANEJO DE CÓDIGO DE BARRAS ==========

  void _onBarcodeScannedFromUSB(String barcode) {
    setState(() {
      _barCodeController.text = barcode;
    });
    _mostrarToast('Código escaneado: $barcode', ToastificationType.success);
    FocusScope.of(context).nextFocus();
  }

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
      _mostrarToast('Error al escanear código', ToastificationType.error);
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
      _mostrarToast('Error al seleccionar imágenes', ToastificationType.error);
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
      _mostrarToast('Error al tomar la foto', ToastificationType.error);
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
      _mostrarToast('Error al subir imágenes', ToastificationType.error);
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
    if (!_formKey.currentState!.validate()) {
      _mostrarToast(
        'Completa todos los campos requeridos',
        ToastificationType.warning,
      );
      return;
    }

    if (!_validarFormulario()) return;

    // Validaciones remotas
    final validation = await ProductController.validateProductNameAndBarCode(
      _nombreController.text.toLowerCase(),
      _barCodeController.text.toLowerCase(),
    );

    if (validation['nameExists']!) {
      _mostrarToast(
        'Ya existe un producto con ese nombre',
        ToastificationType.error,
      );
      return;
    }
    if (validation['barCodeExists']!) {
      _mostrarToast(
        'Ya existe un producto con ese código de barras',
        ToastificationType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Subir imágenes
      List<String> imageKeys = [];
      if (_imagenesSeleccionadas.isNotEmpty) {
        imageKeys = await _subirImagenes();
        if (imageKeys.isEmpty) {
          _mostrarToast('Error al subir imágenes', ToastificationType.error);
          setState(() => _isLoading = false);
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

      _mostrarToast('Producto creado exitosamente', ToastificationType.success);
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      _handleError('Error de conexión. Verifica tu internet', e);
    } catch (e) {
      _handleError('Error inesperado. Intenta de nuevo', e);
    } finally {
      setState(() => _isLoading = false);
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
        _mostrarToast('Error al crear un precio', ToastificationType.error);
        return;
      }
    }
  }

  bool _validarFormulario() {
    if (_categoriaSeleccionada == null) {
      _mostrarToast(
        'Por favor selecciona una categoría',
        ToastificationType.warning,
      );
      return false;
    }

    if (_proveedorSeleccionado == null) {
      _mostrarToast(
        'Por favor selecciona un proveedor',
        ToastificationType.warning,
      );
      return false;
    }

    for (var precio in _preciosControllers) {
      if (precio['nombre']!.text.trim().isEmpty ||
          precio['cantidad']!.text.trim().isEmpty ||
          precio['precio']!.text.trim().isEmpty) {
        _mostrarToast(
          'Todos los campos de precios deben estar completos',
          ToastificationType.warning,
        );
        return false;
      }

      final valorPrecio = double.tryParse(precio['precio']!.text);
      if (valorPrecio == null || valorPrecio <= 0) {
        _mostrarToast(
          'Todos los precios deben ser válidos y mayores a 0',
          ToastificationType.warning,
        );
        return false;
      }

      final valorCantidad = double.tryParse(precio['cantidad']!.text);
      if (valorCantidad == null || valorCantidad <= 0) {
        _mostrarToast(
          'Todas las cantidades deben ser válidas y mayores a 0',
          ToastificationType.warning,
        );
        return false;
      }
    }

    return true;
  }

  // ========== MÉTODOS DE UTILIDAD ==========

  void _handleError(String message, dynamic error) {
    safePrint('Error: $error');
    _mostrarToast(message, ToastificationType.error);
  }

  void _mostrarToast(String mensaje, ToastificationType type) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flatColored,
      title: Text(mensaje),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      showProgressBar: false,
    );
  }

  // ========== NAVEGACIÓN A PANTALLAS DE CREACIÓN ==========

  Future<void> _navegarACrearCategoria() async {
    final categoriesState = ref.read(categoriesProvider);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminCategoriesFormPage(
          categoria: null,
          categoriasDisponibles: categoriesState.categorias,
        ),
      ),
    );
  }

  Future<void> _navegarACrearProveedor() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProveedorFormPage()),
    );

    if (result == true && mounted) {
      ref.read(proveedorProvider.notifier).refresh();
    }
  }

  // ========== BUILD ==========

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BarcodeListenerWrapper(
      contextName: 'create_product',
      onBarcodeScanned: _onBarcodeScannedFromUSB,
      enabled: !_isLoading && !_isUploadingImages,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Crear Producto'),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                color: _isFavorite ? Colors.amber : null,
              ),
              onPressed: () => setState(() => _isFavorite = !_isFavorite),
              tooltip: 'Marcar como favorito',
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: AnimationLimiter(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // Indicador USB
                  _buildUSBReaderIndicator(colorScheme),
                  const SizedBox(height: 20),

                  // Información básica
                  _buildSectionCard(
                    colorScheme: colorScheme,
                    title: 'Información Básica',
                    icon: Icons.info_outline,
                    children: [
                      CustomTextField(
                        controller: _nombreController,
                        focusNode: _nombreFocusNode,
                        labelText: "Nombre del Producto *",
                        prefixIcon: Icons.shopping_bag,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: [LengthLimitingTextInputFormatter(50)],
                        onEditingComplete: () =>
                            _precioCompraFocusNode.requestFocus(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          if (value.trim().length < 2) {
                            return 'Mínimo 2 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _precioCompraController,
                              focusNode: _precioCompraFocusNode,
                              labelText: "Precio compra *",
                              prefixIcon: Icons.attach_money,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              onEditingComplete: () =>
                                  _tipoFocusNode.requestFocus(),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Requerido';
                                }
                                final precio = double.tryParse(value);
                                if (precio == null || precio <= 0) {
                                  return 'Mayor a 0';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _tipoCompraController,
                              focusNode: _tipoFocusNode,
                              labelText: "Tipo *",
                              hintText: "Ej: XL, Normal",
                              prefixIcon: Icons.style,
                              textCapitalization: TextCapitalization.words,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(12),
                              ],
                              onEditingComplete: () =>
                                  _descripcionFocusNode.requestFocus(),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _descripcionController,
                              focusNode: _descripcionFocusNode,
                              labelText: "Descripción *",
                              hintText: 'Describe el producto',
                              prefixIcon: Icons.description,
                              maxLines: 3,
                              maxLength: 150,
                              textCapitalization: TextCapitalization.sentences,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Requerido';
                                }
                                if (value.trim().length < 5) {
                                  return 'Mínimo 5 caracteres';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Tooltip(
                              message: 'Generar descripción automática',
                              child: Material(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: _isGeneratingDescription
                                      ? null
                                      : _generarDescripcion,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: _isGeneratingDescription
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: AppLoadingIndicator(
                                              strokeWidth: 2,
                                              color: colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                          )
                                        : Icon(
                                            Icons.auto_awesome,
                                            color:
                                                colorScheme.onPrimaryContainer,
                                            size: 24,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Categoría y Proveedor
                  _buildSectionCard(
                    colorScheme: colorScheme,
                    title: 'Clasificación',
                    icon: Icons.category,
                    children: [
                      _buildCategoriaSelector(colorScheme),
                      const SizedBox(height: 16),
                      _buildProveedorSelector(colorScheme),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Precios
                  _buildSectionCard(
                    colorScheme: colorScheme,
                    title: 'Precios de Venta',
                    icon: Icons.payments,
                    children: [
                      PriceSectionWidget(
                        preciosControllers: _preciosControllers,
                        onAddPrice: _agregarPrecio,
                        onDeletePrice: _eliminarPrecio,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Inventario
                  _buildSectionCard(
                    colorScheme: colorScheme,
                    title: 'Inventario',
                    icon: Icons.inventory_2,
                    children: [
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
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              controller: _stockController,
                              focusNode: _stockFocusNode,
                              labelText: 'Stock Inicial *',
                              hintText: 'Ej: 10',
                              prefixIcon: Icons.numbers,
                              suffixText: 'unidades',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Requerido';
                                }
                                final stock = int.tryParse(value);
                                if (stock == null || stock < 0) {
                                  return 'No negativo';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _buildEstadoDropdown(colorScheme)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Imágenes
                  _buildSectionCard(
                    colorScheme: colorScheme,
                    title: 'Imágenes',
                    icon: Icons.photo_library,
                    children: [
                      ImagePickerSection(
                        imagenesSeleccionadas: _imagenesSeleccionadas,
                        onSelectFromGallery: _seleccionarImagenes,
                        onTakePhoto: _tomarFoto,
                        onDeleteImage: _eliminarImagen,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Botones de acción
                  PrimaryButton(
                    onPressed: _crearProducto,
                    text: 'Crear Producto',
                    isLoading: _isLoading || _isUploadingImages,
                    loadingText: _isUploadingImages
                        ? 'Subiendo imágenes...'
                        : 'Creando producto...',
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Cancelar',
                    isLoading: _isLoading || _isUploadingImages,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========== WIDGETS AUXILIARES ==========

  Widget _buildSectionCard({
    required ColorScheme colorScheme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildUSBReaderIndicator(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.usb, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Lector USB activo - Escanea un código de barras',
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
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

  Widget _buildCategoriaSelector(ColorScheme colorScheme) {
    // Simular lista de categorías (reemplazar con el provider real)
    final categorias = ref.watch(categoriesProvider).categorias;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SearchField<Categoria>(
                controller: TextEditingController(
                  text: _categoriaSeleccionada?.nombre ?? '',
                ),
                hint: 'Buscar categoría...',
                suggestions: categorias
                    .map(
                      (cat) => SearchFieldListItem<Categoria>(
                        cat.nombre,
                        item: cat,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.folder,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(cat.nombre),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
                maxSuggestionsInViewPort: 5,
                itemHeight: 50,
                onSuggestionTap: (suggestion) {
                  setState(() {
                    _categoriaSeleccionada = suggestion.item;
                  });
                },
                emptyWidget: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No se encontraron categorías',
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Crear nueva categoría',
              child: Material(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _navegarACrearCategoria,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 56,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_categoriaSeleccionada != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Seleccionado: ${_categoriaSeleccionada!.nombre}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => setState(() => _categoriaSeleccionada = null),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProveedorSelector(ColorScheme colorScheme) {
    // Simular lista de proveedores (reemplazar con el provider real)
    final proveedores = ref.watch(proveedorProvider).items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SearchField<Proveedor>(
                controller: TextEditingController(
                  text: _proveedorSeleccionado?.nombre ?? '',
                ),
                hint: 'Buscar proveedor...',

                suggestions: proveedores
                    .map(
                      (prov) => SearchFieldListItem<Proveedor>(
                        prov.nombre,
                        item: prov,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.business,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prov.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
                maxSuggestionsInViewPort: 5,
                itemHeight: 60,
                onSuggestionTap: (suggestion) {
                  setState(() {
                    _proveedorSeleccionado = suggestion.item;
                  });
                },
                emptyWidget: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No se encontraron proveedores',
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Crear nuevo proveedor',
              child: Material(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _navegarACrearProveedor,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 56,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_proveedorSeleccionado != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Seleccionado: ${_proveedorSeleccionado!.nombre}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => setState(() => _proveedorSeleccionado = null),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEstadoDropdown(ColorScheme colorScheme) {
    final estadoColors = {
      'activo': Colors.green,
      'inactivo': Colors.orange,
      'agotado': Colors.red,
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _estadoSeleccionado,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          borderRadius: BorderRadius.circular(12),
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          items: _estadosDisponibles.map((String estado) {
            return DropdownMenuItem<String>(
              value: estado,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: estadoColors[estado],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    estado.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: estadoColors[estado],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _estadoSeleccionado = newValue;
              });
            }
          },
        ),
      ),
    );
  }
}
