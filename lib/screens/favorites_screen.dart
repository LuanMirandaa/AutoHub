import 'package:flutter/material.dart';
import 'package:auto_hub/components/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_hub/models/cars.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_hub/screens/car_detail_screen.dart';
import 'package:auto_hub/helpers/format_number.dart';

class FavoritesScreen extends StatefulWidget {
  final User user;
  const FavoritesScreen({super.key, required this.user});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Car> favoriteCars = [];
  bool isLoading = true;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadFavoriteCars();
  }

  Future<void> _loadFavoriteCars() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('favorites')
          .doc(widget.user.uid)
          .collection('favoriteCars')
          .get();

      List<Car> temp = [];
      for (var doc in snapshot.docs) {
        String carId = doc['carId'];
        DocumentSnapshot<Map<String, dynamic>> carSnapshot =
            await firestore.collection('Anúncios').doc(carId).get();
        if (carSnapshot.exists) {
          Car car = Car.fromMap(carSnapshot.data()!);
          temp.add(car);
        }
      }

      setState(() {
        favoriteCars = temp;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu(user: widget.user),
      appBar: AppBar(
        title: const Text(
          'Meus Favoritos',
          style: TextStyle(fontSize: 22,color: Color.fromARGB(255, 84, 4, 98)),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : favoriteCars.isEmpty
                ? Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 250,
                      height: 250,
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Carros Favoritos',
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 1,
                        color: Colors.purpleAccent,
                        indent: 0,
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 8),
                          itemCount: favoriteCars.length,
                          itemBuilder: (context, index) {
                            Car model = favoriteCars[index];
                            return Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: Colors.purple.shade200, width: 4),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CarDetailScreen(car: model),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              'Quilometragem: ${formatNumber(model.quilometragem)} Km',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              'Preço: ${formatNumber(model.preco)} R\$',
                                              style: const TextStyle(
                                                color: Colors.purple,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
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
                    ],
                  ),
      ),
    );
  }
}
