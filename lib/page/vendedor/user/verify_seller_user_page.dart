import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyAttributePage extends StatefulWidget {
  final AuthUserAttributeKey attributeKey;
  final String attributeValue;
  final String attributeName;

  const VerifyAttributePage({
    super.key,
    required this.attributeKey,
    required this.attributeValue,
    required this.attributeName,
  });

  @override
  State<VerifyAttributePage> createState()=> _VerifyAttributePageState();
}

class _VerifyAttributePageState extends State<VerifyAttributePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  int _countdown = 0;

  @override
  void dispose(){
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyAttribute()async {
    if (!_formKey.currentState!.validate()){
      return;
    }

    setState((){
      _isLoading = true;
    });

    try {
      await Amplify.Auth.confirmUserAttribute(
        userAttributeKey: widget.attributeKey,
        confirmationCode: _codeController.text.trim(),
      );

      if (mounted){
        _showSuccessDialog();
      }
    } on AuthException catch (e){
      _showErrorSnackBar('Error al verificar: ${e.message}');
    } catch (e){
      _showErrorSnackBar('Error inesperado: $e');
    } finally {
      if (mounted){
        setState((){
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode()async {
    if (_countdown > 0)return;

    setState((){
      _isResending = true;
    });

    try {
      await Amplify.Auth.sendUserAttributeVerificationCode(
        userAttributeKey: widget.attributeKey,
      );

      _showSuccessSnackBar('Código reenviado exitosamente');
      _startCountdown();
    } on AuthException catch (e){
      _showErrorSnackBar('Error al reenviar código: ${e.message}');
    } catch (e){
      _showErrorSnackBar('Error inesperado: $e');
    } finally {
      if (mounted){
        setState((){
          _isResending = false;
        });
      }
    }
  }

  void _startCountdown(){
    setState((){
      _countdown = 60;
    });

    Future.delayed(const Duration(seconds: 1), (){
      if (mounted && _countdown > 0){
        setState((){
          _countdown--;
        });
        _startCountdown();
      }
    });
  }

  void _showSuccessDialog(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context)=> AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('¡Verificación exitosa!'),
        content: Text(
          'Tu ${widget.attributeName.toLowerCase()} ha sido verificado correctamente.',
        ),
        actions: [
          ElevatedButton(
            onPressed: (){
              Navigator.of(context).pop(); // Cerrar dialog
              Navigator.of(
                context,
              ).pop(true); // Volver a editar perfil con resultado
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message){
    if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: (){
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message){
    if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String get _maskedValue {
    if (widget.attributeKey.key == 'email'){
      final email = widget.attributeValue;
      final parts = email.split('@');
      if (parts.length == 2){
        final username = parts[0];
        final domain = parts[1];
        final maskedUsername = username.length > 2
            ? '${username.substring(0, 2)}${'*' * (username.length - 2)}'
            : username;
        return '$maskedUsername@$domain';
      }
    } else if (widget.attributeKey.key == 'phone_number'){
      final phone = widget.attributeValue;
      if (phone.length > 6){
        return '${phone.substring(0, 4)}${'*' * (phone.length - 6)}${phone.substring(phone.length - 2)}';
      }
    }
    return widget.attributeValue;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Verificar ${widget.attributeName}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header con icono y mensaje
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      widget.attributeKey.key == 'email'
                          ? Icons.email_outlined
                          : Icons.phone_outlined,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Código de verificación',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hemos enviado un código de verificación a:',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _maskedValue,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Formulario de código
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Código de verificación',
                        hintText: '000000',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (value){
                        if (value == null || value.isEmpty){
                          return 'Ingresa el código de verificación';
                        }
                        if (value.length < 4){
                          return 'El código debe tener al menos 4 dígitos';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botón de verificar
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyAttribute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
                        'Verificar Código',
                        style: TextStyle(fontSize: 16),
                      ),
              ),

              const SizedBox(height: 16),

              // Botón de reenviar código
              TextButton(
                onPressed: (_isResending || _countdown > 0)
                    ? null
                    : _resendCode,
                child: _isResending
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
                    : _countdown > 0
                    ? Text(
                        'Reenviar código en ${_countdown}s',
                        style: TextStyle(color: Colors.grey[600]),
)
                    : const Text(
                        'Reenviar código',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const Spacer(),

              // Información adicional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Revisa tu bandeja de entrada y carpeta de spam. El código puede tardar unos minutos en llegar.',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
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
