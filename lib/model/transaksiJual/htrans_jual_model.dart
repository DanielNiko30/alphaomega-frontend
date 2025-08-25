import 'dtrans_jual_model.dart';

class HTransJual {
  final String? idHTransJual;
  String idUser;
  String idUserPenjual;
  String namaPembeli;
  String tanggal;
  int totalHarga;
  String metodePembayaran;
  String? nomorInvoice;
  String? status;
  String? namaUser; // Tambahan: dari relasi User
  String? namaPegawai; // Tambahan: dari relasi Penjual
  List<DTransJual> detail;

  HTransJual({
    this.idHTransJual,
    required this.idUser,
    required this.idUserPenjual,
    required this.namaPembeli,
    required this.tanggal,
    required this.totalHarga,
    required this.metodePembayaran,
    this.nomorInvoice,
    this.status,
    this.namaUser,
    this.namaPegawai,
    required this.detail,
  });

  /// Method toJson untuk kirim data ke backend
  Map<String, dynamic> toJson() {
    return {
      "id_user": idUser,
      "id_user_penjual": idUserPenjual,
      "nama_pembeli": namaPembeli,
      "tanggal": tanggal, // format: YYYY-MM-DD
      "total_harga": totalHarga,
      "metode_pembayaran": metodePembayaran,
      "detail": detail.map((d) => d.toJson()).toList(),
    };
  }

  /// Method fromJson untuk ambil data dari backend
  factory HTransJual.fromJson(Map<String, dynamic> json) {
    return HTransJual(
      idHTransJual: json["id_htrans_jual"],
      idUser: json["id_user"],
      idUserPenjual: json["id_user_penjual"],
      namaPembeli: json["nama_pembeli"],
      tanggal: json["tanggal"],
      totalHarga: json["total_harga"] is String
          ? int.parse(json["total_harga"])
          : json["total_harga"],
      metodePembayaran: json["metode_pembayaran"],
      nomorInvoice: json["nomor_invoice"],
      status: json["status"],
      namaUser: json["user"]?["name"],
      namaPegawai: json["penjual"]?["name"],
      detail: (json["detail_transaksi"] as List<dynamic>)
          .map((d) => DTransJual.fromJson(d))
          .toList(),
    );
  }
}
