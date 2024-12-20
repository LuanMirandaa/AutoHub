import 'package:auto_hub/services/auth_services.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
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
                      width: 250,
                      height: 250,
                    ),
                    TextField(
                      controller: _nomeController,
                      decoration: const InputDecoration(hintText: 'Nome'),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(hintText: 'E-mail'),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      obscureText: true,
                      controller: _senhaController,
                      decoration: const InputDecoration(hintText: 'Senha'),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      obscureText: true,
                      controller: _confirmarSenhaController,
                      decoration: const InputDecoration(hintText: 'Confirmar Senha'),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        if (_senhaController.text == _confirmarSenhaController.text) {
                          final String? erro = await authService.cadastrarUsuario(
                            email: _emailController.text,
                            senha: _senhaController.text,
                            nome: _nomeController.text,
                          );

                          if (erro != null) {
                            if (context.mounted) {
                              final snackBar = SnackBar(
                                content: Text(erro),
                                backgroundColor: Colors.red,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          } else {
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        } else {
                          if (context.mounted) {
                            const snackBar = SnackBar(
                              content: Text('As senhas não correspondem'),
                              backgroundColor: Colors.red,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        }
                      },
                      child: const Text('Cadastrar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

