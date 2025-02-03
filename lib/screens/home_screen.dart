import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_hub/models/cars.dart';
import 'package:auto_hub/components/menu.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Car> listCars = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    List<Car> temp = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('Anúncios').get();
      print('Número de documentos retornados: ${snapshot.docs.length}'); // Log
      for (var doc in snapshot.docs) {
        temp.add(Car.fromMap(doc.data()));
      }
    } catch (e) {
      print('Erro ao carregar anúncios: $e');
    }

    setState(() {
      listCars = temp;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Número de anúncios carregados: ${listCars.length}'); // Log
    return Scaffold(
      drawer: Menu(user: widget.user),
      appBar: AppBar(
        title: const Text('Todos os Anúncios'),
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : listCars.isEmpty
                ? Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 250,
                      height: 250,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: listCars.length,
                    itemBuilder: (context, index) {
                      Car model = listCars[index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.purple.shade200, width: 4),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Ação ao clicar no anúncio
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                model.imageUrl != null
                                    ? Image.network(
                                        model.imageUrl!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.image,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Modelo: ${model.modelo}',
                                        style: const TextStyle(
                                          color: Colors.purple,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Marca: ${model.marca}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Quilometragem: ${model.quilometragem} Km',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Preço: ${model.preco} R\$',
                                        style: const TextStyle(
                                          color: Colors.purple,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (model.descricao != null)
                                        Text(
                                          'Descrição: ${model.descricao!}',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}