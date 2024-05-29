import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:catatankeuangan/SQLite/sqlite.dart';
import 'package:catatankeuangan/JsonModels/pengeluaran.dart';

// Halaman untuk menampilkan dan mengelola pengeluaran.
class PengeluaranPage extends StatefulWidget {
  @override
  _PengeluaranPageState createState() => _PengeluaranPageState();
}

// State dari halaman pengeluaran.
class _PengeluaranPageState extends State<PengeluaranPage> {
  final _currencyFormatter = NumberFormat("#,##0"); // Formatter untuk format mata uang.
  final _judulController = TextEditingController();
  final _pengeluaranController = TextEditingController();
  late List<Pengeluaran> _listPengeluaran = []; // List pengeluaran.
  int? _totalPengeluaran; // Total pengeluaran.
  late DatabaseHelper _dbHelper;

  // Inisialisasi state.
  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadData();
  }

  // Fungsi untuk memuat data pengeluaran dari database.
  _loadData() async {
    int userId = 1;
    _listPengeluaran = await _dbHelper.getPengeluaran(userId);
    _totalPengeluaran = await _dbHelper.getTotalPengeluaran() ?? 0;
    setState(() {});
  }

  // Fungsi untuk menambahkan pengeluaran baru.
  Future<void> _tambahPengeluaran() async {
    int amount = int.parse(_pengeluaranController.text);
    String note = _judulController.text;

    // Cek apakah pengeluaran sudah ada sebelumnya.
    int existingIndex = _listPengeluaran.indexWhere((pengeluaran) => pengeluaran.note == note);

    if (existingIndex != -1) {
      setState(() {
        _listPengeluaran[existingIndex].amount = (_listPengeluaran[existingIndex].amount ?? 0) + amount;
      });
      await _dbHelper.updatePengeluaran(_listPengeluaran[existingIndex]);
    } else {
      await _dbHelper.createPengeluaran(Pengeluaran(userId: 1, amount: amount, note: note));
    }

    _pengeluaranController.clear();
    _judulController.clear();
    _loadData();
  }

  // Fungsi untuk menghapus pengeluaran.
  void _hapusPengeluaran(int id) async {
    await _dbHelper.deletePengeluaran(id);
    _loadData();
  }

  // Fungsi untuk menampilkan daftar pengeluaran dalam bottom sheet.
  void _showPengeluaranList(BuildContext context) {
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
                'Daftar Pengeluaran',
                style: TextStyle(fontSize: 18.0, color: Color(0xFFF9F7F7)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _listPengeluaran.length,
                  itemBuilder: (context, index) {
                    final pengeluaran = _listPengeluaran[index];
                    return ListTile(
                      title: Text(
                        '${pengeluaran.note}: Rp. ${_currencyFormatter.format(pengeluaran.amount)}',
                        style: TextStyle(color: Color(0xFFF9F7F7)),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _hapusPengeluaran(pengeluaran.pengeluaranId!);
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

  // Membuild UI halaman pengeluaran.
  @override
  Widget build(BuildContext context) {
    final _seriesData = [
      charts.Series<Pengeluaran, String>(
        id: 'Pengeluaran',
        domainFn: (Pengeluaran pengeluaran, _) => pengeluaran.note ?? '',
        measureFn: (Pengeluaran pengeluaran, _) => pengeluaran.amount ?? 0,
        data: _listPengeluaran.where((pengeluaran) => pengeluaran.note != null).toList(),
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
              'Total Pengeluaran: Rp. ${_currencyFormatter.format(_totalPengeluaran)}',
              style: TextStyle(fontSize: 18.0, color: Color(0xFFF9F7F7)),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _judulController,
              style: TextStyle(color: Color(0xFFF9F7F7)),
              cursorColor: Color(0xFFF9F7F7),
              decoration: InputDecoration(
                labelText: 'Alasan Pengeluaran',
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
              controller: _pengeluaranController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Color(0xFFF9F7F7)),
              cursorColor: Color(0xFFF9F7F7),
              decoration: InputDecoration(
                labelText: 'Jumlah Pengeluaran',
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
              onPressed: _tambahPengeluaran,
              child: Text('Tambah Pengeluaran'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3F72AF),
                foregroundColor: Color(0xFFF9F7F7),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Grafik Pengeluaran',
              style: TextStyle(fontSize: 18.0, color: Color(0xFFF9F7F7))
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
                _showPengeluaranList(context);
              },
              child: Text('Lihat Daftar Pengeluaran'),
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
    _pengeluaranController.dispose();
    super.dispose();
  }
}