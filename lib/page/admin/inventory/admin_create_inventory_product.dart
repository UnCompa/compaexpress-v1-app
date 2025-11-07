import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/services/product/product_controller.dart';
import 'package:compaexpress/services/product/product_service.dart';
import 'package:compaexpress/services/proveedor/proveedor_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:uuid/uuid.dart';

class AdminCreateInventoryProduct extends StatefulWidget {
  final String negocioID; // ID del negocio al que pertenece el producto

  const AdminCreateInventoryProduct({super.key, required this.negocioID});

  @override
  State<AdminCreateInventoryProduct> createState() =>
      _AdminCreateInventoryProductState();
}

class _AdminCreateInventoryProductState
    extends State<AdminCreateInventoryProduct> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _tipoCompraController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _stockController = TextEditingController();
  final _barCodeController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingCategorias = true;
  bool _isLoadingProveedores = true;
  bool _isUploadingImages = false;
  bool _isFavorite = false;

  // Listas y variables para categorías
  List<Categoria> _categorias = [];
  List<Categoria> _categoriasFiltradas = [];
  Categoria? _categoriaSeleccionada;
  //Listar los proveedores
  List<Proveedor> _proveedores = [];
  Proveedor? _proveedorSeleccionado;
  // Variables para imágenes
  List<File> _imagenesSeleccionadas = [];
  final ImagePicker _picker = ImagePicker();

  // Estado del producto
  String _estadoSeleccionado = 'activo';
  final List<String> _estadosDisponibles = ['activo', 'inactivo', 'agotado'];

  // Variables para precios múltiples
  final List<Map<String, TextEditingController>> _preciosControllers = [];

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _cargarProveedores();
    // Inicializar con un precio por defecto
    _agregarPrecio();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioCompraController.dispose();
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
      setState(() {
        _isLoadingCategorias = false;
      });
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
      setState(() {
        _isLoadingProveedores = false;
      });
      _mostrarError('Error al cargar los proveedores');
    }
  }

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

      if (image != null) {
        setState(() {
          if (_imagenesSeleccionadas.length < 5) {
            _imagenesSeleccionadas.add(File(image.path));
          }
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
    if (_imagenesSeleccionadas.isEmpty) {
      return [];
    }

    setState(() {
      _isUploadingImages = true;
    });

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
      _mostrarError('Error al subir las imágenes');
      return [];
    } finally {
      setState(() {
        _isUploadingImages = false;
      });
    }

    return uploadedKeys;
  }

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

  Future<void> _crearProducto() async {
    if (!_formKey.currentState!.validate()) return;

    // Validaciones locales
    if (_categoriaSeleccionada == null) {
      _mostrarError('Por favor selecciona una categoría');
      return;
    }
    for (var precio in _preciosControllers) {
      if (precio['nombre']!.text.trim().isEmpty ||
          precio['cantidad']!.text.trim().isEmpty ||
          precio['precio']!.text.trim().isEmpty) {
        _mostrarError('Todos los campos de precios deben estar completos');
        return;
      }
      final valorPrecio = double.tryParse(precio['precio']!.text);
      if (valorPrecio == null || valorPrecio <= 0) {
        _mostrarError('Todos los precios deben ser válidos y mayores a 0');
        return;
      }
      final valorCantidad = double.tryParse(precio['cantidad']!.text);
      if (valorCantidad == null || valorCantidad <= 0) {
        _mostrarError('Todos las cantidades deben ser válidos y mayores a 0');
        return;
      }
    }

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
      final precioRequests = _preciosControllers.map((precio) {
        final productoPrecio = ProductoPrecios(
          nombre: precio['nombre']!.text.trim(),
          precio: double.parse(precio['precio']!.text),
          negocioID: widget.negocioID,
          productoID: createdProducto!.id,
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

  void _handleError(String message, dynamic error) {
    safePrint('Error: $error');
    _mostrarError(message);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _scanBarcode(BuildContext context) async {
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
        _barCodeController.text = result;
      }
    } catch (e) {
      safePrint('Error al escanear: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Producto'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isFavorite) ...[
            Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isFavorite = false;
                  });
                },
                icon: Icon(Icons.star, color: Colors.yellow[700]),
                label: Text("Favorito", style: TextStyle(color: Colors.white)),
              ),
            ),
          ] else
            Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isFavorite = true;
                  });
                },
                icon: Icon(Icons.star, color: Colors.grey[100]),
                label: Text("Favorito", style: TextStyle(color: Colors.white)),
              ),
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
              // Campo Nombre
              TextFormField(
                controller: _nombreController,
                decoration: _buildInputDecoration(
                  labelText: "Nombre del Producto *",
                  prefixIcon: Icons.shopping_bag,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  if (value.trim().length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  return null;
                },
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precioCompraController,
                      decoration: _buildInputDecoration(
                        labelText: "Precio compra",
                        prefixIcon: Icons.money_off,
                      ),
                      keyboardType: TextInputType.numberWithOptions(
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
                        if (precio == null) {
                          return 'Ingresa un precio de compra válido';
                        }
                        if (precio <= 0) {
                          return 'El precio de compra debe ser mayor a 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _tipoCompraController,
                      decoration: _buildInputDecoration(
                        labelText: "Tipo *",
                        prefixIcon: Icons.type_specimen_outlined,
                        hintText: "Ej: XL, Normal",
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El tipo es obligatorio';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [LengthLimitingTextInputFormatter(12)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Campo Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: _buildInputDecoration(
                  labelText: "Descripción",
                  prefixIcon: Icons.description,
                  hintText: 'Describe las características del producto',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  if (value.trim().length < 5) {
                    return 'La descripción debe tener al menos 2 caracteres';
                  }
                  return null;
                },
                maxLines: 3,
                maxLength: 150,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              // Selector de Categoría
              _isLoadingCategorias
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          constraints: BoxConstraints(
                            minHeight: 24,
                            minWidth: 24,
                          ),
                        ),
                      ),
                    )
                  : DropdownButtonFormField<Categoria>(
                      value: _categoriaSeleccionada,
                      decoration: _buildInputDecoration(
                        labelText: "Categoría *",
                        prefixIcon: Icons.category,
                      ),
                      hint: const Text('Selecciona una categoría'),
                      items: _categoriasFiltradas.map((categoria) {
                        return DropdownMenuItem<Categoria>(
                          value: categoria,
                          child: Text(categoria.nombre),
                        );
                      }).toList(),
                      onChanged: (Categoria? newValue) {
                        setState(() {
                          _categoriaSeleccionada = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona una categoría';
                        }
                        return null;
                      },
                    ),

              const SizedBox(height: 16),
              // Selector de Categoría
              _isLoadingProveedores
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          constraints: BoxConstraints(
                            minHeight: 24,
                            minWidth: 24,
                          ),
                        ),
                      ),
                    )
                  : DropdownButtonFormField<Proveedor>(
                      value: _proveedorSeleccionado,
                      decoration: _buildInputDecoration(
                        labelText: "Proveedor *",
                        prefixIcon: Icons.car_rental,
                      ),
                      hint: const Text('Selecciona un Proveedor'),
                      items: _proveedores.map((proveedor) {
                        return DropdownMenuItem<Proveedor>(
                          value: proveedor,
                          child: Text(proveedor.nombre),
                        );
                      }).toList(),
                      onChanged: (Proveedor? newValue) {
                        setState(() {
                          _proveedorSeleccionado = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona un proveedor';
                        }
                        return null;
                      },
                    ),

              const SizedBox(height: 16),

              // Sección de Precios
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Precios del Producto *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._preciosControllers.asMap().entries.map((entry) {
                        int index = entry.key;
                        var controllers = entry.value;
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            bool isMobile = constraints.maxWidth < 600;

                            return isMobile
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: controllers['nombre'],
                                        decoration: _buildInputDecoration(
                                          labelText: 'Nombre del Precio',
                                          hintText: 'Ej: Público',
                                          prefixIcon: Icons.label,
                                        ),
                                        textCapitalization:
                                            TextCapitalization.words,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'El nombre es obligatorio';
                                          }
                                          return null;
                                        },
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(20),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: controllers['precio'],
                                              decoration: _buildInputDecoration(
                                                labelText: 'Precio',
                                                hintText: 'Ej: 999.99',
                                                prefixIcon: Icons.attach_money,
                                                suffixText: 'USD',
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d*\.?\d{0,2}'),
                                                ),
                                                LengthLimitingTextInputFormatter(
                                                  10,
                                                ),
                                              ],

                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'El precio es obligatorio';
                                                }
                                                final precio = double.tryParse(
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
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  controllers['cantidad'],
                                              decoration: _buildInputDecoration(
                                                labelText: 'Cantidad',
                                                hintText: 'Ej: 1',
                                                prefixIcon:
                                                    Icons.numbers_rounded,
                                                suffixText: 'USD',
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                  5,
                                                ),
                                              ],

                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'La cantidad es obligatorio';
                                                }
                                                final cantidad =
                                                    double.tryParse(value);
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
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed:
                                                _preciosControllers.length > 1
                                                ? () => _eliminarPrecio(index)
                                                : null,
                                            icon: const Icon(Icons.delete),
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  )
                                : Padding(
                                    padding: EdgeInsetsGeometry.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(height: 8),
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            controller: controllers['nombre'],
                                            decoration: _buildInputDecoration(
                                              labelText: 'Nombre del Precio',
                                              hintText: 'Ej: Público',
                                              prefixIcon: Icons.label,
                                            ),
                                            textCapitalization:
                                                TextCapitalization.words,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'El nombre es obligatorio';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            controller: controllers['precio'],
                                            decoration: _buildInputDecoration(
                                              labelText: 'Precio',
                                              hintText: 'Ej: 999.99',
                                              prefixIcon: Icons.attach_money,
                                              suffixText: 'USD',
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d{0,2}'),
                                              ),
                                              LengthLimitingTextInputFormatter(
                                                10,
                                              ),
                                            ],

                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'El precio es obligatorio';
                                              }
                                              final precio = double.tryParse(
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
                                        Expanded(
                                          child: TextFormField(
                                            controller: controllers['cantidad'],
                                            decoration: _buildInputDecoration(
                                              labelText: 'Cantidad',
                                              hintText: 'Ej: 1',
                                              prefixIcon: Icons.numbers_rounded,
                                              suffixText: 'USD',
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                5,
                                              ),
                                            ],

                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'La cantidad es obligatorio';
                                              }
                                              final cantidad = double.tryParse(
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
                                        IconButton(
                                          onPressed:
                                              _preciosControllers.length > 1
                                              ? () => _eliminarPrecio(index)
                                              : null,
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  );
                          },
                        );
                      }),
                      ElevatedButton.icon(
                        onPressed: _agregarPrecio,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar otro precio'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Campo Código de Barras
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barCodeController,
                      decoration: _buildInputDecoration(
                        labelText: 'Código de Barras',
                        hintText: 'Ej: 2500000004957',
                        prefixIcon: Icons.barcode_reader,
                        suffixText: 'código',
                      ),
                      maxLength: 15,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El código es obligatorio';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _scanBarcode(context);
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: 'Escanear código de barras',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Campo Stock
              TextFormField(
                controller: _stockController,
                decoration: _buildInputDecoration(
                  labelText: 'Stock *',
                  hintText: 'Ej: 10',
                  prefixIcon: Icons.inventory,
                  suffixText: 'unidades',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El stock es obligatorio';
                  }
                  final stock = int.tryParse(value);
                  if (stock == null) {
                    return 'Ingresa un stock válido';
                  }
                  if (stock < 0) {
                    return 'El stock no puede ser negativo';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),

              const SizedBox(height: 16),

              // Selector de Estado
              DropdownButtonFormField<String>(
                value: _estadoSeleccionado,
                decoration: _buildInputDecoration(
                  labelText: 'Estado *',
                  hintText: 'Ej: 10',
                  prefixIcon: Icons.toggle_on,
                ),
                items: _estadosDisponibles.map((estado) {
                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Text(estado.toUpperCase()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _estadoSeleccionado = newValue!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Sección de Imágenes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
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
                              onPressed: _isLoading ? null : _tomarFoto,
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

                      // Vista previa de imágenes
                      if (_imagenesSeleccionadas.isNotEmpty)
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imagenesSeleccionadas.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _imagenesSeleccionadas[index],
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _eliminarImagen(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
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

                      if (_imagenesSeleccionadas.isEmpty)
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Sin imágenes seleccionadas\n(Máximo 5 imágenes)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón Crear
              ElevatedButton(
                onPressed: (_isLoading || _isUploadingImages)
                    ? null
                    : _crearProducto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: (_isLoading || _isUploadingImages)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isUploadingImages
                                ? 'Subiendo imágenes...'
                                : 'Creando producto...',
                          ),
                        ],
                      )
                    : const Text(
                        'Crear Producto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // Botón Cancelar
              OutlinedButton(
                onPressed: (_isLoading || _isUploadingImages)
                    ? null
                    : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? suffixText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(color: Colors.blue),
      prefixIcon: Icon(prefixIcon, color: Colors.blueAccent),
      suffixText: suffixText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[800]!, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[900]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2.5),
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
    );
  }
}
