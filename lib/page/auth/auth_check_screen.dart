import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/page/admin/admin_page.dart';
import 'package:compaexpress/services/network_service.dart';
import 'package:compaexpress/services/user_service.dart';
import 'package:compaexpress/widget/loading_overlay.dart';
import 'package:flutter/material.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  String _status = 'Verificando sesión…';

  @override
  void initState() {
    super.initState();
    _checkUserAuth();
  }

  Future<void> _checkUserAuth() async {
    _updateStatus('Comprobando conexión…');
    final isOnline = await NetworkService.isConnected();

    if (isOnline) {
      _updateStatus('Validando credenciales…');
      try {
        final session = await Amplify.Auth.fetchAuthSession();
        if (session.isSignedIn) {
          _updateStatus('Obteniendo datos del usuario…');
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          final roleAttr = userAttributes.firstWhere(
            (attr) => attr.userAttributeKey.key == 'custom:role',
            orElse: () => const AuthUserAttribute(
              userAttributeKey: CognitoUserAttributeKey.custom('role'),
              value: 'unknown',
            ),
          );
          final role = roleAttr.value.toLowerCase();
          await UserService.saveUserRoleLocally(role);
          _navigateToRoleScreen(role);
        } else {
          _goToLogin();
        }
      } on AuthException catch (_) {
        await _handleOfflineFlow();
      }
    } else {
      await _handleOfflineFlow();
    }
  }

  Future<void> _handleOfflineFlow() async {
    _updateStatus('Modo sin conexión…');
    try {
      final currentUser = await Amplify.Auth.getCurrentUser();
      final role = await UserService.getUserRoleLocally() ?? 'unknown';
      _navigateToRoleScreen(role);
    } catch (_) {
      _goToLogin();
    }
  }

  void _updateStatus(String text) {
    if (mounted) setState(() => _status = text);
  }

  void _navigateToRoleScreen(String role) {
    switch (role) {
      case 'superadmin':
        Navigator.of(context).pushReplacementNamed('/superadmin');
        break;
      case 'admin':
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const AdminPage()));
        break;
      case 'vendedor':
        Navigator.of(context).pushReplacementNamed('/vendedor');
        break;
      default:
        _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(caption: _status);
  }
}
