import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/providers/proveedor_provider.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
class ProveedorFormPage extends ConsumerStatefulWidget {
  final Proveedor? proveedor;

  const ProveedorFormPage({super.key, this.proveedor});

  @override
  ConsumerState<ProveedorFormPage> createState() => _ProveedorFormPageState();
}

class _ProveedorFormPageState extends ConsumerState<ProveedorFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _ciudadCtrl;
  late final TextEditingController _direccionCtrl;
  // TODO: Descomentar cuando estos campos estén en el modelo
  // late final TextEditingController _telefonoCtrl;
  // late final TextEditingController _emailCtrl;
  // late final TextEditingController _rucCiCtrl;
  // late final TextEditingController _notasCtrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final p = widget.proveedor;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _ciudadCtrl = TextEditingController(text: p?.ciudad ?? '');
    _direccionCtrl = TextEditingController(text: p?.direccion ?? '');
    // TODO: Descomentar cuando estos campos estén en el modelo
    // _telefonoCtrl = TextEditingController(text: p?.telefono ?? '');
    // _emailCtrl = TextEditingController(text: p?.email ?? '');
    // _rucCiCtrl = TextEditingController(text: p?.rucCi ?? '');
    // _notasCtrl = TextEditingController(text: p?.notas ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _ciudadCtrl.dispose();
    _direccionCtrl.dispose();
    // TODO: Descomentar cuando estos campos estén en el modelo
    // _telefonoCtrl.dispose();
    // _emailCtrl.dispose();
    // _rucCiCtrl.dispose();
    // _notasCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.proveedor != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  /* ---------------- AppBar ---------------- */

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      title: Text(
        _isEditing ? 'Editar Proveedor' : 'Nuevo Proveedor',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SpinKitCircle(color: theme.colorScheme.onPrimary, size: 24),
          ),
      ],
    );
  }

  /* ---------------- Body ---------------- */

  Widget _buildBody(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(theme),
            const SizedBox(height: 16),
            _buildFormSection(
              theme: theme,
              title: 'Información Básica',
              icon: Icons.business_rounded,
              children: [
                _buildTextField(
                  controller: _nombreCtrl,
                  label: 'Nombre del proveedor',
                  hint: 'Ej: Distribuidora ABC',
                  icon: Icons.store_rounded,
                  validator: (v) =>
                      v?.isEmpty == true ? 'Campo requerido' : null,
                  theme: theme,
                ),
                // TODO: Descomentar cuando RUC/CI esté en el modelo
                // const SizedBox(height: 16),
                // _buildTextField(
                //   controller: _rucCiCtrl,
                //   label: 'RUC/CI',
                //   hint: 'Ej: 1234567890001',
                //   icon: Icons.badge_rounded,
                //   theme: theme,
                //   keyboardType: TextInputType.number,
                // ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormSection(
              theme: theme,
              title: 'Ubicación',
              icon: Icons.location_on_rounded,
              children: [
                _buildTextField(
                  controller: _ciudadCtrl,
                  label: 'Ciudad',
                  hint: 'Ej: Quito',
                  icon: Icons.location_city_rounded,
                  theme: theme,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _direccionCtrl,
                  label: 'Dirección',
                  hint: 'Ej: Av. Principal #123',
                  icon: Icons.home_rounded,
                  theme: theme,
                  maxLines: 2,
                ),
              ],
            ),
            const SizedBox(height: 16),
            /* 
            _buildFormSection(
              theme: theme,
              title: 'Contacto',
              icon: Icons.contact_phone_rounded,
              children: [
                _buildTextField(
                  controller: _telefonoCtrl,
                  label: 'Teléfono',
                  hint: 'Ej: 0987654321',
                  icon: Icons.phone_rounded,
                  theme: theme,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'Ej: contacto@proveedor.com',
                  icon: Icons.email_rounded,
                  theme: theme,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v?.isEmpty == true) return null;
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    return emailRegex.hasMatch(v!) ? null : 'Email inválido';
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildFormSection(
              theme: theme,
              title: 'Notas Adicionales',
              icon: Icons.note_rounded,
              children: [
                _buildTextField(
                  controller: _notasCtrl,
                  label: 'Notas',
                  hint: 'Información adicional...',
                  icon: Icons.notes_rounded,
                  theme: theme,
                  maxLines: 4,
                ),
              ],
            ), */
            const SizedBox(height: 100), // Espacio para el bottom bar
          ],
        ),
      ),
    );
  }

  /* ---------------- Info Card ---------------- */

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isEditing
                    ? 'Modifica la información del proveedor'
                    : 'Completa los datos del nuevo proveedor',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------------- Form Section ---------------- */

  Widget _buildFormSection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  /* ---------------- Text Field ---------------- */

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: theme.textTheme.bodyLarge,
    );
  }

  /* ---------------- Bottom Bar ---------------- */

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _onSubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: AppLoadingIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Icon(_isEditing ? Icons.save_rounded : Icons.add_rounded),
                label: Text(_isEditing ? 'Guardar Cambios' : 'Crear Proveedor'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------------- Submit ---------------- */

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userData = await NegocioService.getCurrentUserInfo();
      final nombre = _nombreCtrl.text.trim();
      final ciudad = _ciudadCtrl.text.trim().isEmpty
          ? null
          : _ciudadCtrl.text.trim();
      final direccion = _direccionCtrl.text.trim().isEmpty
          ? null
          : _direccionCtrl.text.trim();
      /* final telefono = _telefonoCtrl.text.trim().isEmpty
          ? null
          : _telefonoCtrl.text.trim();
      final email = _emailCtrl.text.trim().isEmpty
          ? null
          : _emailCtrl.text.trim();
      final rucCi = _rucCiCtrl.text.trim().isEmpty
          ? null
          : _rucCiCtrl.text.trim();
      final notas = _notasCtrl.text.trim().isEmpty
          ? null
          : _notasCtrl.text.trim(); */

      final proveedor = widget.proveedor == null
          ? Proveedor(
              nombre: nombre,
              ciudad: ciudad ?? "",
              direccion: direccion ?? "",
              pais: ciudad ?? "",
              tiempoEntrega: 0,
              isDeleted: false,
              createdAt: TemporalDateTime.now(),
              updatedAt: TemporalDateTime.now(),
              negocioID: userData.negocioId,
              //telefono: telefono,
              //email: email,
              //rucCi: rucCi,
              //notas: notas,
            )
          : widget.proveedor!.copyWith(
              nombre: nombre,
              ciudad: ciudad,
              direccion: direccion,
              //telefono: telefono,
              //email: email,
              //rucCi: rucCi,
              //notas: notas,
            );

      final success = _isEditing
          ? await ref.read(proveedorProvider.notifier).update(proveedor)
          : await ref.read(proveedorProvider.notifier).create(proveedor);

      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
