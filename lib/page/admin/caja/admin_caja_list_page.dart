import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/admin/caja/admin_caja_create_page.dart';
import 'package:compaexpress/page/admin/caja/admin_caja_detalle_page.dart';
import 'package:compaexpress/page/admin/caja/admin_caja_edit_page.dart';
import 'package:compaexpress/page/admin/caja/admin_caja_monedas.page.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/views/pagination.dart';
import 'package:compaexpress/widget/balance_cards.dart';
import 'package:flutter/material.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
class AdminCajaListPage extends StatefulWidget {
  const AdminCajaListPage({super.key});

  @override
  State<AdminCajaListPage> createState() => _AdminCajaListPageState();
}

class _AdminCajaListPageState extends State<AdminCajaListPage> {
  List<Caja> _cajas = [];
  List<Caja> _paginatedCaja = [];
  bool _isLoading = true;
  double _totalGeneral = 0.0;
  int currentPage = 1;
  int itemsPerPage = 2;

  @override
  void initState() {
    super.initState();
    _loadCajas();
  }

  void _updatePageItems() {
    _paginatedCaja = PaginationWidget.paginateList(
      _cajas,
      currentPage,
      itemsPerPage,
    );
  }

  void _onPageChanged(int newPage) {
    if (newPage < 1 ||
        newPage > (_cajas.length / itemsPerPage).ceil() ||
        _isLoading) {
      return; // Evita cambios de página inválidos o mientras carga
    }

    setState(() {
      _isLoading =
          true; // Opcional: para indicar que está "cargando" la nueva página
    });

    setState(() {
      currentPage = newPage;
      _updatePageItems();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Cajas'),
        
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () {
              _loadCajas();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTotalGeneralCard(Theme.of(context)),
          PaginationWidget(
            currentPage: currentPage,
            totalItems: _cajas.length,
            itemsPerPage: itemsPerPage,
            onPageChanged: _onPageChanged,
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Cargando cajas..."),
                        SizedBox(height: 8),
                        AppLoadingIndicator(),
                      ],
                    ),
                  )
                : _paginatedCaja.isEmpty
                ? _buildEmptyState(Theme.of(context))
                : _buildCajasList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createCaja,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTotalGeneralCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total General',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${_totalGeneral.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up,
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_cajas.length} cajas activas',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay cajas registradas',
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para crear una nueva caja',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCajasList() {
    return RefreshIndicator(
      onRefresh: _refreshCajas,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _paginatedCaja.length,
        itemBuilder: (context, index) {
          final caja = _paginatedCaja[index];
          return _buildCajaCard(caja, Theme.of(context));
        },
      ),
    );
  }

  Widget _buildCajaCard(Caja caja, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showCajaDetails(caja),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de la caja
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Balance del día',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                                  ),
                                ),
                                Text(
                                  _formatDate(
                                    DateTime.parse(caja.createdAt.toString()),
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: caja.isActive ? theme.colorScheme.primary : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              caja.isActive
                                  ? Icons.check_circle
                                  : Icons.pause_circle,
                              color: theme.colorScheme.onPrimary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              caja.isActive ? 'Activa' : 'Inactiva',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleMenuAction(value, caja),
                        icon: Icon(Icons.more_vert, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'monedas',
                            child: Row(
                              children: [
                                Icon(Icons.monetization_on, size: 18),
                                SizedBox(width: 8),
                                Text('Ver Monedas'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: caja.isActive ? 'deactivate' : 'activate',
                            child: Row(
                              children: [
                                Icon(
                                  caja.isActive
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(caja.isActive ? 'Desactivar' : 'Activar'),
                              ],
                            ),
                          ),
                         PopupMenuItem(
                            value: 'cierre',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.close_fullscreen_rounded,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Cerrar caja',
                                  style: TextStyle(color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Saldo destacado
              BalanceCards(
                saldoInicial: caja.saldoInicial,
                saldoTransferencias: caja.saldoTransferencias,
                saldoTarjetas: caja.saldoTarjetas,
                saldoOtros: caja.saldoOtros,
              ),

              const SizedBox(height: 16),

              // Información adicional
             Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Creado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(
                              DateTime.parse(caja.createdAt.toString()),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons
                                    .account_balance_wallet, // Ícono más relevante para balance
                                size: 16,
                                color: theme.colorScheme.primary.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Balance total',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                                  fontWeight: FontWeight
                                      .w600, // Mayor peso para el título
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "\$${_getTotalBalance(caja).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize:
                                  16, // Tamaño de fuente ligeramente mayor
                              color: theme.colorScheme.primary.withValues(alpha: 0.6), // Color más oscuro para contraste
                              fontWeight:
                                  FontWeight.w700, // Mayor peso para destacar
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createCaja() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminCajaCreatePage()),
    );
    if (result) {
      _loadCajas();
    }
  }

  double _getTotalBalance(Caja caja) {
    final sum =
        caja.saldoInicial +
        (caja.saldoTransferencias ?? 0.0) +
        (caja.saldoTarjetas ?? 0.0) +
        (caja.saldoOtros ?? 0.0).toDouble();
    return sum;
  }

  void _showCajaDetails(Caja caja) async {
    final negocioData = await NegocioService.getCurrentUserInfo();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminCajaDetallePage(
          cajaId: caja.id,
          negocioId: negocioData.negocioId,
        ),
      ),
    ).then((_) => _loadCajas());
  }

  void _handleMenuAction(String action, Caja caja) {
    switch (action) {
      case 'monedas':
        _viewCajaMonedas(caja);
        break;
      case 'activate':
      case 'deactivate':
        _toggleCajaStatus(caja);
        break;
      case 'editar':
        _editCaja(caja);
        break;
      case 'cierre':
        _showCerrarCajaModal(caja);
        break;
      case 'delete':
        _deleteCaja(caja);
        break;
    }
  }

  Future<void> _loadCajas() async {
    setState(() {
      _isLoading = true;
    });

    final negocioData = await NegocioService.getCurrentUserInfo();
    final request = ModelQueries.list(
      Caja.classType,
      where:
          Caja.ISDELETED.eq(false) & Caja.NEGOCIOID.eq(negocioData.negocioId),
    );
    final result = await Amplify.API.query(request: request).response;
    final cajas = result.data?.items;
    debugPrint('Cajas: ${cajas?.length}');

    final filteredCajas = cajas!
        .where((caja) => caja != null)
        .cast<Caja>()
        .toList();

    // Calcular total general
    double total = 0.0;
    for (final caja in filteredCajas) {
      total += _getTotalBalance(caja);
    }

    setState(() {
      _cajas = filteredCajas;
      _cajas.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _updatePageItems();
      _totalGeneral = total;
      _isLoading = false;
    });
  }

  void _showCerrarCajaModal(Caja caja) {
    final observacionesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar Caja'),
        content: TextField(
          controller: observacionesController,
          decoration: const InputDecoration(
            labelText: 'Observaciones',
            hintText: 'Ingresa observaciones (opcional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _cerrarCaja(
                caja,
                observacionesController.text.isEmpty
                    ? null
                    : observacionesController.text,
              );
            },
            child: const Text(
              'Cerrar Caja',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cerrarCaja(Caja caja, String? observaciones) async {
    try {
      final negocioData = await NegocioService.getCurrentUserInfo();
      // 1. Sumar el monto de las monedas asociadas a la caja
      final monedasRequest = ModelQueries.list(
        CajaMoneda.classType,
        where: CajaMoneda.CAJAID
            .eq(caja.id)
            .and(CajaMoneda.ISDELETED.eq(false)),
      );
      final monedasResponse = await Amplify.API
          .query(request: monedasRequest)
          .response;
      final monedas =
          monedasResponse.data?.items.whereType<CajaMoneda>().toList() ?? [];

      // Calcular el monto final sumando los montos de las monedas
      final montoFinal = monedas.fold<double>(
        0.0,
        (sum, moneda) => sum + (moneda.monto ?? 0.0),
      );

      // Calcular la diferencia (monto final - saldo inicial)
      final diferencia = montoFinal - (caja.saldoInicial ?? 0.0);

      // 2. Actualizar la caja con el nuevo estado (desactivar)
      final updatedCaja = caja.copyWith(
        isActive: false,
        updatedAt: TemporalDateTime(DateTime.now()),
      );
      final updateCajaRequest = ModelMutations.update(updatedCaja);
      await Amplify.API.mutate(request: updateCajaRequest).response;

      // 3. Crear el registro de cierre de caja
      final cierreCaja = CierreCaja(
        cajaID: caja.id,
        negocioID: caja.negocioID,
        saldoFinal: montoFinal,
        diferencia: diferencia,
        observaciones: observaciones,
        isDeleted: false,
        createdAt: TemporalDateTime(DateTime.now()),
        updatedAt: TemporalDateTime(DateTime.now()),
      );
      final cierreRequest = ModelMutations.create(cierreCaja);
      await Amplify.API.mutate(request: cierreRequest).response;

      // 4. Opcional: Crear un registro en el historial de cierre
      final cierreHistorial = CierreCajaHistorial(
        cierreCajaID: cierreCaja.id,
        negocioID: caja.negocioID,
        usuarioID: negocioData.userId,
        fechaCierre: TemporalDateTime(DateTime.now()),
        isDeleted: false,
        createdAt: TemporalDateTime(DateTime.now()),
        updatedAt: TemporalDateTime(DateTime.now()),
      );
      final historialRequest = ModelMutations.create(cierreHistorial);
      await Amplify.API.mutate(request: historialRequest).response;

      // Notificar éxito (puedes usar un SnackBar o similar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Caja cerrada exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar la caja: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _refreshCajas() async {
    await _loadCajas();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editCaja(Caja caja) {
    // TODO: Implementar edición de caja
    showDialog(
      context: context,
      builder: (context) => EditCajaDialog(
        caja: caja,
        onCajaUpdated: () {
          _loadCajas();
        },
      ),
    );
  }

  void _viewCajaMonedas(Caja caja) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CajaMonedasPage(caja: caja)),
    );
    if (result) {
      _loadCajas();
    }
  }

  Future<void> _toggleCajaStatus(Caja caja) async {
    // TODO: Implementar cambio de estado activo/inactivo
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${caja.isActive ? 'Desactivar' : 'Activar'} Caja'),
        content: Text(
          '¿Estás seguro de que deseas ${caja.isActive ? 'desactivar' : 'activar'} esta caja?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => {
              !caja.isActive ? _activeCaja(caja) : _inactiveCaja(caja),
              Navigator.pop(context, false),
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Implementar actualización del estado
      _loadCajas();
    }
  }

  Future<void> _activeCaja(Caja caja) async {
    try {
      final negocioData = await NegocioService.getCurrentUserInfo();
      final cajaNew = caja.copyWith(
        isActive: true,
        negocioID: negocioData.negocioId,
        saldoInicial: caja.saldoInicial,
        createdAt: caja.createdAt,
        updatedAt: TemporalDateTime(DateTime.now()),
        isDeleted: false,
      );
      final updateCajaRequest = ModelMutations.update(cajaNew);
      await Amplify.API.mutate(request: updateCajaRequest).response;
      _loadCajas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al activar la caja: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _inactiveCaja(Caja caja) async {
    try {
      final negocioData = await NegocioService.getCurrentUserInfo();
      final cajaNew = caja.copyWith(
        isActive: false,
        negocioID: negocioData.negocioId,
        saldoInicial: caja.saldoInicial,
        createdAt: caja.createdAt,
        updatedAt: TemporalDateTime(DateTime.now()),
        isDeleted: false,
      );
      final updateCajaRequest = ModelMutations.update(cajaNew);
      await Amplify.API.mutate(request: updateCajaRequest).response;
      _loadCajas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al inactivar la caja: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _deleteCaja(Caja caja) async {
    // TODO: Implementar eliminación lógica de caja
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Caja'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta caja? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Implementar eliminación lógica (isDeleted = true)
      final cajaDeleted = caja.copyWith(isDeleted: true);
      final request = ModelMutations.update(cajaDeleted);
      await Amplify.API.mutate(request: request).response;
      _loadCajas();
    }
  }
}

class EditCajaDialog extends StatelessWidget {
  final Caja caja;
  final VoidCallback onCajaUpdated;

  const EditCajaDialog({
    super.key,
    required this.caja,
    required this.onCajaUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Editar Caja'),
      content: const Text('¿Estas seguro de editar la caja?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            final result = await Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => AdminCajaEditPage(caja: caja)),
            );
            if (result) {
              onCajaUpdated();
            }
          },
          child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
