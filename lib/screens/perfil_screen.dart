import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:auto_hub/screens/my_announcements_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  ImageProvider<Object> _avatarImage =
      const AssetImage('assets/images/avatar.png');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user.displayName ?? 'Usuário');
    _loadAvatarImage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _loadAvatarImage() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(widget.user.uid).get();
    if (userDoc.exists) {
      String imagePath = userDoc['avatarImage'] ?? 'assets/images/avatar.png';
      setState(() {
        if (imagePath.startsWith('http')) {
          _avatarImage = NetworkImage(imagePath);
        } else {
          _avatarImage = AssetImage(imagePath);
        }
      });
    }
  }

  void _saveAvatarImage(String imagePath) async {
    await _firestore.collection('users').doc(widget.user.uid).set({
      'avatarImage': imagePath,
    }, SetOptions(merge: true));
  }

  void _saveName() async {
    try {
      await widget.user.updateDisplayName(_nameController.text);
      await widget.user.reload();
      setState(() {});
      Navigator.pop(context);
    } catch (e) {
      print('Erro ao atualizar nome: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erro ao atualizar o nome. Tente novamente.')),
      );
    }
  }

  void _showEditNameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar nome de usuário'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Novo nome',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: _saveName,
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  bool _isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Escolha um avatar'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImageOption('assets/images/homem1.png'),
                    const SizedBox(width: 10),
                    _buildImageOption('assets/images/mulher1.png'),
                    const SizedBox(width: 10),
                    _buildImageOption('assets/images/adolescente.png'),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _avatarImage =
                          const AssetImage('assets/images/avatar.png');
                    });
                    _saveAvatarImage('assets/images/avatar.png');
                    Navigator.pop(context);
                  },
                  child: const Text('Remover imagem'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);

                    if (pickedFile != null) {
                      final imageBytes = await pickedFile.readAsBytes();
                      final cloudinaryService = CloudinaryService();
                      try {
                        final imageUrl =
                            await cloudinaryService.uploadImage(imageBytes);
                        setState(() {
                          _avatarImage = NetworkImage(imageUrl);
                        });
                        _saveAvatarImage(imageUrl);
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao fazer upload da imagem: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Selecionar imagem'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption(String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _avatarImage = AssetImage(imagePath);
        });
        _saveAvatarImage(imagePath);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(imagePath),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _avatarImage,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImagePickerDialog,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.purple,
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 50),
          Center(
            child: Text(
              widget.user.displayName ?? 'Usuário',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
          const Divider(
            thickness: 1,
            color: Colors.purple,
            indent: 40,
            endIndent: 40,
            height: 30,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Email:',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.user.email ?? 'sem email',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Usuário:',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.user.displayName ?? 'Usuário',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.purple),
                      onPressed: () {
                        _showEditNameDialog();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
                  const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyAnnouncementsScreen(user: widget.user),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Meus anúncios 23'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Adicione a funcionalidade do botão "Favoritados 17" aqui
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Favoritados 17'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
