import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/page/admin/admin_page.dart';
import 'package:compaexpress/page/auth/reset_password_page.dart';
import 'package:compaexpress/page/vendedor/seller_page.dart';
import 'package:compaexpress/services/user_service.dart';
import 'package:compaexpress/views/login_form.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static SignInResult? pendingSignInResult;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  // Variable para guardar el resultado del signIn cuando se requiere cambio de contraseña

  Future<void> signInUser(
    BuildContext context,
    String username,
    String password,
  ) async {
    try {
      await Amplify.Auth.signOut();
      debugPrint("Intentando login con: $username / $password");
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );

      if (result.isSignedIn) {
        debugPrint("Login exitoso");
        //await _navigateByUserRole(context);
        await _navigateByUserGroup(context);
      } else {
        debugPrint("Login fallido");
        await _handleSignInResult(context, result, username);
        setState(() => isLoading = false);
      }
    } on AuthException catch (e) {
      _showErrorDialog(context, 'Crendeciales incorrectas');
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleSignInResult(
    BuildContext context,
    SignInResult result,
    String username,
  ) async {
    switch (result.nextStep.signInStep) {
      case AuthSignInStep.confirmSignInWithNewPassword:
        // Guardamos el resultado para usarlo en la pantalla de cambio de contraseña
        LoginScreen.pendingSignInResult = result;
        // Navegamos a la pantalla de cambio de contraseña
        Navigator.of(context).pushReplacementNamed("/login/newpassword");
        break;

      case AuthSignInStep.confirmSignInWithSmsMfaCode:
      case AuthSignInStep.confirmSignInWithCustomChallenge:
      case AuthSignInStep.confirmSignUp:
      case AuthSignInStep.resetPassword:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(username: username),
          ),
        );
        break;

      case AuthSignInStep.done:
        await _navigateByUserRole(context);
        break;

      default:
        _showErrorDialog(
          context,
          'Paso de autenticación no implementado: ${result.nextStep.signInStep.name}',
        );
    }
  }

  Future<void> _navigateByUserRole(BuildContext context) async {
    try {
      final userAttributes = await Amplify.Auth.fetchUserAttributes();
      final roleAttr = userAttributes.firstWhere(
        (attr) => attr.userAttributeKey.key == 'custom:role',
        orElse: () => const AuthUserAttribute(
          userAttributeKey: CognitoUserAttributeKey.custom('role'),
          value: 'unknown',
        ),
      );

      final role = roleAttr.value.toLowerCase();
      print("ROL QUE INGRESA");
      print(role);
      switch (role) {
        case 'superadmin':
          Navigator.of(context).pushReplacementNamed('/superadmin');
          break;
        case 'admin':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminPage()),
          );
          break;
        case 'vendedor':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SellerPage()),
          );
          break;
        default:
          _showErrorDialog(context, 'Rol no autorizado: $role');
      }
    } on AuthException catch (e) {
      _showErrorDialog(
        context,
        'No se pudieron obtener los atributos del usuario: ${e.message}',
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _navigateByUserGroup(BuildContext context) async {
    try {
      final authSession = await Amplify.Auth.fetchAuthSession();

      if (authSession is CognitoAuthSession) {
        final idToken = authSession.userPoolTokensResult.value.idToken;

        final decodedToken = JwtDecoder.decode(idToken.raw);
        final List<dynamic> groups = decodedToken['cognito:groups'] ?? [];
        debugPrint(groups.toString());
        UserService.saveUserRoleLocally(groups.first);
        if (groups.contains('superadmin')) {
          Navigator.of(context).pushReplacementNamed('/superadmin');
        } else if (groups.contains('admin')) {
          Navigator.of(context).pushReplacementNamed('/admin');
        } else if (groups.contains('vendedor')) {
          Navigator.of(context).pushReplacementNamed('/vendedor');
        } else {
          _showErrorDialog(
            context,
            'Grupo no autorizado: ${groups.join(", ")}',
          );
        }
      } else {
        _showErrorDialog(context, 'Sesión inválida');
      }
    } on AuthException catch (e) {
      _showErrorDialog(context, 'Error al obtener el token: ${e.message}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
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
    return Scaffold(
      body: LoginForm(
        onLogin: (email, password) {
          setState(() => isLoading = true);
          signInUser(context, email, password);
        },
        isLoading: isLoading,
      ),
    );
  }
}
