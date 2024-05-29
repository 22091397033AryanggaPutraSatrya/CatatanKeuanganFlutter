// Definisikan kelas Pemasukan dengan beberapa properti opsional.
class Pemasukan {
  int? pemasukanId;
  int? userId;
  int? amount;
  String? note;
  int? totalPemasukan;

  // Konstruktor Pemasukan dengan parameter-parameter opsional.
  Pemasukan({
    this.pemasukanId,
    this.userId,
    this.amount,
    this.note,
    this.totalPemasukan,
  });

  // Factory method untuk membuat objek Pemasukan dari map JSON.
  factory Pemasukan.fromMap(Map<String, Object?> map) {
    return Pemasukan(
      pemasukanId: map['pemasukanId'] as int?,
      userId: map['userId'] as int?,
      amount: map['amount'] as int?,
      note: map['note'] as String?,
      totalPemasukan: map['totalPemasukan'] as int?,
    );
  }

  // Metode untuk mengonversi objek Pemasukan menjadi map JSON.
  Map<String, Object?> toMap() {
    return {
      'pemasukanId': pemasukanId,
      'userId': userId,
      'amount': amount,
      'note': note,
      'totalPemasukan': totalPemasukan,
    };
  }
}