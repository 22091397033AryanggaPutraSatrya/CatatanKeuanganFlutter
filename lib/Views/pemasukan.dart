import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:catatankeuangan/SQLite/sqlite.dart';
import 'package:catatankeuangan/JsonModels/pemasukan.dart';

// Halaman untuk menampilkan dan mengelola pemasukan.
class PemasukanPage extends StatefulWidget {
  @override
  _PemasukanPageState createState() => _PemasukanPageState();
}

// State dari halaman pemasukan.
class _PemasukanPageState extends State<PemasukanPage> {
  final _currencyFormatter = NumberFormat("#,##0"); // Formatter untuk format mata uang.
  final _judulController = TextEditingController();
  final _pemasukanController = TextEditingController();
  late List<Pemasukan> _listPemasukan = []; // List pemasukan.
  int? _totalPemasukan; // Total pemasukan.
  late DatabaseHelper _dbHelper;

  // Inisialisasi state.
  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadData();
  }

  // Fungsi untuk memuat data pemasukan dari database.
  _loadData() async {
    int userId = 1;
    _listPemasukan = await _dbHelper.getPemasukan(userId);
    _totalPemasukan = await _dbHelper.getTotalPemasukan() ?? 0;
    setState(() {});
  }

  // Fungsi untuk menambahkan pemasukan baru.
  Future<void> _tambahPemasukan() async {
    String note = _judulController.text;
    int amount = int.parse(_pemasukanController.text);

    // Cek apakah pemasukan sudah ada sebelumnya.
    int existingIndex = _listPemasukan.indexWhere((pemasukan) => pemasukan.note == note);

    if (existingIndex != -1) {
      setState(() {
        _listPemasukan[existingIndex].amount = (_listPemasukan[existingIndex].amount ?? 0) + amount;
      });
      await _dbHelper.updatePemasukan(_listPemasukan[existingIndex]);
    } else {
      await _dbHelper.createPemasukan(Pemasukan(userId: 1, amount: amount, note: note));
    }

    _pemasukanController.clear();
    _judulController.clear();
    _loadData();
  }

  // Fungsi untuk menghapus pemasukan.
  void _hapusPemasukan(int id) async {
    await _dbHelper.deletePemasukan(id);
    _loadData();
  }

  // Fungsi untuk menampilkan daftar pemasukan dalam bottom sheet.
  void _showPemasukanList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF3F72AF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.0),
              Text(
                'Daftar Pemasukan',
                style: TextStyle(fontSize: 18.0, color: Color(0xFFF9F7F7)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _listPemasukan.length,
                  itemBuilder: (context, index) {
                    final pemasukan = _listPemasukan[index];
                    return ListTile(
                      title: Text(
                        '${pemasukan.note}: Rp. ${_currencyFormatter.format(pemasukan.amount)}',
                        style: TextStyle(color: Color(0xFFF9F7F7)),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _hapusPemasukan(pemasukan.pemasukanId!);
                          Navigator.pop(context);
                        },
                        color: Color(0xFFF9F7F7),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Membuild UI halaman pemasukan.
  @override
  Widget build(BuildContext context) {
    final _seriesData = [
      // Data untuk grafik pemasukan.
      charts.Series<Pemasukan, String>(
        id: 'Pemasukan',
        domainFn: (Pemasukan pemasukan, _) => pemasukan.note ?? '',
        measureFn: (Pemasukan pemasukan, _) => pemasukan.amount ?? 0,
        data: _listPemasukan.where((pemasukan) => pemasukan.note != null).toList(),
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(0xFFDBE2EF)),
      ),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total Pemasukan: Rp. ${_currencyFormatter.format(_totalPemasukan)}',
              style: TextStyle(fontSize: 18.0, color: Color(0xFFF9F7F7)),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _judulController,
              style: TextStyle(color: Color(0xFFF9F7F7)),
              cursorColor: Color(0xFFF9F7F7),
              decoration: InputDecoration(
                labelText: 'Sumber Pemasukan',
                labelStyle: TextStyle(color: Color(0xFFF9F7F7)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFF9F7F7)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFF9F7F7)),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _pemasukanController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Color(0xFFF9F7F7)),
              cursorColor: Color(0xFFF9F7F7),
              decoration: InputDecoration(
                labelText: 'Jumlah Pemasukan',
                labelStyle: TextStyle(color: Color(0xFFF9F7F7)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFF9F7F7)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFF9F7F7)),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _tambahPemasukan,
              child: Text('Tambah Pemasukan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3F72AF),
                foregroundColor: Color(0xFFF9F7F7),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Grafik Pemasukan',
              style: TextStyle(fontSize: 18.0, color: Color(0xFFF9F7F7)),
            ),
            SizedBox(height: 8.0),
            Container(
              height: 300,
              child: charts.BarChart(
                _seriesData,
                animate: true,
                domainAxis: charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                    labelStyle: charts.TextStyleSpec(
                      color: charts.ColorUtil.fromDartColor(Color(0xFFF9F7F7)),
                    ),
                  ),
                ),
                primaryMeasureAxis: charts.NumericAxisSpec(
                  renderSpec: charts.GridlineRendererSpec(
                    labelStyle: charts.TextStyleSpec(
                      color: charts.ColorUtil.fromDartColor(Color(0xFFF9F7F7)),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _showPemasukanList(context);
              },
              child: Text('Lihat Daftar Pemasukan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3F72AF),
                foregroundColor: Color(0xFFF9F7F7),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF112D4E),
    );
  }

  // Dispose controller ketika widget di dispose.
  @override
  void dispose() {
    _judulController.dispose();
    _pemasukanController.dispose();
    super.dispose();
  }
}