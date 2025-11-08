import 'package:compaexpress/routes/routes.dart';
import 'package:compaexpress/views/logout_button.dart';
import 'package:compaexpress/widget/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuperAdminPage extends StatelessWidget {
  const SuperAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Panel SuperAdmin',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.surface,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.surface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Bienvenido, SuperAdministrador',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface
                    ),
                  ),
                ),
                LogoutButton(),
              ],
            ),
            const SizedBox(height: 16),
            ThemeManager(),
            /// Gestión de Compradores
            Text(
              'Gestión de Negocios',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildOptionCard(
                  icon: Icons.location_city,
                  title: 'Negocios',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.superAdminNegocios);
                  },
                  context: context
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// Gestión de Usuarios
            Text(
              'Gestión de Usuarios',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildOptionCard(
                  icon: Icons.people,
                  title: 'Usuarios',
                  onTap: () {
                    Navigator.pushNamed(context, "/superadmin/users");
                  },
                  context: context
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// Configuración del Sistema
            /* Text(
              'Configuración del Sistema',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildOptionCard(
                  icon: Icons.settings,
                  title: 'Parámetros Generales',
                  onTap: (){},
                ),
                _buildOptionCard(
                  icon: Icons.receipt_long,
                  title: 'Facturación',
                  onTap: (){},
                ),
                _buildOptionCard(
                  icon: Icons.analytics,
                  title: 'Reportes',
                  onTap: (){},
                ),
              ],
            ), */
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        height: 120,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
