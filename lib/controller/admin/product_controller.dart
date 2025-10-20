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
import '../../model/product/product_with_stok_model.dart';
import '../../model/product/stok_model.dart' as stokModel;
import '../../model/product/update_product_model.dart';
import '../../model/product/add_product_model.dart';
import '../../model/product/kategori_model.dart';

class ProductController {
  static const String baseUrl = "https://tokalphaomegaploso.my.id/api/product";

  static Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil data produk");
    }
  }

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

  static Future<Response> updateProduct({
    required String id,
    required UpdateProduct product,
    Uint8List? imageBytes,
  }) async {
    try {
      // Pastikan stokList selalu diubah ke Map sebelum di-encode
      final List<Map<String, dynamic>> stokJsonList =
          product.stokList.map((item) {
        if (item is stokModel.StokProduct) {
          // Convert model ke Map
          return item.toJson();
        } else {
          throw Exception("Tipe stok tidak dikenal: ${item.runtimeType}");
        }
      }).toList(); // Pastikan hasil akhir benar-benar List<Map<String, dynamic>>

      print("DEBUG: Data stok yang dikirim ke backend -> $stokJsonList");

      final formData = FormData.fromMap({
        "nama_product": product.namaProduct,
        "product_kategori": product.productKategori,
        "deskripsi_product": product.deskripsiProduct ?? "",
        "stok_list": jsonEncode(stokJsonList), // Encode ke JSON
      });

      // Jika ada gambar
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

      // Convert balik supaya BLoC tetap menerima List<Stok>
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final resData = Map<String, dynamic>.from(response.data);

        if (resData.containsKey("stok_list") && resData["stok_list"] is List) {
          resData["stok_list"] = (resData["stok_list"] as List)
              .map((e) =>
                  stokModel.StokProduct.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }

        return Response(
          data: resData,
          statusCode: response.statusCode,
          requestOptions: response.requestOptions,
        );
      } else {
        throw Exception("Response API tidak valid: ${response.data}");
      }
    } catch (e, stack) {
      print("ERROR updateProduct: $e\n$stack");
      throw Exception("⚠️ Error update produk: ${e.toString()}");
    }
  }

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

  static Future<bool> updateKategori(String idKategori, String namaBaru) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/kategori/$idKategori'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama_kategori": namaBaru,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data["message"] ?? "Gagal memperbarui kategori");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat update kategori: $e");
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

  static Future<bool> deleteStok(String idStok) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/stok/$idStok"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print("✅ Stok $idStok berhasil di-nonaktifkan");
        return true;
      } else if (response.statusCode == 404) {
        print("⚠️ Stok tidak ditemukan");
        return false;
      } else {
        print("❌ Gagal delete stok: ${response.statusCode} | ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error deleteStok: $e");
      return false;
    }
  }

  static Future<LatestProduct> getLatestProduct({String? productId}) async {
    // 🔹 Tentukan URL: pakai query param id_product jika ada
    final url = productId != null && productId.isNotEmpty
        ? Uri.parse("$baseUrl/latest?id_product=$productId")
        : Uri.parse("$baseUrl/latest");

    print("==== [DEBUG] getLatestProduct ====");
    print("Request URL: $url");

    final response = await http.get(url);

    print("==== [DEBUG] getLatestProduct Response ====");
    print("Status Code: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (jsonData['success'] == true && jsonData['data'] != null) {
        return LatestProduct.fromJson(jsonData['data']);
      } else {
        throw Exception(jsonData['message'] ?? "Gagal memuat produk");
      }
    } else {
      throw Exception(
          "Gagal mengambil produk: ${response.statusCode} | ${response.body}");
    }
  }

  static Future<List<ProductWithStok>> getAllProductsWithStok() async {
    final url = Uri.parse("$baseUrl/with-stok");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        if (jsonBody["success"] == true && jsonBody["data"] != null) {
          List<dynamic> data = jsonBody["data"];
          return data.map((e) => ProductWithStok.fromJson(e)).toList();
        } else {
          throw Exception(jsonBody["message"] ?? "Data produk kosong");
        }
      } else {
        throw Exception(
            "Gagal mengambil data produk: ${response.statusCode} | ${response.body}");
      }
    } catch (e) {
      print("❌ Error getAllProductsWithStok: $e");
      throw Exception("Terjadi kesalahan saat memuat produk dengan stok: $e");
    }
  }
}
