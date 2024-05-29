import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:catatankeuangan/JsonModels/pemasukan.dart';
import 'package:catatankeuangan/JsonModels/pengeluaran.dart';
import 'package:catatankeuangan/JsonModels/users.dart';

// Kelas yang bertanggung jawab atas operasi database dan ekspor data ke PDF.
class DatabaseHelper {
  // Nama database dan query pembuatan tabel.
  final databaseName = "catatankeuangan.db";
  String pemasukanTable =
      "CREATE TABLE pemasukan (pemasukanId INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, amount INTEGER NOT NULL, note TEXT NOT NULL, totalPemasukan INTEGER, FOREIGN KEY (userId) REFERENCES users(usrId))";

  String pengeluaranTable =
      "CREATE TABLE pengeluaran (pengeluaranId INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, amount INTEGER NOT NULL, note TEXT NOT NULL, totalPengeluaran INTEGER, FOREIGN KEY (userId) REFERENCES users(usrId))";

  String usersTable =
      "CREATE TABLE users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrName TEXT UNIQUE, usrPassword TEXT)";

  // Controller stream untuk penyiaran pembaruan saldo.
  late StreamController<int> _balanceController;

  // Konstruktor yang menginisialisasi controller stream dan menghitung saldo.
  DatabaseHelper() {
    _balanceController = StreamController<int>.broadcast();
    _calculateBalance();
  }

  // Getter untuk mengakses stream pembaruan saldo.
  Stream<int> get balanceStream => _balanceController.stream;

  // Future function untuk menginisialisasi database.
  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(usersTable);
      await db.execute(pemasukanTable);
      await db.execute(pengeluaranTable);
    });
  }

  // Future function untuk otentikasi login pengguna.
  Future<bool> login(Users user) async {
    final Database db = await initDB();
    var result = await db.rawQuery(
        "SELECT * FROM users WHERE usrName = ? AND usrPassword = ?",
        [user.usrName, user.usrPassword]);
    return result.isNotEmpty;
  }

  // Future function untuk pendaftaran pengguna.
  Future<int> signup(Users user) async {
    final Database db = await initDB();
    return db.insert('users', user.toMap());
  }

  // Future function untuk membuat catatan pemasukan.
  Future<int> createPemasukan(Pemasukan pemasukan) async {
    final Database db = await initDB();
    int result = await db.insert('pemasukan', pemasukan.toMap());
    await db.rawQuery("UPDATE pemasukan SET totalPemasukan = (SELECT SUM(amount) FROM pemasukan WHERE userId = ?) WHERE pemasukanId = ?", [pemasukan.userId, result]);
    return result;
  }

  // Future function untuk membuat catatan pengeluaran.
  Future<int> createPengeluaran(Pengeluaran pengeluaran) async {
    final Database db = await initDB();
    int result = await db.insert('pengeluaran', pengeluaran.toMap());
    await db.rawQuery("UPDATE pengeluaran SET totalPengeluaran = (SELECT SUM(amount) FROM pengeluaran WHERE userId = ?) WHERE pengeluaranId = ?", [pengeluaran.userId, result]);
    return result;
  }

  // Future function untuk mendapatkan daftar pemasukan berdasarkan ID pengguna.
  Future<List<Pemasukan>> getPemasukan(int userId) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result =
    await db.query('pemasukan', where: 'userId = ?', whereArgs: [userId]);
    return result.map((e) => Pemasukan.fromMap(e)).toList();
  }

  // Future function untuk mendapatkan daftar pengeluaran berdasarkan ID pengguna.
  Future<List<Pengeluaran>> getPengeluaran(int userId) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result =
    await db.query('pengeluaran', where: 'userId = ?', whereArgs: [userId]);
    return result.map((e) => Pengeluaran.fromMap(e)).toList();
  }

  // Future function untuk menghapus catatan pemasukan berdasarkan ID.
  Future<int> deletePemasukan(int pemasukanId) async {
    final Database db = await initDB();
    return db.delete(
        'pemasukan', where: 'pemasukanId = ?', whereArgs: [pemasukanId]);
  }

  // Future function untuk menghapus catatan pengeluaran berdasarkan ID.
  Future<int> deletePengeluaran(int pengeluaranId) async {
    final Database db = await initDB();
    return db.delete(
        'pengeluaran', where: 'pengeluaranId = ?', whereArgs: [pengeluaranId]);
  }

  // Future function untuk mendapatkan total pemasukan dari database.
  Future<int?> getTotalPemasukan() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('pemasukan');
    int totalPemasukan = 0;
    for (var item in result) {
      totalPemasukan += (item['amount'] as int?)!;
    }
    return totalPemasukan;
  }

  // Future function untuk mendapatkan total pengeluaran dari database.
  Future<int?> getTotalPengeluaran() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('pengeluaran');
    int totalPengeluaran = 0;
    for (var item in result) {
      totalPengeluaran += (item['amount'] as int?)!;
    }
    return totalPengeluaran;
  }

  // Future function untuk menghitung saldo dan mengirimkan pembaruan ke controller stream.
  Future<void> _calculateBalance() async {
    while (true) {
      await Future.delayed(Duration(seconds: 1)); // update balance every second
      int? totalPemasukan = await getTotalPemasukan();
      int? totalPengeluaran = await getTotalPengeluaran();
      int balance = totalPemasukan != null && totalPengeluaran != null
          ? totalPemasukan - totalPengeluaran
          : 0;
      _balanceController.sink.add(balance);
    }
  }

  // Future function untuk memperbarui catatan pemasukan.
  Future<int> updatePemasukan(Pemasukan pemasukan) async {
    final Database db = await initDB();
    return db.update(
      'pemasukan',
      pemasukan.toMap(),
      where: 'pemasukanId = ?',
      whereArgs: [pemasukan.pemasukanId],
    );
  }

  // Future function untuk memperbarui catatan pengeluaran.
  Future<int> updatePengeluaran(Pengeluaran pengeluaran) async {
    final Database db = await initDB();
    return db.update(
      'pengeluaran',
      pengeluaran.toMap(),
      where: 'pengeluaranId = ?',
      whereArgs: [pengeluaran.pengeluaranId],
    );
  }

  // Future function untuk mengekspor data ke PDF.
  Future<void> exportData(BuildContext context) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    final List<Pemasukan> pemasukanList = await getPemasukan(1);
    final List<Pengeluaran> pengeluaranList = await getPengeluaran(1);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Pemasukan'),
              ),
              pw.Table.fromTextArray(
                headers: ['ID', 'Jumlah', 'Sumber'],
                data: pemasukanList.map((pemasukan) =>
                [
                  pemasukan.pemasukanId.toString(),
                  pemasukan.amount.toString(),
                  pemasukan.note,
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Header(
                level: 0,
                child: pw.Text('Pengeluaran'),
              ),
              pw.Table.fromTextArray(
                headers: ['ID', 'Jumlah', 'Alasan'],
                data: pengeluaranList.map((pengeluaran) =>
                [
                  pengeluaran.pengeluaranId.toString(),
                  pengeluaran.amount.toString(),
                  pengeluaran.note,
                ]).toList(),
              ),
            ],
          );
        },
      ),
    );

    final String dir = '/storage/emulated/0/Download';
    final String path = '$dir/keuangan_data.pdf';
    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Data berhasil diekspor di folder Download'),
    ));
  }
}
