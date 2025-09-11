class Stok {
  final String idStok;
  final String satuan;
  final int harga;
  final int jumlah;
  final String? idProductShopee;
  final String? idProductLazada;

  Stok({
    required this.idStok,
    required this.satuan,
    required this.harga,
    required this.jumlah,
    this.idProductShopee,
    this.idProductLazada,
  });

  factory Stok.fromJson(Map<String, dynamic> json) {
    return Stok(
      idStok: json['id_stok'] ?? '',
      satuan: json['satuan'] ?? '',
      harga: (json['harga'] is String)
          ? int.tryParse(json['harga']) ?? 0
          : json['harga'] ?? 0,
      jumlah: (json['jumlah'] is String)
          ? int.tryParse(json['jumlah']) ?? 0
          : json['jumlah'] ?? 0,
      idProductShopee: json['id_product_shopee'],
      idProductLazada: json['id_product_lazada'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_stok': idStok,
      'satuan': satuan,
      'harga': harga,
      'jumlah': jumlah,
      'id_product_shopee': idProductShopee,
      'id_product_lazada': idProductLazada,
    };
  }
}
