import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:catatankeuangan/Views/pemasukan.dart';
import 'package:catatankeuangan/Views/pengeluaran.dart';
import 'package:catatankeuangan/SQLite/sqlite.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';


// Main function yang memulai aplikasi dan menginisialisasi Firebase.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// Kelas utama aplikasi.
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

// ButtonStyle untuk digunakan pada tombol kalkulator.
final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
  foregroundColor: Color(0xFFF9F7F7),
  backgroundColor: Colors.transparent,
  elevation: 0,
  textStyle: TextStyle(fontSize: 20.0),
  padding: EdgeInsets.symmetric(horizontal: 21, vertical: 21),
);

// Widget kalkulator.
class CalculatorWidget extends StatefulWidget {
  @override
  _CalculatorWidgetState createState() => _CalculatorWidgetState();
}

// State dari kalkulator.
class _CalculatorWidgetState extends State<CalculatorWidget> {
  String _displayValue = '';
  double? _result;

  // Fungsi untuk memperbarui tampilan kalkulator.
  void _updateDisplay(String value) {
    setState(() {
      _displayValue += value;
    });
  }

  // Fungsi untuk menghitung hasil perhitungan.
  void _calculateResult() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_displayValue);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      setState(() {
        _result = eval;
        _displayValue = eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 2);
      });
    } catch (e) {
      setState(() {
        _displayValue = 'Error';
      });
    }
  }

  // Fungsi untuk menghapus satu digit.
  void _clearOneDigit() {
    setState(() {
      if (_displayValue.isNotEmpty) {
        _displayValue = _displayValue.substring(0, _displayValue.length - 1);
      }
    });
  }

  // Fungsi untuk menghapus seluruh tampilan.
  void _clearDisplay() {
    setState(() {
      _displayValue = '';
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3F72AF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        children: [
          // Tampilan nilai yang sedang dimasukkan.
          SizedBox(height: 50.0),
          Text(
            _displayValue,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF9F7F7),
            ),
          ),
          SizedBox(height: 50.0),
          // Tombol-tombol kalkulator.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _updateDisplay('7'),
                child: Text('7'),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: () => _updateDisplay('8'),
                child: Text('8'),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: () => _updateDisplay('9'),
                child: Text('9'),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: () => _updateDisplay('/'),
                child: Text('÷'),
                style: buttonStyle,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _updateDisplay('4'),
                child: Text('4'),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: () => _updateDisplay('5'),
                child: Text('5'),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: () => _updateDisplay('6'),
                child: Text('6'),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: () => _updateDisplay('*'),
                child: Text('×'),
                style: buttonStyle,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _updateDisplay('1'),
                child: Text('1'),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: () => _updateDisplay('2'),
                child: Text('2'),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: () => _updateDisplay('3'),
                child: Text('3'),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: () => _updateDisplay('-'),
                child: Text('-'),
                style: buttonStyle,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _updateDisplay('0'),
                child: Text('0'),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: () => _updateDisplay('00'),
                child: Text('00'),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: () => _updateDisplay('000'),
                child: Text('000'),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: () => _updateDisplay('+'),
                child: Text('+'),
                style: buttonStyle,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _displayValue));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Nilai telah disalin ke clipboard')),
                  );
                },
                child: Icon(Icons.copy),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: _clearOneDigit,
                child: Icon(Icons.backspace),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: _clearDisplay,
                child: Icon(Icons.delete_forever),
                style: buttonStyle,
              ),
              ElevatedButton(
                onPressed: _calculateResult,
                child: Text('='),
                style: buttonStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Halaman utama aplikasi.
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final databaseHelper = DatabaseHelper();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF112D4E),
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul aplikasi dan tampilan sisa uang.
              Text(
                'Catatan Keuangan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFFF9F7F7)),
              ),
              SizedBox(height: 5),
              StreamBuilder<int>(
                stream: databaseHelper.balanceStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      'Sisa Uang: Rp. ${NumberFormat('#,###', 'id_ID').format(snapshot.data)}',
                      style: TextStyle(fontSize: 20, color: Color(0xFFF9F7F7)),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
          bottom: TabBar(
            labelColor: Color(0xFFF9F7F7),
            unselectedLabelColor: Color(0xFF3F72AF),
            indicatorColor: Color(0xFFF9F7F7),
            tabs: [
              Tab(text: 'Pemasukan'),
              Tab(text: 'Pengeluaran'),
            ],
          ),
          // Aksi-aksi di app bar.
          actions: [
            IconButton(
              icon: Icon(Icons.file_download),
              onPressed: () {
                databaseHelper.exportData(context);
              },
              color: Color(0xFFF9F7F7),
            ),
            IconButton(
              icon: Icon(Icons.calculate),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return CalculatorWidget();
                  },
                );
              },
              color: Color(0xFFF9F7F7),
            ),
          ],
        ),
        // Isi dari tab-bar.
        body: TabBarView(
          children: [
            PemasukanPage(),
            PengeluaranPage(),
          ],
        ),
      ),
    );
  }
}