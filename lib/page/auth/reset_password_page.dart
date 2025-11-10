import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
class ResetPasswordPage extends StatefulWidget {
  final String username; // Agregamos el username como parámetro
  const ResetPasswordPage({super.key, required this.username});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController(); // Controlador para el código
  bool _isLoading = false;

  Future<void> _submitNewPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final newPassword = _passwordController.text.trim();
    final confirmationCode = _codeController.text.trim();

    try {
      // Confirmar el restablecimiento de contraseña
      await Amplify.Auth.confirmResetPassword(
        username: widget.username, // Usamos el username pasado como parámetro
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );

      // Intentar iniciar sesión automáticamente después de restablecer
      final signInResult = await Amplify.Auth.signIn(
        username: widget.username,
        password: newPassword,
      );

      if (signInResult.isSignedIn) {
        // Navegar a la pantalla principal
        Navigator.of(context).pop();
      } else {
        _showError(
          "No se pudo iniciar sesión después de restablecer la contraseña.",
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String? message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message ?? 'Error desconocido'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restablecer Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Debes cambiar tu contraseña para continuar.'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Código de verificación',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El código de verificación es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña no puede estar vacía';
                  }
                  if (value.length < 8) {
                    return 'La contraseña debe tener al menos 8 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const AppLoadingIndicator()
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
