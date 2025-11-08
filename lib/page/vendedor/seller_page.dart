import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/mixin/session_control_mixin.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/vendedor/caja/vendedor_cierre_caja_page.dart';
import 'package:compaexpress/page/vendedor/invoice/vendedor_invoice_create_page.dart';
import 'package:compaexpress/page/vendedor/order/vendedor_order_create_page.dart';
import 'package:compaexpress/page/vendedor/seller_settings_page.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          negocio != null
              ? 'Panel de vendedor\n${negocio!.nombre}'
              : 'Panel de vendedor',
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
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
                              builder: (_) => VendedorOrderCreatePage(),
                            ),
                          ),
                          isEnabled: negocio != null && vigenciaValida,
                        ),
                        QuickAccessItem(
                          icon: Icons.attach_money,
                          title: 'Pre-Orden',
                          subtitle: 'Crea una pre-orden',
                          variant: QuickAccessVariant.primary,
                          onTap: () =>
                              Navigator.of(context).pushNamed(Routes.preorders),
                          isEnabled: negocio != null && vigenciaValida,
                        ),
                        QuickAccessItem(
                          icon: Icons.settings,
                          title: 'Ajustes',
                          subtitle: 'Configura tu experiencia',
                          variant: QuickAccessVariant.primary,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SellerSettingsPage(),
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
                                  builder: (_) =>
                                      VendedorCierreCajaPage(caja: caja),
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
    // Asume que 'negocio' y 'vigenciaValida' están disponibles en el contexto del widget padre.
    final bool isEnabled = negocio != null && vigenciaValida;
    final theme = Theme.of(context);

    // Colores principales del tema
    final Color primaryColor = theme.colorScheme.primary;
    final Color disabledColor =
        theme.disabledColor; // Color estándar para elementos deshabilitados

    // Colores basados en el estado (habilitado/deshabilitado)
    final Color tileColor = isEnabled
        ? theme.cardColor
        : theme.colorScheme.surface;
    final Color iconColor = isEnabled ? primaryColor : disabledColor;
    final Color titleColor = isEnabled
        ? theme.textTheme.titleLarge!.color!
        : disabledColor.withOpacity(0.7);
    final Color subtitleColor = isEnabled
        ? theme.textTheme.bodyMedium!.color!
        : disabledColor.withOpacity(0.5);
    final Color borderColor = isEnabled
        ? primaryColor.withOpacity(0.5)
        : Colors.grey.withOpacity(0.2);

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),

        // *** Ajuste de Decoración (Gradiente y Sombra) ***
        decoration: BoxDecoration(
          color:
              tileColor, // Usar un color de fondo si no quieres gradiente complejo
          gradient: isEnabled
              ? LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.1),
                    primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null, // Sin gradiente cuando está deshabilitado
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
          border: Border.all(color: borderColor, width: 1),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),

          // *** Icono Principal (Adaptado al Tema) ***
          leading: AnimatedScale(
            scale: isEnabled ? 1.0 : 0.9,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // Usamos un color de fondo más suave para el icono
                color: isEnabled
                    ? primaryColor.withOpacity(0.15)
                    : disabledColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: iconColor),
            ),
          ),

          // *** Título (Usando TextTheme del Tema) ***
          title: Text(
            title,
            // Puedes definir este estilo en tu ThemeData como 'titleLarge' o 'headlineSmall'
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),

          // *** Subtítulo (Usando TextTheme del Tema) ***
          subtitle: Text(
            subtitle,
            // Puedes definir este estilo en tu ThemeData como 'bodyMedium' o similar
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: subtitleColor,
            ),
          ),

          // *** Icono de Trailing (Adaptado al Tema) ***
          trailing: AnimatedOpacity(
            opacity: isEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.arrow_forward_ios, size: 18, color: iconColor),
          ),
          // No es necesario el onTap del ListTile si ya está en el GestureDetector,
          // pero lo mantengo por si quisieras solo usar el ListTile.
          // onTap: isEnabled ? onTap : null,
        ),
      ),
    );
  }
}
