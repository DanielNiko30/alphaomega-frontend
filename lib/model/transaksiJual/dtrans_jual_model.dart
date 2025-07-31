class DTransJual {
  String idProduk;
  int jumlahBarang;
  int hargaSatuan;
  int subtotal;
  String satuan;

  DTransJual({
    required this.idProduk,
    required this.jumlahBarang,
    required this.hargaSatuan,
    required this.subtotal,
    required this.satuan,
  });

  Map<String, dynamic> toJson() {
    return {
      "id_produk": idProduk,
      "satuan": satuan,
      "jumlah_barang": jumlahBarang,
      "harga_satuan": hargaSatuan,
      "subtotal": subtotal,
    };
  }

  factory DTransJual.fromJson(Map<String, dynamic> json) {
    return DTransJual(
      idProduk: json["id_produk"] ?? "",
      jumlahBarang: json["jumlah_barang"] ?? 0,
      hargaSatuan: json["harga_satuan"] ?? 0,
      subtotal: json["subtotal"] ?? 0,
      satuan: json["satuan"] ?? "",
    );
  }
}
