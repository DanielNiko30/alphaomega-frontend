class EditProductView {
  final String idProduct;
  final String productKategori;
  final String namaProduct;
  final String gambarProduct;
  final String deskripsiProduct;
  final List<Stok> stokList;
  final String kategori;

  EditProductView({
    required this.idProduct,
    required this.productKategori,
    required this.namaProduct,
    required this.gambarProduct,
    required this.deskripsiProduct,
    required this.stokList,
    required this.kategori,
  });

  // Factory method untuk decode dari JSON
  factory EditProductView.fromJson(Map<String, dynamic> json) {
    print("Response JSON: $json"); // Debugging respons penuh
    print("Data Stok dari JSON: ${json['stok']}"); // Cek isi 'stok'

    return EditProductView(
      idProduct: json['id_product'] ?? "",
      productKategori: json['product_kategori'] ?? "",
      namaProduct: json['nama_product'] ?? "",
      gambarProduct: json['gambar_product'] ?? "",
      deskripsiProduct: json['deskripsi_product'] ?? "",
      stokList: (json['stok'] != null && json['stok'] is List)
          ? (json['stok'] as List)
              .where((item) =>
                  item is Map<String, dynamic>) // Filter hanya objek valid
              .map((item) {
              print("Parsing Stok: $item"); // Debugging setiap item stok
              return Stok.fromJson(item);
            }).toList()
          : [], // Jika tidak valid, set sebagai list kosong
      kategori: json['kategori'] ?? "",
    );
  }

  // Metode untuk encode ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id_product': idProduct,
      'product_kategori': productKategori,
      'nama_product': namaProduct,
      'gambar_product': gambarProduct,
      'deskripsi_product': deskripsiProduct,
      'stok': stokList
          .map((stok) => stok.toJson())
          .toList(), // Konversi list stok ke JSON
      'kategori': kategori,
    };
  }
}

class Stok {
  final String? idStok;
  final String satuan;
  final int jumlah;
  final int harga;
  final String? idProductShopee; // ✅ Untuk integrasi Shopee
  final String? idProductLazada; // ✅ Untuk integrasi Lazada

  Stok({
    this.idStok,
    required this.satuan,
    required this.jumlah,
    required this.harga,
    required String stok,
    this.idProductShopee,
    this.idProductLazada,
  });

  // Factory method untuk decode dari JSON
  factory Stok.fromJson(Map<String, dynamic> json) {
    return Stok(
      idStok: json['id_stok'] ?? "",
      satuan: json['satuan'] ?? "", // Gunakan string kosong jika null
      jumlah: json['jumlah'] != null
          ? json['jumlah'] as int
          : 0, // Default ke 0 jika null
      harga: json['harga'] != null ? json['harga'] as int : 0,
      stok: '', // Default ke 0 jika null
      idProductShopee: json['id_product_shopee'] != null
          ? json['id_product_shopee'].toString()
          : null,
      idProductLazada: json['id_product_lazada'] != null
          ? json['id_product_lazada'].toString()
          : null,
    );
  }

  // Metode untuk encode ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id_stok': idStok,
      'satuan': satuan,
      'jumlah': jumlah,
      'harga': harga,
      'id_product_shopee': idProductShopee,
      'id_product_lazada': idProductLazada,
    };
  }
}
