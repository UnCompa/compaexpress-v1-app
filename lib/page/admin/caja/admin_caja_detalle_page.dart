import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminCajaDetallePage extends StatefulWidget {
  final String cajaId;
  final String negocioId;

  const AdminCajaDetallePage({
    super.key,
    required this.cajaId,
    required this.negocioId,
  });

  @override
  _CajaDetailScreenState createState() => _CajaDetailScreenState();
}

class _CajaDetailScreenState extends State<AdminCajaDetallePage> {
  Caja? _caja;
  List<CajaMoneda> _cajaMonedas = [];
  List<CajaMovimiento> _cajaMovimientos = [];
  List<CierreCaja> _cierresCaja = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCajaDetails();
  }

  Future<void> _fetchCajaDetails() async {
    try {
      // Consultar detalles de la caja
      final cajaRequest = ModelQueries.get(
        Caja.classType,
        CajaModelIdentifier(id: widget.cajaId),
      );
      final cajaResponse = await Amplify.API
          .query(request: cajaRequest)
          .response;
      final caja = cajaResponse.data;

      if (caja == null) {
        setState(() {
          _error = 'Caja no encontrada';
          _isLoading = false;
        });
        return;
      }

      // Consultar monedas de la caja
      final monedasRequest = ModelQueries.list(
        CajaMoneda.classType,
        where: CajaMoneda.CAJAID
            .eq(widget.cajaId)
            .and(CajaMoneda.ISDELETED.eq(false)),
      );
      final monedasResponse = await Amplify.API
          .query(request: monedasRequest)
          .response;
      final monedas = monedasResponse.data?.items ?? [];

      // Consultar movimientos de la caja
      final movimientosRequest = ModelQueries.list(
        CajaMovimiento.classType,
        where: CajaMovimiento.CAJAID
            .eq(widget.cajaId)
            .and(CajaMovimiento.ISDELETED.eq(false)),
      );
      final movimientosResponse = await Amplify.API
          .query(request: movimientosRequest)
          .response;
      final movimientos = movimientosResponse.data?.items ?? [];

      // Consultar cierres de caja
      final cierresRequest = ModelQueries.list(
        CierreCaja.classType,
        where: CierreCaja.CAJAID
            .eq(widget.cajaId)
            .and(CierreCaja.ISDELETED.eq(false)),
      );
      final cierresResponse = await Amplify.API
          .query(request: cierresRequest)
          .response;
      final cierres = cierresResponse.data?.items ?? [];

      setState(() {
        _caja = caja;
        _cajaMonedas = monedas.whereType<CajaMoneda>().toList();
        _cajaMovimientos = movimientos.whereType<CajaMovimiento>().toList();
        _cajaMovimientos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _cierresCaja = cierres.whereType<CierreCaja>().toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los detalles: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: Text(
          'Detalles de Caja',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
            )
          : _error != null
          ? Center(
              child: Text(
                _error!,
                style: GoogleFonts.inter(fontSize: 16, color: Colors.red[700]),
              ),
            )
          : _caja == null
          ? Center(
              child: Text(
                'No se encontraron datos',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información general de la caja
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: const Color(0xFF1976D2),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Información de la Caja',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1565C0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('ID de Caja', _caja!.id),
                        _buildInfoRow(
                          'Saldo Inicial',
                          '\$${_caja!.saldoInicial.toStringAsFixed(2)}',
                        ),
                        _buildInfoRow(
                          'Saldo Transferencias',
                          _caja!.saldoTransferencias != null
                              ? '\$${_caja!.saldoTransferencias!.toStringAsFixed(2)}'
                              : 'N/A',
                        ),
                        _buildInfoRow(
                          'Saldo Tarjetas',
                          _caja!.saldoTarjetas != null
                              ? '\$${_caja!.saldoTarjetas!.toStringAsFixed(2)}'
                              : 'N/A',
                        ),
                        _buildInfoRow(
                          'Saldo Otros',
                          _caja!.saldoOtros != null
                              ? '\$${_caja!.saldoOtros!.toStringAsFixed(2)}'
                              : 'N/A',
                        ),
                        _buildInfoRow(
                          'Estado',
                          _caja!.isActive ? "Activa" : "Inactiva",
                          valueColor: _caja!.isActive
                              ? Colors.green[600]
                              : Colors.red[600],
                        ),
                        _buildInfoRow(
                          'Fecha de Creación',
                          _formatDate(_caja!.createdAt.getDateTimeInUtc()),
                        ),
                        _buildInfoRow(
                          'Última Actualización',
                          _formatDate(_caja!.updatedAt.getDateTimeInUtc()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Monedas
                  _buildSection(
                    'Monedas',
                    Icons.monetization_on,
                    _cajaMonedas.isEmpty
                        ? [_buildEmptyState('No hay monedas registradas')]
                        : _cajaMonedas
                              .map((moneda) => _buildMonedaCard(moneda))
                              .toList(),
                  ),
                  const SizedBox(height: 20),

                  // Movimientos
                  _buildSection(
                    'Movimientos',
                    Icons.swap_horiz,
                    _cajaMovimientos.isEmpty
                        ? [_buildEmptyState('No hay movimientos registrados')]
                        : _cajaMovimientos
                              .map(
                                (movimiento) =>
                                    _buildMovimientoCard(movimiento),
                              )
                              .toList(),
                  ),
                  const SizedBox(height: 20),

                  // Cierres de caja
                  _buildSection(
                    'Cierres de Caja',
                    Icons.lock_clock,
                    _cierresCaja.isEmpty
                        ? [_buildEmptyState('No hay cierres registrados')]
                        : _cierresCaja
                              .map((cierre) => _buildCierreCard(cierre))
                              .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF263238),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF1976D2), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildMonedaCard(CajaMoneda moneda) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3F2FD)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.monetization_on,
              color: const Color(0xFF2196F3),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${moneda.moneda} - ${moneda.denominacion}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monto: \$${moneda.monto}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovimientoCard(CajaMovimiento movimiento) {
    final isIngreso =
        movimiento.tipo.toLowerCase().contains('ingreso') ?? false;
    final color = isIngreso ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3F2FD)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isIngreso ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${movimiento.tipo} - \$${movimiento.monto}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  movimiento.descripcion ?? 'Sin descripción',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCierreCard(CierreCaja cierre) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3F2FD)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF673AB7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.lock_clock,
              color: const Color(0xFF673AB7),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo Final: \$${cierre.saldoFinal}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Diferencia: \$${cierre.diferencia}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                if (cierre.observaciones != null &&
                    cierre.observaciones!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Observaciones: ${cierre.observaciones}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
