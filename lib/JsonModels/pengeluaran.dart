// Definisikan kelas Pengeluaran dengan beberapa properti opsional.
class Pengeluaran {
  int? pengeluaranId;
  int? userId;
  int? amount;
  String? note;
  int? totalPengeluaran;

  // Konstruktor Pengeluaran dengan parameter-parameter opsional.
  Pengeluaran({
    this.pengeluaranId,
    this.userId,
    this.amount,
    this.note,
    this.totalPengeluaran,
  });

  // Factory method untuk membuat objek Pengeluaran dari map JSON.
  factory Pengeluaran.fromMap(Map<String, Object?> map) {
    return Pengeluaran(
      pengeluaranId: map['pengeluaranId'] as int?,
      userId: map['userId'] as int?,
      amount: map['amount'] as int?,
      note: map['note'] as String?,
      totalPengeluaran: map['totalPengeluaran'] as int?,
    );
  }

  // Metode untuk mengonversi objek Pengeluaran menjadi map JSON.
  Map<String, Object?> toMap() {
    return {
      'pengeluaranId': pengeluaranId,
      'userId': userId,
      'amount': amount,
      'note': note,
      'totalPengeluaran': totalPengeluaran,
    };
  }
}