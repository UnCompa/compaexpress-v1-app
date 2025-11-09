import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class FechaEcuador {
  static void inicializarZonaHoraria() {
    tz.initializeTimeZones();
  }

  /// Zona horaria de Ecuador
  static tz.Location get _zonaEcuador => tz.getLocation('America/Guayaquil');

  /// De DateTime a texto: 07/11/2025 19:03
  static String formatoConHora({DateTime? fecha}) {
    final fechaEcuador = fecha != null
        ? tz.TZDateTime.from(fecha, _zonaEcuador)
        : tz.TZDateTime.now(_zonaEcuador);
    return DateFormat('dd/MM/yyyy HH:mm').format(fechaEcuador);
  }

  /// De DateTime a texto: 07/11/2025
  static String formatoFecha({DateTime? fecha}) {
    final fechaEcuador = fecha != null
        ? tz.TZDateTime.from(fecha, _zonaEcuador)
        : tz.TZDateTime.now(_zonaEcuador);
    return DateFormat('dd/MM/yyyy').format(fechaEcuador);
  }

  /// De texto a DateTime: 07/11/2025 19:03
  static DateTime? parseConHora(String fechaHoraStr) {
    try {
      final parsed = DateFormat('dd/MM/yyyy HH:mm').parse(fechaHoraStr);
      return tz.TZDateTime.from(parsed, _zonaEcuador);
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// De texto a DateTime: 07/11/2025 (a las 00:00 Ecuador)
  static DateTime? parseFecha(String fechaStr) {
    try {
      final parsed = DateFormat('dd/MM/yyyy').parse(fechaStr);
      return tz.TZDateTime.from(parsed, _zonaEcuador);
    } catch (e) {
      print(e);
      return null;
    }
  }
  /// Formatea un TemporalDateTime (ISO string) a texto en zona Ecuador
  static String formatearDesdeTemporal(
    String isoString, {
    bool conHora = false,
  }) {
    try {
      final fechaUtc = DateTime.parse(isoString);
      final fechaEcuador = aZonaEcuador(fechaUtc);
      return conHora
          ? formatoConHora(fecha: fechaEcuador)
          : formatoFecha(fecha: fechaEcuador);
    } catch (e) {
      print("Error al formatear TemporalDateTime: $e");
      return "";
    }
  }

  static DateTime aZonaEcuador(DateTime fecha) {
  final fechaUtc = fecha.isUtc ? fecha : fecha.toUtc();
  return tz.TZDateTime.from(fechaUtc, _zonaEcuador);
}

/// Convierte cualquier DateTime a zona horaria de Ecuador y lo devuelve como UTC
/// Útil para guardar en backend o base de datos
static DateTime aUtcDesdeEcuador(DateTime fecha) {
  final fechaEcuador = aZonaEcuador(fecha);
  return fechaEcuador.toUtc();
}
}