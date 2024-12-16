import 'dart:typed_data';
import 'package:auto_hub/components/menu.dart';
import 'package:auto_hub/models/cars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

class MyAnnouncementsScreen extends StatefulWidget {
  final User user;
  const MyAnnouncementsScreen({super.key, required this.user});

  @override
  State<MyAnnouncementsScreen> createState() => _MyAnnouncementsScreenState();
}

class _MyAnnouncementsScreenState extends State<MyAnnouncementsScreen> {
  List<Car> listCars = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

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
        title: const Text('Seus carros'),
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
                        side: BorderSide(color: Colors.purple.shade200, width: 4),
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
                            color: Colors.white, // Fundo branco
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              model.imageUrl != null
                                  ? Image.network(
                                      model.imageUrl!,
                                      width: 64,
                                      height: 64,
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
                    ),
                  );
                },
              ),
      ),
    );
  }

  void remove(Car model) {
    firestore.collection('Anúncios').doc(model.id).delete();
    refresh();
  }

  Future<void> refresh() async {
    List<Car> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection('Anúncios').where('userId', isEqualTo: widget.user.uid).get();
    for (var doc in snapshot.docs) {
      temp.add(Car.fromMap(doc.data()));
    }
    setState(() {
      listCars = temp;
    });
  }
}

class AddEditCarScreen extends StatefulWidget {
  final User user;
  final Car? car;
  final VoidCallback onRefresh;

  const AddEditCarScreen({
    Key? key,
    required this.user,
    this.car,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<AddEditCarScreen> createState() => _AddEditCarScreenState();
}

class _AddEditCarScreenState extends State<AddEditCarScreen> {
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController quilometragemController = TextEditingController();
  final TextEditingController precoController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  String? imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      modeloController.text = widget.car!.modelo;
      marcaController.text = widget.car!.marca;
      quilometragemController.text = widget.car!.quilometragem;
      precoController.text = widget.car!.preco;
      descricaoController.text = widget.car!.descricao ?? '';
      imageUrl = widget.car!.imageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car == null ? 'Adicionar Carro' : 'Editar Carro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: modeloController,
              decoration: const InputDecoration(labelText: 'Modelo'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: marcaController,
              decoration: const InputDecoration(labelText: 'Marca'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: quilometragemController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Quilometragem'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: precoController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Preço (R\$)'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: selectImage,
              icon: const Icon(Icons.image),
              label: const Text('Selecionar Imagem'),
            ),
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Image.network(imageUrl!),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveCar,
              child: Text(widget.car == null ? 'Salvar' : 'Atualizar'),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List? imageData = await pickedFile.readAsBytes();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('${widget.user.uid}/${Uuid().v1()}');

      final uploadTask = storageRef.putData(imageData);
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      setState(() {
        imageUrl = url;
      });
    }
  }

  Future<void> saveCar() async {
    if (modeloController.text.isEmpty ||
        marcaController.text.isEmpty ||
        quilometragemController.text.isEmpty ||
        precoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Car car = Car(
      id: widget.car?.id ?? const Uuid().v1(),
      modelo: modeloController.text,
      marca: marcaController.text,
      quilometragem: quilometragemController.text,
      preco: precoController.text,
      descricao: descricaoController.text.isNotEmpty
          ? descricaoController.text
          : null,
      imageUrl: imageUrl,
      userId: widget.user.uid, // Inclui o identificador do usuário
    );

    await FirebaseFirestore.instance
        .collection('Anúncios')
        .doc(car.id)
        .set(car.toMap());

    widget.onRefresh();
    Navigator.pop(context);
  }
}
