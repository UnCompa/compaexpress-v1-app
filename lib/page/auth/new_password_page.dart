import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/page/auth/login_page.dart';
import 'package:flutter/material.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState()=> _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitNewPassword()async {
    if (!_formKey.currentState!.validate())return;

    setState((){
      _isLoading = true;
    });

    final newPassword = _passwordController.text.trim();

    try {
      final signInResult = LoginScreen.pendingSignInResult;
      if (signInResult == null){
        throw Exception("No hay sesión pendiente para cambio de contraseña.");
      }

      final result = await Amplify.Auth.confirmSignIn(
        confirmationValue: newPassword,
      );

      if (result.isSignedIn){
        // Navegar a la pantalla principal, o según el rol
        Navigator.of(
          context,
        ).pushReplacementNamed('/'); // o cualquier ruta que uses
      } else {
        _showError("No se pudo completar el cambio de contraseña.");
      }
    } on AuthException catch (e){
      _showError(e.message);
    } catch (e){
      _showError(e.toString());
    } finally {
      setState((){
        _isLoading = false;
      });
    }
  }

  void _showError(String? message){
    showDialog(
      context: context,
      builder: (_)=> AlertDialog(
        title: const Text('Error'),
        content: Text(message ?? 'Error desconocido'),
        actions: [
          TextButton(
            onPressed: ()=> Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Debes cambiar tu contraseña para continuar.'),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                ),
                obscureText: true,
                validator: (value){
                  if (value == null || value.isEmpty){
                    return 'La contraseña no puede estar vacía';
                  }
                  if (value.length < 8){
                    return 'La contraseña debe tener al menos 8 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitNewPassword,
                      child: const Text('Confirmar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
