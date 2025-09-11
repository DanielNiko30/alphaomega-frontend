import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/model/product/shope_model.dart';

class ShopeeController {
  static const String baseUrl = "https://tokalphaomegaploso.my.id/api/shopee";

  // 1️⃣ Callback Shopee (untuk debug / tidak dipanggil manual biasanya)
  static Future<Map<String, dynamic>> shopeeCallback(String code, String shopId) async {
    final url = Uri.parse('$baseUrl/callback?code=$code&shop_id=$shopId');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal melakukan Shopee callback");
    }
  }

  // 2️⃣ Ambil daftar item Shopee
  static Future<List<ShopeeItem>> getItemList() async {
    final response = await http.get(Uri.parse('$baseUrl/items'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> items = data['shopee_response']['item'] ?? [];
      return items.map((e) => ShopeeItem.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil item list dari Shopee");
    }
  }

  // 3️⃣ Ambil kategori Shopee
  static Future<List<ShopeeCategory>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> categories = data['data'] ?? [];
      return categories.map((e) => ShopeeCategory.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil kategori Shopee");
    }
  }

  // 4️⃣ Ambil logistic list
  static Future<List<ShopeeLogistic>> getLogistics() async {
    final response = await http.get(Uri.parse('$baseUrl/logistics'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> channels = data['channels'] ?? [];
      return channels.map((e) => ShopeeLogistic.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil logistic Shopee");
    }
  }

  // 5️⃣ Ambil brand list
  static Future<List<ShopeeBrand>> getBrands(int categoryId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/brands'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"category_id": categoryId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> brands = data['shopee_response']['brands'] ?? [];
      return brands.map((e) => ShopeeBrand.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil brand Shopee");
    }
  }

  // 6️⃣ Create product Shopee
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
    final response = await http.post(
      Uri.parse('$baseUrl/create/$idProduct'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "item_sku": itemSku,
        "weight": weight,
        "dimension": dimension,
        "condition": condition,
        "logistic_id": logisticId,
        "category_id": categoryId,
        "brand_name": brandName,
        "brand_id": brandId ?? 0,
        "selected_unit": selectedUnit,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? "Gagal menambahkan produk ke Shopee");
    }
  }
}
