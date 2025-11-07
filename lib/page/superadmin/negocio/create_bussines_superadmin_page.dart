import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/Negocio.dart';
import 'package:compaexpress/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CrearNegocioScreen extends StatefulWidget {
  const CrearNegocioScreen({super.key});

  @override
  State<CrearNegocioScreen> createState() => _CrearNegocioScreenState();
}

class _CrearNegocioScreenState extends State<CrearNegocioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _representanteController = TextEditingController();
  final _rucController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _durationController = TextEditingController();
  final _correoElectronicoController = TextEditingController();
  final _paisController = TextEditingController();
  final _provinciaController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _movilAccessController = TextEditingController();
  final _pcAccessController = TextEditingController();
  final _direccionController = TextEditingController();

  bool _isLoading = false;
  bool _isDurationInfinite = false;
  File? _selectedLogo;
  String? _logoKey;

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

  Future<void> _crearNegocio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Subir logo si está seleccionado
      if (_selectedLogo != null) {
        final fileName =
            'logos/${_nombreController.text}/${DateTime.now().millisecondsSinceEpoch}';
        _logoKey = await StorageService.uploadFile(_selectedLogo!, fileName);
      }

      final negocio = Negocio(
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
        logo: _logoKey,
        correoElectronico: _correoElectronicoController.text.isEmpty
            ? null
            : _correoElectronicoController.text,
        pais: _paisController.text.isEmpty ? null : _paisController.text,
        provincia: _provinciaController.text.isEmpty
            ? null
            : _provinciaController.text,
        ciudad: _ciudadController.text.isEmpty ? null : _ciudadController.text,
        movilAccess: _movilAccessController.text.isEmpty
            ? null
            : int.parse(_movilAccessController.text),
        pcAccess: _pcAccessController.text.isEmpty
            ? null
            : int.parse(_pcAccessController.text),
        direccion: _direccionController.text.isEmpty
            ? null
            : _direccionController.text,
        isDeleted: false,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
      );
      debugPrint("Negocio $negocio");
      final request = ModelMutations.create(negocio);

      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        throw Exception('Error al crear negocio: ${response.errors}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Negocio creado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        _limpiarFormulario();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      safePrint('Error creating business: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear negocio: ${e.toString()}'),
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

  void _limpiarFormulario() {
    _nombreController.clear();
    _representanteController.clear();
    _rucController.clear();
    _telefonoController.clear();
    _durationController.clear();
    _correoElectronicoController.clear();
    _paisController.clear();
    _provinciaController.clear();
    _ciudadController.clear();
    _movilAccessController.clear();
    _pcAccessController.clear();
    _direccionController.clear();
    setState(() {
      _selectedLogo = null;
      _logoKey = null;
      _isDurationInfinite = false;
    });
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Crear Negocio'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.surface, theme.colorScheme.surface],
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
                          theme.colorScheme.surface,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.business,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Nuevo Negocio',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete la información del negocio',
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
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _limpiarFormulario,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: const Text(
                          'Limpiar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _crearNegocio,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ?  Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Creando...',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              )
                            : const Text(
                                'Crear Negocio',
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
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Los campos marcados con (*) son obligatorios',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
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
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
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
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _selectedLogo != null
                    ? 'Logo seleccionado'
                    : 'Seleccionar logo',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _pickLogo,
            icon: const Icon(Icons.upload_file),
            label: Text(_selectedLogo != null ? 'Cambiar logo' : 'Subir logo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
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
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
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
        fillColor: enabled ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceBright,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
