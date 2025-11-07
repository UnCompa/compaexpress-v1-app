import 'package:compaexpress/models/ModelProvider.dart';

class PaymentOption {
  final TiposPago tipo;
  double monto;
  bool seleccionado;

  PaymentOption({
    required this.tipo,
    this.monto = 0,
    this.seleccionado = false,
  });
}
