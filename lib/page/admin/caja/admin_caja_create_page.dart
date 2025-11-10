import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/utils/denominaciones.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
class AdminCajaCreatePage extends StatefulWidget {
  const AdminCajaCreatePage({super.key});

  @override
  State<AdminCajaCreatePage> createState() => _AdminCajaCreatePageState();
}

class _AdminCajaCreatePageState extends State<AdminCajaCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _saldoInicialController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  List<CajaMonedaForm> _monedas = [];

  final Map<String, List<double>> _denominacionesPorMoneda =
      Denominaciones.denominaciones;

  @override
  void initState() {
    super.initState();
    _initializeMonedasDefecto();
  }

  @override
  void dispose() {
    _saldoInicialController.dispose();
    super.dispose();
  }

  void _initializeMonedasDefecto() {
    final denominacionesUSD = _denominacionesPorMoneda['USD'] ?? [];
    setState(() {
      _monedas = denominacionesUSD.map((denominacion) {
        return CajaMonedaForm(
          moneda: 'USD',
          denominacion: denominacion,
          cantidad: 0,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Crear Nueva Caja',
          style: GoogleFonts.mulish(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _guardarCaja,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: AppLoadingIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onSecondary,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(
                'GUARDAR',
                style: GoogleFonts.mulish(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCajaInfoSection(context),
                    const SizedBox(height: 16),
                    _buildMonedasSection(context),
                  ],
                ),
              ),
            ),
            _buildBottomSummary(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCajaInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Información de la Caja',
                  style: GoogleFonts.mulish(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _saldoInicialController,
              style: GoogleFonts.mulish(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Saldo Inicial',
                labelStyle: GoogleFonts.mulish(),
                prefixIcon: Icon(
                  Icons.attach_money_rounded,
                  color: colorScheme.primary,
                ),
                prefixText: '\$ ',
                prefixStyle: GoogleFonts.mulish(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.error),
                ),
                helperText: 'Ingrese el saldo inicial de la caja',
                helperStyle: GoogleFonts.mulish(fontSize: 12),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El saldo inicial es requerido';
                }
                final saldo = double.tryParse(value);
                if (saldo == null || saldo < 0) {
                  return 'Ingrese un saldo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isActive
                    ? colorScheme.primaryContainer.withOpacity(0.3)
                    : colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isActive
                      ? colorScheme.primary.withOpacity(0.5)
                      : colorScheme.error.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value ?? true;
                      });
                    },
                    activeColor: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isActive
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: _isActive ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isActive ? 'Caja activa' : 'Caja inactiva',
                    style: GoogleFonts.mulish(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: _isActive ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonedasSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.monetization_on_rounded,
                        color: Colors.amber[700],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Denominaciones',
                      style: GoogleFonts.mulish(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                _buildMonedaSelector(context),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Configure las cantidades de cada denominación',
              style: GoogleFonts.mulish(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _buildMonedasList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMonedaSelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Cambiar moneda',
        onSelected: _cambiarMoneda,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.currency_exchange_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                _monedas.isNotEmpty ? _monedas.first.moneda : 'USD',
                style: GoogleFonts.mulish(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ],
          ),
        ),
        itemBuilder: (context) => _denominacionesPorMoneda.keys
            .map(
              (moneda) => PopupMenuItem(
                value: moneda,
                child: Row(
                  children: [
                    Icon(
                      Icons.currency_exchange_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cambiar a $moneda',
                      style: GoogleFonts.mulish(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMonedasList(BuildContext context) {
    return Column(
      children: _monedas.asMap().entries.map((entry) {
        final index = entry.key;
        final moneda = entry.value;
        return _buildMonedaItem(context, moneda, index);
      }).toList(),
    );
  }

  Widget _buildMonedaItem(
    BuildContext context,
    CajaMonedaForm moneda,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final montoCalculado = moneda.cantidad * moneda.denominacion;
    final tieneValor = moneda.cantidad > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tieneValor
            ? colorScheme.primaryContainer.withOpacity(0.3)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tieneValor
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Denominación Badge
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: tieneValor
                    ? [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.7),
                      ]
                    : [
                        colorScheme.surfaceContainerHighest,
                        colorScheme.surfaceContainer,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: tieneValor
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  moneda.moneda,
                  style: GoogleFonts.mulish(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tieneValor
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDenominacion(moneda.denominacion),
                  style: GoogleFonts.mulish(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: tieneValor
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDenominacionLabel(moneda.moneda, moneda.denominacion),
                  style: GoogleFonts.mulish(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: tieneValor
                        ? Colors.green.withOpacity(0.15)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: tieneValor
                          ? Colors.green.withOpacity(0.3)
                          : colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.payments_rounded,
                        size: 14,
                        color: tieneValor
                            ? Colors.green[700]
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Total: \$${montoCalculado.toStringAsFixed(2)}',
                        style: GoogleFonts.mulish(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: tieneValor
                              ? Colors.green[700]
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Input de cantidad
          SizedBox(
            width: 100,
            child: TextFormField(
              initialValue: moneda.cantidad.toString(),
              style: GoogleFonts.mulish(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Cant.',
                labelStyle: GoogleFonts.mulish(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.numbers_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                final cantidad = int.tryParse(value) ?? 0;
                setState(() {
                  _monedas[index] = moneda.copyWith(cantidad: cantidad);
                });
              },
              validator: (value) {
                final cantidad = int.tryParse(value ?? '0') ?? 0;
                if (cantidad < 0) {
                  return 'Inválido';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalMonedas = _monedas.fold<double>(
      0.0,
      (sum, moneda) => sum + (moneda.cantidad * moneda.denominacion),
    );
    final saldoInicial = double.tryParse(_saldoInicialController.text) ?? 0.0;
    final diferencia = saldoInicial - totalMonedas;
    final hayDiferencia = diferencia.abs() > 0.001;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  context,
                  icon: Icons.monetization_on_rounded,
                  label: 'Total en Monedas',
                  value: totalMonedas,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                _buildSummaryRow(
                  context,
                  icon: Icons.account_balance_rounded,
                  label: 'Saldo Inicial',
                  value: saldoInicial,
                  color: Colors.green,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(
                    thickness: 1,
                    color: colorScheme.outlineVariant,
                  ),
                ),
                _buildSummaryRow(
                  context,
                  icon: hayDiferencia
                      ? Icons.warning_rounded
                      : Icons.balance_rounded,
                  label: 'Diferencia',
                  value: diferencia,
                  color: hayDiferencia ? Colors.orange : Colors.green,
                  isTotal: true,
                ),
              ],
            ),
          ),
          if (hayDiferencia) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.orange[700],
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      diferencia > 0
                          ? 'Saldo inicial excede el total en monedas por \$${diferencia.toStringAsFixed(2)}'
                          : 'Total en monedas excede el saldo inicial por \$${(-diferencia).toStringAsFixed(2)}',
                      style: GoogleFonts.mulish(
                        fontSize: 13,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: isTotal ? 22 : 20),
            ),
            const SizedBox(width: 12),
            Text(
              '$label:',
              style: GoogleFonts.mulish(
                fontSize: isTotal ? 17 : 15,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: GoogleFonts.mulish(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDenominacion(double denominacion) {
    if (denominacion < 1) {
      return '${(denominacion * 100).toInt()}¢';
    } else {
      return '\$${denominacion.toStringAsFixed(denominacion == denominacion.toInt() ? 0 : 2)}';
    }
  }

  String _getDenominacionLabel(String moneda, double denominacion) {
    if (denominacion < 1) {
      return '$moneda - ${(denominacion * 100).toInt()} centavos';
    } else if (denominacion == 1) {
      return '$moneda - 1 ${moneda == 'USD' ? 'dólar' : 'euro'}';
    } else {
      return '$moneda - ${denominacion.toInt()} ${moneda == 'USD' ? 'dólares' : 'euros'}';
    }
  }

  void _cambiarMoneda(String nuevaMoneda) {
    final denominaciones = _denominacionesPorMoneda[nuevaMoneda] ?? [];
    setState(() {
      _monedas = denominaciones.map((denominacion) {
        return CajaMonedaForm(
          moneda: nuevaMoneda,
          denominacion: denominacion,
          cantidad: 0,
        );
      }).toList();
    });
  }

  Future<void> _guardarCaja() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _crearCaja();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Caja creada exitosamente',
                  style: GoogleFonts.mulish(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error al crear la caja: $e',
                    style: GoogleFonts.mulish(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _crearCaja() async {
    final saldoInicial = double.parse(_saldoInicialController.text);
    final negocioId = await _getCurrentNegocioId();

    final nuevaCaja = Caja(
      negocioID: negocioId,
      isDeleted: false,
      saldoInicial: saldoInicial,
      isActive: _isActive,
      createdAt: TemporalDateTime.now(),
      updatedAt: TemporalDateTime.now(),
    );

    final cajaCreada = await Amplify.API
        .mutate(request: ModelMutations.create(nuevaCaja))
        .response;

    final monedasACrear = _monedas.where((m) => m.cantidad > 0).toList();

    for (final monedaForm in monedasACrear) {
      final monto = monedaForm.cantidad * monedaForm.denominacion;
      final cajaMoneda = CajaMoneda(
        cajaID: cajaCreada.data!.id,
        negocioID: negocioId,
        moneda: monedaForm.moneda,
        denominacion: monedaForm.denominacion,
        monto: monto,
        isDeleted: false,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
      );

      await Amplify.API
          .mutate(request: ModelMutations.create(cajaMoneda))
          .response;
    }
  }

  Future<String> _getCurrentNegocioId() async {
    final userData = await NegocioService.getCurrentUserInfo();
    return userData.negocioId;
  }
}

class CajaMonedaForm {
  final String? id;
  final String moneda;
  final double denominacion;
  final int cantidad;

  CajaMonedaForm({
    this.id,
    required this.moneda,
    required this.denominacion,
    required this.cantidad,
  });

  CajaMonedaForm copyWith({
    String? id,
    String? moneda,
    double? denominacion,
    int? cantidad,
  }) {
    return CajaMonedaForm(
      id: id ?? this.id,
      moneda: moneda ?? this.moneda,
      denominacion: denominacion ?? this.denominacion,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}
