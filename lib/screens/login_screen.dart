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
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 180,
                    width: 180,
                  ),
                  const SizedBox(height:220),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 280), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Insira seu email',
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 30,vertical: 0),
                            hintStyle: TextStyle(
                              color: const Color(0xFF520453).withOpacity(0.6), 
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color(0xFF9A007E), 
                                width: 2, 
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color(0xFF9A007E), 
                                width: 2, 
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40), 
                        TextField(
                          obscureText: true,
                          controller: _senhaController,
                          decoration: InputDecoration(
                            hintText: 'Senha',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                            hintStyle: TextStyle(
                              color: const Color(0xFF520453).withOpacity(0.6), 
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color(0xFF9A007E), 
                                width: 2, 
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color(0xFF9A007E),
                                width: 2, 
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                  const SizedBox(height: 80),
ElevatedButton(
                    onPressed: () {
                      authService
                          .entrarUsuario(
                        email: _emailController.text,
                        senha: _senhaController.text,
                      )
                          .then((String? erro) {
                        if (erro != null) {
                          final snackBar = SnackBar(
                            content: Text(erro),
                            backgroundColor: Colors.red,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color.fromARGB(255, 127, 6, 148), 
                        width: 4, 
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), 
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 17),
                    ),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        color: Color.fromARGB(255, 127, 6, 148), 
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(height: 20),
ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 127, 6, 148), 
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), 
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 18), 
                    ),
                    child: const Text(
                      "Cadastrar-se",
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w500, 
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Entrar com conta Google",
                            style: TextStyle(
                              color: Color.fromARGB(255, 127, 6, 148),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Divider(
                          color: Color.fromARGB(255, 127, 6, 148),
                          thickness: 2,
                          indent: 370,
                          endIndent: 370,
                        ),
                      ],
                    ),
                  ),


                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
