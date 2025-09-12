class LatestProduct {
  final String idProduct;
  final String namaProduct;
  final String productKategori;
  final String gambarProduct;
  final String deskripsiProduct;
  final List<LatestProductStok> stok;

  LatestProduct({
    required this.idProduct,
    required this.namaProduct,
    required this.productKategori,
    required this.gambarProduct,
    required this.deskripsiProduct,
    required this.stok,
  });

  factory LatestProduct.fromJson(Map<String, dynamic> json) {
    return LatestProduct(
      idProduct: json['id_product'] ?? '',
      namaProduct: json['nama_product'] ?? '',
      productKategori: json['product_kategori'] ?? '',
      gambarProduct: json['gambar_product'] ?? '',
      deskripsiProduct: json['deskripsi_product'] ?? '',
      stok: (json['stok'] as List? ?? [])
          .map((e) => LatestProductStok.fromJson(e))
          .toList(),
    );
  }
}

class LatestProductStok {
  final String satuan;
  final int harga;
  final int stokQty;

  LatestProductStok({
    required this.satuan,
    required this.harga,
    required this.stokQty,
  });

  factory LatestProductStok.fromJson(Map<String, dynamic> json) {
    return LatestProductStok(
      satuan: json['satuan'],
      harga: json['harga'],
      stokQty: json['stokQty'],
    );
  }

  Map<String, dynamic> toJson() => {
        "satuan": satuan,
        "harga": harga,
        "stokQty": stokQty,
      };
}
