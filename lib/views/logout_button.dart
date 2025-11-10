import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/routes/routes.dart';
import 'package:compaexpress/services/device_session_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key});
  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool isLoading = false;
  Future<void> _logout(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      debugPrint('CERRANDO SESION');
      await DeviceSessionService.closeCurrentSession();
      await Amplify.Auth.signOut();
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.loginPage);
      }
    } catch (e) {
      debugPrint('ERROR AL CERRAR SESION');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        _logout(context);
      },
      child: isLoading
          ? const AppLoadingIndicator(
              color: Colors.red,
              strokeWidth: 2,
            )
          : Text(
              "Cerrar sesión",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.redAccent),
            ),
    );
  }
}
