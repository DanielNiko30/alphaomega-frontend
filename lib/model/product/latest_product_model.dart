class LatestProduct {
  final String idProduct;
  final String namaProduct;
  final String productKategori;
  final String gambarProduct;
  final String deskripsiProduct;
  final List<LatestProductStok> stok;

  // ✅ Tambahan
  final String? idProductShopee;
  final String? idProductLazada;

  LatestProduct({
    required this.idProduct,
    required this.namaProduct,
    required this.productKategori,
    required this.gambarProduct,
    required this.deskripsiProduct,
    required this.stok,
    this.idProductShopee,
    this.idProductLazada,
  });

  factory LatestProduct.fromJson(Map<String, dynamic> json) {
    return LatestProduct(
      idProduct: json['id_product'] ?? '',
      namaProduct: json['nama_product'] ?? '',
      productKategori: json['product_kategori'] ?? '',
      gambarProduct: json['gambar_product'] ?? '',
      deskripsiProduct: json['deskripsi_product'] ?? '',
      idProductShopee: json['id_product_shopee'], // ✅ tambahan
      idProductLazada: json['id_product_lazada'], // ✅ tambahan
      stok: (json['stok'] as List? ?? [])
          .map((e) => LatestProductStok.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id_product": idProduct,
        "nama_product": namaProduct,
        "product_kategori": productKategori,
        "gambar_product": gambarProduct,
        "deskripsi_product": deskripsiProduct,
        "id_product_shopee": idProductShopee, // ✅ tambahan
        "id_product_lazada": idProductLazada, // ✅ tambahan
        "stok": stok.map((e) => e.toJson()).toList(),
      };

  LatestProduct copyWith({
    String? idProduct,
    String? namaProduct,
    String? productKategori,
    String? gambarProduct,
    String? deskripsiProduct,
    List<LatestProductStok>? stok,
    String? idProductShopee,
    String? idProductLazada,
  }) {
    return LatestProduct(
      idProduct: idProduct ?? this.idProduct,
      namaProduct: namaProduct ?? this.namaProduct,
      productKategori: productKategori ?? this.productKategori,
      gambarProduct: gambarProduct ?? this.gambarProduct,
      deskripsiProduct: deskripsiProduct ?? this.deskripsiProduct,
      stok: stok ?? this.stok,
      idProductShopee: idProductShopee ?? this.idProductShopee,
      idProductLazada: idProductLazada ?? this.idProductLazada,
    );
  }
}

class LatestProductStok {
  final String idStok;
  final String satuan;
  final int harga;
  final int stokQty;
  final String? idProductShopee; // ✅ tetap String
  final String? idProductLazada; // ✅ tetap String

  LatestProductStok({
    required this.idStok,
    required this.satuan,
    required this.harga,
    required this.stokQty,
    this.idProductShopee,
    this.idProductLazada,
  });

  factory LatestProductStok.fromJson(Map<String, dynamic> json) {
    print("TRACE LatestProductStok JSON: $json"); // 🔥 Trace debug

    return LatestProductStok(
      idStok: json['idStok'] ?? '',
      satuan: json['satuan'] ?? '',
      harga: json['harga'] ?? 0,
      stokQty: json['stokQty'] ?? 0,

      // ✅ FIX: gunakan camelCase sesuai JSON Postman
      idProductShopee: json['idProductShopee']?.toString(),
      idProductLazada: json['idProductLazada']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id_stok": idStok,
        "satuan": satuan,
        "harga": harga,
        "stokQty": stokQty,
        "id_product_shopee": idProductShopee,
        "id_product_lazada": idProductLazada,
      };

  /// ✅ copyWith untuk stok
  LatestProductStok copyWith({
    String? idStok,
    String? satuan,
    int? harga,
    int? stokQty,
    String? idProductShopee,
  }) {
    return LatestProductStok(
        idStok: idStok ?? this.idStok,
        satuan: satuan ?? this.satuan,
        harga: harga ?? this.harga,
        stokQty: stokQty ?? this.stokQty,
        idProductShopee: idProductShopee ?? this.idProductShopee,
        idProductLazada: idProductLazada ?? this.idProductLazada);
  }
}
