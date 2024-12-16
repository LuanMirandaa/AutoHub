import 'package:auto_hub/screens/home_screen.dart';
import 'package:auto_hub/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: LoginScreen(),
      home: const ScreenRouter(),
    );
  }
}

class ScreenRouter extends StatelessWidget {
  const ScreenRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: FirebaseAuth.instance.userChanges(), builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting){
        return const Center(
          child: CircularProgressIndicator(),);
      } else {
        if (snapshot.hasData){
          return HomeScreen(user: snapshot.data!);
        } else{
          return LoginScreen();
        }
      }

    });
  }
}
