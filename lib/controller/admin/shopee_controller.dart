import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/model/product/shope_model.dart';

import '../../model/product/shopee_product_info.dart';

class ShopeeController {
  static const String baseUrl = "https://tokalphaomegaploso.my.id/api/shopee";

  /// 1️⃣ Callback Shopee (jarang dipanggil manual, biasanya Shopee yang memanggil ini)
  static Future<Map<String, dynamic>> shopeeCallback(
      String code, String shopId) async {
    final url = Uri.parse('$baseUrl/callback?code=$code&shop_id=$shopId');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal melakukan Shopee callback");
    }
  }

  /// 2️⃣ Ambil daftar produk yang sudah terhubung dengan Shopee
  static Future<List<ShopeeItem>> getItemList() async {
    final response = await http.get(Uri.parse('$baseUrl/items'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Pastikan format benar
      if (data['shopee_response'] == null ||
          data['shopee_response']['item'] == null) {
        throw Exception(
            "Format response Shopee tidak valid: ${data.toString()}");
      }

      final List<dynamic> items = data['shopee_response']['item'] ?? [];
      return items.map((e) => ShopeeItem.fromJson(e)).toList();
    } else {
      throw Exception(
          "Gagal mengambil item list dari Shopee (${response.statusCode})");
    }
  }

  /// 3️⃣ Ambil daftar kategori Shopee
  static Future<List<ShopeeCategory>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['data'] == null || data['data'] is! List) {
        throw Exception(
            "Format kategori Shopee tidak valid: ${data.toString()}");
      }

      return (data['data'] as List)
          .map((e) => ShopeeCategory.fromJson(e))
          .toList();
    } else {
      throw Exception(
          "Gagal mengambil kategori Shopee (${response.statusCode})");
    }
  }

  /// 4️⃣ Ambil daftar logistic Shopee
  static Future<List<ShopeeLogistic>> getLogistics() async {
    final response = await http.get(Uri.parse('$baseUrl/logistics'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['channels'] == null || data['channels'] is! List) {
        throw Exception(
            "Format logistic Shopee tidak valid: ${data.toString()}");
      }

      return (data['channels'] as List)
          .map((e) => ShopeeLogistic.fromJson(e))
          .toList();
    } else {
      throw Exception(
          "Gagal mengambil logistic Shopee (${response.statusCode})");
    }
  }

  /// 5️⃣ Ambil brand list berdasarkan kategori
  static Future<List<ShopeeBrand>> getBrands(int categoryId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/brands'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"category_id": categoryId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['shopee_response'] == null ||
          data['shopee_response']['brands'] == null) {
        throw Exception("Format brand Shopee tidak valid: ${data.toString()}");
      }

      final List<dynamic> brands = data['shopee_response']['brands'] ?? [];
      return brands.map((e) => ShopeeBrand.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil brand Shopee (${response.statusCode})");
    }
  }

  /// 6️⃣ Create product Shopee
  static Future<Map<String, dynamic>> createProduct({
    required String idProduct,
    required String itemSku,
    required num weight,
    required Map<String, dynamic> dimension,
    required String condition,
    required int logisticId,
    required int categoryId,
    required String brandName,
    int? brandId,
    String? selectedUnit,
  }) async {
    final url = Uri.parse('$baseUrl/products/$idProduct');
    final payload = {
      "item_sku": itemSku,
      "weight": weight,
      "dimension": dimension,
      "condition": condition,
      "logistic_id": logisticId,
      "category_id": categoryId,
      "brand_name": brandName,
      "brand_id": brandId ?? 0,
      "selected_unit": selectedUnit,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // Success
      return data;
    } else {
      // Jika gagal, lempar error dari backend
      final message = data['message'] ?? "Gagal menambahkan produk ke Shopee";
      throw Exception(message);
    }
  }

  static Future<Map<String, dynamic>> editShopeeProduct({
    required String itemId,
    required String itemSku,
    required num weight,
    required int categoryId,
    required int length,
    required int width,
    required int height,
    required String condition,
    required String selectedUnit,
    required int logisticId,
    int brandId = 0,
    String brandName = "No Brand",
  }) async {
    final url = Uri.parse(
        '$baseUrl/product/update/$itemId'); // Route backend edit product Shopee

    final payload = {
      "weight": weight,
      "category_id": categoryId,
      "dimension": {
        "height": height,
        "length": length,
        "width": width,
      },
      "condition": condition,
      "item_sku": itemSku,
      "brand_id": brandId,
      "brand_name": brandName,
      "selected_unit": selectedUnit,
      "logistic_id": logisticId,
    };

    print("=== DEBUG Edit Product Payload ===");
    print(payload);

    final resp = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    final data = jsonDecode(resp.body);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Gagal edit product Shopee (${resp.statusCode})',
      );
    }
  }

  /// Ambil detail base info dari Shopee via backend
  static Future<ShopeeProductInfo> getShopeeProductInfo({
    required String idProduct,
    required String satuan,
  }) async {
    final url = Uri.parse(
        '$baseUrl/product/item-info/$idProduct'); // id_product di path
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body:
          jsonEncode({"satuan": satuan.toUpperCase()}), // pastikan huruf besar
    );

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      if (body['success'] == true) {
        // ambil dari field 'data' sesuai backend
        return ShopeeProductInfo.fromJson(body['data']);
      } else {
        throw Exception('Error backend: ${body['message']}');
      }
    } else if (resp.statusCode == 404) {
      throw Exception('Produk atau stok tidak ditemukan (${resp.statusCode})');
    } else {
      throw Exception(
          'Gagal ambil info product (${resp.statusCode}) : ${resp.body}');
    }
  }
}
