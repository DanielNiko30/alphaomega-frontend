import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../utils/download_pdf_stub.dart'
    if (dart.library.html) '../../utils/download_pdf_web.dart';
import '../../model/product/lazada_model.dart';

class LazadaController {
  final String baseUrl = 'https://tokalphaomegaploso.my.id/api/lazada';

  /// === GET CATEGORY TREE ===
  Future<Map<String, dynamic>> getCategoryTree() async {
    final url = Uri.parse('$baseUrl/categories');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Gagal mengambil category tree Lazada: ${response.body}',
      );
    }
  }

  /// === GET CATEGORY ATTRIBUTES ===
  Future<Map<String, dynamic>> getCategoryAttributes(String categoryId) async {
    final url = Uri.parse('$baseUrl/category/attribute/$categoryId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Gagal mengambil atribut kategori Lazada: ${response.body}',
      );
    }
  }

  /// === GET PRODUCT ITEM ===
  Future<Map<String, dynamic>> getProductItem(String itemId) async {
    final url = Uri.parse('$baseUrl/product/item?item_id=$itemId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Gagal mengambil produk Lazada: ${response.body}',
      );
    }
  }

  /// === CREATE PRODUCT LAZADA ===
  Future<Map<String, dynamic>> createProductLazada({
    required String idProduct,
    required String categoryId,
    required String selectedUnit,
    required Map<String, dynamic> attributes,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/create-product/$idProduct');

      final body = {
        "category_id": categoryId,
        "selected_unit": selectedUnit,
        "attributes": attributes,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Gagal membuat produk Lazada [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal membuat produk Lazada: $e');
    }
  }

  /// === UPDATE PRODUCT LAZADA ===
  Future<Map<String, dynamic>> updateProductLazada({
    required String idProduct,
    required String categoryId,
    required String selectedUnit,
    required Map<String, dynamic> attributes,
    bool updateImage = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/update-product/$idProduct');

      final body = {
        "category_id": categoryId,
        "selected_unit": selectedUnit,
        "update_image": updateImage,
        "attributes": attributes,
      };

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Gagal update produk Lazada [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal update produk Lazada: $e');
    }
  }

  Future<Map<String, dynamic>> getFullOrderDetailLazada(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/order/detail?order_id=$orderId"),
        headers: {"Content-Type": "application/json"},
      );

      print("🔹 [LazadaController] Response status: ${response.statusCode}");
      print("🔹 [LazadaController] Raw response body:");
      print(response.body); // 👈 log seluruh isi body untuk debug

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);

        if (jsonBody is Map<String, dynamic>) {
          return jsonBody;
        } else {
          print("⚠️ Response bukan Map<String, dynamic>");
          throw Exception("Format response tidak valid (bukan object JSON)");
        }
      } else {
        throw Exception(
            "Gagal ambil detail order (status: ${response.statusCode})");
      }
    } catch (e, stack) {
      print("❌ Error di getFullOrderDetailLazada: $e");
      print(stack);
      rethrow;
    }
  }

  Future<List<LazadaOrder>> getPendingOrders() async {
    final url = Uri.parse('$baseUrl/orders/full');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final ordersList = (jsonData['data'] as List<dynamic>? ?? []);
      return ordersList.map((e) => LazadaOrder.fromJson(e)).toList();
    } else {
      throw Exception(
        'Gagal mengambil Pending Orders Lazada: ${response.body}',
      );
    }
  }

  /// === GET READY TO SHIP ORDERS ===
  Future<List<LazadaOrder>> getReadyToShipOrders() async {
    final url = Uri.parse('$baseUrl/ready/orders/full');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final ordersList = (jsonData['data'] as List<dynamic>? ?? []);
      return ordersList.map((e) => LazadaOrder.fromJson(e)).toList();
    } else {
      throw Exception(
        'Gagal mengambil Ready To Ship Orders Lazada: ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> readyToShipLazada(String orderId) async {
    try {
      final url = Uri.parse('$baseUrl/lazada/ready-to-ship');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"order_id": orderId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "success": data["success"] ?? false,
          "message": data["message"] ?? "Tidak ada pesan",
          "data": data["data"],
        };
      } else {
        return {
          "success": false,
          "message":
              "Gagal mengubah status pesanan menjadi Ready To Ship: ${response.body}",
        };
      }
    } catch (e) {
      throw Exception('Gagal request Ready To Ship Lazada: $e');
    }
  }

  Future<String?> printResiLazada(String orderId) async {
    try {
      final url = Uri.parse('$baseUrl/print-resi');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"order_id": orderId}), // 🔹 pake order_id sekarang
      );

      final jsonRes = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && jsonRes['pdf_base64'] != null) {
        return jsonRes['pdf_base64']; // ✅ backend kirim base64 string
      } else {
        throw Exception(jsonRes['message'] ?? 'Gagal mengambil PDF');
      }
    } catch (e) {
      throw Exception('Gagal ambil AWB dari Lazada: $e');
    }
  }

  static Future<void> downloadResi(Uint8List bytes, String filename) async {
    await downloadPdf(bytes, filename);
  }
}
