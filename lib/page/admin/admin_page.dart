import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:compaexpress/mixin/session_control_mixin.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/admin/admin_account_page.dart';
import 'package:compaexpress/page/admin/admin_summary_page.dart';
import 'package:compaexpress/page/admin/clientes/admin_clientes_view_page.dart';
import 'package:compaexpress/page/admin/compras/admin_compras_create_page.dart';
import 'package:compaexpress/page/admin/compras/admin_compras_list_page.dart';
import 'package:compaexpress/page/admin/inventory/admin_create_inventory_product.dart';
import 'package:compaexpress/page/admin/proveedor/admin_proveedor_form_page.dart';
import 'package:compaexpress/page/vendedor/caja/vendedor_cierre_caja_page.dart';
import 'package:compaexpress/page/vendedor/invoice/vendedor_invoice_create_page.dart';
import 'package:compaexpress/page/vendedor/order/vendedor_order_create_page.dart';
import 'package:compaexpress/page/vendedor/user/edit_seller_user_page.dart';
import 'package:compaexpress/routes/routes.dart';
import 'package:compaexpress/services/caja_service.dart';
import 'package:compaexpress/services/device/device_session_controller.dart';
import 'package:compaexpress/utils/get_image_for_bucker.dart';
import 'package:compaexpress/views/compact_option_tile.dart';
import 'package:compaexpress/views/quick_access_carousel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with WidgetsBindingObserver, SessionControlMixin {
  String? userName;
  Negocio? negocio;
  bool isLoading = true;
  String? errorMessage;
  DateTime? fechaVencimiento;
  int diasRestantes = 0;
  int dispositivosConectados = 0;
  int maxDispositivosMovil = 0;
  int maxDispositivosPC = 0;
  bool vigenciaValida = true;
  String? imageUrl;
  Timer? _refreshTimer;

  // Cache para evitar recrear objetos constantes
  static const Duration _refreshInterval = Duration(seconds: 120);
  late final List<QuickAccessItem> _quickAccessItems;
  late final List<_MenuItem> _menuItems;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inicializar listas de elementos una sola vez
    _initializeMenuItems();

    // Cargar datos inmediatamente sin Future.microtask
    _loadUserAndBusiness();
    initializeSessionControl();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    disposeSessionControl();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initializeMenuItems() {
    _menuItems = [
      _MenuItem(
        Icons.attach_money,
        'Gestión de Caja',
        'Gestionar caja',
        Routes.adminViewCaja,
        null,
      ),
      _MenuItem(
        Icons.inventory_2,
        'Inventario',
        'Categorías y productos',
        Routes.adminViewInventory,
        null,
      ),
      _MenuItem(
        Icons.group,
        'Vendedores',
        'Control de usuarios',
        Routes.adminViewUsers,
        null,
      ),
      _MenuItem(
        Icons.inventory,
        'Compras',
        'Gestiona la compra de productos',
        null,
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdminComprasListPage(negocioID: negocio!.id),
          ),
        ),
      ),
      _MenuItem(
        Icons.description,
        'Facturas',
        'Ventas por factura',
        Routes.adminViewFacturas,
        null,
      ),
      _MenuItem(
        Icons.flash_on,
        'Venta Rápida',
        'Productos al instante',
        Routes.adminViewOrdenes,
        null,
      ),
      _MenuItem(
        Icons.lock_outline,
        'Cerrar Caja',
        'Finalizar turno',
        null,
        _handleCerrarCaja,
      ),
      _MenuItem(
        Icons.car_repair,
        'Proveedores',
        'Gestionar proveedores',
        Routes.adminViewProveedores,
        null,
      ),
      _MenuItem(
        Icons.people,
        'Clientes',
        'Gestionar clientes',
        null,
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdminClientesViewPage(negocioID: negocio!.id),
          ),
        ),
      ),
      _MenuItem(
        Icons.person,
        'Perfil',
        'Datos del usuario',
        null,
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const EditSellerUserPage())),
      ),
    ];
  }

  void _initializeQuickAccessItems() {
    _quickAccessItems = [
      QuickAccessItem(
        icon: Icons.document_scanner,
        title: 'Facturar',
        subtitle: 'Crea una factura',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const VendedorCreateInvoiceScreen(),
          ),
        ),
        isEnabled: negocio != null && vigenciaValida,
      ),
      QuickAccessItem(
        icon: Icons.attach_money,
        title: 'Compra',
        subtitle: 'Crea una compra',
        variant: QuickAccessVariant.primary,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VendedorOrderCreatePage()),
        ),
        isEnabled: negocio != null && vigenciaValida,
      ),
      QuickAccessItem(
        icon: Icons.attach_money,
        title: 'Pre-Orden',
        subtitle: 'Crea una pre-orden',
        variant: QuickAccessVariant.primary,
        onTap: () => Navigator.of(context).pushNamed(Routes.preorders),
        isEnabled: negocio != null && vigenciaValida,
      ),
      QuickAccessItem(
        icon: Icons.add,
        title: 'Añadir producto',
        subtitle: 'Crea un producto',
        variant: QuickAccessVariant.primary,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdminCreateInventoryProduct(negocioID: negocio!.id),
          ),
        ),
        isEnabled: negocio != null && vigenciaValida,
      ),
      QuickAccessItem(
        icon: Icons.add,
        title: 'Añadir proveedor',
        subtitle: 'Crea un proveedor',
        variant: QuickAccessVariant.primary,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProveedorFormPage())),
        isEnabled: negocio != null && vigenciaValida,
      ),
      QuickAccessItem(
        icon: Icons.add,
        title: 'Realizar compra',
        subtitle: 'Compra mas productos!',
        variant: QuickAccessVariant.primary,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdminComprasCreatePage(negocioID: negocio!.id),
          ),
        ),
        isEnabled: negocio != null && vigenciaValida,
      ),
    ];
  }

  void _startRefreshTimer() {
    debugPrint('REFREZCANDO INFORMACION');
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (mounted) {
        _refreshVigenciaInfo();
      }
    });
  }

  Future<void> _loadUserAndBusiness() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Cargar datos del usuario y negocio en paralelo
      final futures = await Future.wait([_loadUserData(), _loadBusinessData()]);

      if (mounted) {
        setState(() {
          userName = futures[0] as String?;
          isLoading = false;
        });

        // Inicializar quick access items después de cargar negocio
        if (negocio != null) {
          _initializeQuickAccessItems();
          _loadVigenciaInfo(); // No usar await para no bloquear UI
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        setState(() {
          errorMessage = 'Error al cargar datos';
          isLoading = false;
        });
      }
    }
  }

  Future<String?> _loadUserData() async {
    final user = await Amplify.Auth.getCurrentUser();
    final attributes = await Amplify.Auth.fetchUserAttributes();

    String? userDisplayName;
    for (final attribute in attributes) {
      if (attribute.userAttributeKey.key == 'name' ||
          attribute.userAttributeKey.key == 'preferred_username') {
        userDisplayName = attribute.value;
        break; // Optimización: salir del loop temprano
      }
    }

    return userDisplayName ?? user.username;
  }

  Future<void> _loadBusinessData() async {
    final attributes = await Amplify.Auth.fetchUserAttributes();
    String? negocioId;

    for (final attribute in attributes) {
      print(attribute);
      if (attribute.userAttributeKey.key == 'custom:negocioid') {
        negocioId = attribute.value;
        break;
      }
    }

    if (negocioId != null) {
      final request = ModelQueries.get(
        Negocio.classType,
        NegocioModelIdentifier(id: negocioId),
      );
      final response = await Amplify.API.query(request: request).response;

      if (response.data != null && mounted) {
        // Cargar imagen en paralelo, no bloquear UI
        _loadBusinessImage(response.data!.logo);

        setState(() {
          negocio = response.data;
        });
      } else if (mounted) {
        setState(() {
          errorMessage = 'No se pudo cargar la información del negocio';
        });
      }
    } else if (mounted) {
      setState(() {
        errorMessage = 'Usuario sin negocio asignado';
      });
    }
  }

  Future<void> _loadBusinessImage(String? logoKey) async {
    if (logoKey != null && logoKey.isNotEmpty) {
      try {
        final signedImageUrls = await GetImageFromBucket.getSignedImageUrls(
          s3Keys: [logoKey],
        );

        if (mounted && signedImageUrls.isNotEmpty) {
          setState(() {
            imageUrl = signedImageUrls.first;
          });
        }
      } catch (e) {
        // Manejar error silenciosamente, no es crítico para la UI
        debugPrint('Error loading business image: $e');
      }
    }
  }

  Future<void> _loadVigenciaInfo() async {
    if (negocio == null) return;

    try {
      final now = DateTime.now().toUtc();
      DateTime? tempFechaVencimiento;
      int tempDiasRestantes = 0;
      bool tempVigenciaValida = true;

      if (negocio!.duration != null) {
        final fechaCreacion = negocio!.createdAt.getDateTimeInUtc();
        tempFechaVencimiento = fechaCreacion.add(
          Duration(days: negocio!.duration!),
        );
        tempDiasRestantes =
            (tempFechaVencimiento.difference(now).inSeconds / 86400).ceil();
        tempVigenciaValida = tempFechaVencimiento.isAfter(now);
      }

      final deviceInfo = await DeviceSessionController.getConnectedDevices(
        negocio!.id,
      );

      if (mounted) {
        setState(() {
          fechaVencimiento = tempFechaVencimiento;
          diasRestantes = tempDiasRestantes;
          vigenciaValida = tempVigenciaValida;
          maxDispositivosMovil = negocio!.movilAccess ?? 0;
          maxDispositivosPC = negocio!.pcAccess ?? 0;
          dispositivosConectados = deviceInfo['total'] ?? 0;
        });
      }
    } catch (e) {
      safePrint('Error cargando información de vigencia: $e');
    }
  }

  Future<void> _refreshVigenciaInfo() async {
    if (negocio != null && mounted) {
      await _loadVigenciaInfo();
    }
  }

  Future<void> _handleCerrarCaja() async {
    try {
      final caja = await CajaService.getCurrentCaja(forceRefresh: true);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => VendedorCierreCajaPage(caja: caja)),
        );
      }
    } catch (e) {
      // Manejar error
      debugPrint('Error loading caja: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: _buildAppBar(Theme.of(context)),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
        negocio?.nombre != null
            ? 'Panel de Administración\n${negocio!.nombre}'
            : 'Panel de Administración',
        textAlign: TextAlign.center,
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      bottom: TabBar(
        indicatorColor: theme.colorScheme.onPrimary,
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onPrimary.withValues(
          alpha: 0.5,
        ),
        tabs: [
          Tab(text: 'General'),
          Tab(text: 'Resumen'),
          Tab(text: 'Ajustes'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: AppLoadingIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserAndBusiness,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      children: [
        _buildGeneralTab(),
        AdminSummaryPage(negocioID: negocio?.id ?? ''),
        const AdminAccountPage(),
      ],
    );
  }

  Widget _buildGeneralTab() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (negocio != null) ...[
            _buildQuickAccessCarousel(),
            const SizedBox(height: 16),
            Expanded(child: _buildMenuGrid()),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildBusinessLogo(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido, ${userName ?? 'Usuario'} 👏',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Estás en: ${negocio?.nombre ?? 'Negocio no disponible'}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessLogo() {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  width: 50,
                  height: 50,
                  child: AppLoadingIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.business, size: 50, color: Colors.grey),
            )
          : const Icon(Icons.business, size: 50, color: Colors.grey),
    );
  }

  Widget _buildQuickAccessCarousel() {
    if (_quickAccessItems.isEmpty) {
      _initializeQuickAccessItems();
    }

    return QuickAccessCarousel(items: _quickAccessItems, height: 140);
  }

  Widget _buildMenuGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 1200
            ? 4
            : width > 1000
            ? 3
            : width > 600
            ? 2
            : 1;
        final childAspectRatio = width > 600 ? 2.0 : 2.6;

        return Stack(
          children: [
            // Imagen de fondo
            if (imageUrl != null)
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(imageUrl ?? ""),
                    fit: BoxFit.contain, // Cubre todo el espacio
                    alignment: Alignment.center, // Centra la imagen
                    opacity: 0.1,
                  ),
                ),
                child:
                    const SizedBox.expand(), // Asegura que el Container tome todo el espacio
              ),
            // GridView
            GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return CompactOptionTile(
                  icon: item.icon,
                  title: item.title,
                  subtitle: item.subtitle,
                  onTap:
                      item.onTap ??
                      () => Navigator.of(context).pushNamed(item.route!),
                  isEnabled: negocio != null && vigenciaValida,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// Clase auxiliar para los elementos del menú
class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  final VoidCallback? onTap;

  const _MenuItem(this.icon, this.title, this.subtitle, this.route, this.onTap);
}
