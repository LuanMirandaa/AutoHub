import 'package:auto_hub/services/auth_services.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  AuthService authServicer = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 400,
                        height: 260,
                        fit: BoxFit.cover,
                      ),
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          hintText: 'Nome',
                          hintStyle: TextStyle(color: Color.fromARGB(255, 117, 117, 117)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 206, 147, 216), width: 2.0),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'E-mail',
                          hintStyle: TextStyle(color: Color.fromARGB(255, 117, 117, 117)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 206, 147, 216), width: 2.0),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu e-mail';
                          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Por favor, insira um e-mail válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        obscureText: true,
                        controller: _senhaController,
                        decoration: const InputDecoration(
                          hintText: 'Senha',
                          hintStyle: TextStyle(color: Color.fromARGB(255, 117, 117, 117)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 206, 147, 216), width: 2.0),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          } else if (value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        obscureText: true,
                        controller: _confirmarSenhaController,
                        decoration: const InputDecoration(
                          hintText: 'Confirmar Senha',
                          hintStyle: TextStyle(color: Color.fromARGB(255, 117, 117, 117)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 206, 147, 216), width: 2.0),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, confirme sua senha';
                          } else if (value != _senhaController.text) {
                            return 'As senhas não correspondem';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 1920,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(151, 141, 11, 201),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (_senhaController.text == _confirmarSenhaController.text) {
                                String? erro = await authServicer.cadastrarUsuario(
                                  email: _emailController.text,
                                  senha: _senhaController.text,
                                  nome: _nomeController.text,
                                );

                                if (erro != null) {
                                 
                                  if (erro == 'Email já cadastrado') {
                                    _formKey.currentState!.validate(); 
                                  } else if (erro == 'Senha fraca (mínimo de 6 caracteres)') {
                                    _formKey.currentState!.validate(); 
                                  }
                                } else {
                                  Navigator.pop(context);
                                }
                              }
                            }
                          },
                          child: const Text(
                            'Cadastrar',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}