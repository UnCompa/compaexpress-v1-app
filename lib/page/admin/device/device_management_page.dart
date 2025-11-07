import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/device_session_service.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeviceManagementPage extends StatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  State<DeviceManagementPage> createState()=> _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  List<SesionDispositivo> activeSessions = [];
  Negocio? negocio;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState(){
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices()async {
    try {
      setState((){
        isLoading = true;
        errorMessage = null;
      });

      // Obtener información del negocio
      final userInfo = await NegocioService.getCurrentUserInfo();
      final negocioId = userInfo.negocioId;

      final negocioData = await NegocioService.getNegocioById(negocioId);
      if (negocioData == null){
        setState((){
          errorMessage = 'No se pudo cargar la información del negocio';
          isLoading = false;
        });
        return;
      }

      // Obtener sesiones activas
      final sessions = await _getAllActiveSessions(negocioId);

      setState((){
        negocio = negocioData;
        activeSessions = sessions;
        isLoading = false;
      });
    } catch (e){
      setState((){
        errorMessage = 'Error al cargar dispositivos: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<List<SesionDispositivo>> _getAllActiveSessions(
    String negocioId,
  )async {
    try {
      const String query = '''
        query ListSesionesDispositivo(\$negocioId: ID!){
          listSesionDispositivos(
            filter: {
              negocioId: { eq: \$negocioId }
              isActive: { eq: true }
            }
          ){
            items {
              id
              negocioId
              userId
              deviceId
              deviceType
              deviceInfo
              isActive
              lastActivity
              createdAt
              updatedAt
            }
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: query,
        variables: {'negocioId': negocioId},
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null){
        final data = response.data as Map<String, dynamic>;
        final items = data['listSesionDispositivos']['items'] as List;

        return items.map((item)=> SesionDispositivo.fromJson(item)).toList();
      }
      return [];
    } catch (e){
      safePrint('Error obteniendo sesiones: $e');
      return [];
    }
  }

  Future<void> _disconnectDevice(SesionDispositivo session)async {
    try {
      final updatedSession = session.copyWith(isActive: false);
      final request = ModelMutations.update(updatedSession);
      await Amplify.API.mutate(request: request).response;

      // Actualizar la lista
      await _loadDevices();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dispositivo desconectado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al desconectar dispositivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Dispositivos'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadDevices,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 20),
                  Text(
                    'Dispositivos Activos',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: activeSessions.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: activeSessions.length,
                            itemBuilder: (context, index){
                              return _buildDeviceCard(activeSessions[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(){
    if (negocio == null)return const SizedBox.shrink();

    final pcSessions = activeSessions.where((s)=> s.deviceType == 'PC').length;
    final mobilSessions = activeSessions
        .where((s)=> s.deviceType == 'MOVIL')
        .length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              negocio!.nombre,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildUsageIndicator(
                    'PC',
                    pcSessions,
                    negocio!.pcAccess ?? 0,
                    Icons.computer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUsageIndicator(
                    'Móvil',
                    mobilSessions,
                    negocio!.movilAccess ?? 0,
                    Icons.phone_android,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageIndicator(String label, int used, int max, IconData icon){
    final percentage = max > 0 ? used / max : 0.0;
    final isOverLimit = used > max;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverLimit
            ? Colors.red[50]
            : percentage > 0.8
            ? Colors.orange[50]
            : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverLimit
              ? Colors.red[200]!
              : percentage > 0.8
              ? Colors.orange[200]!
              : Colors.green[200]!,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: isOverLimit
                ? Colors.red[700]
                : percentage > 0.8
                ? Colors.orange[700]
                : Colors.green[700],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$used / $max',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isOverLimit
                  ? Colors.red[700]
                  : percentage > 0.8
                  ? Colors.orange[700]
                  : Colors.green[700],
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: max > 0 ? (used / max).clamp(0.0, 1.0): 0.0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(
              isOverLimit
                  ? Colors.red
                  : percentage > 0.8
                  ? Colors.orange
                  : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(SesionDispositivo session){
    final lastActivity = session.lastActivity.getDateTimeInUtc();
    final now = DateTime.now();
    String activityText = 'Desconocido';

    final difference = now.difference(lastActivity);
    if (difference.inMinutes < 1){
      activityText = 'Activo ahora';
    } else if (difference.inHours < 1){
      activityText = 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1){
      activityText = 'Hace ${difference.inHours}h';
    } else {
      activityText = 'Hace ${difference.inDays} días';
    }
  
    final isCurrentDevice =
        session.deviceId ==
        DeviceSessionService.getDeviceInfo().toString(); // Simplificado

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: session.deviceType == 'PC'
                ? Colors.blue[100]
                : Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            session.deviceType == 'PC' ? Icons.computer : Icons.phone_android,
            color: session.deviceType == 'PC'
                ? Colors.blue[700]
                : Colors.green[700],
          ),
        ),
        title: Text(
          session.deviceInfo ?? 'Dispositivo desconocido',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo: ${session.deviceType}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            Text(
              'Última actividad: $activityText',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            if (isCurrentDevice)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Este dispositivo',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.blue[700],
                  ),
                ),
              ),
          ],
        ),
        trailing: isCurrentDevice
            ? const Icon(Icons.smartphone, color: Colors.blue)
            : IconButton(
                onPressed: ()=> _showDisconnectDialog(session),
                icon: const Icon(Icons.close, color: Colors.red),
                tooltip: 'Desconectar',
              ),
      ),
    );
  }

  Widget _buildEmptyState(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay dispositivos activos',
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Los dispositivos aparecerán aquí cuando inicien sesión',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(SesionDispositivo session){
    showDialog(
      context: context,
      builder: (context)=> AlertDialog(
        title: const Text('Desconectar Dispositivo'),
        content: Text(
          '¿Estás seguro de que quieres desconectar "${session.deviceInfo}"?\n\n'
          'El usuario tendrá que iniciar sesión nuevamente.',
        ),
        actions: [
          TextButton(
            onPressed: ()=> Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: (){
              Navigator.of(context).pop();
              _disconnectDevice(session);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );
  }
}
