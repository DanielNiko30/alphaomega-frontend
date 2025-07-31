import 'dart:convert';

import 'package:frontend/model/product/stok_model.dart';

class UpdateProduct {
  final String idProduct;
  final String productKategori;
  final String namaProduct;
  final String? gambarProduct; // Bisa berupa URL atau base64
  final String? deskripsiProduct;
  final List<Stok> stokList;

  UpdateProduct({
    required this.idProduct,
    required this.productKategori,
    required this.namaProduct,
    this.gambarProduct,
    this.deskripsiProduct,
    required this.stokList,
  });

  /// 🔹 Factory untuk konversi dari JSON ke Model
  factory UpdateProduct.fromJson(Map<String, dynamic> json) {
    print("🔥 DEBUG: JSON dari API -> $json");

    return UpdateProduct(
      idProduct: json['id_product'] as String? ?? '',
      productKategori: json['product_kategori'] as String? ?? '',
      namaProduct: json['nama_product'] as String? ?? '',
      gambarProduct: json['gambar_product'] as String?,
      deskripsiProduct: json['deskripsi_product'] as String?,
      stokList: (json['stok'] as List<dynamic>?)?.map((item) {
            print("🔥 DEBUG: Parsing stok item -> $item");
            return Stok.fromJson(item as Map<String, dynamic>);
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
      "stok_list": jsonEncode(
          stokJsonList), // ✅ Seharusnya sudah List<Map<String, dynamic>>
    };
  }

  /// ✨ Metode copyWith untuk update sebagian data tanpa mengubah objek asli
  UpdateProduct copyWith({
    String? idProduct,
    String? productKategori,
    String? namaProduct,
    String? gambarProduct,
    String? deskripsiProduct,
    List<Stok>? stokList,
  }) {
    return UpdateProduct(
      idProduct: idProduct ?? this.idProduct,
      productKategori: productKategori ?? this.productKategori,
      namaProduct: namaProduct ?? this.namaProduct,
      gambarProduct: gambarProduct ?? this.gambarProduct,
      deskripsiProduct: deskripsiProduct ?? this.deskripsiProduct,
      stokList: stokList ?? this.stokList,
    );
  }
}
