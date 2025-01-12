import 'package:auto_hub/screens/chat_screen.dart';
import 'package:auto_hub/screens/home_screen.dart';
import 'package:auto_hub/screens/login_screen.dart';
import 'package:auto_hub/screens/my_announcements_screen.dart';
import 'package:auto_hub/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Menu extends StatelessWidget {
  final User user;

  const Menu({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.manage_accounts_rounded,
                size: 50,
              ),
            ),
            accountName: Text(user.displayName ?? 'Usuário'),
            accountEmail: Text(user.email ?? 'E-mail não disponível'),
          ),
          ListTile(
            leading: const Icon(Icons.home_max_rounded),
            title: const Text('Tela inicial'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(user: user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.apps_rounded),
            title: const Text('Seus anúncios'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyAnnouncementsScreen(user: user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble),
            title: const Text('Conversas'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyChatsScreen(user: user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app_rounded),
            title: const Text('Sair'),
            onTap: () async {
              await AuthService().deslogar();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
