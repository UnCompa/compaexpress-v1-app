import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:compaexpress/config/aws_config.dart';
import 'package:compaexpress/config/theme_config.dart';
import 'package:compaexpress/page/admin/admin_page.dart';
import 'package:compaexpress/page/admin/caja/admin_caja_list_page.dart';
import 'package:compaexpress/page/admin/categories/admin_categories_list_page.dart';
import 'package:compaexpress/page/admin/inventory/admin_view_inventory_screen.dart';
import 'package:compaexpress/page/admin/invoice/admin_invoice_list_page.dart';
import 'package:compaexpress/page/admin/order/admin_order_list_page.dart';
import 'package:compaexpress/page/admin/order/create_preoder_page.dart';
import 'package:compaexpress/page/admin/order/preorder_page.dart';
import 'package:compaexpress/page/admin/proveedor/admin_proveedor_list_page.dart';
import 'package:compaexpress/page/admin/sellers/create_user_admin_page.dart';
import 'package:compaexpress/page/admin/sellers/user_list_admin_page.dart';
import 'package:compaexpress/page/auth/auth_check_screen.dart';
import 'package:compaexpress/page/auth/login_page.dart';
import 'package:compaexpress/page/auth/new_password_page.dart';
import 'package:compaexpress/page/superadmin/negocio/create_bussines_superadmin_page.dart';
import 'package:compaexpress/page/superadmin/negocio/negocios_superadmin_page.dart';
import 'package:compaexpress/page/superadmin/super_admin_page.dart';
import 'package:compaexpress/page/superadmin/user/create_user_superadmin_page.dart';
import 'package:compaexpress/page/superadmin/user/user_list_superadmin_page.dart';
import 'package:compaexpress/page/superadmin/user/user_superadmin_confirm_page.dart';
import 'package:compaexpress/page/vendedor/invoice/vendedor_invoice_list_page.dart';
import 'package:compaexpress/page/vendedor/order/vendedor_order_list_page.dart';
import 'package:compaexpress/page/vendedor/products/vendedor_view_products_screen.dart';
import 'package:compaexpress/page/vendedor/seller_page.dart';
import 'package:compaexpress/providers/theme_provider.dart';
import 'package:compaexpress/widget/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:compaexpress/utils/fecha_ecuador.dart';
import './routes/routes.dart';
import 'models/ModelProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FechaEcuador.inicializarZonaHoraria();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('es_ES', null);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isAmplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      final api = AmplifyAPI(
        options: APIPluginOptions(modelProvider: ModelProvider.instance),
      );
      final auth = AmplifyAuthCognito();
      final storage = AmplifyStorageS3();
      List<AmplifyPluginInterface> plugins = [auth, api, storage];
      await Amplify.addPlugins(plugins);
      await Amplify.configure(AwsConfig.prod);
      setState(() {
        _isAmplifyConfigured = true;
      });
    } on Exception catch (e) {
      safePrint('An error occurred configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themePrefs = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Login Page',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(themePrefs.seedColor),
      darkTheme: AppTheme.darkTheme(themePrefs.seedColor),
      themeMode: themePrefs.themeMode,
      home: _isAmplifyConfigured
          ? const AuthCheckScreen()
          : const LoadingOverlay(caption: 'Iniciando aplicación'),
      routes: {
        Routes.loginPage: (context) => const LoginScreen(),
        Routes.loginPageWithNewPassoword: (context) =>
            const NewPasswordScreen(),
        Routes.superAdminHome: (context) => const SuperAdminPage(),
        Routes.superAdminHomeUsers: (context) => const UserListSuperadminPage(),
        Routes.superAdminHomeUserCrear: (context) =>
            const CreateUserSuperadminPage(),
        Routes.superAdminHomeUserConfirm: (context) =>
            const UserSuperadminConfirmPage(),
        Routes.superAdminNegocios: (context) => const NegociosSuperadminPage(),
        Routes.superAdminNegociosCrear: (context) => const CrearNegocioScreen(),
        Routes.adminHome: (context) => const AdminPage(),
        Routes.adminViewInventory: (context) =>
            const AdminViewInventoryScreen(),
        Routes.adminViewCategorias: (context) =>
            const AdminCategoriesListPage(),
        Routes.adminViewUsers: (context) => const UserListAdminPage(),
        Routes.adminViewUsersCrear: (context) => const CreateUserAdminPage(),
        Routes.vendedorHome: (context) => const SellerPage(),
        Routes.adminViewFacturas: (context) => const AdminInvoiceListPage(),
        Routes.vendedorHomeFacturas: (context) =>
            const VendedorInvoiceListScreen(),
        Routes.vendedorHomeProductos: (context) =>
            const VendedorViewProductsScreen(),
        Routes.adminViewCaja: (context) => const AdminCajaListPage(),
        Routes.vendedorHomeOrder: (context) => const VendedorOrderListScreen(),
        Routes.adminViewOrdenes: (context) => const AdminOrderListScreen(),
        Routes.adminViewProveedores: (context) =>
            const AdminProveedorListPage(),
        Routes.preorders: (context) => const PreordersPage(),
        Routes.preordersCreate: (context) => const CreatePreorderPage(),
      },
    );
  }
}
