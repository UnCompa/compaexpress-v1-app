import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/page/admin/admin_page.dart';
import 'package:compaexpress/services/network_service.dart';
import 'package:compaexpress/services/user_service.dart';
import 'package:flutter/material.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserAuth();
  }

  Future<void> _checkUserAuth() async {
    // Verifica si hay conexión a internet
    final isOnline = await NetworkService.isConnected();
    debugPrint("Estado de conexión: ${isOnline ? 'Online' : 'Offline'}");

    if (isOnline) {
      // Flujo online
      try {
        final session = await Amplify.Auth.fetchAuthSession();
        debugPrint("Validando sesión: ${session.isSignedIn}");

        if (session.isSignedIn) {
          // Obtén los atributos del usuario
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          final roleAttr = userAttributes.firstWhere(
            (attr) => attr.userAttributeKey.key == 'custom:role',
            orElse: () => const AuthUserAttribute(
              userAttributeKey: CognitoUserAttributeKey.custom('role'),
              value: 'unknown',
            ),
          );

          final role = roleAttr.value.toLowerCase();
          // Guarda el rol localmente para uso offline
          await UserService.saveUserRoleLocally(role);

          // Navega según el rol
          _navigateToRoleScreen(role);
        } else {
          _goToLogin();
        }
      } on AuthException catch (e) {
        debugPrint("Error verificando sesión: ${e.message}");
        await _handleOfflineFlow();
      }
    } else {
      // Flujo offline
      await _handleOfflineFlow();
    }
  }

  Future<void> _handleOfflineFlow() async {
    try {
      final currentUser = await Amplify.Auth.getCurrentUser();
      debugPrint("Usuario local encontrado: ${currentUser.userId}");
      // Intenta obtener el rol localmente
      final role = await UserService.getUserRoleLocally() ?? 'unknown';
      // Navega según el rol local
      _navigateToRoleScreen(role);
    } catch (offlineError) {
      debugPrint("No se pudo verificar usuario localmente: $offlineError");
      _goToLogin();
    }
  }

  void _navigateToRoleScreen(String role) {
    debugPrint("Navegando con rol $role");
    switch (role) {
      case 'superadmin':
        Navigator.of(context).pushReplacementNamed('/superadmin');
        break;
      case 'admin':
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const AdminPage()));
        break;
      case "vendedor":
        Navigator.of(context).pushReplacementNamed('/vendedor');
      default:
        _goToLogin(); // Rol inválido o no encontrado
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), Text("Verificando sesión")],
        ),
      ),
    );
  }
}
