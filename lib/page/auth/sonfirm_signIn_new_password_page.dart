import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class ConfirmSignInNewPasswordPage extends StatefulWidget {
  const ConfirmSignInNewPasswordPage({super.key});

  @override
  State<ConfirmSignInNewPasswordPage> createState()=>
      _ConfirmSignInNewPasswordPageState();
}

class _ConfirmSignInNewPasswordPageState
    extends State<ConfirmSignInNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;

  @override
  void dispose(){
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _confirmSignInWithNewPassword()async {
    if (!_formKey.currentState!.validate()){
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text){
      setState((){
        _errorMessage = 'Las contraseñas no coinciden';
      });
      return;
    }

    setState((){
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Amplify.Auth.updatePassword(
        oldPassword: "1234567890",
        newPassword: _newPasswordController.text.trim(),
      );

      Navigator.of(context).pushReplacementNamed('/home');
    } on AuthException catch (e){
      setState((){
        _errorMessage = _getErrorMessage(e);
      });
    } catch (e){
      setState((){
        _errorMessage = 'Error inesperado: ${e.toString()}';
      });
    } finally {
      if (mounted){
        setState((){
          _isLoading = false;
        });
      }
    }
  }

  void _handleNextStep(AuthNextStep nextStep){
    // Verificar el tipo de nextStep y manejar apropiadamente
    if (nextStep is AuthNextSignInStep){
      switch (nextStep.signInStep){
        case AuthSignInStep.confirmSignInWithNewPassword:
          // Permanecer en esta página
          break;
        case AuthSignInStep.confirmSignInWithSmsMfaCode:
          Navigator.of(context).pushReplacementNamed('/confirm-sms');
          break;
        case AuthSignInStep.confirmSignInWithTotpMfaCode:
          Navigator.of(context).pushReplacementNamed('/confirm-totp');
          break;
        case AuthSignInStep.confirmSignInWithCustomChallenge:
          Navigator.of(context).pushReplacementNamed('/confirm-custom');
          break;
        case AuthSignInStep.done:
          Navigator.of(context).pushReplacementNamed('/home');
          break;
        default:
          setState((){
            _errorMessage =
                'Paso de autenticación no soportado: ${nextStep.signInStep}';
          });
      }
    } else {
      setState((){
        _errorMessage = 'Tipo de paso no reconocido';
      });
    }
  }

  String _getErrorMessage(AuthException e){
    // Manejar diferentes tipos de excepciones de Amplify
    if (e is InvalidPasswordException){
      return 'La contraseña no cumple con los requisitos de seguridad';
    } else if (e is InvalidParameterException){
      return 'Parámetros inválidos';
    } else if (e is NotAuthorizedServiceException){
      return 'No autorizado. Verifica tus credenciales';
    } else if (e is UserNotConfirmedException){
      return 'Usuario no confirmado';
    } else if (e is TooManyRequestsException){
      return 'Demasiadas solicitudes. Intenta más tarde';
    } else if (e is LimitExceededException){
      return 'Límite de intentos excedido. Intenta más tarde';
    } else if (e is ExpiredCodeException){
      return 'El código ha expirado. Solicita uno nuevo';
    } else if (e is CodeMismatchException){
      return 'Código incorrecto';
    } else {
      return e.message.isNotEmpty ? e.message : 'Error de autenticación';
    }
  }

  String? _validatePassword(String? value){
    if (value == null || value.isEmpty){
      return 'Por favor ingresa una contraseña';
    }
    if (value.length < 8){
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    // Validar cada requisito por separado para mayor claridad
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    bool hasNumber = RegExp(r'\d').hasMatch(value);
    bool hasSpecialChar = RegExp(
      r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?`~]',
    ).hasMatch(value);

    List<String> missingRequirements = [];

    if (!hasLowercase)missingRequirements.add('• Una letra minúscula');
    if (!hasUppercase)missingRequirements.add('• Una letra mayúscula');
    if (!hasNumber)missingRequirements.add('• Un número');
    if (!hasSpecialChar)missingRequirements.add('• Un carácter especial');

    if (missingRequirements.isNotEmpty){
      return 'La contraseña debe contener al menos:\n${missingRequirements.join('\n')}';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value){
    if (value == null || value.isEmpty){
      return 'Por favor confirma tu contraseña';
    }
    if (value != _newPasswordController.text){
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Contraseña'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Icono y título
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),

                Text(
                  'Establecer Nueva Contraseña',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  'Por seguridad, debes establecer una nueva contraseña antes de continuar.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Campo de nueva contraseña
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_isNewPasswordVisible,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                    hintText: 'Ingresa tu nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: (){
                        setState((){
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de confirmar contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  validator: _validateConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    hintText: 'Confirma tu nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: (){
                        setState((){
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Mensaje de error
                if (_errorMessage != null)...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Botón de confirmar
                ElevatedButton(
                  onPressed: _isLoading ? null : _confirmSignInWithNewPassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                      : const Text(
                          'Establecer Contraseña',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Información adicional sobre requisitos de contraseña
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Requisitos de contraseña:',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Mínimo 8 caracteres\n'
                        '• Al menos una letra minúscula\n'
                        '• Al menos una letra mayúscula\n'
                        '• Al menos un número\n'
                        '• Al menos un carácter especial (!@#\$%^&*()_+-=[]{};\'"\\|,.<>/?`~)',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12),
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
}
