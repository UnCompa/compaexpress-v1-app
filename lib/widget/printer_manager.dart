import 'package:compaexpress/providers/printer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

class PrinterManagerWidget extends ConsumerStatefulWidget {
  const PrinterManagerWidget({super.key});

  @override
  ConsumerState<PrinterManagerWidget> createState() =>
      _PrinterManagerWidgetState();
}

class _PrinterManagerWidgetState extends ConsumerState<PrinterManagerWidget> {
  final _wifiIpController = TextEditingController();
  final _wifiPortController = TextEditingController(text: '9100');
  ConnectionType _selectedConnectionType = ConnectionType.BLE;

  @override
  void dispose() {
    _wifiIpController.dispose();
    _wifiPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final printerState = ref.watch(printerProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Configuración de Impresora',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (printerState.isScanning)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Selector de tipo de conexión
              const Text(
                'Tipo de Conexión',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<ConnectionType>(
                  segments: const [
                    ButtonSegment(
                      value: ConnectionType.BLE,
                      label: Text('Bluetooth'),
                      icon: Icon(Icons.bluetooth, size: 18),
                    ),
                    ButtonSegment(
                      value: ConnectionType.NETWORK,
                      label: Text('WiFi'),
                      icon: Icon(Icons.wifi, size: 18),
                    ),
                    ButtonSegment(
                      value: ConnectionType.USB,
                      label: Text('USB'),
                      icon: Icon(Icons.usb, size: 18),
                    ),
                  ],
                  selected: {_selectedConnectionType},
                  onSelectionChanged: (Set<ConnectionType> newSelection) {
                    setState(() {
                      _selectedConnectionType = newSelection.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Configuración según tipo de conexión
              if (_selectedConnectionType == ConnectionType.BLE)
                _buildBluetoothSection(printerState)
              else if (_selectedConnectionType == ConnectionType.NETWORK)
                _buildWiFiSection(printerState)
              else
                _buildUSBSection(printerState),

              const SizedBox(height: 16),

              // Impresora seleccionada
              if (printerState.selectedPrinter != null ||
                  printerState.wifiIp != null) ...[
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Impresora Activa',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.print, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              printerState.selectedPrinter?.name ??
                                  'Impresora WiFi',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              printerState.selectedPrinter?.address ??
                                  '${printerState.wifiIp}:${printerState.wifiPort}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Mensaje de error
              if (printerState.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          printerState.error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBluetoothSection(PrinterState printerState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: printerState.isScanning
                ? null
                : () => ref.read(printerProvider.notifier).scanBluetooth(),
            icon: const Icon(Icons.bluetooth_searching, size: 20),
            label: Text(
              printerState.isScanning ? 'Escaneando...' : 'Escanear Bluetooth',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (printerState.bluetoothPrinters.isNotEmpty) ...[
          const Text(
            'Dispositivos Encontrados',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: printerState.bluetoothPrinters.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final printer = printerState.bluetoothPrinters[index];
                final isSelected =
                    printerState.selectedBluetoothPrinter?.macAdress ==
                    printer.macAdress;
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.print,
                    color: isSelected ? Colors.blue : Colors.grey,
                    size: 20,
                  ),
                  title: Text(
                    printer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    printer.macAdress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 20,
                        )
                      : null,
                  selected: isSelected,
                  onTap: () {
                    ref
                        .read(printerProvider.notifier)
                        .selectBluetoothPrinter(printer);
                  },
                );
              },
            ),
          ),
        ] else if (!printerState.isScanning)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No se encontraron dispositivos.\nAsegúrate de que el Bluetooth esté encendido\ny los dispositivos estén vinculados.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWiFiSection(PrinterState printerState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _wifiIpController,
          decoration: const InputDecoration(
            labelText: 'Dirección IP',
            hintText: '192.168.1.100',
            prefixIcon: Icon(Icons.computer),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _wifiPortController,
          decoration: const InputDecoration(
            labelText: 'Puerto',
            hintText: '9100',
            prefixIcon: Icon(Icons.settings_ethernet),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final ip = _wifiIpController.text.trim();
              final port = int.tryParse(_wifiPortController.text.trim());
              if (ip.isNotEmpty && port != null) {
                ref.read(printerProvider.notifier).setWifiConfig(ip, port);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuración WiFi guardada'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingresa IP y puerto válidos'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            icon: const Icon(Icons.save, size: 20),
            label: const Text('Guardar Configuración'),
          ),
        ),
      ],
    );
  }

  Widget _buildUSBSection(PrinterState printerState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: printerState.isScanning
                ? null
                : () => ref.read(printerProvider.notifier).scanUSB(),
            icon: const Icon(Icons.usb, size: 20),
            label: const Text('Buscar Impresoras USB'),
          ),
        ),
        const SizedBox(height: 12),
        if (printerState.printers.isNotEmpty) ...[
          const Text(
            'Dispositivos USB',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: printerState.printers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final printer = printerState.printers[index];
                final isSelected =
                    printerState.selectedPrinter?.address == printer.address;
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.usb,
                    color: isSelected ? Colors.blue : Colors.grey,
                    size: 20,
                  ),
                  title: Text(
                    printer.name ?? 'Impresora USB',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    printer.address ?? 'Conectada',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 20,
                        )
                      : null,
                  selected: isSelected,
                  onTap: () {
                    ref.read(printerProvider.notifier).selectPrinter(printer);
                  },
                );
              },
            ),
          ),
        ] else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Conecta tu impresora USB y presiona el botón.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
      ],
    );
  }
}
