import 'package:auto_hub/screens/register_screen.dart';
import 'package:auto_hub/services/auth_services.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 250,
                    width: 250,
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(hintText: 'E-mail'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                      obscureText: true,
                      controller: _senhaController,
                      decoration: InputDecoration(hintText: 'Senha')),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        authService
                            .entrarUsuario(
                                email: _emailController.text,
                                senha: _senhaController.text)
                            .then((String? erro) {
                          if (erro != null) {
                            final snackBar = SnackBar(content: Text(erro),backgroundColor: Colors.red);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        });
                      },
                      child: Text('Entrar')),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {}, child: Text('Entrar com o Google')),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ));
                    },
                    child: Text('Cadastrar-se'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}