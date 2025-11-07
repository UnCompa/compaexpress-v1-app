class FormatDate {
  static String formatFecha(DateTime fecha) {
    final diasSemana = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    final diaSemana = diasSemana[fecha.weekday - 1];
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = meses[fecha.month - 1];
    final ano = fecha.year;
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$diaSemana, $dia $mes $ano • $hora:$minuto';
  }
}
