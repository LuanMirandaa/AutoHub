import 'package:auto_hub/screens/register_screen.dart';
import 'package:auto_hub/screens/reset_password_screen.dart';
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
                    height: 260,
                    width: 400,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    'Bem-vindo ao AutoHub',
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Faça login',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(
                    height: 5,
                  ),
                  Text('e aproveite a experiência',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        labelText: 'E-mail',
                        suffixIcon: Icon(Icons.email_outlined),
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 147, 216),
                                width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.purple, width: 2.0),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                      obscureText: true,
                      controller: _senhaController,
                      decoration: InputDecoration(
                          labelText: 'Senha',
                          suffixIcon: Icon(Icons.password_outlined),
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 206, 147, 216),
                                  width: 2.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.purple, width: 2.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))))),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ResetPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Esqueci minha senha',
                            style: TextStyle(
                                color: Color.fromARGB(255, 206, 147, 216),
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 1920,
                    height: 45,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        onPressed: () {
                          authService
                              .entrarUsuario(
                                  email: _emailController.text,
                                  senha: _senhaController.text)
                              .then((String? erro) {
                            if (erro != null) {
                              final snackBar = SnackBar(
                                  content: Text(erro),
                                  backgroundColor: Colors.red);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          });
                        },
                        child: Text(
                          'Entrar',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        )),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 1920,
                    height: 45,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.purple,
                            width: 2),
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(),
                            ));
                      },
                      child: Text('Cadastrar-se',
                          style: TextStyle(
                              color: Colors.purple,
                              fontSize: 15)),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    '____________________ Conectar usando ___________________',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.purple,
                        ),
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () {},
                      child: Icon(Icons.g_mobiledata_sharp))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
