import 'package:auto_hub/models/filial.dart';
import 'package:auto_hub/services/filial_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_hub/components/menu.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MapScreen extends StatefulWidget {
  final User user;

  const MapScreen({required this.user});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FilialService _filialService = FilialService();
  List<Filial> filiais = [];
  List<Filial> filiaisFiltradas = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFiliais();
    _searchController.addListener(_filterFiliais);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFiliais() async {
    filiais = await _filialService.getFiliais();
    filiaisFiltradas = filiais; // Inicialmente, mostra todas as filiais
    setState(() {});
  }

  void _filterFiliais() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filiaisFiltradas = filiais
          .where((filial) =>
              filial.localizacao.toLowerCase().contains(query) ||
              filial.nome.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu(user: widget.user),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Mapa das Filiais',
          style: TextStyle(color: Color.fromARGB(255, 84, 4, 98)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_outlined, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FilialSearchDelegate(filiais),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar',
                prefixIcon: Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(-8.05428, -34.8813),
                initialZoom: 5.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: filiaisFiltradas.map((filial) {
                    return Marker(
                      point: LatLng(filial.lat, filial.lng),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(filial.nome),
                                content: Text(filial.endereco),
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
          ),
        ],
      ),
    );
  }
}

class FilialSearchDelegate extends SearchDelegate<String> {
  final List<Filial> filiais;

  FilialSearchDelegate(this.filiais);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = filiais
        .where((filial) =>
            filial.localizacao.toLowerCase().contains(query.toLowerCase()) ||
            filial.nome.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final filial = results[index];
        return ListTile(
          title: Text(filial.nome),
          subtitle: Text(filial.localizacao),
          onTap: () {
            close(context, filial.localizacao);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = filiais
        .where((filial) =>
            filial.localizacao.toLowerCase().contains(query.toLowerCase()) ||
            filial.nome.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final filial = suggestions[index];
        return ListTile(
          title: Text(filial.nome),
          subtitle: Text(filial.localizacao),
          onTap: () {
            query = filial.localizacao;
            showResults(context);
          },
        );
      },
    );
  }
}