import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_hub/components/menu.dart';
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
  final List<Map<String, dynamic>> filiais = [
    {
      'nome': 'Filial Recife',
      'endereco': 'Pernambuco - Recife \n Av.Maria Melo, 1000',
      'cidade': 'Recife',
      'lat': -8.05428,
      'lng': -34.8813,
    },
    {
      'nome': 'Filial Rio de Janeiro',
      'endereco': 'Rio de Janeiro - RJ \n Praça do expecionario, 2020',
      'cidade': 'Rio de Janeiro',
      'lat': -22.9068,
      'lng': -43.1729,
    },
    {
      'nome': 'Filial São Paulo',
      'endereco': 'São Paulo - SP \n Av. Paulista, 1000',
      'cidade': 'São Paulo',
      'lat': -23.5505,
      'lng': -46.6333,
    },
  ];

  String cidadeSelecionada = 'Todas';

  @override
  Widget build(BuildContext context) {
    final filiaisFiltradas = cidadeSelecionada == 'Todas'
        ? filiais
        : filiais
            .where((filial) => filial['cidade'] == cidadeSelecionada)
            .toList();

    return Scaffold(
      drawer: Menu(user: widget.user),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.purple),
        title: const Text(
          'Mapa das Filiais',
          style: TextStyle(color: Color.fromARGB(255, 84, 4, 98)),
        ),
        centerTitle: true,
        actions: [
          Row(
            children: [
              Text(
                cidadeSelecionada,
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (String novaCidade) {
                  setState(() {
                    cidadeSelecionada = novaCidade;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return [
                    'Todas',
                    'Recife',
                    'Rio de Janeiro',
                    'São Paulo',
                  ].map((String value) {
                    return PopupMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList();
                },
                icon: Icon(Icons.filter_list, color: Colors.purple),
              ),
            ],
          ),
        ],
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
            markers: filiaisFiltradas.map((filial) {
              return Marker(
                point: LatLng(filial['lat'], filial['lng']),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(filial['nome']),
                          content: Text(filial['endereco']),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Fechar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.business,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              );
            }).toList(),
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'Mapa de Filiais do AutoHub',
                onTap: () => launchUrl(Uri.parse('')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
