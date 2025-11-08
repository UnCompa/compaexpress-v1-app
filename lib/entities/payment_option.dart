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

  Map<String, dynamic> toJson() => {
    'tipo': tipo.name,
    'monto': monto,
    'seleccionado': seleccionado,
  };

  factory PaymentOption.fromJson(Map<String, dynamic> json) => PaymentOption(
    tipo: TiposPago.values.firstWhere(
      (e) => e.name == json['tipo'],
      orElse: () => TiposPago.EFECTIVO,
    ),
    monto: json['monto'] as double,
    seleccionado: json['seleccionado'] as bool,
  );
}
