import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/services/user_service.dart';

class DashboardSummaryService {
  final String negocioID;

  DashboardSummaryService({required this.negocioID});

  Future<Map<String, dynamic>> obtenerResumen() async {
    final ventasPorVendedor = await _ventasPorVendedor();
    final totalCaja = await _totalEnCajas();
    final totalGeneral = await _totalGeneral();
    final maxCierreCaja = await _mayorCierreCaja();

    return {
      'ventasPorVendedor': ventasPorVendedor,
      'totalCaja': totalCaja,
      'maxCierreCaja': maxCierreCaja,
      'totalGeneral': totalGeneral,
    };
  }

  Future<Map<String, double>> _ventasPorVendedor() async {
    final query = ModelQueries.list(
      Invoice.classType,
      where: Invoice.NEGOCIOID.eq(negocioID).and(Invoice.ISDELETED.ne(true)),
    );

    final result = await Amplify.API.query(request: query).response;
    final data = result.data?.items ?? [];
    final user = await UserService.fetchUsersSellers();

    final Map<String, String> userIdToUsername = {
      for (var u in user!.users) u.id: u.email,
    };

    final Map<String, double> ventas = {};
    for (final factura in data) {
      if (factura == null) continue;

      // Verificar que sellerID no sea null antes de usarlo
      final sellerID =
          factura.sellerID; // Saltar esta factura si no tiene sellerID

      final total = factura.invoiceReceivedTotal.toDouble() ?? 0.0;

      final username = userIdToUsername[sellerID] ?? 'Desconocido';

      ventas[username] = (ventas[username] ?? 0) + total;
    }

    return ventas;
  }

  Future<double> _totalEnCajas() async {
    final query = ModelQueries.list(
      Caja.classType,
      where: Caja.NEGOCIOID.eq(negocioID).and(Caja.ISDELETED.ne(true)),
    );

    final result = await Amplify.API.query(request: query).response;
    final data = result.data?.items ?? [];
    double total = 0.0;

    for (final caja in data) {
      if (caja == null) continue;
      // Verificar que saldoInicial no sea null
      final saldo = caja.saldoInicial.toDouble() ?? 0.0;
      total += saldo;
    }

    return total;
  }

  Future<double> _totalGeneral() async {
    final query = ModelQueries.list(
      Caja.classType,
      where: Caja.NEGOCIOID.eq(negocioID).and(Caja.ISDELETED.ne(true)),
    );

    final result = await Amplify.API.query(request: query).response;
    final data = result.data?.items ?? [];
    double total = 0.0;

    for (final caja in data) {
      if (caja == null) continue;
      final saldo = caja.saldoInicial + (caja.saldoTransferencias ?? 0.0) +
          (caja.saldoTarjetas ?? 0.0) +
          (caja.saldoOtros ?? 0.0).toDouble();
      total += saldo;
    }

    return total;
  }

  Future<double> _mayorCierreCaja() async {
    final query = ModelQueries.list(
      CierreCaja.classType,
      where: CierreCaja.NEGOCIOID
          .eq(negocioID)
          .and(CierreCaja.ISDELETED.ne(true)),
    );

    final result = await Amplify.API.query(request: query).response;
    final data = result.data?.items ?? [];
    double max = 0.0;

    for (final cierre in data) {
      if (cierre == null) continue;
      // Verificar que saldoFinal no sea null
      final saldo = cierre.saldoFinal.toDouble() ?? 0.0;
      if (saldo > max) {
        max = saldo;
      }
    }

    return max;
  }
}
