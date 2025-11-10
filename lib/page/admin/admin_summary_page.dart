import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/summary/bussines_summary_service.dart';
import 'package:compaexpress/services/summary/dahboard_summary_service.dart';
import 'package:compaexpress/services/summary/product_summary_service.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSummaryPage extends StatefulWidget {
  final String negocioID;

  const AdminSummaryPage({super.key, required this.negocioID});

  @override
  State<StatefulWidget> createState() {
    return _AdminSummaryState();
  }
}

class _AdminSummaryState extends State<AdminSummaryPage> {
  List<Producto> _products = [];
  Map<String, int> _totalUnitsSold = {};
  Map<String, dynamic> _dashboardData = {};
  Map<String, dynamic> _businessData = {};
  bool _isLoading = true;
  bool _isDashboardLoading = true;
  bool _isBusinessLoading = true;
  String _selectedChart = 'units'; // 'units', 'invoices'

  late DashboardSummaryService _dashboardService;
  late BussinesSummaryService _businessService;

  @override
  void initState() {
    super.initState();
    _dashboardService = DashboardSummaryService(negocioID: widget.negocioID);
    _businessService = BussinesSummaryService(negocioID: widget.negocioID);
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    await Future.wait([
      _fetchProductData(),
      _fetchDashboardData(),
      _fetchBusinessData(),
    ]);
  }

