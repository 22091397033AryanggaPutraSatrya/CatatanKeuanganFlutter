import 'package:flutter/material.dart';
import 'package:catatankeuangan/JsonModels/users.dart';
import 'package:catatankeuangan/SQLite/sqlite.dart';
import 'package:catatankeuangan/main.dart';

// Halaman pendaftaran akun baru.
class SignUp extends StatefulWidget {
  const SignUp({Key? key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Pendaftaran Akun',
                    style: TextStyle(fontSize: 40,color: Color(0xFFF9F7F7), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  // Form input untuk username
                  TextFormField(
                    controller: username,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Username diperlukan";
                      }
                      return null;
                    },
                    style: TextStyle(color: Color(0xFFF9F7F7)),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Color(0xFFF9F7F7)),
                      prefixIcon: Icon(Icons.person, color: Color(0xFFF9F7F7)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF9F7F7)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF9F7F7)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Form input untuk password
                  TextFormField(
                    controller: password,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Password diperlukan";
                      }
                      return null;
                    },
                    obscureText: !isVisible,
                    style: TextStyle(color: Color(0xFFF9F7F7)),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Color(0xFFF9F7F7)),
                      prefixIcon: Icon(Icons.lock, color: Color(0xFFF9F7F7)),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                          color: Color(0xFFF9F7F7),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF9F7F7)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF9F7F7)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Form input untuk konfirmasi password
                  TextFormField(
                    controller: confirmPassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Password diperlukan";
                      } else if (password.text != confirmPassword.text) {
                        return "Password tidak cocok";
                      }
                      return null;
                    },
                    obscureText: !isVisible,
                    style: TextStyle(color: Color(0xFFF9F7F7)),
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      labelStyle: TextStyle(color: Color(0xFFF9F7F7)),
                      prefixIcon: Icon(Icons.lock, color: Color(0xFFF9F7F7)),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                          color: Color(0xFFF9F7F7),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF9F7F7)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF9F7F7)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tombol daftar
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * .9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFF3F72AF),
                    ),
                    child: TextButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final db = DatabaseHelper();
                          db.signup(Users(
                            usrName: username.text,
                            usrPassword: password.text,
                          )).whenComplete(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          });
                        }
                      },
                      child: const Text(
                        "DAFTAR",
                        style: TextStyle(color: Color(0xFFF9F7F7)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFF112D4E),
    );
  }
}