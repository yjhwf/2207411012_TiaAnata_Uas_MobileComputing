import 'package:flutter/material.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wi-Fi App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Wi-Fi Info'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Menggunakan WifiInfo untuk mendapatkan informasi Wi-Fi
              String wifiName = await WifiInfo().getWifiName() ?? 'N/A';
              String wifiIP = await WifiInfo().getWifiIP() ?? 'N/A';
              String wifiBSSID = await WifiInfo().getWifiBSSID() ?? 'N/A';

              // Menampilkan informasi dalam dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Wi-Fi Info'),
                    content: Text('SSID: $wifiName\n'
                        'IP Address: $wifiIP\n'
                        'BSSID: $wifiBSSID'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Get Wi-Fi Info'),
          ),
        ),
      ),
    );
  }
}