  Future<void> _fetchProductData() async {
    try {
      setState(() => _isLoading = true);

      final products = await ProductSummaryService.getBestsProducts(
        negocioID: widget.negocioID,
      );
      final unitsSold = await ProductSummaryService.getTotalUnitsSold(
        negocioID: widget.negocioID,
      );

      setState(() {
        _products = products ?? [];
        _totalUnitsSold = unitsSold ?? {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos de productos: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _fetchDashboardData() async {
    try {
      setState(() => _isDashboardLoading = true);

      final dashboardData = await _dashboardService.obtenerResumen();

      setState(() {
        _dashboardData = dashboardData ?? {};
        _isDashboardLoading = false;
      });
    } catch (e) {
      setState(() => _isDashboardLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar resumen del negocio: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _fetchBusinessData() async {
    try {
      setState(() => _isBusinessLoading = true);
      print("CARGANDO DATOS...");
      final businessData = await Future.wait([
        _businessService.obtenerDistribucionTipoPago(),
        _businessService.obtenerIngresosPorFecha(),
        _businessService.obtenerDiferenciaAcumuladaCierreCaja(),
        _businessService.obtenerConteoOrdenesYFacturas(),
        _businessService.obtenerProductosBajoStock(),
        _businessService.obtenerGananciaPorcentual(),
      ]);

      print(businessData);
      final businessDataLoad = {
        'tiposPago': businessData[0] ?? {},
        'ingresosPorFecha': businessData[1] ?? {},
        'diferenciaCierre': businessData[2] ?? 0.0,
        'ordenesFacturas': businessData[3] ?? {},
        'stockBajo': businessData[4] ?? {},
        'ganancias': businessData[5] ?? 0.0,
      };
      print(businessDataLoad);
      setState(() {
        _businessData = businessDataLoad;
        _isBusinessLoading = false;
      });
    } catch (e) {
      setState(() => _isBusinessLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar análisis del negocio: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildDashboardMetrics(ThemeData theme) {
    if (_isDashboardLoading) {
      return Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 20),
        child: Center(
          child: AppLoadingIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    final ventasPorVendedor =
        _dashboardData['ventasPorVendedor'] as Map<String, double>? ?? {};
    final totalCaja = _dashboardData['totalCaja'] as double? ?? 0.0;
    final totalGeneral = _dashboardData['totalGeneral'] as double? ?? 0.0;
    final maxCierreCaja = _dashboardData['maxCierreCaja'] as double? ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen Financiero',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // Métricas principales
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total en General',
                  '\$${totalGeneral.toStringAsFixed(2)}',
                  Icons.account_balance_wallet_outlined,
                  theme.colorScheme.primary,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Total en Efectivo',
                  '\$${totalCaja.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  theme.colorScheme.secondary,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Mayor Cierre',
                  '\$${maxCierreCaja.toStringAsFixed(2)}',
                  Icons.trending_up,
                  theme.colorScheme.tertiary,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Vendedores',
                  '${ventasPorVendedor.length}',
                  Icons.people,
                  theme.colorScheme.primary,
                  theme,
                ),
              ),
            ],
          ),

          // Ventas por vendedor si hay datos
          if (ventasPorVendedor.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Ventas por Vendedor',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      ventasPorVendedor.values.reduce((a, b) => a > b ? a : b) *
                      1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final vendedor = ventasPorVendedor.keys.elementAt(
                          group.x.toInt(),
                        );
                        final valor = rod.toY;
                        return BarTooltipItem(
                          'Vendedor $vendedor\n\$${valor.toStringAsFixed(2)}',
                          TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < ventasPorVendedor.length) {
                            final vendedor = ventasPorVendedor.keys.elementAt(
                              index,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'V${vendedor ?? "?"}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: ventasPorVendedor.entries.map((entry) {
                    final index = ventasPorVendedor.keys.toList().indexOf(
                      entry.key,
                    );
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: theme.colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval:
                        (ventasPorVendedor.values.reduce(
                              (a, b) => a > b ? a : b,
                            ) *
                            1.2) /
                        5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBusinessAnalytics(ThemeData theme) {
    if (_isBusinessLoading) {
      return Container(
        height: 200,
        margin: const EdgeInsets.only(bottom: 20),
        child: Center(
          child: AppLoadingIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    final tiposPago = _businessData['tiposPago'] as Map<String, int>? ?? {};
    final diferenciaCierre =
        _businessData['diferenciaCierre'] as double? ?? 0.0;
    final ordenesFacturas =
        _businessData['ordenesFacturas'] as Map<String, int>? ?? {};
    final stockBajo = _businessData['stockBajo'] as Map<String, int>? ?? {};
    final ingresosPorFecha =
        _businessData['ingresosPorFecha'] as Map<String, double>? ?? {};

    // Manejo seguro de ganancias
    final gananciasData = _businessData['ganancias'];
    double ganancias = 0.0;
    if (gananciasData is double) {
      ganancias = gananciasData;
    } else if (gananciasData is String) {
      ganancias = double.tryParse(gananciasData) ?? 0.0;
    } else if (gananciasData is int) {
      ganancias = gananciasData.toDouble();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis del Negocio',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // Primera fila de métricas
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Diferencia Cierres',
                  '\$${diferenciaCierre.toStringAsFixed(2)}',
                  Icons.compare_arrows,
                  diferenciaCierre >= 0
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.error,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Ganancias Porcentual',
                  '${ganancias.toStringAsFixed(2)}%',
                  Icons.arrow_circle_up,
                  ganancias >= 0
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.error,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Total Órdenes',
                  '${ordenesFacturas['ordenes'] ?? 0}',
                  Icons.list_alt,
                  theme.colorScheme.primary,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Total Facturas',
                  '${ordenesFacturas['facturas'] ?? 0}',
                  Icons.receipt_long,
                  theme.colorScheme.tertiary,
                  theme,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Segunda fila - Stock y tipos de pago
          Row(
            children: [
              // Columna de stock
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado del Inventario',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallMetricCard(
                            'Sin Stock',
                            '${stockBajo['sinStock'] ?? 0}',
                            theme.colorScheme.error,
                            theme,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSmallMetricCard(
                            'Bajo Stock',
                            '${stockBajo['bajoStock'] ?? 0}',
                            theme.colorScheme.tertiary,
                            theme,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Columna de tipos de pago
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipos de Pago',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallMetricCard(
                            'Efectivo',
                            '${tiposPago['EFECTIVO'] ?? 0}',
                            theme.colorScheme.secondary,
                            theme,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSmallMetricCard(
                            'Transferencia',
                            '${tiposPago['TRASNFERENCIA'] ?? 0}',
                            theme.colorScheme.primary,
                            theme,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Gráfico de ingresos por fecha (últimos 30 días)
          if (ingresosPorFecha.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Ingresos Últimos 30 Días',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: _buildIncomeChart(ingresosPorFecha, theme),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIncomeChart(
    Map<String, double> ingresosPorFecha,
    ThemeData theme,
  ) {
    final sortedEntries = ingresosPorFecha.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sortedEntries.isEmpty) {
      return Center(
        child: Text(
          'No hay datos de ingresos',
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }

    final maxY = sortedEntries
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.outline.withOpacity(0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                '\$${value.toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              reservedSize: 50,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < sortedEntries.length && index >= 0) {
                  try {
                    final date = DateTime.parse(sortedEntries[index].key);
                    return Text(
                      '${date.day}/${date.month}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    );
                  } catch (e) {
                    return const Text('');
                  }
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        minX: 0,
        maxX: (sortedEntries.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: sortedEntries.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value);
            }).toList(),
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetricCard(
    String title,
    String value,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSelector() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            'Tipo de gráfico: ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'units',
                  label: Text('Por Unidades'),
                  icon: Icon(Icons.inventory),
                ),
                ButtonSegment(
                  value: 'invoices',
                  label: Text('Por Facturas'),
                  icon: Icon(Icons.receipt),
                ),
              ],
              selected: {_selectedChart},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _selectedChart = selection.first;
                });
                _loadDataForChart();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDataForChart() async {
    if (_selectedChart == 'invoices') {
      try {
        setState(() => _isLoading = true);
        final products =
            await ProductSummaryService.getProductsByInvoiceCount();
        setState(() {
          _products = products ?? [];
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    } else {
      setState(() {});
    }
  }

  double _getProductValue(Producto product) {
    if (_selectedChart == 'units') {
      return (_totalUnitsSold[product.id] ?? 0).toDouble();
    } else {
      return (_totalUnitsSold[product.id] ?? 0).toDouble();
    }
  }

  Widget _buildBarChart() {
    final theme = Theme.of(context);

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay datos disponibles',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    final maxValue = _products.isNotEmpty
        ? _products
              .map((p) => _getProductValue(p))
              .reduce((a, b) => a > b ? a : b)
        : 10.0;

    return Column(
      children: [
        Text(
          _selectedChart == 'units'
              ? 'Productos Más Vendidos (por Unidades)'
              : 'Productos Más Frecuentes (por Facturas)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue * 1.2,
              barGroups: _products.asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;
                final value = _getProductValue(product);

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: _getBarColor(index, theme),
                      width: 35,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),

              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    reservedSize: 45,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < _products.length) {
                        final productName = _products[index].nombre;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            width: 60,
                            child: Text(
                              productName.length > 10
                                  ? '${productName.substring(0, 10)}...'
                                  : productName,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 50,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),

              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),

              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                  strokeWidth: 1,
                ),
                horizontalInterval: maxValue > 0 ? (maxValue / 5) : 1.0,
              ),

              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final product = _products[groupIndex];
                    final value = _getProductValue(product);
                    final unit = _selectedChart == 'units'
                        ? 'unidades'
                        : 'facturas';

                    return BarTooltipItem(
                      '${product.nombre}\n${value.toInt()} $unit',
                      GoogleFonts.poppins(
                        color: theme.colorScheme.onInverseSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getBarColor(int index, ThemeData theme) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.primary.withOpacity(0.7),
      theme.colorScheme.secondary.withOpacity(0.7),
    ];
    return colors[index % colors.length];
  }

  Widget _buildStatsCards() {
    final theme = Theme.of(context);

    if (_products.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final value = _getProductValue(product);
          final unit = _selectedChart == 'units' ? 'unidades' : 'facturas';

          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: _getBarColor(index, theme),
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.poppins(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product.nombre,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${value.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getBarColor(index, theme),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text(
          'Dashboard Completo',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAllData,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen Financiero
            _buildDashboardMetrics(theme),

            // Divisor
            Divider(
              color: theme.colorScheme.outline.withOpacity(0.2),
              thickness: 1,
            ),

            // Análisis del Negocio
            _buildBusinessAnalytics(theme),

            // Divisor
            Divider(
              color: theme.colorScheme.outline.withOpacity(0.2),
              thickness: 1,
            ),

            // Sección de productos
            Text(
              'Análisis de Productos',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),

            _buildChartSelector(),

            if (_isLoading)
              SizedBox(
                height: 400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppLoadingIndicator(
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cargando datos de productos...',
                        style: GoogleFonts.poppins(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              _buildStatsCards(),
              SizedBox(height: 400, child: _buildBarChart()),
            ],
          ],
        ),
      ),
    );
  }
}
