import 'package:auto_hub/components/menu.dart';
import 'package:auto_hub/helpers/format_number.dart';
import 'package:auto_hub/models/cars.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_hub/services/firestore_service.dart';
import 'add_edit_car_screen.dart';

class MyAnnouncementsScreen extends StatefulWidget {
  final User user;
  const MyAnnouncementsScreen({super.key, required this.user});

  @override
  State<MyAnnouncementsScreen> createState() => _MyAnnouncementsScreenState();
}

class _MyAnnouncementsScreenState extends State<MyAnnouncementsScreen> {
  List<Car> listCars = [];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu(user: widget.user),
      appBar: AppBar(
        title: const Text(
          'Meus Anúncios',
          style: TextStyle(color: Color.fromARGB(255, 84, 4, 98)),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditCarScreen(
                user: widget.user,
                onRefresh: refresh,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        color: Colors.white,
        child: (listCars.isEmpty)
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
                  return Dismissible(
                    key: ValueKey<Car>(model),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 12),
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      remove(model);
                    },
                    child: Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side:
                            BorderSide(color: Colors.purple.shade200, width: 4),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditCarScreen(
                                user: widget.user,
                                car: model,
                                onRefresh: refresh,
                              ),
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
                    ),
                  );
                },
              ),
      ),
    );
  }

  void remove(Car model) {
    _firestoreService.deleteCar(model.id);
    refresh();
  }

  Future<void> refresh() async {
    List<Car> temp = await _firestoreService.getCarsByUser(widget.user.uid);
    setState(() {
      listCars = temp;
    });
  }
}