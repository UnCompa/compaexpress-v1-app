import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/page/vendedor/user/verify_seller_user_page.dart';
import 'package:flutter/material.dart';

class EditSellerUserPage extends StatefulWidget {
  const EditSellerUserPage({super.key});

  @override
  State<StatefulWidget> createState(){
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
  void initState(){
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData()async {
    setState((){
      _isLoading = true;
    });

    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();

      for (final attribute in attributes){
        print("ATRIBUTOS");
        print(attribute);
        switch (attribute.userAttributeKey.key){
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
    } catch (e){
      _showErrorSnackBar('Error al cargar los datos del usuario: $e');
    } finally {
      setState((){
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserAttributes()async {
    if (!_formKey.currentState!.validate()){
      return;
    }

    setState((){
      _isLoading = true;
    });

    try {
      final attributes = <AuthUserAttribute>[];
      final attributesNeedingVerification = <String, AuthUserAttributeKey>{};

      // Obtener atributos actuales para comparar
      final currentAttributes = await Amplify.Auth.fetchUserAttributes();
      final currentEmail = currentAttributes
          .firstWhere(
            (attr)=> attr.userAttributeKey.key == 'email',
            orElse: ()=> const AuthUserAttribute(
              userAttributeKey: AuthUserAttributeKey.email,
              value: '',
            ),
)
          .value;
      final currentPhone = currentAttributes
          .firstWhere(
            (attr)=> attr.userAttributeKey.key == 'phone_number',
            orElse: ()=> const AuthUserAttribute(
              userAttributeKey: AuthUserAttributeKey.phoneNumber,
              value: '',
            ),
)
          .value;

      // Email
      if (_emailController.text.trim()!= currentEmail){
        final emailAttribute = AuthUserAttribute(
          userAttributeKey: AuthUserAttributeKey.email,
          value: _emailController.text.trim(),
        );
        attributes.add(emailAttribute);
        attributesNeedingVerification['Email'] = AuthUserAttributeKey.email;
      }

      // Teléfono
      if (_phoneController.text.trim()!= currentPhone &&
          _phoneController.text.trim().isNotEmpty){
        final phoneAttribute = AuthUserAttribute(
          userAttributeKey: AuthUserAttributeKey.phoneNumber,
          value: _phoneController.text.trim(),
        );
        attributes.add(phoneAttribute);
        attributesNeedingVerification['Teléfono'] =
            AuthUserAttributeKey.phoneNumber;
      }

      await Amplify.Auth.updateUserAttributes(attributes: attributes);

      if (attributesNeedingVerification.isNotEmpty){
        // Navegar a verificación
        await _handleVerification(attributesNeedingVerification);
      } else {
        _showSuccessSnackBar('Perfil actualizado exitosamente');
        Navigator.pop(context);
      }
    } catch (e){
      _showErrorSnackBar('Error al actualizar el perfil: $e');
    } finally {
      setState((){
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerification(
    Map<String, AuthUserAttributeKey> attributesToVerify,
  )async {
    for (final entry in attributesToVerify.entries){
      final attributeName = entry.key;
      final attributeKey = entry.value;
      final attributeValue = attributeKey.key == 'email'
          ? _emailController.text.trim()
          : _phoneController.text.trim();

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context)=> VerifyAttributePage(
            attributeKey: attributeKey,
            attributeValue: attributeValue,
            attributeName: attributeName,
          ),
        ),
      );

      if (result == true){
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
    Navigator.pop(context);
  }

  void _showErrorSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose(){
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edita tu perfil'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header con información del usuario
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.greenAccent.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.greenAccent,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rol: ${_currentRole ?? "N/A"}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Campo Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        helperText:
                            'Requerirá verificación si cambias el email',
                      ),
                      validator: (value){
                        if (value == null || value.isEmpty){
                          return 'El email es requerido';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)){
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
                      decoration: const InputDecoration(
                        labelText: 'Número de teléfono',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                        helperText: 'Formato: +593XXXXXXXXX',
                      ),
                      validator: (value){
                        if (value == null || value.isEmpty){
                          return null; // Teléfono es opcional
                        }
                        if (!value.startsWith('+')){
                          return 'El teléfono debe incluir el código de país (+593)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : (){
                                    Navigator.pop(context);
                                  },
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : _updateUserAttributes,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
)
                                : const Text('Guardar Cambios'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Información adicional
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Los cambios en email y teléfono requieren verificación.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
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
    );
  }
}
