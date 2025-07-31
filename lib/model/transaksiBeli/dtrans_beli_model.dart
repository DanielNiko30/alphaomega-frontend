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
      idProduk: json["id_produk"],
      jumlahBarang: json["jumlah_barang"],
      hargaSatuan: json["harga_satuan"],
      subtotal: json["subtotal"],
      diskonBarang: json["diskon_barang"], // ✅ harus sesuai toJson
      satuan: json["satuan"],
    );
  }
}
