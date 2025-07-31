class Product {
  final String idProduct;
  final String productKategori;
  final String namaProduct;
  final String? gambarProduct; // Base64 atau URL
  final String? deskripsiProduct;

  Product({
    required this.idProduct,
    required this.productKategori,
    required this.namaProduct,
    this.gambarProduct,
    this.deskripsiProduct,
  });

  // Konversi dari JSON ke Model
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      idProduct: json['id_product'],
      productKategori: json['product_kategori'],
      namaProduct: json['nama_product'],
      gambarProduct: json['gambar_product'], // Base64 atau URL
      deskripsiProduct: json['deskripsi_product'],
    );
  }

  // Konversi dari Model ke JSON (untuk POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'id_product': idProduct,
      'product_kategori': productKategori,
      'nama_product': namaProduct,
      'gambar_product': gambarProduct,
      'deskripsi_product': deskripsiProduct,
    };
  }
}
