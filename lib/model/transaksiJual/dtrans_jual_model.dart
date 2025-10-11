class DTransJual {
  String idProduk;
  double jumlahBarang;
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
      idProduk: json["id_produk"],
      jumlahBarang: (json['jumlah_barang'] is String)
          ? double.parse(json['jumlah_barang'])
          : (json['jumlah_barang'] as num).toDouble(), // ✅ Perbaikan di sini
      hargaSatuan: (json['harga_satuan'] as num).toInt(), // ✅ Aman untuk int
      subtotal: (json['subtotal'] as num).toInt(), // ✅ Aman untuk int
      satuan: json["satuan"],
    );
  }
}
