class StokProduct {
  final String? idStok;
  final String satuan;
  final int harga;
  final int jumlah;
  final String? idProductShopee;
  final String? idProductLazada;
  final int? hargaBeli;

  StokProduct(
      {this.idStok,
      required this.satuan,
      required this.harga,
      required this.jumlah,
      this.idProductShopee,
      this.idProductLazada,
      this.hargaBeli});

  factory StokProduct.fromJson(Map<String, dynamic> json) {
    return StokProduct(
      idStok: json['id_stok'] as String?,
      satuan: json['satuan'] ?? '',
      harga: (json['harga'] is String)
          ? int.tryParse(json['harga']) ?? 0
          : json['harga'] ?? 0,
      jumlah: (json['jumlah'] is String)
          ? int.tryParse(json['jumlah']) ?? 0
          : json['jumlah'] ?? 0,
      idProductShopee: json['id_product_shopee']?.toString(),
      idProductLazada: json['id_product_lazada']?.toString(),
      hargaBeli: (json['harga_beli'] is String)
          ? int.tryParse(json['harga_beli']) ?? 0
          : json['harga_beli'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'satuan': satuan,
      'harga': harga,
      'jumlah': jumlah,
      'id_product_shopee': idProductShopee,
      'id_product_lazada': idProductLazada,
      'harga_beli': hargaBeli,
    };

    // hanya sertakan id_stok jika ada
    if (idStok != null && idStok!.isNotEmpty) {
      data['id_stok'] = idStok;
    }

    return data;
  }
}
