import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_hub/components/menu.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(user: FirebaseAuth.instance.currentUser!),
    );
  }
}

class MapScreen extends StatefulWidget {
  final User user;

  const MapScreen({required this.user});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<LatLng> carLocations = [];

  @override
  void initState() {
    super.initState();
    _generateRandomCars();
  }

  void _generateRandomCars() {
    final Random random = Random();
    for (int i = 0; i < 10; i++) {
      double lat = -8.05428 + (random.nextDouble() * 0.1 - 0.05);
      double lng = -34.8813 + (random.nextDouble() * 0.1 - 0.05);
      carLocations.add(LatLng(lat, lng));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu(user: widget.user),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.purple),
        title: const Text(
          'Mapa',
          style: TextStyle(color: Color.fromARGB(255, 84, 4, 98)),
        ),
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-8.05428, -34.8813),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: carLocations.map((location) {
              return Marker(
                point: location,
                width: 40,
                height: 40,
                child: Icon(
                  Icons.local_taxi,
                  color: Colors.red,
                  size: 40,
                ),
              );
            }).toList(),
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () =>
                    launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
          ),],
          ),
        ],
      ),
    );
  }
}