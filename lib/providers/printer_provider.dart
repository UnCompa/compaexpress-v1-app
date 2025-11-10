import 'dart:developer';

import 'package:compaexpress/entities/invoice_with_details.dart';
import 'package:compaexpress/entities/order_with_details.dart';
import 'package:compaexpress/providers/admin_account_provider.dart';
import 'package:compaexpress/providers/invoice_design_provider.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/utils/get_image_for_bucker.dart';
import 'package:compaexpress/utils/printer_termal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

final printerProvider = StateNotifierProvider<PrinterNotifier, PrinterState>((
  ref,
) {
  return PrinterNotifier();
});

class PrinterState {
  final List<Printer> printers; // Para WiFi/USB
  final List<BluetoothInfo> bluetoothPrinters; // Para Bluetooth
  final bool isScanning;
  final bool isPrinting;
  final String? error;
  final Printer? selectedPrinter; // Para WiFi/USB
  final BluetoothInfo? selectedBluetoothPrinter; // Para Bluetooth
  final String? wifiIp;
  final int? wifiPort;

  PrinterState({
    this.printers = const [],
    this.bluetoothPrinters = const [],
    this.isScanning = false,
    this.isPrinting = false,
    this.error,
    this.selectedPrinter,
    this.selectedBluetoothPrinter,
    this.wifiIp,
    this.wifiPort,
  });

  PrinterState copyWith({
    List<Printer>? printers,
    List<BluetoothInfo>? bluetoothPrinters,
    bool? isScanning,
    bool? isPrinting,
    String? error,
    Printer? selectedPrinter,
    BluetoothInfo? selectedBluetoothPrinter,
    String? wifiIp,
    int? wifiPort,
    bool clearSelectedPrinter = false,
    bool clearSelectedBluetooth = false,
  }) {
    return PrinterState(
      printers: printers ?? this.printers,
      bluetoothPrinters: bluetoothPrinters ?? this.bluetoothPrinters,
      isScanning: isScanning ?? this.isScanning,
      isPrinting: isPrinting ?? this.isPrinting,
      error: error,
      selectedPrinter: clearSelectedPrinter
          ? null
          : (selectedPrinter ?? this.selectedPrinter),
      selectedBluetoothPrinter: clearSelectedBluetooth
          ? null
          : (selectedBluetoothPrinter ?? this.selectedBluetoothPrinter),
      wifiIp: wifiIp ?? this.wifiIp,
      wifiPort: wifiPort ?? this.wifiPort,
    );
  }
}

class PrinterNotifier extends StateNotifier<PrinterState> {
  PrinterNotifier() : super(PrinterState()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? type = prefs.getString('printer_type');

    if (type == 'bluetooth') {
      final String? mac = prefs.getString('bluetooth_mac');
      if (mac != null) {
        await scanBluetooth();
        final matching = state.bluetoothPrinters.firstWhere(
          (p) => p.macAdress == mac,
          orElse: () =>
              BluetoothInfo(name: '', macAdress: ''), // Placeholder para orElse
        );
        if (matching.macAdress.isNotEmpty) {
          selectBluetoothPrinter(matching);
        }
      }
    } else if (type == 'wifi') {
      final String? ip = prefs.getString('wifi_ip');
      final int? port = prefs.getInt('wifi_port');
      if (ip != null && port != null) {
        setWifiConfig(ip, port);
      }
    } else if (type == 'usb') {
      final String? address = prefs.getString('usb_address');
      if (address != null) {
        await scanUSB();
        final matching = state.printers.firstWhere(
          (p) => p.address == address,
          orElse: () => Printer(
            name: '',
            address: '',
            connectionType: ConnectionType.USB,
          ), // Placeholder
        );
        if (matching.address != null) {
          selectPrinter(matching);
        }
      }
    }
  }

  // --- GUARDAR PREFERENCIAS ---
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpia prefs antiguas

