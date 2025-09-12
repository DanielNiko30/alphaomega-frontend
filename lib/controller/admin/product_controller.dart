import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:frontend/model/product/update_product_model.dart';
import 'package:frontend/presentation/admin/masterBarang/editProduct/bloc/edit_product_event.dart';
import 'package:http/http.dart' as http;
import '../../model/product/konversi_stok.dart';
import '../../model/product/latest_product_model.dart';
import '../../model/product/product_model.dart';
import '../../model/product/edit_productView_model.dart';
import '../../model/product/update_product_model.dart';
import '../../model/product/add_product_model.dart';
import '../../model/product/kategori_model.dart';

class ProductController {
  static const String baseUrl = "https://tokalphaomegaploso.my.id/api/product";

  // Ambil semua produk
  static Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil data produk");
    }
  }

  // Ambil produk berdasarkan ID
  static Future<EditProductView> getProductById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        return EditProductView.fromJson(jsonData);
      } catch (e) {
        throw Exception(
            "Gagal memuat produk: Format data tidak sesuai (${e.toString()})");
      }
    } else if (response.statusCode == 404) {
      throw Exception("Produk tidak ditemukan");
    } else {
      throw Exception(
          "Terjadi kesalahan (${response.statusCode}): ${response.body}");
    }
  }

  // Tambah produk (dengan gambar dalam Base64)
  static Future<bool> createProduct(AddProduct product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(product.toJson()),
    );

    return response.statusCode == 201;
  }

  static Future<Response> addProduct(FormData formData) async {
    try {
      final response = await Dio().post(
        baseUrl,
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      return response; // Kembalikan response untuk dicek di BLoC
    } catch (e) {
      throw Exception("Gagal menambahkan produk: ${e.toString()}");
    }
  }

  // Update produk
  static Future<Response> updateProduct({
    required String id,
    required UpdateProduct product,
    Uint8List? imageBytes,
  }) async {
    try {
      final List<Map<String, dynamic>> stokJsonList =
          product.stokList.map((stok) => stok.toJson()).toList();

      FormData formData = FormData.fromMap({
        "nama_product": product.namaProduct,
        "product_kategori": product.productKategori,
        "deskripsi_product": product.deskripsiProduct ?? "",
        "stok_list": jsonEncode(
            stokJsonList), // Pastikan dikirim dalam format JSON String
      });

      if (imageBytes != null) {
        formData.files.add(MapEntry(
          "gambar_product",
          MultipartFile.fromBytes(imageBytes, filename: "product.jpg"),
        ));
      }

      final response = await Dio().put(
        "$baseUrl/$id",
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey("idProduct")) {
          return response;
        } else {
          throw Exception("⚠️ Response API tidak sesuai! ${response.data}");
        }
      } else {
        throw Exception("⚠️ Gagal update produk: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("⚠️ Error update produk: ${e.toString()}");
    }
  }

  // Hapus produk
  static Future<bool> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    return response.statusCode == 200;
  }

  static Future<List<Kategori>> fetchKategori() async {
    final response = await http.get(Uri.parse('$baseUrl/kategori'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Kategori.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data kategori');
    }
  }

  static Future<bool> addKategori(String namaKategori) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kategori'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama_kategori": namaKategori,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data["message"] ?? "Gagal menambahkan kategori");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  static Future<List<Stok>> getSatuanByProductId(String productId) async {
    final response = await http.get(Uri.parse("$baseUrl/$productId/satuan"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Stok.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return []; // Jika tidak ada satuan, kembalikan list kosong
    } else {
      throw Exception("Gagal mengambil satuan produk");
    }
  }

  static Future<List<Product>> searchProductByName(String name) async {
    final response = await http.get(Uri.parse("$baseUrl/search/$name"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mencari produk dengan nama: $name");
    }
  }

  static Future<KonversiStok> konversiStok(KonversiStok request) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/konversi-stok"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return KonversiStok.fromJson(jsonDecode(response.body));
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal melakukan konversi stok');
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat konversi stok: $e");
    }
  }

  static Future<LatestProduct> getLatestProduct() async {
    final response = await http.get(Uri.parse("$baseUrl/latest"));

    print("==== [DEBUG] getLatestProduct Response ====");
    print("Status Code: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (jsonData['success'] == true && jsonData['data'] != null) {
        return LatestProduct.fromJson(
            jsonData['data']); // ✅ Ambil data dari key `data`
      } else {
        throw Exception(jsonData['message'] ?? "Gagal memuat produk terbaru");
      }
    } else {
      throw Exception("Gagal mengambil produk terbaru: ${response.statusCode}");
    }
  }
}
