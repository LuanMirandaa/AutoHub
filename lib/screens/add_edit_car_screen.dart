import 'dart:typed_data';
import 'package:auto_hub/models/cars.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:auto_hub/services/cloudinary_service.dart';
import 'package:auto_hub/services/firestore_service.dart';
import 'package:auto_hub/helpers/format_number.dart';

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
        title: Text(
          widget.car == null ? 'Adicionar Anúncio' : 'Editar Anúncio',
          style: TextStyle(color: Color.fromARGB(255, 84, 4, 98)),
        ),
        centerTitle: true,
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
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purple, width: 4),
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
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purple, width: 4),
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
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.purple, width: 4),
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
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 147, 216),
                          width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10)))),),
            const SizedBox(height: 15),
            TextField(
              controller: marcaController,
              decoration: const InputDecoration(
                  labelText: 'Marca',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(225, 117, 117, 117)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 147, 216),
                          width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10)))),),
            const SizedBox(height: 15),
            TextField(
              controller: quilometragemController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsFormatter()],
              decoration: const InputDecoration(
                  labelText: 'Quilometragem (km)',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(225, 117, 117, 117)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 206, 147, 216), width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10)))),),
            const SizedBox(height: 15),
            TextField(
              controller: precoController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsFormatter()],
              decoration: const InputDecoration(
                  labelText: 'Preço (R\$)',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(225, 117, 117, 117)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 206, 147, 216), width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10)))),),
            const SizedBox(height: 15),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                  labelText: 'Descrição',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(225, 117, 117, 117)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 147, 216),
                          width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 2.0),
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
                  backgroundColor: Colors.purple,
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

    final firestoreService = FirestoreService();
    if (widget.car == null) {
      await firestoreService.addCar(car);
    } else {
      await firestoreService.updateCar(car);
    }

    widget.onRefresh();
    Navigator.pop(context);
  }
}