    if (state.selectedBluetoothPrinter != null) {
      await prefs.setString('printer_type', 'bluetooth');
      await prefs.setString(
        'bluetooth_mac',
        state.selectedBluetoothPrinter!.macAdress,
      );
    } else if (state.wifiIp != null && state.wifiPort != null) {
      await prefs.setString('printer_type', 'wifi');
      await prefs.setString('wifi_ip', state.wifiIp!);
      await prefs.setInt('wifi_port', state.wifiPort!);
    } else if (state.selectedPrinter != null) {
      await prefs.setString('printer_type', 'usb');
      await prefs.setString('usb_address', state.selectedPrinter!.address!);
    }
  }

  // Modifica los métodos de selección/configuración para guardar al final
  void selectBluetoothPrinter(BluetoothInfo printer) {
    state = state.copyWith(
      selectedBluetoothPrinter: printer,
      clearSelectedPrinter: true,
    );
    debugPrint("Impresora Bluetooth seleccionada: ${printer.name}");
    _savePreferences();
  }

  void selectPrinter(Printer printer) {
    state = state.copyWith(
      selectedPrinter: printer,
      clearSelectedBluetooth: true,
    );
    debugPrint("Impresora USB seleccionada: ${printer.name}");
    _savePreferences();
  }

  void setWifiConfig(String ip, int port) {
    state = state.copyWith(wifiIp: ip, wifiPort: port);
    debugPrint("WiFi configurado: $ip:$port");
    _savePreferences();
  }

  // --- ESCANEAR BLUETOOTH (usando print_bluetooth_thermal) ---
  Future<void> scanBluetooth() async {
    state = state.copyWith(isScanning: true, error: null);
    debugPrint("Escaneando impresoras Bluetooth...");
    try {
      // Verificar si Bluetooth está disponible
      final bool isAvailable = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isAvailable) {
        throw Exception("Bluetooth no está habilitado");
      }

      // Escanear dispositivos
      final List<BluetoothInfo> devices =
          await PrintBluetoothThermal.pairedBluetooths;
      debugPrint("Dispositivos encontrados: ${devices.length}");

      state = state.copyWith(bluetoothPrinters: devices, isScanning: false);
    } catch (e) {
      debugPrint("Error al escanear impresoras Bluetooth: $e");
      state = state.copyWith(
        error: e.toString(),
        isScanning: false,
        bluetoothPrinters: [],
      );
    }
  }

  // --- ESCANEAR USB ---
  Future<void> scanUSB() async {
    state = state.copyWith(isScanning: true, error: null);
    debugPrint("Escaneando impresoras USB...");
    try {
      await FlutterThermalPrinter.instance.getPrinters(
        connectionTypes: [ConnectionType.USB],
      );
      FlutterThermalPrinter.instance.devicesStream.listen((printers) {
        final usbPrinters = printers
            .where((p) => p.connectionType == ConnectionType.USB)
            .toList();
        state = state.copyWith(printers: usbPrinters, isScanning: false);
      });
    } catch (e) {
      debugPrint("Error al escanear impresoras USB: $e");
      state = state.copyWith(error: e.toString(), isScanning: false);
    }
  }

  // --- IMPRIMIR FACTURA ---
  Future<void> printInvoice(
    InvoiceWithDetails invoiceWithDetails,
    BuildContext context,
    WidgetRef ref,
  ) async {
    state = state.copyWith(isPrinting: true, error: null);
    try {
      final negocio = await NegocioService.getNegocioById(
        invoiceWithDetails.invoice.negocioID,
      );
      if (negocio == null) throw Exception('Negocio no encontrado');
      final design = ref.watch(invoiceDesignProvider);
      final url = await GetImageFromBucket.getSingleSignedImageUrl(
        negocio.logo!,
        expiresIn: Duration(minutes: 5),
      );
      final bytes = await PrinterThermal.generarBytesFactura(
        invoiceWithDetails,
        negocio,
        design: design,
        incluirLogo: false,
        logoUrl: url,
      );

      // Determinar qué tipo de impresora usar
      if (state.selectedBluetoothPrinter != null) {
        // Imprimir por Bluetooth usando print_bluetooth_thermal
        debugPrint(
          "Imprimiendo por Bluetooth: ${state.selectedBluetoothPrinter?.name}",
        );
        await _printWithBluetooth(state.selectedBluetoothPrinter!, bytes);
      } else if (state.wifiIp != null && state.wifiPort != null) {
        // Imprimir por WiFi usando flutter_thermal_printer
        debugPrint("Imprimiendo por WiFi: ${state.wifiIp}:${state.wifiPort}");
        final service = FlutterThermalPrinterNetwork(
          state.wifiIp!,
          port: state.wifiPort!,
        );
        await service.connect();
        if (context.mounted) {
          await service.printTicket(bytes);
        }
        await service.disconnect();
      } else if (state.selectedPrinter != null) {
        // Imprimir por USB usando flutter_thermal_printer
        debugPrint("Imprimiendo por USB: ${state.selectedPrinter?.name}");
        await _printWithFlutterThermalPrinter(state.selectedPrinter!, bytes);
      } else {
        throw Exception("No hay impresora seleccionada ni WiFi configurada");
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Factura impresa con éxito"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error al imprimir factura: $e");
      state = state.copyWith(error: e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al imprimir: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      state = state.copyWith(isPrinting: false);
    }
  }

  Future<void> printOrder(
    OrderWithDetails orderWithDetails,
    BuildContext context,
    WidgetRef ref,
  ) async {
    state = state.copyWith(isPrinting: true, error: null);
    try {
      final negocio = await NegocioService.getNegocioById(
        orderWithDetails.order.negocioID,
      );
      final accountData = ref
          .read(userBusinessProvider)
          .when(
            data: (data) => data.imageUrl,
            error: (error, stackTrace) => null,
            loading: () => null,
          );
      if (negocio == null) throw Exception('Negocio no encontrado');
      final design = ref.watch(invoiceDesignProvider);
      log("Logo url: $accountData");
      final bytes = await PrinterThermal.generarBytesOrden(
        orderWithDetails,
        negocio,
        design: design,
        logoUrl: accountData,
      );

      // Determinar qué tipo de impresora usar
      if (state.selectedBluetoothPrinter != null) {
        // Imprimir por Bluetooth usando print_bluetooth_thermal
        debugPrint(
          "Imprimiendo orden por Bluetooth: ${state.selectedBluetoothPrinter?.name}",
        );
        await _printWithBluetooth(state.selectedBluetoothPrinter!, bytes);
      } else if (state.wifiIp != null && state.wifiPort != null) {
        // Imprimir por WiFi usando flutter_thermal_printer
        debugPrint(
          "Imprimiendo orden por WiFi: ${state.wifiIp}:${state.wifiPort}",
        );
        final service = FlutterThermalPrinterNetwork(
          state.wifiIp!,
          port: state.wifiPort!,
        );
        await service.connect();
        if (context.mounted) {
          await service.printTicket(bytes);
        }
        await service.disconnect();
      } else if (state.selectedPrinter != null) {
        // Imprimir por USB usando flutter_thermal_printer
        debugPrint("Imprimiendo orden por USB: ${state.selectedPrinter?.name}");
        await _printWithFlutterThermalPrinter(state.selectedPrinter!, bytes);
      } else {
        throw Exception("No hay impresora seleccionada ni WiFi configurada");
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Orden impresa con éxito"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error al imprimir orden: $e");
      state = state.copyWith(error: e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al imprimir: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      state = state.copyWith(isPrinting: false);
    }
  }

  // --- IMPRIMIR CON BLUETOOTH (print_bluetooth_thermal) ---
  Future<void> _printWithBluetooth(
    BluetoothInfo printer,
    List<int> bytes,
  ) async {
    try {
      // Conectar al dispositivo Bluetooth
      final bool connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: printer.macAdress,
      );

      if (!connected) {
        throw Exception("No se pudo conectar a la impresora Bluetooth");
      }

      // Esperar un momento para asegurar la conexión
      await Future.delayed(const Duration(milliseconds: 500));

      // Imprimir los bytes
      final bool printed = await PrintBluetoothThermal.writeBytes(bytes);

      if (!printed) {
        throw Exception("Error al enviar datos a la impresora");
      }

      // Esperar a que termine de imprimir
      await Future.delayed(const Duration(milliseconds: 500));

      // Desconectar
      await PrintBluetoothThermal.disconnect;
    } catch (e) {
      debugPrint("Error en _printWithBluetooth: $e");
      rethrow;
    }
  }

  // --- IMPRIMIR CON WIFI/USB (flutter_thermal_printer) ---
  Future<void> _printWithFlutterThermalPrinter(
    Printer printer,
    List<int> bytes,
  ) async {
    try {
      await FlutterThermalPrinter.instance.connect(printer);
      await FlutterThermalPrinter.instance.printData(
        printer,
        bytes,
        longData: true,
      );
      await FlutterThermalPrinter.instance.disconnect(printer);
    } catch (e) {
      debugPrint("Error en _printWithFlutterThermalPrinter: $e");
      rethrow;
    }
  }

  // --- VERIFICAR ESTADO BLUETOOTH ---
  Future<bool> isBluetoothEnabled() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e) {
      debugPrint("Error al verificar Bluetooth: $e");
      return false;
    }
  }

  // --- VERIFICAR CONEXIÓN BLUETOOTH ---
  Future<bool> isBluetoothConnected() async {
    try {
      return await PrintBluetoothThermal.connectionStatus;
    } catch (e) {
      debugPrint("Error al verificar conexión Bluetooth: $e");
      return false;
    }
  }

  // --- LIMPIAR ---
  void clear() {
    state = PrinterState();
  }
}
