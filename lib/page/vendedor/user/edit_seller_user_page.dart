import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/page/vendedor/user/verify_seller_user_page.dart';
import 'package:flutter/material.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';

class EditSellerUserPage extends StatefulWidget {
  const EditSellerUserPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EditSellerUserPageState();
  }
}

class _EditSellerUserPageState extends State<EditSellerUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  String? _currentRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();

      for (final attribute in attributes) {
        debugPrint(
          'Attribute: ${attribute.userAttributeKey.key} = ${attribute.value}',
        );
        switch (attribute.userAttributeKey.key) {
          case 'email':
            _emailController.text = attribute.value;
            break;
          case 'phone_number':
            _phoneController.text = attribute.value;
            break;
          case 'custom:role':
            _currentRole = attribute.value;
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error al cargar los datos del usuario: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateUserAttributes() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final attributes = <AuthUserAttribute>[];
      final attributesNeedingVerification = <String, AuthUserAttributeKey>{};

      // Obtener atributos actuales para comparar
      final currentAttributes = await Amplify.Auth.fetchUserAttributes();
      final currentEmail = currentAttributes
          .firstWhere(
            (attr) => attr.userAttributeKey.key == 'email',
            orElse: () => const AuthUserAttribute(
              userAttributeKey: AuthUserAttributeKey.email,
              value: '',
            ),
          )
          .value;
      final currentPhone = currentAttributes
          .firstWhere(
            (attr) => attr.userAttributeKey.key == 'phone_number',
            orElse: () => const AuthUserAttribute(
              userAttributeKey: AuthUserAttributeKey.phoneNumber,
              value: '',
            ),
          )
          .value;

      // Email
      if (_emailController.text.trim() != currentEmail) {
        final emailAttribute = AuthUserAttribute(
          userAttributeKey: AuthUserAttributeKey.email,
          value: _emailController.text.trim(),
        );
        attributes.add(emailAttribute);
        attributesNeedingVerification['Email'] = AuthUserAttributeKey.email;
      }

      // Teléfono
      if (_phoneController.text.trim() != currentPhone &&
          _phoneController.text.trim().isNotEmpty) {
        final phoneAttribute = AuthUserAttribute(
          userAttributeKey: AuthUserAttributeKey.phoneNumber,
          value: _phoneController.text.trim(),
        );
        attributes.add(phoneAttribute);
        attributesNeedingVerification['Teléfono'] =
            AuthUserAttributeKey.phoneNumber;
      }

      if (attributes.isEmpty) {
        _showInfoSnackBar('No hay cambios para guardar');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await Amplify.Auth.updateUserAttributes(attributes: attributes);

      if (attributesNeedingVerification.isNotEmpty) {
        // Navegar a verificación
        await _handleVerification(attributesNeedingVerification);
      } else {
        _showSuccessSnackBar('Perfil actualizado exitosamente');
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error al actualizar el perfil: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleVerification(
    Map<String, AuthUserAttributeKey> attributesToVerify,
  ) async {
    for (final entry in attributesToVerify.entries) {
      final attributeName = entry.key;
      final attributeKey = entry.value;
      final attributeValue = attributeKey.key == 'email'
          ? _emailController.text.trim()
          : _phoneController.text.trim();

      if (!mounted) return;

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyAttributePage(
            attributeKey: attributeKey,
            attributeValue: attributeValue,
            attributeName: attributeName,
          ),
        ),
      );

      if (result == true) {
        // Verificación exitosa, continuar con siguiente atributo si existe
        continue;
      } else {
        // Usuario canceló o falló la verificación
        _showErrorSnackBar('Verificación cancelada para $attributeName');
        return;
      }
    }

    // Todas las verificaciones completadas
    _showSuccessSnackBar('¡Perfil actualizado y verificado exitosamente!');
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onError,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppLoadingIndicator(
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando datos...',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header con información del usuario
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 48,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Información del Usuario',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Rol: ${_currentRole ?? "No asignado"}',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Título de la sección
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Datos de Contacto',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),

                    // Campo Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: colorScheme.primary),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.error),
                        ),
                        helperText:
                            'Requerirá verificación si cambias el email',
                        helperStyle: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El email es requerido';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Ingresa un email válido';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Campo Teléfono
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Número de teléfono (opcional)',
                        labelStyle: TextStyle(color: colorScheme.primary),
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.error),
                        ),
                        helperText: 'Formato: +593XXXXXXXXX',
                        helperStyle: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null; // Teléfono es opcional
                        }
                        if (!value.startsWith('+')) {
                          return 'El teléfono debe incluir el código de país (+593)';
                        }
                        if (value.length < 12) {
                          return 'Ingresa un número válido';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Información adicional
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.secondary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.onSecondaryContainer,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Los cambios en email y teléfono requieren verificación mediante código.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: colorScheme.outline),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: _isLoading
                                ? null
                                : _updateUserAttributes,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: AppLoadingIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Guardar Cambios',
                                    style: textTheme.labelLarge?.copyWith(
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
