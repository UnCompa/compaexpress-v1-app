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
import 'package:flutter/material.dart';

class Routes {
  static const loginPage = "/login";
  static const loginPageWithNewPassoword = "/login/newpassword";
  static const superAdminHome = "/superadmin";
  static const superAdminNegocios = "/superadmin/negocios";
  static const superAdminNegociosCrear = "/superadmin/negocios/crear";
  static const superAdminNegociosEditar = "/superadmin/negocios/editar";
  static const superAdminHomeUsers = "/superadmin/users";
  static const superAdminHomeUserConfirm = "/superadmin/users/confirm";
  static const superAdminHomeUserCrear = "/superadmin/users/crear";
  static const adminHome = "/admin";
  static const adminViewInventory = "/admin/inventory";
  static const adminViewInventoryCrear = "/admin/inventory/crear";
  static const adminViewCategorias = "/admin/categories";
  static const adminViewCategoriasCrear = "/admin/categories/crear";
  static const adminViewUsers = "/admin/users";
  static const adminViewFacturas = "/admin/facturas";
  static const adminViewOrdenes = "/admin/ordenes";
  static const adminViewProveedores = "/admin/proveedores";
  static const adminViewCompras = "/admin/compras";
  static const adminViewUsersCrear = "/admin/users/crear";
  static const adminViewCaja = "/admin/caja";
  static const vendedorHome = "/vendedor";
  static const vendedorHomeFacturas = "/vendedor/facturas";
  static const vendedorHomeProductos = "/vendedor/products";
  static const vendedorHomeOrder = "/vendedor/orders";
  static const vendedorCierreCaja = "/vendedor/cierre";
  static const preorders = "/preorders";
  static const preordersCreate = "/preorders/create";
  static const preordersEdit = "/preorders/edit";

  static WidgetBuilder? getRouteBuilder(String? routeName) {
    switch (routeName) {
      case Routes.loginPage:
        return (_) => const LoginScreen();
      case Routes.loginPageWithNewPassoword:
        return (_) => const NewPasswordScreen();
      case Routes.superAdminHome:
        return (_) => const SuperAdminPage();
      case Routes.superAdminHomeUsers:
        return (_) => const UserListSuperadminPage();
      case Routes.superAdminHomeUserCrear:
        return (_) => const CreateUserSuperadminPage();
      case Routes.superAdminHomeUserConfirm:
        return (_) => const UserSuperadminConfirmPage();
      case Routes.superAdminNegocios:
        return (_) => const NegociosSuperadminPage();
      case Routes.superAdminNegociosCrear:
        return (_) => const CrearNegocioScreen();
      case Routes.adminHome:
        return (_) => const AdminPage();
      case Routes.adminViewInventory:
        return (_) => const AdminViewInventoryScreen();
      case Routes.adminViewCategorias:
        return (_) => const AdminCategoriesListPage();
      case Routes.adminViewUsers:
        return (_) => const UserListAdminPage();
      case Routes.adminViewUsersCrear:
        return (_) => const CreateUserAdminPage();
      case Routes.vendedorHome:
        return (_) => const SellerPage();
      case Routes.adminViewFacturas:
        return (_) => const AdminInvoiceListPage();
      case Routes.vendedorHomeFacturas:
        return (_) => const VendedorInvoiceListScreen();
      case Routes.vendedorHomeProductos:
        return (_) => const VendedorViewProductsScreen();
      case Routes.adminViewCaja:
        return (_) => const AdminCajaListPage();
      case Routes.vendedorHomeOrder:
        return (_) => const VendedorOrderListScreen();
      case Routes.adminViewOrdenes:
        return (_) => const AdminOrderListScreen();
      case Routes.adminViewProveedores:
        return (_) => const AdminProveedorListPage();
      case Routes.preorders:
        return (_) => const PreordersPage();
      case Routes.preordersCreate:
        return (_) => const CreatePreorderPage();
      default:
        return null;
    }
  }
}
