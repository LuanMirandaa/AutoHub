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
            accountName: Text(user.displayName ?? ''),
            accountEmail: Text(user.email ?? ''),
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
          ListTile(leading: const Icon(Icons.apps_rounded),
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
          ListTile(leading: const Icon(Icons.chat_bubble),
<<<<<<< HEAD
            title: const Text('Minhas Conversas'),
=======
            title: const Text('Conversas'),
>>>>>>> 5065bb2c6c47a97f97a3646b9285333ef13db456
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