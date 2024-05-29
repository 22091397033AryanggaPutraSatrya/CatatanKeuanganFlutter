import 'package:flutter/material.dart';
import 'package:catatankeuangan/Authtentication/login.dart';
import 'package:catatankeuangan/Authtentication/signup.dart';

void main() {
  runApp(MyApp());
}

// Kelas utama aplikasi yang menentukan tata letak tab bar dan halaman terkait.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      title: 'Catat Uang',
    );
  }
}

// Halaman utama yang berisi tab bar untuk login dan sign up.
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF112D4E),
          automaticallyImplyLeading: false,
          title: Text(
            'Catatan Keuangan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFFF9F7F7)),
          ),
          bottom: TabBar(
            labelColor: Color(0xFFF9F7F7),
            unselectedLabelColor: Color(0xFF3F72AF),
            indicatorColor: Color(0xFFF9F7F7),
            tabs: [
              Tab(text: 'MASUK'), // Tab untuk halaman login
              Tab(text: 'DAFTAR'), // Tab untuk halaman sign up
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LoginScreen(), // Halaman login
            SignUp(), // Halaman sign up
          ],
        ),
      ),
    );
  }
}
