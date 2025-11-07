import 'package:compaexpress/utils/invoice_design.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key para almacenar el diseño en SharedPreferences
const String _kInvoiceDesignKey = 'invoice_design_preference';

/// Notifier para gestionar el diseño de factura seleccionado
class InvoiceDesignNotifier extends StateNotifier<InvoiceDesign> {
  InvoiceDesignNotifier() : super(InvoiceDesign.classic) {
    _loadDesign();
  }

  /// Carga el diseño guardado desde SharedPreferences
  Future<void> _loadDesign() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDesign = prefs.getString(_kInvoiceDesignKey);

      if (savedDesign != null) {
        state = InvoiceDesign.fromString(savedDesign);
      }
    } catch (e) {
      // Si hay error, se mantiene el diseño por defecto
      print('Error cargando diseño de factura: $e');
    }
  }

  /// Cambia el diseño y lo guarda en SharedPreferences
  Future<void> setDesign(InvoiceDesign design) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kInvoiceDesignKey, design.name);
      state = design;
    } catch (e) {
      print('Error guardando diseño de factura: $e');
      // Aún así actualiza el estado en memoria
      state = design;
    }
  }

  /// Resetea al diseño por defecto
  Future<void> resetToDefault() async {
    await setDesign(InvoiceDesign.classic);
  }
}

/// Provider principal para el diseño de factura
final invoiceDesignProvider =
    StateNotifierProvider<InvoiceDesignNotifier, InvoiceDesign>(
      (ref) => InvoiceDesignNotifier(),
    );

/// Provider para verificar si el diseño está cargando
final invoiceDesignLoadingProvider = FutureProvider<bool>((ref) async {
  // Espera a que SharedPreferences esté disponible
  await SharedPreferences.getInstance();
  return true;
});
