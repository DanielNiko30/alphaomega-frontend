class DTransBeli {
  String idProduk;
  int jumlahBarang;
  int hargaSatuan;
  int subtotal;
  int diskonBarang;
  String satuan;

  DTransBeli({
    required this.idProduk,
    required this.jumlahBarang,
    required this.hargaSatuan,
    required this.subtotal,
    required this.diskonBarang,
    required this.satuan,
  });

  Map<String, dynamic> toJson() {
    return {
      "id_produk": idProduk,
      "jumlah_barang": jumlahBarang,
      "harga_satuan": hargaSatuan,
      "subtotal": subtotal,
      "diskon_barang": diskonBarang, // ✅ perbaikan
      "satuan": satuan,
    };
  }

  factory DTransBeli.fromJson(Map<String, dynamic> json) {
    return DTransBeli(
      idProduk: json["id_produk"] ?? '',
      jumlahBarang: json["jumlah_barang"] ?? 0,
      satuan: json["satuan"] ?? '',
      subtotal: json["subtotal"] ?? 0,
      diskonBarang: json["diskon_barang"] ?? 0,
      hargaSatuan: json["harga_satuan"] ?? 0,
    );
  }
}
