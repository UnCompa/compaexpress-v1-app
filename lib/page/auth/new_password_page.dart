import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/page/auth/login_page.dart';
import 'package:flutter/material.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? _passwordError;

  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecial = false;
  bool _hasMinLength = false;

  void _validatePassword(String value) {
    setState(() {
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasLowercase = value.contains(RegExp(r'[a-z]'));
      _hasDigit = value.contains(RegExp(r'[0-9]'));
      _hasSpecial = value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>-_]'));
      _hasMinLength = value.length >= 8;
    });
  }

  Future<void> _submitNewPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final newPassword = _passwordController.text.trim();

    try {
      final signInResult = LoginScreen.pendingSignInResult;
      if (signInResult == null) {
        throw Exception("No hay sesión pendiente para cambio de contraseña.");
      }

      final result = await Amplify.Auth.confirmSignIn(
        confirmationValue: newPassword,
      );

      if (result.isSignedIn) {
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        _showError("No se pudo completar el cambio de contraseña.");
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Debes cambiar tu contraseña para continuar.'),
              const SizedBox(height: 16),

              // Nueva contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                onChanged: _validatePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña no puede estar vacía';
                  }
                  if (!(_hasUppercase &&
                      _hasLowercase &&
                      _hasDigit &&
                      _hasSpecial &&
                      _hasMinLength)) {
                    return 'No cumple con los requisitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Confirmar contraseña
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Requisitos de contraseña
              Text(
                'La contraseña debe tener:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              _buildRequirement('Al menos 8 caracteres', _hasMinLength),
              _buildRequirement('Una mayúscula', _hasUppercase),
              _buildRequirement('Una minúscula', _hasLowercase),
              _buildRequirement('Un número', _hasDigit),
              _buildRequirement('Un símbolo especial', _hasSpecial),

              const SizedBox(height: 20),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
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

  Widget _buildRequirement(String text, bool met) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.circle,
          color: met ? Colors.green : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: met ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
