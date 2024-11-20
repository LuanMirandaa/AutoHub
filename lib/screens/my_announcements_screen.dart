import 'package:auto_hub/components/menu.dart';
import 'package:auto_hub/models/cars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MyAnnouncementsScreen extends StatefulWidget {
  final User user;
  MyAnnouncementsScreen({super.key, required this.user});

  @override
  State<MyAnnouncementsScreen> createState() => _MyAnnouncementsScreenState();
}

class _MyAnnouncementsScreenState extends State<MyAnnouncementsScreen> {
  List<Car> listCars = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: (Menu(user: widget.user)),
      appBar: AppBar(
        title: const Text('Seus carros'),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showFormModal();
          },
          child: const Icon(Icons.add)),
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
            : ListView(
                padding: const EdgeInsets.only(right: 4, left: 4),
                children: List.generate(
                  listCars.length,
                  (index) {
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
                          elevation: 2,
                          child: Column(
                            children: [
                              ListTile(
                                onLongPress: () {
                                  showFormModal(model: model);
                                },
                                onTap: () {},
                                leading: const Icon(
                                  Icons.car_rental,
                                  size: 56,
                                ),
                                title: Text(
                                    'Modelo: ${model.modelo} \nMarca: ${model.marca} \nQuilometragem: ${model.quilometragem} Km \nPreço: ${model.preco} R\$'),
                                subtitle: Text(model.descricao!),
                              )
                            ],
                          ),
                        ));
                  },
                ),
              ),
      ),
    );
  }

  showFormModal({Car? model}) {
    String title = 'Adicionar';
    String confirmationButton = 'Salvar';
    String skipButton = 'Cancelar';

    TextEditingController modeloController = TextEditingController();
    TextEditingController marcaController = TextEditingController();
    TextEditingController quilometragemController = TextEditingController();
    TextEditingController precoController = TextEditingController();
    TextEditingController descricaoController = TextEditingController();

    if (model != null) {
      title = 'Editar';
      modeloController.text = model.modelo;
      marcaController.text = model.marca;
      quilometragemController.text = model.quilometragem;
      precoController.text = model.preco;
      if (model.descricao != null) {
        descricaoController.text = model.descricao!;
      }
      confirmationButton = 'Atualizar';
      skipButton = 'Cancelar';
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32),
          child: ListView(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextFormField(
                controller: modeloController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Modelo'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: marcaController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Marca'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: quilometragemController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quilometragem'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: precoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '20.000',
                  labelText: 'R\$',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: descricaoController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(skipButton),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (modeloController.text.isEmpty ||
                          marcaController.text.isEmpty ||
                          quilometragemController.text.isEmpty ||
                          precoController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Por favor, preencha todos os campos obrigatórios.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Car car = Car(
                        id: model?.id ?? const Uuid().v1(),
                        modelo: modeloController.text,
                        marca: marcaController.text,
                        quilometragem: quilometragemController.text,
                        preco: precoController.text,
                      );

                      if (descricaoController.text.isNotEmpty) {
                        car.descricao = descricaoController.text;
                      }

                      firestore
                          .collection(widget.user.uid)
                          .doc(car.id)
                          .set(car.toMap())
                          .then((_) {
                        refresh();
                        Navigator.pop(context);
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao salvar: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      });
                    },
                    child: Text(confirmationButton),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void remove(Car model) {
    firestore.collection(widget.user.uid).doc(model.id).delete();
    refresh();
  }

  Future<void> refresh() async {
    List<Car> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection(widget.user.uid).get();
    for (var doc in snapshot.docs) {
      temp.add(Car.fromMap(doc.data()));
    }
    setState(() {
      listCars = temp;
    });
  }
}
