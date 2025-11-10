import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:compaexpress/models/Negocio.dart';
import 'package:compaexpress/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
class EditBussinesSuperadminPage extends StatefulWidget {
  final Negocio negocio;
  const EditBussinesSuperadminPage({super.key, required this.negocio});

  @override
  State<EditBussinesSuperadminPage> createState() =>
      _EditBussinesSuperadminPageState();
}

class _EditBussinesSuperadminPageState
    extends State<EditBussinesSuperadminPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _representanteController;
  late TextEditingController _rucController;
  late TextEditingController _telefonoController;
  late TextEditingController _durationController;
  late TextEditingController _correoElectronicoController;
  late TextEditingController _paisController;
  late TextEditingController _provinciaController;
  late TextEditingController _ciudadController;
  late TextEditingController _movilAccessController;
  late TextEditingController _pcAccessController;
  late TextEditingController _direccionController;
  late TextEditingController _createdAtController;

  bool _isLoading = false;
  bool _isDurationInfinite = false;
  File? _selectedLogo;
  String? _currentLogoKey;
  String? _newLogoKey;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.negocio.nombre ?? '',
    );
    _representanteController = TextEditingController(
      text: widget.negocio.representate ?? '',
    );
    _rucController = TextEditingController(text: widget.negocio.ruc ?? '');
    _telefonoController = TextEditingController(
      text: widget.negocio.telefono ?? '',
    );
    _correoElectronicoController = TextEditingController(
      text: widget.negocio.correoElectronico ?? '',
    );
    _paisController = TextEditingController(text: widget.negocio.pais ?? '');
    _provinciaController = TextEditingController(
      text: widget.negocio.provincia ?? '',
    );
    _ciudadController = TextEditingController(
      text: widget.negocio.ciudad ?? '',
    );
    _movilAccessController = TextEditingController(
      text: widget.negocio.movilAccess?.toString() ?? '',
    );
    _pcAccessController = TextEditingController(
      text: widget.negocio.pcAccess?.toString() ?? '',
    );
    _direccionController = TextEditingController(
      text: widget.negocio.direccion ?? '',
    );
    _createdAtController = TextEditingController(
      text: widget.negocio.createdAt.toString() ?? '',
    );

    // Configurar duración
    if (widget.negocio.duration == -1) {
      _isDurationInfinite = true;
      _durationController = TextEditingController(text: 'Infinito');
    } else {
      _durationController = TextEditingController(
        text: widget.negocio.duration?.toString() ?? '',
      );
    }
    _currentLogoKey = widget.negocio.logo;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _representanteController.dispose();
    _rucController.dispose();
    _telefonoController.dispose();
    _durationController.dispose();
    _correoElectronicoController.dispose();
    _paisController.dispose();
    _provinciaController.dispose();
    _ciudadController.dispose();
    _movilAccessController.dispose();
    _pcAccessController.dispose();
    _direccionController.dispose();
    _createdAtController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Mostrar dialog para elegir entre cámara o galería
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Seleccionar Logo'),
            content: const Text('¿Desde dónde quieres seleccionar el logo?'),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cámara'),
              ),
              TextButton.icon(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galería'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );

      if (source != null) {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          setState(() {
            _selectedLogo = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      safePrint('Error picking logo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al seleccionar el logo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleInfiniteDuration() {
    setState(() {
      _isDurationInfinite = !_isDurationInfinite;
      if (_isDurationInfinite) {
        _durationController.text = 'Infinito';
      } else {
        _durationController.clear();
      }
    });
  }

  Future<String?> _getCurrentLogoUrl() async {
    if (_currentLogoKey == null) return null;

    try {
      final getUrlResult = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(_currentLogoKey!),
        options: StorageGetUrlOptions(
          pluginOptions: S3GetUrlPluginOptions(
            validateObjectExistence: true,
            expiresIn: Duration(days: 1),
          ),
        ),
      ).result;
      debugPrint('Logo URL: ${getUrlResult.url.toString()}');
      return getUrlResult.url.toString();
    } catch (e) {
      safePrint('Error getting logo URL: $e');
      return null;
    }
  }

  Future<void> _editarNegocio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Subir nuevo logo si está seleccionado
      if (_selectedLogo != null) {
        final fileName =
            'logos/${_nombreController.text}/${DateTime.now().millisecondsSinceEpoch}';
        _newLogoKey = await StorageService.uploadFile(_selectedLogo!, fileName);
      }

      final request = ModelMutations.update(
        Negocio(
          id: widget.negocio.id,
          nombre: _nombreController.text,
          representate: _representanteController.text.isEmpty
              ? null
              : _representanteController.text,
          ruc: _rucController.text,
          telefono: _telefonoController.text.isEmpty
              ? null
              : _telefonoController.text,
          duration: _isDurationInfinite
              ? null
              : (_durationController.text.isEmpty
                    ? null
                    : int.parse(_durationController.text)),
          logo: _newLogoKey ?? _currentLogoKey,
          correoElectronico: _correoElectronicoController.text.isEmpty
              ? null
              : _correoElectronicoController.text,
          pais: _paisController.text.isEmpty ? null : _paisController.text,
          provincia: _provinciaController.text.isEmpty
              ? null
              : _provinciaController.text,
          ciudad: _ciudadController.text.isEmpty
              ? null
              : _ciudadController.text,
          movilAccess: _movilAccessController.text.isEmpty
              ? null
              : int.parse(_movilAccessController.text),
          pcAccess: _pcAccessController.text.isEmpty
              ? null
              : int.parse(_pcAccessController.text),
          direccion: _direccionController.text.isEmpty
              ? null
              : _direccionController.text,
          isDeleted: widget.negocio.isDeleted,
          createdAt: widget.negocio.createdAt,
          updatedAt: widget.negocio.updatedAt,
        ),
      );
      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        throw Exception('Error al editar negocio: ${response.errors}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Negocio editado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      safePrint('Error editing business: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al editar negocio: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validarCampoRequerido(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return '$campo es requerido';
    }
    return null;
  }

  String? _validarRuc(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'RUC es requerido';
    }
    final ruc = valor.trim();
    if (ruc.length != 13) {
      return 'RUC debe tener 13 dígitos';
    }
    if (!RegExp(r'^\d+$').hasMatch(ruc)) {
      return 'RUC solo debe contener números';
    }
    return null;
  }

  String? _validarTelefono(String? valor) {
    if (valor != null && valor.isNotEmpty) {
      if (!RegExp(r'^\d{10}$').hasMatch(valor.trim())) {
        return 'Teléfono debe tener 10 dígitos';
      }
    }
    return null;
  }

  String? _validarEmail(String? valor) {
    if (valor != null && valor.isNotEmpty) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(valor.trim())) {
        return 'Formato de correo electrónico inválido';
      }
    }
    return null;
  }

  String? _validarNumeroEntero(String? valor, String campo) {
    if (valor != null && valor.isNotEmpty && valor != 'Infinito') {
      if (int.tryParse(valor) == null) {
        return '$campo debe ser un número entero';
      }
      if (int.parse(valor) < 0) {
        return '$campo debe ser mayor o igual a 0';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Negocio'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado
                Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.1),
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.business,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Editar Negocio',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Modifique la información del negocio',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Logo
                _buildSectionTitle('Logo del Negocio'),
                const SizedBox(height: 16),

                _buildLogoSelector(),

                const SizedBox(height: 24),

                // Información básica
                _buildSectionTitle('Información Básica'),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _nombreController,
                  labelText: 'Nombre del Negocio *',
                  icon: Icons.store,
                  validator: (value) => _validarCampoRequerido(value, 'Nombre'),
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _representanteController,
                  labelText: 'Representante',
                  icon: Icons.person,
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _rucController,
                  labelText: 'RUC *',
                  icon: Icons.receipt_long,
                  validator: _validarRuc,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _telefonoController,
                        labelText: 'Teléfono',
                        icon: Icons.phone,
                        validator: _validarTelefono,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _correoElectronicoController,
                        labelText: 'Correo Electrónico',
                        icon: Icons.email,
                        validator: _validarEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Ubicación
                _buildSectionTitle('Ubicación'),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _paisController,
                        labelText: 'País',
                        icon: Icons.public,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _provinciaController,
                        labelText: 'Provincia',
                        icon: Icons.map,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _ciudadController,
                        labelText: 'Ciudad',
                        icon: Icons.location_city,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _direccionController,
                  labelText: 'Dirección',
                  icon: Icons.location_on,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 24),

                // Configuración de acceso
                _buildSectionTitle('Configuración de Acceso'),
                const SizedBox(height: 16),

                // Duración con botón infinito
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _durationController,
                        labelText: 'Duración (días)',
                        icon: Icons.schedule,
                        validator: (value) =>
                            _validarNumeroEntero(value, 'Duración'),
                        keyboardType: _isDurationInfinite
                            ? null
                            : TextInputType.number,
                        inputFormatters: _isDurationInfinite
                            ? null
                            : [FilteringTextInputFormatter.digitsOnly],
                        enabled: !_isDurationInfinite,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: _isDurationInfinite
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: _toggleInfiniteDuration,
                        icon: const Icon(Icons.all_inclusive),
                        color: _isDurationInfinite
                            ? Colors.white
                            : Colors.grey.shade600,
                        tooltip: _isDurationInfinite
                            ? 'Desactivar duración infinita'
                            : 'Activar duración infinita',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _movilAccessController,
                        labelText: 'Acceso Móvil',
                        icon: Icons.smartphone,
                        validator: (value) =>
                            _validarNumeroEntero(value, 'Acceso Móvil'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _pcAccessController,
                        labelText: 'Acceso PC',
                        icon: Icons.computer,
                        validator: (value) =>
                            _validarNumeroEntero(value, 'Acceso PC'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Botones
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _editarNegocio,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: AppLoadingIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Guardando...',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              )
                            : const Text(
                                'Guardar Cambios',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Nota informativa
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Los campos marcados con (*) son obligatorios',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          // Mostrar logo actual o seleccionado
          if (_selectedLogo != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedLogo!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nuevo logo seleccionado',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ] else if (_currentLogoKey != null) ...[
            FutureBuilder<String?>(
              future: _getCurrentLogoUrl(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          snapshot.data!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Logo actual',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  );
                } else {
                  return Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                }
              },
            ),
          ] else ...[
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_photo_alternate,
                color: Colors.grey,
                size: 40,
              ),
            ),
          ],

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _selectedLogo != null
                    ? 'Nuevo logo seleccionado'
                    : _currentLogoKey != null
                    ? 'Cambiar logo actual'
                    : 'Seleccionar logo',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _pickLogo,
            icon: const Icon(Icons.upload_file),
            label: Text(
              _currentLogoKey != null || _selectedLogo != null
                  ? 'Cambiar logo'
                  : 'Subir logo',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
