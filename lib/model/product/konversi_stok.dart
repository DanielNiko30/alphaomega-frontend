class KonversiStok {
  final String idProduct;
  final String dariSatuan;
  final int jumlahDari;
  final String keSatuan;
  final int jumlahKe;
  final String? message; // opsional untuk response

  KonversiStok({
    required this.idProduct,
    required this.dariSatuan,
    required this.jumlahDari,
    required this.keSatuan,
    required this.jumlahKe,
    this.message,
  });

  Map<String, dynamic> toJson() => {
        "id_product": idProduct,
        "dari_satuan": dariSatuan,
        "jumlah_dari": jumlahDari,
        "ke_satuan": keSatuan,
        "jumlah_ke": jumlahKe,
      };

  factory KonversiStok.fromJson(Map<String, dynamic> json) => KonversiStok(
        idProduct: json['id_product'] ?? "",
        dariSatuan: json['dari_satuan'] ?? "",
        jumlahDari: json['jumlah_dari'] ?? 0,
        keSatuan: json['ke_satuan'] ?? "",
        jumlahKe: json['jumlah_ke'] ?? 0,
        message: json['message'], // hanya ada di response
      );
}
