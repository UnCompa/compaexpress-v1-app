import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/utils/fecha_ecuador.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Detalles de Caja',
          style: GoogleFonts.mulish(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : _error != null
          ? Center(
              child: Text(
                _error!,
                style: GoogleFonts.mulish(
                  fontSize: 16,
                  color: colorScheme.error,
                ),
              ),
            )
          : _caja == null
          ? Center(
              child: Text(
                'No se encontraron datos',
                style: GoogleFonts.mulish(fontSize: 16, color: theme.hintColor),
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
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.1),
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
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: colorScheme.onPrimaryContainer,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Información de la Caja',
                                style: GoogleFonts.mulish(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(context, 'ID de Caja', _caja!.id),
                        _buildInfoRow(
                          context,
                          'Saldo Inicial',
                          '\$${_caja!.saldoInicial.toStringAsFixed(2)}',
                        ),
                        _buildInfoRow(
                          context,
                          'Saldo Transferencias',
                          _caja!.saldoTransferencias != null
                              ? '\$${_caja!.saldoTransferencias!.toStringAsFixed(2)}'
                              : 'N/A',
                        ),
                        _buildInfoRow(
                          context,
                          'Saldo Tarjetas',
                          _caja!.saldoTarjetas != null
                              ? '\$${_caja!.saldoTarjetas!.toStringAsFixed(2)}'
                              : 'N/A',
                        ),
                        _buildInfoRow(
                          context,
                          'Saldo Otros',
                          _caja!.saldoOtros != null
                              ? '\$${_caja!.saldoOtros!.toStringAsFixed(2)}'
                              : 'N/A',
                        ),
                        _buildInfoRow(
                          context,
                          'Estado',
                          _caja!.isActive ? "Activa" : "Inactiva",
                          valueColor: _caja!.isActive
                              ? Colors.green[600]
                              : Colors.red[600],
                        ),
                        _buildInfoRow(
                          context,
                          'Fecha de Creación',
                          _formatDate(_caja!.createdAt.getDateTimeInUtc()),
                        ),
                        _buildInfoRow(
                          context,
                          'Última Actualización',
                          _formatDate(_caja!.updatedAt.getDateTimeInUtc()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Monedas
                  _buildSection(
                    context,
                    'Monedas',
                    Icons.monetization_on,
                    _cajaMonedas.isEmpty
                        ? [
                            _buildEmptyState(
                              context,
                              'No hay monedas registradas',
                            ),
                          ]
                        : _cajaMonedas
                              .map(
                                (moneda) => _buildMonedaCard(context, moneda),
                              )
                              .toList(),
                  ),
                  const SizedBox(height: 20),

                  // Movimientos
                  _buildSection(
                    context,
                    'Movimientos',
                    Icons.swap_horiz,
                    _cajaMovimientos.isEmpty
                        ? [
                            _buildEmptyState(
                              context,
                              'No hay movimientos registrados',
                            ),
                          ]
                        : _cajaMovimientos
                              .map(
                                (movimiento) =>
                                    _buildMovimientoCard(context, movimiento),
                              )
                              .toList(),
                  ),
                  const SizedBox(height: 20),

                  // Cierres de caja
                  _buildSection(
                    context,
                    'Cierres de Caja',
                    Icons.lock_clock,
                    _cierresCaja.isEmpty
                        ? [
                            _buildEmptyState(
                              context,
                              'No hay cierres registrados',
                            ),
                          ]
                        : _cierresCaja
                              .map(
                                (cierre) => _buildCierreCard(context, cierre),
                              )
                              .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.mulish(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.mulish(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
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
              color: colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.mulish(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
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

  Widget _buildEmptyState(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.mulish(
            fontSize: 14,
            color: theme.hintColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildMonedaCard(BuildContext context, CajaMoneda moneda) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calcular cantidad de billetes/monedas
    final cantidad = (moneda.monto / moneda.denominacion).round();
    final total = moneda.monto;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.attach_money, color: Colors.amber[700], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      moneda.moneda,
                      style: GoogleFonts.mulish(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${moneda.denominacion.toStringAsFixed(2)}',
                      style: GoogleFonts.mulish(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.numbers,
                            size: 14,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$cantidad',
                            style: GoogleFonts.mulish(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Total:',
                      style: GoogleFonts.mulish(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: GoogleFonts.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovimientoCard(BuildContext context, CajaMovimiento movimiento) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isIngreso = movimiento.tipo.toLowerCase().contains('ingreso');
    final color = isIngreso ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIngreso ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      movimiento.tipo,
                      style: GoogleFonts.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '\$${movimiento.monto.toStringAsFixed(2)}',
                      style: GoogleFonts.mulish(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  movimiento.descripcion ?? 'Sin descripción',
                  style: GoogleFonts.mulish(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCierreCard(BuildContext context, CierreCaja cierre) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lock_clock,
              color: Colors.deepPurple[400],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saldo Final:',
                      style: GoogleFonts.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '\$${cierre.saldoFinal.toStringAsFixed(2)}',
                      style: GoogleFonts.mulish(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Diferencia:',
                      style: GoogleFonts.mulish(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '\$${cierre.diferencia.toStringAsFixed(2)}',
                      style: GoogleFonts.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cierre.diferencia == 0
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                if (cierre.observaciones != null &&
                    cierre.observaciones!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notes, size: 14, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            cierre.observaciones!,
                            style: GoogleFonts.mulish(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
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
    final ecuadorDate = FechaEcuador.aZonaEcuador(date);
    return '${ecuadorDate.day}/${ecuadorDate.month}/${ecuadorDate.year} ${ecuadorDate.hour}:${ecuadorDate.minute.toString().padLeft(2, '0')}';
  }
}
