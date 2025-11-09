import 'package:compaexpress/mixin/session_control_mixin.dart';
import 'package:compaexpress/providers/admin_account_provider.dart';
import 'package:compaexpress/views/logout_button.dart';
import 'package:compaexpress/views/responsive_two_column.dart';
import 'package:compaexpress/widget/invoice_design_preview.dart';
import 'package:compaexpress/widget/printer_manager.dart';
import 'package:compaexpress/widget/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerSettingsPage extends ConsumerStatefulWidget {
  const SellerSettingsPage({super.key});

  @override
  ConsumerState<SellerSettingsPage> createState() => _SellerSettingsPageState();
}

class _SellerSettingsPageState extends ConsumerState<SellerSettingsPage>
    with WidgetsBindingObserver, SessionControlMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeSessionControl();
  }

  @override
  void dispose() {
    disposeSessionControl();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refreshData() async {
    ref.invalidate(userBusinessProvider);
  }

  @override
  Widget build(BuildContext context) {
    final userBusinessAsync = ref.watch(userBusinessProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: userBusinessAsync.when(
        data: (userBusiness) => RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrinterManagerWidget(),
                  InvoiceDesignSelectorWithPreview(),
                  _buildUserInfoCard(userBusiness),
                  const SizedBox(height: 4),
                  ResponsiveTwoColumn(
                    first: _buildVigenciaCard(),
                    second: _buildDevicesCard(),
                  ),
                  ThemeManager()
                ],
              ),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error al cargar datos',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(UserBusinessData userBusiness) {
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
              child: userBusiness.imageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        userBusiness.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.business,
                              size: 50,
                              color: Colors.grey,
                            ),
                      ),
                    )
                  : const Icon(Icons.business, size: 50, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido, ${userBusiness.userName}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (userBusiness.negocio != null) ...[
                    Text(
                      'RUC: ${userBusiness.negocio!.ruc}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (userBusiness.negocio!.telefono != null)
                      Text(
                        'Tel: ${userBusiness.negocio!.telefono}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                  if (userBusiness.errorMessage != null)
                    Text(
                      userBusiness.errorMessage!,
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

  Widget _buildVigenciaCard() {
    final vigenciaInfo = ref.watch(vigenciaInfoProvider);

    if (vigenciaInfo.fechaVencimiento == null) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Vigencia',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Sin información',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final vigenciaColor = _getVigenciaColor(vigenciaInfo);
    final vigenciaIcon = _getVigenciaIcon(vigenciaInfo);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(vigenciaIcon, color: vigenciaColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Vigencia',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${vigenciaInfo.diasRestantes} días',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: vigenciaColor,
                  ),
                ),
                Text(
                  '${vigenciaInfo.fechaVencimiento!.day}/${vigenciaInfo.fechaVencimiento!.month}/${vigenciaInfo.fechaVencimiento!.year}',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 2),
            LinearProgressIndicator(
              value: vigenciaInfo.vigenciaValida
                  ? vigenciaInfo.diasRestantes /
                        (vigenciaInfo.duracionTotal ?? 365)
                  : 0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(vigenciaColor),
              minHeight: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesCard() {
    final devicesAsync = ref.watch(devicesInfoProvider);

    return devicesAsync.when(
      data: (devicesInfo) => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.devices, color: Colors.blue, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Dispositivos',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildDeviceInfo(
                    'Móvil',
                    Icons.smartphone,
                    devicesInfo.maxDispositivosMovil,
                    Colors.green,
                  ),
                  const SizedBox(width: 4),
                  _buildDeviceInfo(
                    'PC',
                    Icons.computer,
                    devicesInfo.maxDispositivosPC,
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.connected_tv,
                      color: Colors.purple,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Conectados: ${devicesInfo.dispositivosConectados}',
                      style: GoogleFonts.poppins(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (error, stack) => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Error al cargar dispositivos',
                  style: GoogleFonts.poppins(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceInfo(String label, IconData icon, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                Text(
                  '$count permitidos',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getVigenciaColor(VigenciaInfo vigenciaInfo) {
    if (!vigenciaInfo.vigenciaValida) return Colors.red;
    if (vigenciaInfo.diasRestantes <= 7) return Colors.orange;
    if (vigenciaInfo.diasRestantes <= 30) return Colors.yellow[700]!;
    return Colors.green;
  }

  IconData _getVigenciaIcon(VigenciaInfo vigenciaInfo) {
    if (!vigenciaInfo.vigenciaValida) return Icons.error;
    if (vigenciaInfo.diasRestantes <= 7) return Icons.warning;
    return Icons.check_circle;
  }
}
