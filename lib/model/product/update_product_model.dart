import 'dart:convert';
import 'package:frontend/model/product/stok_model.dart';

class UpdateProduct {
  final String idProduct;
  final String productKategori;
  final String namaProduct;
  final String? gambarProduct; // Bisa berupa URL atau base64
  final String? deskripsiProduct;
  final List<StokProduct> stokList;

  // ✅ Tambahan field untuk Shopee dan Lazada
  final String? idProductShopee;
  final String? idProductLazada;

  UpdateProduct({
    required this.idProduct,
    required this.productKategori,
    required this.namaProduct,
    this.gambarProduct,
    this.deskripsiProduct,
    required this.stokList,
    this.idProductShopee,
    this.idProductLazada,
  });

  /// 🔹 Factory untuk konversi dari JSON ke Model
  factory UpdateProduct.fromJson(Map<String, dynamic> json) {
    print("🔥 DEBUG: JSON dari API -> $json");

    return UpdateProduct(
      idProduct: json['idProduct'] as String? ?? '',
      productKategori: json['productKategori'] as String? ?? '',
      namaProduct: json['namaProduct'] as String? ?? '',
      gambarProduct: json['gambarProduct'] as String?,
      deskripsiProduct: json['deskripsiProduct'] as String?,
      idProductShopee: json['idProductShopee'] as String?, // ✅ tambahan
      idProductLazada: json['idProductLazada'] as String?, // ✅ tambahan
      stokList: (json['stokList'] as List<dynamic>?)?.map((item) {
            print("🔥 DEBUG: Parsing stok item -> $item");
            return StokProduct.fromJson(item as Map<String, dynamic>);
          }).toList() ??
          [],
    );
  }

  /// 🔹 Konversi dari Model ke JSON yang sesuai dengan backend
  Map<String, dynamic> toJson() {
    final stokJsonList = stokList.map((stok) => stok.toJson()).toList();

    print("DEBUG: stokList setelah dikonversi -> ${stokJsonList.runtimeType}");
    print("DEBUG: Isi stokList setelah dikonversi -> $stokJsonList");

    return {
      'id_product': idProduct,
      'product_kategori': productKategori,
      'nama_product': namaProduct,
      'gambar_product': gambarProduct ?? "",
      'deskripsi_product': deskripsiProduct ?? "",
      'id_product_shopee': idProductShopee ?? "", // ✅ tambahan
      'id_product_lazada': idProductLazada ?? "", // ✅ tambahan
      "stok_list":
          jsonEncode(stokJsonList), // ✅ sudah List<Map<String, dynamic>>
    };
  }

  /// ✨ Metode copyWith untuk update sebagian data tanpa mengubah objek asli
  UpdateProduct copyWith({
    String? idProduct,
    String? productKategori,
    String? namaProduct,
    String? gambarProduct,
    String? deskripsiProduct,
    List<StokProduct>? stokList,
    String? idProductShopee,
    String? idProductLazada,
  }) {
    return UpdateProduct(
      idProduct: idProduct ?? this.idProduct,
      productKategori: productKategori ?? this.productKategori,
      namaProduct: namaProduct ?? this.namaProduct,
      gambarProduct: gambarProduct ?? this.gambarProduct,
      deskripsiProduct: deskripsiProduct ?? this.deskripsiProduct,
      stokList: stokList ?? this.stokList,
      idProductShopee: idProductShopee ?? this.idProductShopee,
      idProductLazada: idProductLazada ?? this.idProductLazada,
    );
  }
}
