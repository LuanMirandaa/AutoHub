import 'dart:typed_data';
import 'dart:convert';
import 'package:auto_hub/screens/favorites_screen.dart';
import 'package:auto_hub/services/cloudinary_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:auto_hub/screens/my_announcements_screen.dart';
import 'package:auto_hub/components/menu.dart';

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
  int _favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user.displayName ?? 'Usuário');
    _loadAvatarImage();
    _loadFavoriteCount();
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

    void _loadFavoriteCount() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('favorites')
          .doc(widget.user.uid)
          .collection('favoriteCars')
          .get();

      setState(() {
        _favoriteCount = snapshot.size; // Atualiza a quantidade de favoritos
      });
    } catch (e) {
      print('Erro ao carregar quantidade de favoritos: $e');
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
      drawer: Menu(user: widget.user),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(fontSize: 22, color: Color.fromARGB(255, 84, 4, 98)),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
            padding: const EdgeInsets.only(left: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
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
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
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
                            fontSize: 16,
                            color: Colors.black54,
                          ),
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
                      backgroundColor: Colors.purple[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Meus anúncios'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavoritesScreen(
                            user: FirebaseAuth.instance.currentUser!,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Favoritados $_favoriteCount',),
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

