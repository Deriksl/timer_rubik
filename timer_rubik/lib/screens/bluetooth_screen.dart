import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  List<String> _receivedData = [];
  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _devices = [];
      _isScanning = true;
    });

    // Escaneo por 5 segundos
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    
    // Escuchar resultados del escaneo
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!_devices.contains(result.device)) {
          setState(() {
            _devices.add(result.device);
          });
        }
      }
    });

    await Future.delayed(const Duration(seconds: 5));
    _stopScan();
  }

  Future<void> _stopScan() async {
    await FlutterBluePlus.stopScan();
    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnected = false;
      _connectedDevice = device;
    });

    try {
      await device.connect(autoConnect: false);
      setState(() {
        _isConnected = true;
      });
      _discoverServices(device);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar: ${e.toString()}')),
      );
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.read) {
          List<int> value = await characteristic.read();
          _addData('Lectura: ${String.fromCharCodes(value)}');
        }
        
        if (characteristic.properties.notify) {
          await characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            _addData('Notificación: ${String.fromCharCodes(value)}');
          });
        }
      }
    }
  }

  void _addData(String data) {
    setState(() {
      _receivedData.insert(0, data); // Agrega al inicio para mostrar lo más reciente primero
    });
  }

  Future<void> _disconnectDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      setState(() {
        _isConnected = false;
        _connectedDevice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth BLE'),
        actions: [
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.bluetooth_disabled),
              onPressed: _disconnectDevice,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_devices[index].name),
                  subtitle: Text(_devices[index].remoteId.str),
                  onTap: () => _connectToDevice(_devices[index]),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: _receivedData.isEmpty
                ? const Center(child: Text('No hay datos recibidos'))
                : ListView.builder(
                    reverse: true,
                    itemCount: _receivedData.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_receivedData[index]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isScanning ? null : _startScan,
        child: _isScanning 
            ? const CircularProgressIndicator()
            : const Icon(Icons.bluetooth),
      ),
    );
  }
}