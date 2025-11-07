import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/mixin/session_control_mixin.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/admin/order/admin_order_create_page.dart';
import 'package:compaexpress/page/vendedor/caja/vendedor_cierre_caja_page.dart';
import 'package:compaexpress/page/vendedor/invoice/vendedor_invoice_create_page.dart';
import 'package:compaexpress/page/vendedor/user/edit_seller_user_page.dart';
import 'package:compaexpress/routes/routes.dart';
import 'package:compaexpress/services/caja_service.dart';
import 'package:compaexpress/services/device_session_service.dart';
import 'package:compaexpress/utils/get_image_for_bucker.dart';
import 'package:compaexpress/views/logout_button.dart';
import 'package:compaexpress/views/quick_access_carousel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage>
    with WidgetsBindingObserver, SessionControlMixin {
  String? userName;
  Negocio? negocio;
  bool isLoading = true;
  String? errorMessage;

  // Nueva información de vigencia y dispositivos
  DateTime? fechaVencimiento;
  int diasRestantes = 0;
  int dispositivosConectados = 0;
  int maxDispositivosMovil = 0;
  int maxDispositivosPC = 0;
  bool vigenciaValida = true;
  Timer? _refreshTimer;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserAndBusiness();
    WidgetsBinding.instance.addObserver(this);
    initializeSessionControl();

    // Actualizar información cada 30 segundos
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    disposeSessionControl();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _refreshVigenciaInfo();
      }
    });
  }

  Future<void> _loadUserAndBusiness() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Obtener el usuario actual
      final user = await Amplify.Auth.getCurrentUser();
      final attributes = await Amplify.Auth.fetchUserAttributes();

      String? negocioId;
      String? userDisplayName;

      for (final attribute in attributes) {
        if (attribute.userAttributeKey.key == 'custom:negocioid') {
          negocioId = attribute.value;
        }
        if (attribute.userAttributeKey.key == 'name' ||
            attribute.userAttributeKey.key == 'preferred_username') {
          userDisplayName = attribute.value;
        }
      }

      userDisplayName ??= user.username;

      if (negocioId != null) {
        // Consultar los datos del negocio
        final request = ModelQueries.get(
          Negocio.classType,
          NegocioModelIdentifier(id: negocioId),
        );
        final response = await Amplify.API.query(request: request).response;

        if (response.data != null) {
          final signedImageUrls =
              response.data!.logo != null && response.data!.logo!.isNotEmpty
              ? await GetImageFromBucket.getSignedImageUrls(
                  s3Keys: [response.data!.logo!],
                )
              : <String>[];
          imageUrl = signedImageUrls.isNotEmpty ? signedImageUrls.first : null;
          setState(() {
            userName = userDisplayName;
            negocio = response.data;
          });

          // Cargar información adicional de vigencia y dispositivos
          await _loadVigenciaInfo();
        } else {
          setState(() {
            userName = userDisplayName;
            errorMessage = 'No se pudo cargar la información del negocio';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          userName = userDisplayName;
          errorMessage = 'Usuario sin negocio asignado';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar datos: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _loadVigenciaInfo() async {
    if (negocio == null) return;

    try {
      // Calcular vigencia
      final now = DateTime.now().toUtc(); // Comparación justa en UTC
      if (negocio!.duration != null) {
        final fechaCreacion = negocio!.createdAt.getDateTimeInUtc();
        fechaVencimiento = fechaCreacion.add(
          Duration(days: negocio!.duration!),
        );
        diasRestantes = (fechaVencimiento!.difference(now).inSeconds / 86400)
            .ceil();
        vigenciaValida = fechaVencimiento!.isAfter(now);
      }
      final deviceInfo = await DeviceSessionService.getConnectedDevicesInfo(
        negocio!.id,
      );
      setState(() {
        maxDispositivosMovil = negocio!.movilAccess ?? 0;
        maxDispositivosPC = negocio!.pcAccess ?? 0;
        isLoading = false;
        dispositivosConectados = deviceInfo['total'] ?? 0;
      });
    } catch (e) {
      safePrint('Error cargando información de vigencia: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshVigenciaInfo() async {
    if (negocio != null && mounted) {
      await _loadVigenciaInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          negocio != null
              ? 'Panel de vendedor\n${negocio!.nombre}'
              : 'Panel de vendedor',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserAndBusiness,
            tooltip: 'Actualizar información',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserAndBusiness,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Compact user info
                    _buildUserInfoCard(),
                    const SizedBox(height: 6),
                    // Prominent menu options
                     QuickAccessCarousel(
                      items: [
                        QuickAccessItem(
                          icon: Icons.document_scanner,
                          title: 'Facturar',
                          subtitle: 'Crea una factura',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VendedorCreateInvoiceScreen(),
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
                            MaterialPageRoute(
                              builder: (_) => CreateOrderScreen(),
                            ),
                          ),
                          isEnabled: negocio != null && vigenciaValida,
                        ),
                      ],
                      height: 140,
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          
                          _buildOptionTile(
                            icon: Icons.shopping_bag,
                            title: 'Productos',
                            subtitle: 'Ver productos disponibles',
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed(Routes.vendedorHomeProductos);
                            },
                          ),
                          _buildOptionTile(
                            icon: Icons.document_scanner,
                            title: 'Venta por Factura',
                            subtitle: 'Seguimiento de ventas por factura',
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed(Routes.vendedorHomeFacturas);
                            },
                          ),
                          _buildOptionTile(
                            icon: Icons.fast_forward,
                            title: 'Venta Rapida',
                            subtitle: 'Selecciona los productos, y listo!',
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed(Routes.vendedorHomeOrder);
                            },
                          ),
                          _buildOptionTile(
                            icon: Icons.person,
                            title: 'Gestionar perfil',
                            subtitle: 'Datos personales',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditSellerUserPage(),
                                ),
                              );
                            },
                          ),
                          _buildOptionTile(
                            icon: Icons.add_box,
                            title: 'Cerrar caja',
                            subtitle: 'Cierra la caja',
                            onTap: () async {
                              final caja = await CajaService.getCurrentCaja();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => VendedorCierreCajaPage(caja: caja),
                                ),
                              );
                            },
                          ),
                          /* _buildOptionTile(
                            icon: Icons.inventory_outlined,
                            title: 'Facturación',
                            subtitle: 'Generar y gestionar facturas',
                            onTap: (){
                              // Navegar a facturación
                            },
                          ),
                          _buildOptionTile(
                            icon: Icons.devices,
                            title: 'Gestión de Dispositivos',
                            subtitle: 'Ver y gestionar sesiones activas',
                            onTap: (){
                              _showDevicesDialog();
                            },
                          ),
                          _buildOptionTile(
                            icon: Icons.settings,
                            title: 'Configuraciones',
                            subtitle: 'Ajustes del negocio',
                            onTap: (){
                              // Navegar a configuraciones
                            },
                          ),
                          _buildOptionTile(
                            icon: Icons.analytics,
                            title: 'Ver Reportes',
                            subtitle: 'Análisis y estadísticas',
                            onTap: (){
                              // Navegar a reportes
                            },
                          ), */
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Image.network(
                imageUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido, ${userName ?? 'Usuario'}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (negocio != null) ...[
                    Text(
                      'RUC: ${negocio!.ruc}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (negocio!.telefono != null)
                      Text(
                        'Tel: ${negocio!.telefono}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.orange[700],
                      ),
                    ),
                ],
              ),
            ),
            LogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final bool isEnabled = negocio != null && vigenciaValida;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey[200]!, Colors.grey[300]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isEnabled
                  ? Colors.black12
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isEnabled
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: AnimatedScale(
            scale: isEnabled ? 1.0 : 0.9,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isEnabled
                    ? Theme.of(context).primaryColor.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: isEnabled
                    ? Theme.of(context).primaryColor
                    : Colors.grey[400],
              ),
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isEnabled ? Colors.black87 : Colors.grey[500],
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isEnabled ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          trailing: AnimatedOpacity(
            opacity: isEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: isEnabled
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
            ),
          ),
          onTap: isEnabled
              ? () {
                  // Agregar feedback háptico (si está soportado)
                  // HapticFeedback.lightImpact();
                  onTap();
                }
              : null,
        ),
      ),
    );
  }
}
