import 'stok_model.dart';

class Product {
  final String idProduct;
  final String productKategori;
  final String namaProduct;
  final String gambarProduct; // Base64 atau URL, default string kosong
  final String deskripsiProduct; // Deskripsi opsional, default string kosong
  final List<StokProduct> stokList; // ✅ Tambahan stok list

  Product({
    required this.idProduct,
    required this.productKategori,
    required this.namaProduct,
    this.gambarProduct = '',
    this.deskripsiProduct = '',
    required this.stokList,
  });

  /// Konversi dari JSON ke Model
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      idProduct: json['id_product'] ?? '', // default kosong
      productKategori: json['product_kategori'] ?? '',
      namaProduct: json['nama_product'] ?? '',
      gambarProduct: json['gambar_product'] ?? '', // aman terhadap null
      deskripsiProduct: json['deskripsi_product'] ?? '', // aman terhadap null
      stokList: (json['stok'] as List? ?? [])
          .map((item) => StokProduct.fromJson(item))
          .toList(),
    );
  }

  /// Konversi dari Model ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id_product': idProduct,
      'product_kategori': productKategori,
      'nama_product': namaProduct,
      'gambar_product': gambarProduct,
      'deskripsi_product': deskripsiProduct,
      'stok': stokList.map((stok) => stok.toJson()).toList(),
    };
  }

  void operator [](String other) {}
}
