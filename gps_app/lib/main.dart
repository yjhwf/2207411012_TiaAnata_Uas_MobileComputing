// ignore_for_file: prefer_const_declarations

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;
  LatLng _currentLocation =
      const LatLng(45.521563, -122.677433); // Default location
  String _locationInfo = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    try {
      final hasPermission = await _checkPermissions();
      if (hasPermission) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _locationInfo =
              'Latitude: ${position.latitude}\nLongitude: ${position.longitude}';
        });
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation,
              zoom: 15.0,
            ),
          ),
        );
      } else {
        setState(() {
          _locationInfo = 'Location permission denied.';
        });
      }
    } catch (e) {
      developer.log('Error getting location: $e');
      setState(() {
        _locationInfo = 'Error fetching location.';
      });
    }
  }

  Future<bool> _checkPermissions() async {
    final permissionStatus = await Geolocator.checkPermission();
    if (permissionStatus == LocationPermission.denied) {
      final permissionResult = await Geolocator.requestPermission();
      return permissionResult == LocationPermission.whileInUse ||
          permissionResult == LocationPermission.always;
    }
    return permissionStatus == LocationPermission.whileInUse ||
        permissionStatus == LocationPermission.always;
  }

  @override
  Widget build(BuildContext context) {
    final String nim = "2207411012";
    final String name = "Tia Anata";

    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.purple),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps App'),
          elevation: 2,
        ),
        body: Column(
          children: [
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentLocation,
                  zoom: 15.0,
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(4, 16, 4, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NIM: $nim',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nama: $name',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _locationInfo,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}