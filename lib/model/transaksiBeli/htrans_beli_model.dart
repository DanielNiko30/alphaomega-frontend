import 'dtrans_beli_model.dart';

class HTransBeli {
  String idSupplier;
  String tanggal;
  int totalHarga;
  String metodePembayaran;
  String nomorInvoice;
  int ppn;
  List<DTransBeli> detail;

  HTransBeli({
    required this.idSupplier,
    required this.tanggal,
    required this.totalHarga,
    required this.metodePembayaran,
    required this.nomorInvoice,
    required this.ppn,
    required this.detail,
  });

  Map<String, dynamic> toJson() {
    return {
      "id_supplier": idSupplier,
      "tanggal": tanggal,
      "total_harga": totalHarga,
      "metode_pembayaran": metodePembayaran,
      "nomor_invoice": nomorInvoice,
      "ppn": ppn,
      "detail": detail.map((d) => d.toJson()).toList(),
    };
  }

  factory HTransBeli.fromJson(Map<String, dynamic> json) {
    return HTransBeli(
      idSupplier: json["id_supplier"],
      tanggal: json["tanggal"],
      totalHarga: json["total_harga"],
      metodePembayaran: json["metode_pembayaran"],
      nomorInvoice: json["nomor_invoice"],
      ppn: json["ppn"],
      detail: (json["detail"] as List)
          .map((d) => DTransBeli.fromJson(d))
          .toList(),
    );
  }
}
