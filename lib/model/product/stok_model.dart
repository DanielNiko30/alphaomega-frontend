class StokProduct {
  final String idStok;
  final String satuan;
  final int harga;
  final int jumlah;
  final String? idProductShopee;
  final String? idProductLazada;

  StokProduct({
    required this.idStok,
    required this.satuan,
    required this.harga,
    required this.jumlah,
    this.idProductShopee,
    this.idProductLazada,
  });

  factory StokProduct.fromJson(Map<String, dynamic> json) {
    return StokProduct(
      idStok: json['id_stok'] ?? '',
      satuan: json['satuan'] ?? '',
      harga: (json['harga'] is String)
          ? int.tryParse(json['harga']) ?? 0
          : json['harga'] ?? 0,
      jumlah: (json['jumlah'] is String)
          ? int.tryParse(json['jumlah']) ?? 0
          : json['jumlah'] ?? 0,
      idProductShopee: json['id_product_shopee'] != null
          ? json['id_product_shopee'].toString()
          : null,
      idProductLazada: json['id_product_lazada'] != null
          ? json['id_product_lazada'].toString()
          : null,
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
