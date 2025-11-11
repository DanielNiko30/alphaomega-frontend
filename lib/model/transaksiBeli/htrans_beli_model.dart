import 'dtrans_beli_model.dart';

class HTransBeli {
  String? idHTransBeli;
  String idSupplier;
  String tanggal;
  int totalHarga;
  String metodePembayaran;
  String nomorInvoice;
  int ppn;
  List<DTransBeli> detail;

  HTransBeli({
    this.idHTransBeli,
    required this.idSupplier,
    required this.tanggal,
    required this.totalHarga,
    required this.metodePembayaran,
    required this.nomorInvoice,
    required this.ppn,
    required this.detail,
  });

  factory HTransBeli.fromJson(Map<String, dynamic> json) {
    return HTransBeli(
      idHTransBeli: json["id_htrans_beli"] ?? '',
      idSupplier: json["id_supplier"] ?? '',
      tanggal: json["tanggal"] ?? '',
      totalHarga: json["total_harga"] ?? 0,
      metodePembayaran: json["metode_pembayaran"] ?? '',
      nomorInvoice: json["nomor_invoice"] ?? '',
      ppn: json["ppn"] ?? 0,
      detail: (json["detail_transaksi"] == null ||
              json["detail_transaksi"] is! List)
          ? []
          : (json["detail_transaksi"] as List)
              .map((d) => DTransBeli.fromJson(d))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_htrans_beli": idHTransBeli,
      "id_supplier": idSupplier,
      "tanggal": tanggal,
      "total_harga": totalHarga,
      "metode_pembayaran": metodePembayaran,
      "nomor_invoice": nomorInvoice,
      "ppn": ppn,
      "detail_transaksi": detail.map((d) => d.toJson()).toList(),
    };
  }
}
