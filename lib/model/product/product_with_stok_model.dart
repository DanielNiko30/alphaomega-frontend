class ProductWithStok {
  final String idProduct;
  final String namaProduct;
  final String? deskripsiProduct;
  final String productKategori;
  final String? gambarProduct;
  final List<StokItem> stokList;

  ProductWithStok({
    required this.idProduct,
    required this.namaProduct,
    this.deskripsiProduct,
    required this.productKategori,
    this.gambarProduct,
    required this.stokList,
  });

  factory ProductWithStok.fromJson(Map<String, dynamic> json) {
    return ProductWithStok(
      idProduct: json['id_product'] ?? '',
      namaProduct: json['nama_product'] ?? '',
      deskripsiProduct: json['deskripsi_product'],
      productKategori: json['product_kategori'] ?? '-',
      gambarProduct: json['gambar_product'],
      stokList: (json['stok_list'] as List<dynamic>? ?? [])
          .map((e) => StokItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_product': idProduct,
      'nama_product': namaProduct,
      'deskripsi_product': deskripsiProduct,
      'product_kategori': productKategori,
      'gambar_product': gambarProduct,
      'stok_list': stokList.map((e) => e.toJson()).toList(),
    };
  }
}

class StokItem {
  final String idStok;
  final String satuan;
  final int harga;
  final int hargaBeli;
  final int stok;

  StokItem({
    required this.idStok,
    required this.satuan,
    required this.harga,
    required this.hargaBeli,
    required this.stok,
  });

  factory StokItem.fromJson(Map<String, dynamic> json) {
    return StokItem(
      idStok: json['id_stok'] ?? '',
      satuan: json['satuan'] ?? '',
      harga: json['harga'] ?? 0,
      hargaBeli: json['harga_beli'] ?? 0,
      stok: json['stok'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_stok': idStok,
      'satuan': satuan,
      'harga': harga,
      'harga_beli': hargaBeli,
      'stok': stok,
    };
  }
}
