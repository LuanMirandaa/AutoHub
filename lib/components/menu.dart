import 'package:auto_hub/screens/chat_list.dart';
import 'package:auto_hub/screens/home_screen.dart';
import 'package:auto_hub/screens/login_screen.dart';
import 'package:auto_hub/screens/map_screen.dart'; 
import 'package:auto_hub/screens/perfil_screen.dart';
import 'package:auto_hub/screens/my_announcements_screen.dart';
import 'package:auto_hub/screens/favorites_screen.dart';
import 'package:auto_hub/screens/financing_screen.dart';
import 'package:auto_hub/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Menu extends StatefulWidget {
  final User user;

  const Menu({super.key, required this.user});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  ImageProvider<Object> _avatarImage =
      const AssetImage('assets/images/avatar.png');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadAvatarImage();
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundImage: _avatarImage,
            ),
            accountName: Text(
              widget.user.displayName ?? '',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              widget.user.email ?? '',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.purple,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_max_rounded, color: Colors.purple),
            title: const Text('Tela inicial'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(user: widget.user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.apps_rounded, color: Colors.purple),
            title: const Text('Meus anúncios'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MyAnnouncementsScreen(user: widget.user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble, color: Colors.purple),
            title: const Text('Minhas conversas'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatListScreen(user: widget.user,),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.purple),
            title: const Text('Favoritos'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(user: widget.user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.purple),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: widget.user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.map, color: Colors.purple),
            title: const Text('Mapa'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MapScreen(user: widget.user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate, color: Colors.purple),
            title: const Text('Simulador de financiamento'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FinancingScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.exit_to_app_rounded, color: Colors.purple),
            title: const Text('Sair'),
            onTap: () async {
              await AuthService().deslogar();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
