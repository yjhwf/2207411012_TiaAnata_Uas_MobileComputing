// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, avoid_print, deprecated_member_use, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth App',
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> pairedDevices = [];
  List<BluetoothDiscoveryResult> scanResults = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  void _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (statuses[Permission.locationWhenInUse] != PermissionStatus.granted) {
      print("object not granted");
      return;
    }

    _getPairedDevices();
    _startScan();
  }

  void _getPairedDevices() async {
    try {
      var classicDevices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        pairedDevices = classicDevices;
      });
    } catch (e) {
      print("Error getting paired devices: $e");
    }
  }

  void _startScan() {
    FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      setState(() {
        scanResults.add(result);
      });
    });
  }

  void _connectToDevice(dynamic device) async {
    try {
      if (device is BluetoothDevice) {
        await FlutterBluetoothSerial.instance.connect(device);
      } else if (device is BluetoothDiscoveryResult) {
        await FlutterBluetoothSerial.instance.connect(device.device);
      }
      setState(() {});
    } catch (e) {
      print("Error connecting to device: $e");
    }
  }

  String _getDeviceName(dynamic device) {
    if (device is BluetoothDevice) {
      return device.name ?? 'Unknown Device';
    } else if (device is BluetoothDiscoveryResult) {
      return device.device.name ?? 'Unknown Device';
    }
    return 'Unknown Device';
  }

  String _getDeviceId(dynamic device) {
    if (device is BluetoothDevice) {
      return device.address;
    } else if (device is BluetoothDiscoveryResult) {
      return device.device.address;
    }
    return 'Unknown ID';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Devices'),
      ),
      body: Center(
        child: ListView(
          children: [
            ListTile(
              title: Text('Paired Devices'),
            ),
            ...pairedDevices.map((device) {
              return ListTile(
                title: Text(_getDeviceName(device)),
                subtitle: Text(_getDeviceId(device)),
                trailing: ElevatedButton(
                  onPressed: () => _connectToDevice(device),
                  child: Text('Connect'),
                ),
              );
            }).toList(),
            ListTile(
              title: Text('Scanned Devices'),
            ),
            ...scanResults.map((result) {
              return ListTile(
                title: Text(_getDeviceName(result)),
                subtitle: Text(_getDeviceId(result)),
                trailing: ElevatedButton(
                  onPressed: () => _connectToDevice(result),
                  child: Text('Connect'),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startScan,
        tooltip: 'Rescan',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}