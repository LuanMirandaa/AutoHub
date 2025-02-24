import 'dart:typed_data';
import 'dart:convert';
import 'package:auto_hub/components/menu.dart';
import 'package:auto_hub/models/cars.dart';
import 'package:auto_hub/helpers/format_number.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class MyAnnouncementsScreen extends StatefulWidget {
  final User user;
  const MyAnnouncementsScreen({super.key, required this.user});

  @override
  State<MyAnnouncementsScreen> createState() => _MyAnnouncementsScreenState();
}

class CloudinaryService {
  final String cloudName = 'dew8dbsgv';
  final String apiKey = '945639635579818';
  final String apiSecret = '';
  final String uploadPreset = 'AutoHub';

  Future<String> uploadImage(Uint8List imageBytes) async {
    final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['upload_preset'] = uploadPreset
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'upload.jpg',
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);
      return jsonResponse['secure_url'];
    } else {
      throw Exception('Falha ao fazer upload da imagem');
    }
  }
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
        title: const Text(
          'Meus Anúncios',
        style: TextStyle(color: Color.fromARGB(255, 84, 4, 98)),),
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
    firestore.collection('Anúncios').doc(model.id).delete();
    refresh();
  }

  Future<void> refresh() async {
    List<Car> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection('Anúncios')
        .where('userId', isEqualTo: widget.user.uid)
        .get();
    for (var doc in snapshot.docs) {
      temp.add(Car.fromMap(doc.data()));
    }
    setState(() {
      listCars = temp;
    });
  }
}

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String cleanedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    double value = double.tryParse(cleanedText) ?? 0.0;
    final formatter = NumberFormat.decimalPattern('pt_BR');
    String formattedText = formatter.format(value);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

double parseFormattedNumber(String formattedNumber) {
  String cleanedNumber =
      formattedNumber.replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(cleanedNumber) ?? 0.0;
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

  Uint8List? imageData;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      modeloController.text = widget.car!.modelo;
      marcaController.text = widget.car!.marca;
      quilometragemController.text = widget.car!.quilometragem.toString();
      precoController.text = widget.car!.preco.toString();
      descricaoController.text = widget.car!.descricao ?? '';
      imageUrl = widget.car!.imageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.car == null ? 'Adicionar Anúncio' : 'Editar Anúncio'),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (imageData != null)
              Container(
                height: 350,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.purple.shade200, width: 4),
                    color: Colors.white),
                child: Image.memory(
                  imageData!,
                  fit: BoxFit.contain,
                ),
              )
            else if (imageUrl != null)
              Container(
                height: 350,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.purple.shade200, width: 4),
                    color: Colors.white),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                ),
              )
            else
              Container(
                  height: 350,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Colors.purple.shade200, width: 4),
                      color: Colors.white),
                  child: Image.asset('assets/images/photo_add_icon.png')),
            const SizedBox(height: 30),
            TextField(
              controller:
                  modeloController, // Color.fromARGB(255, 206, 147, 216)
              decoration: const InputDecoration(
                  labelText: 'Modelo',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(225, 117, 117, 117)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 147, 216),
                          width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: marcaController,
              decoration: const InputDecoration(
                  labelText: 'Marca',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(225, 117, 117, 117)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 147, 216),
                          width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: quilometragemController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsFormatter()],
              decoration: const InputDecoration(
                labelText: 'Quilometragem (km)',
                labelStyle:
                    TextStyle(color: Color.fromARGB(225, 117, 117, 117)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 206, 147, 216), width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: precoController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsFormatter()],
              decoration: const InputDecoration(
                labelText: 'Preço (R\$)',
                labelStyle:
                    TextStyle(color: Color.fromARGB(225, 117, 117, 117)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 206, 147, 216), width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                  labelText: 'Descrição',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(225, 117, 117, 117)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 147, 216),
                          width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
            ),
            const SizedBox(height: 30),
            Container(
              width: 1920,
              height: 45,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: Color.fromARGB(255, 206, 147, 216), width: 2),
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onPressed: selectImage,
                icon: const Icon(
                  Icons.image,
                  color: Color.fromARGB(255, 206, 147, 216),
                ),
                label: const Text('Selecionar Imagem',
                    style: TextStyle(
                      color: Color.fromARGB(255, 206, 147, 216),
                      fontSize: 15,
                    )),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: 1920,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(151, 141, 11, 201),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onPressed: saveCar,
                child: Text(
                  widget.car == null ? 'Salvar' : 'Atualizar',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
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
      final data = await pickedFile.readAsBytes();
      setState(() {
        imageData = data;
        imageUrl = null;
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

    double quilometragem = parseFormattedNumber(quilometragemController.text);
    double preco = parseFormattedNumber(precoController.text);

    String? uploadedImageUrl;

    if (imageData != null) {
      final cloudinaryService = CloudinaryService();
      try {
        uploadedImageUrl = await cloudinaryService.uploadImage(imageData!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer upload da imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    Car car = Car(
      id: widget.car?.id ?? const Uuid().v1(),
      modelo: modeloController.text,
      marca: marcaController.text,
      quilometragem: quilometragem,
      preco: preco,
      descricao:
          descricaoController.text.isNotEmpty ? descricaoController.text : null,
      imageUrl: uploadedImageUrl ?? imageUrl,
      userId: widget.user.uid,
    );

    await FirebaseFirestore.instance
        .collection('Anúncios')
        .doc(car.id)
        .set(car.toMap());

    widget.onRefresh();
    Navigator.pop(context);
  }
}