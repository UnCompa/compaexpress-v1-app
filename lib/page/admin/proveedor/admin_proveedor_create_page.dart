import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/negocio/negocio_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProveedorFormPage extends StatefulWidget {
  final Proveedor? proveedor; // null para crear, con datos para editar

  const ProveedorFormPage({super.key, this.proveedor});

  @override
  State<ProveedorFormPage> createState() => _ProveedorFormPageState();
}

class _ProveedorFormPageState extends State<ProveedorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _paisController = TextEditingController();
  final _tiempoEntregaController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;

  // Paleta de colores azules (misma que la lista)
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color cardBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _isEditing = widget.proveedor != null;

    if (_isEditing) {
      _nombreController.text = widget.proveedor!.nombre;
      _direccionController.text = widget.proveedor!.direccion;
      _paisController.text = widget.proveedor!.pais;
      _ciudadController.text = widget.proveedor!.ciudad;
      _tiempoEntregaController.text = widget.proveedor!.tiempoEntrega
          .toString();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _saveProveedor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final negocio = await NegocioController.getUserInfo();

      if (_isEditing) {
        // Actualizar proveedor existente
        final updatedProveedor = widget.proveedor!.copyWith(
          nombre: _nombreController.text.trim(),
          direccion: _direccionController.text,
          ciudad: _ciudadController.text,
          pais: _paisController.text,
          tiempoEntrega: int.parse(_tiempoEntregaController.text),
        );

        final request = ModelMutations.update(updatedProveedor);
        final response = await Amplify.API.mutate(request: request).response;

        if (response.data != null) {
          _showSuccessMessage('Proveedor actualizado exitosamente');
          Navigator.pop(context, true);
        } else {
          throw Exception('Error al actualizar el proveedor');
        }
      } else {
        // Crear nuevo proveedor
        final newProveedor = Proveedor(
          nombre: _nombreController.text.trim(),
          negocioID: negocio.negocioId,
          direccion: _direccionController.text,
          ciudad: _ciudadController.text,
          pais: _paisController.text,
          tiempoEntrega: int.parse(_tiempoEntregaController.text),
          isDeleted: false,
          createdAt: TemporalDateTime.now(),
          updatedAt: TemporalDateTime.now(),
        );

        final request = ModelMutations.create(newProveedor);
        final response = await Amplify.API.mutate(request: request).response;
        print("RESPONSE: $response");
        //await Amplify.DataStore.save(newProveedor);
        if (response.data != null) {
          _showSuccessMessage('Proveedor creado exitosamente');
          Navigator.pop(context, true);
        } else {
          throw Exception('Error al crear el proveedor');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      _showErrorMessage(_errorMessage!);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_nombreController.text.trim().isEmpty) {
      return true; // Permitir salir si no hay cambios
    }

    // Si hay texto, mostrar confirmación
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => _buildExitConfirmationDialog(),
    );

    return shouldPop ?? false;
  }

  Widget _buildExitConfirmationDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Descartar cambios',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: darkBlue,
        ),
      ),
      content: Text(
        '¿Estás seguro de que deseas salir? Los cambios no guardados se perderán.',
        style: GoogleFonts.poppins(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancelar',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
          ),
          child: Text('Descartar', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomActions(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Text(
        _isEditing ? 'Editar Proveedor' : 'Nuevo Proveedor',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () async {
          final shouldPop = await _onWillPop();
          if (shouldPop) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildFormCard(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Icon(
              _isEditing ? Icons.edit_rounded : Icons.add_business_rounded,
              size: 48,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isEditing ? 'Modificar Información' : 'Agregar Nuevo Proveedor',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: darkBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _isEditing
                ? 'Actualiza los datos del proveedor existente'
                : 'Completa la información para crear un nuevo proveedor',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Proveedor',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 16),
            _buildNombreField(),
            const SizedBox(height: 16),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildNombreField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre del Proveedor *',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _nombreController,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Ingresa el nombre del proveedor',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.business_rounded, color: lightBlue),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accentBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 14, color: darkBlue),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre del proveedor es obligatorio';
            }
            if (value.trim().length < 2) {
              return 'El nombre debe tener al menos 2 caracteres';
            }
            if (value.trim().length > 100) {
              return 'El nombre no puede exceder 100 caracteres';
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
          maxLength: 100,
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) {
                return Text(
                  '$currentLength/${maxLength ?? 0}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                );
              },
        ),
        Text(
          'Dirección del Proveedor *',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: darkBlue,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _direccionController,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Ingresa la dirección del proveedor',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.location_on, color: lightBlue),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accentBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 14, color: darkBlue),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La dirección del proveedor es obligatorio';
            }
            if (value.trim().length < 2) {
              return 'La dirección debe tener al menos 2 caracteres';
            }
            if (value.trim().length > 100) {
              return 'La dirección no puede exceder 50 caracteres';
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
          maxLength: 50,
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) {
                return Text(
                  '$currentLength/${maxLength ?? 0}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                );
              },
        ),
        Text(
          'Pais del Proveedor *',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _paisController,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Ingresa el pais del proveedor',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.flag, color: lightBlue),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accentBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 14, color: darkBlue),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El país del proveedor es obligatorio';
            }
            if (value.trim().length < 2) {
              return 'El país debe tener al menos 2 caracteres';
            }
            if (value.trim().length > 100) {
              return 'El país no puede exceder 30 caracteres';
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
          maxLength: 30,
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) {
                return Text(
                  '$currentLength/${maxLength ?? 0}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                );
              },
        ),
        Text(
          'Ciudad del Proveedor *',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: darkBlue,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _ciudadController,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Ingresa la ciudad del proveedor',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.apartment, color: lightBlue),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accentBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 14, color: darkBlue),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La ciudad del proveedor es obligatorio';
            }
            if (value.trim().length < 2) {
              return 'La ciudad debe tener al menos 2 caracteres';
            }
            if (value.trim().length > 100) {
              return 'La ciudad no puede exceder 30 caracteres';
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
          maxLength: 30,
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) {
                return Text(
                  '$currentLength/${maxLength ?? 0}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                );
              },
        ),
        Text(
          'Tiempo Estimado del Proveedor *',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: darkBlue,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _tiempoEntregaController,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Tiempo estimado en días',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.timer, color: lightBlue),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accentBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.poppins(fontSize: 14, color: darkBlue),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El tiempo estimado es obligatorio';
            }
            final valueInt = int.tryParse(value);
            if (valueInt == null) {
              return 'El tiempo estimado es invalido';
            }
            return null;
          },
          maxLength: 3,
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: lightBlue.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: accentBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'El proveedor se creará activo por defecto y será asociado automáticamente a tu negocio.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: darkBlue,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.red[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        final shouldPop = await _onWillPop();
                        if (shouldPop) {
                          Navigator.pop(context);
                        }
                      },
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProveedor,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isEditing ? Icons.save_rounded : Icons.add_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEditing ? 'Guardar Cambios' : 'Crear Proveedor',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
