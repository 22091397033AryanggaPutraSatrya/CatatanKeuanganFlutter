import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:catatankeuangan/JsonModels/users.dart';
import 'package:catatankeuangan/SQLite/sqlite.dart';
import 'package:catatankeuangan/Views/main.dart';

// Halaman untuk masuk ke aplikasi dengan username dan password.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool isVisible = false;
  bool isLoginTrue = false;
  bool rememberMe = false;
  final db = DatabaseHelper();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  // Memuat pengaturan "Ingat Saya" dari penyimpanan lokal.
  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        username.text = prefs.getString('username') ?? '';
        password.text = prefs.getString('password') ?? '';
      }
    });
  }

  // Menyimpan pengaturan "Ingat Saya" ke penyimpanan lokal.
  void _saveRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', rememberMe);
    if (rememberMe) {
      prefs.setString('username', username.text);
      prefs.setString('password', password.text);
    } else {
      prefs.remove('username');
      prefs.remove('password');
    }
  }

  // Fungsi untuk melakukan login.
  login() async {
    var response = await db
        .login(Users(usrName: username.text, usrPassword: password.text));
    if (response == true) {
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      setState(() {
        isLoginTrue = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Halaman Masuk',
                    style: TextStyle(fontSize: 40,color: Color(0xFFF9F7F7), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (bool? value) {
                              setState(() {
                                rememberMe = value!;
                              });
                            },
                            checkColor: Color(0xFFF9F7F7),
                            activeColor: Color(0xFF3F72AF),
                          ),
                          Text(
                            'Ingat Saya',
                            style: TextStyle(color: Color(0xFFF9F7F7)),
                          ),
                        ],
                      ),
                      Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width * .5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF3F72AF),
                        ),
                        child: TextButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              login();
                              _saveRememberMe();
                            }
                          },
                          child: Text(
                            'MASUK',
                            style: TextStyle(color: Color(0xFFF9F7F7)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isLoginTrue)
                    Text(
                      "Username atau password salah",
                      style: TextStyle(color: Colors.red),
                    ),
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
