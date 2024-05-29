// Definisikan kelas Users dengan tiga properti: usrId, usrName, dan usrPassword.
class Users {
  final int? usrId;
  final String usrName;
  final String usrPassword;

  // Konstruktor Users dengan parameter opsional usrId, dan parameter wajib usrName dan usrPassword.
  Users({
    this.usrId,
    required this.usrName,
    required this.usrPassword,
  });

  // Factory method untuk membuat objek Users dari map JSON.
  factory Users.fromMap(Map<String, dynamic> json) => Users(
        usrId: json["usrId"],
        usrName: json["usrName"],
        usrPassword: json["usrPassword"],
      );

  // Metode untuk mengonversi objek Users menjadi map JSON.
  Map<String, dynamic> toMap() => {
        "usrId": usrId,
        "usrName": usrName,
        "usrPassword": usrPassword,
      };
}
