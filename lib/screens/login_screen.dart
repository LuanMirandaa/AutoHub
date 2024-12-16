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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          height: screenHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                margin: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: screenHeight * 0.2,
                      width: screenWidth * 0.4,
                    ),
                    SizedBox(height: screenHeight * 0.1),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Insira seu email',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.08,
                                vertical: 0,
                              ),
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
                          SizedBox(height: screenHeight * 0.05),
                          TextField(
                            obscureText: true,
                            controller: _senhaController,
                            decoration: InputDecoration(
                              hintText: 'Senha',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.08,
                              ),
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
                    SizedBox(height: screenHeight * 0.05),
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
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: const Color.fromARGB(255, 127, 6, 148),
                          width: screenWidth * 0.01,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.2,
                          vertical: screenHeight * 0.02,
                        ),
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
                    SizedBox(height: screenHeight * 0.02),
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
                        backgroundColor: const Color.fromARGB(255, 127, 6, 148),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.16,
                          vertical: screenHeight * 0.02,
                        ),
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
                      padding: EdgeInsets.only(top: screenHeight * 0.05),
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
                          Divider(
                            color: const Color.fromARGB(255, 127, 6, 148),
                            thickness: 2,
                            indent: screenWidth * 0.15,
                            endIndent: screenWidth * 0.15,
                          ),
                        ],
                      ),
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
