import 'dart:convert';

import '../product/stok_model.dart';

class AddProduct {
  final String? idProduct;
  final String productKategori;
  final String namaProduct;
  final dynamic? gambarProduct; // Base64 atau URL
  final List<String> harga; // Ubah ke List<String> sesuai dengan DB
  final String? deskripsiProduct;
  final List<Stok> stokList;

  AddProduct({
    this.idProduct,
    required this.productKategori,
    required this.namaProduct,
    this.gambarProduct,
    required this.harga, // Ubah harga_product -> harga
    this.deskripsiProduct,
    required this.stokList,
  });

  // Konversi dari JSON ke Model
  factory AddProduct.fromJson(Map<String, dynamic> json) {
    return AddProduct(
      idProduct: json['id_product'],
      productKategori: json['product_kategori'],
      namaProduct: json['nama_product'],
      gambarProduct: json['gambar_product'],
      harga: List<String>.from(json['harga']), // Sesuai dengan DB
      deskripsiProduct: json['deskripsi_product'],
      stokList:
          (json['stok'] as List).map((item) => Stok.fromJson(item)).toList(),
    );
  }

  // Konversi dari Model ke JSON (untuk POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'id_product': idProduct,
      'product_kategori': productKategori,
      'nama_product': namaProduct,
      'gambar_product': gambarProduct,
      'harga': jsonEncode(harga), // <- INI WAJIB: array jadi JSON string
      'deskripsi_product': deskripsiProduct,
      'satuan_stok': jsonEncode(
          stokList.map((stok) => stok.satuan).toList()), // <- juga encode array
    };
  }
}
