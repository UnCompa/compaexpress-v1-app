import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserSuperadminConfirmPage extends StatefulWidget {
  final String? username;

  const UserSuperadminConfirmPage({super.key, this.username});

  @override
  State<UserSuperadminConfirmPage> createState()=> _UserConfirmationPageState();
}

class _UserConfirmationPageState extends State<UserSuperadminConfirmPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _confirmationCodeController = TextEditingController();

  bool _isLoading = false;
  bool _isResendingCode = false;

  @override
  void initState(){
    super.initState();
    // Si se proporciona un username, lo prellenamos
    if (widget.username != null){
      _usernameController.text = widget.username!;
    }
  }

  @override
  void dispose(){
    _usernameController.dispose();
    _confirmationCodeController.dispose();
    super.dispose();
  }

  /// Confirma el registro del usuario con el código de verificación
  Future<void> confirmUser({
    required String username,
    required String confirmationCode,
  })async {
    setState((){
      _isLoading = true;
    });

    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );

      // Check if further confirmations are needed or if
      // the sign up is complete.
      await _handleSignUpResult(result);
    } on AuthException catch (e){
      safePrint('Error confirming user: ${e.message}');
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e.message)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted){
        setState((){
          _isLoading = false;
        });
      }
    }
  }

  /// Reenvía el código de confirmación
  Future<void> resendConfirmationCode({required String username})async {
    setState((){
      _isResendingCode = true;
    });

    try {
      await Amplify.Auth.resendSignUpCode(username: username);
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código de confirmación reenviado. Revisa tu email.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } on AuthException catch (e){
      safePrint('Error resending confirmation code: ${e.message}');
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reenviar código: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted){
        setState((){
          _isResendingCode = false;
        });
      }
    }
  }

  Future<void> _handleSignUpResult(SignUpResult result)async {
    switch (result.nextStep.signUpStep){
      case AuthSignUpStep.confirmSignUp:
        safePrint('Additional confirmation required');
        if (mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se requiere confirmación adicional'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        break;
      case AuthSignUpStep.done:
        safePrint('Sign up confirmation is complete');
        if (mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Usuario confirmado exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navegar de vuelta o a la página principal
          Navigator.of(context).pop(true);
        }
        break;
    }
  }

  String _getErrorMessage(String error){
    if (error.toLowerCase().contains('invalid verification code')){
      return 'Código de verificación inválido';
    } else if (error.toLowerCase().contains('user not found')){
      return 'Usuario no encontrado';
    } else if (error.toLowerCase().contains('expired')){
      return 'El código de verificación ha expirado';
    }
    return 'Error de confirmación: $error';
  }

  void _submitForm()async {
    if (_formKey.currentState!.validate()){
      await confirmUser(
        username: _usernameController.text.trim(),
        confirmationCode: _confirmationCodeController.text.trim(),
      );
    }
  }

  void _resendCode()async {
    if (_usernameController.text.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa el nombre de usuario para reenviar el código'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await resendConfirmationCode(username: _usernameController.text.trim());
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Usuario'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.email_outlined, size: 64, color: Colors.blue),
              const SizedBox(height: 16),

              const Text(
                'Verificación de Email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              const Text(
                'Ingresa el código de verificación que enviamos a tu email',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Usuario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                enabled:
                    widget.username ==
                    null, // Solo editable si no se pasó como parámetro
                validator: (value){
                  if (value == null || value.trim().isEmpty){
                    return 'El nombre de usuario es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirmation code field
              TextFormField(
                controller: _confirmationCodeController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                    6,
                  ), // Asumiendo códigos de 6 dígitos
                ],
                decoration: const InputDecoration(
                  labelText: 'Código de Verificación',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.security),
                  hintText: '123456',
                ),
                validator: (value){
                  if (value == null || value.trim().isEmpty){
                    return 'El código de verificación es requerido';
                  }
                  if (value.length < 4){
                    return 'Ingresa un código válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Confirm button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Confirmando...'),
                        ],
)
                    : const Text(
                        'Confirmar Usuario',
                        style: TextStyle(fontSize: 16),
                      ),
              ),

              const SizedBox(height: 16),

              // Resend code button
              TextButton(
                onPressed: (_isLoading || _isResendingCode)
                    ? null
                    : _resendCode,
                child: _isResendingCode
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Reenviando...'),
                        ],
)
                    : const Text('¿No recibiste el código? Reenviar'),
              ),

              const SizedBox(height: 32),

              // Help text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(height: 8),
                    Text(
                      'Revisa tu bandeja de entrada y carpeta de spam. El código de verificación puede tardar unos minutos en llegar.',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
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
