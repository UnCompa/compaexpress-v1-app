import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/routes/routes.dart';
import 'package:compaexpress/services/device_session_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
import 'package:compaexpress/providers/categories_provider.dart';
import 'package:compaexpress/providers/clients_provider.dart';
import 'package:compaexpress/providers/order_provider.dart';
import 'package:compaexpress/providers/products_provider.dart';
import 'package:compaexpress/providers/proveedor_provider.dart';
import 'package:compaexpress/providers/preorders_provider.dart';
import 'package:compaexpress/providers/admin_account_provider.dart';


class LogoutButton extends ConsumerStatefulWidget {
  const LogoutButton({super.key});

  @override
  ConsumerState<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends ConsumerState<LogoutButton> {
  bool isLoading = false;

  Future<void> _logout() async {
    try {
      setState(() => isLoading = true);

      await DeviceSessionService.closeCurrentSession();
      await Amplify.Auth.signOut();

      await cleanProviders();
      setState(() => isLoading = false);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.loginPage);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> cleanProviders() async {
    print("cleaning providers");
    ref.invalidate(orderProvider);
    ref.invalidate(sellersProvider);
    ref.invalidate(filterProvider);
    ref.invalidate(productsProvider);
    ref.invalidate(favoriteProductsProvider);
    ref.invalidate(lowStockProductsProvider);
    ref.invalidate(outOfStockProductsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(subcategoriasProvider);
    ref.invalidate(availableParentCategoriesProvider);
    ref.invalidate(rootCategoriesProvider);
    ref.invalidate(proveedorProvider);
    ref.invalidate(filteredProveedoresProvider);
    ref.invalidate(searchQueryProvider);
    ref.invalidate(currentPageProvider);
    ref.invalidate(itemsPerPageProvider);
    ref.invalidate(preordersProvider);
    ref.invalidate(clientsProvider);
    ref.invalidate(clientsByNegocioProvider);
    ref.invalidate(clientByIdentificacionProvider);
    ref.invalidate(userBusinessProvider);
    ref.invalidate(vigenciaInfoProvider);
    ref.invalidate(devicesInfoProvider);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : _logout,
      child: isLoading
          ? const AppLoadingIndicator(color: Colors.red, strokeWidth: 2)
          : Text(
              "Cerrar sesión",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.redAccent),
            ),
    );
  }
}