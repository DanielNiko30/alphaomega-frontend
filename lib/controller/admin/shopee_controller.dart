import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/model/product/shope_model.dart';
import 'package:http/http.dart' as box;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../model/orderOnline/ship_order_response_model.dart';
import '../../model/orderOnline/shipping_document_model.dart';
import '../../model/orderOnline/shipping_parameter_model.dart';
import '../../model/orderOnline/shopee_order_model.dart';
import '../../model/product/shopee_product_info.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../utils/download_pdf_stub.dart'
    if (dart.library.html) '../../utils/download_pdf_web.dart';

class ShopeeController {
  static const String baseUrl = "https://tokalphaomegaploso.my.id/api/shopee";
  final box = GetStorage();

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

  static Future<ShopeeProductInfo> getShopeeProductInfo({
    required String idProduct,
    required String satuan,
  }) async {
    final url = Uri.parse('$baseUrl/product/item-info/$idProduct');
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"satuan": satuan.toUpperCase()}),
    );

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      if (body['success'] == true) {
        // mapping field 'data' ke ShopeeProductInfo dengan parsing logistics aman
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

  static Future<List<dynamic>> getOrders() async {
    final url = Uri.parse('$baseUrl/orders');
    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);

      if (body['success'] != true || body['data'] == null) {
        throw Exception("Response getOrders tidak valid: ${resp.body}");
      }

      return body['data']['order_list'] ?? [];
    } else {
      throw Exception(
          'Gagal mengambil orders (${resp.statusCode}): ${resp.body}');
    }
  }

  Future<List<ShopeeOrder>> fetchShippedOrders() async {
    final url = Uri.parse("$baseUrl/orders/shipped");
    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
      // "Authorization": "Bearer <TOKEN>", // kalau ada auth
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final ordersJson = data['data']['order_list'] as List;
        return ordersJson.map((e) => ShopeeOrder.fromJson(e)).toList();
      } else {
        throw Exception(data['message'] ?? "Gagal mengambil data");
      }
    } else {
      throw Exception("Error server: ${response.statusCode}");
    }
  }

  static Future<Map<String, dynamic>> getOrderDetail(String orderSn) async {
    final url = Uri.parse('$baseUrl/order-detail?order_sn_list=$orderSn');
    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);

      if (body['success'] != true || body['data'] == null) {
        print("📦 Response tidak valid: ${resp.body}");
        throw Exception("Response getOrderDetail tidak valid");
      }

      final data = body['data'];

      // ✅ Cek apakah data adalah List dan berisi elemen
      if (data is List &&
          data.isNotEmpty &&
          data.first is Map<String, dynamic>) {
        return data.first as Map<String, dynamic>;
      } else {
        print("📦 Format data tidak sesuai: ${body['data']}");
        throw Exception("Format data tidak sesuai (data kosong atau salah)");
      }
    } else {
      throw Exception(
        'Gagal mengambil detail order (${resp.statusCode}): ${resp.body}',
      );
    }
  }

  static Future<List<dynamic>> getFullOrders() async {
    final url = Uri.parse('$baseUrl/orders/full');
    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);

      if (body['success'] != true || body['data'] == null) {
        throw Exception("Response getFullOrders tidak valid: ${resp.body}");
      }

      return body['data'] ?? [];
    } else {
      throw Exception(
          'Gagal mengambil orders (${resp.statusCode}): ${resp.body}');
    }
  }

  Future<List<ShopeeOrder>> getShippedOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/orders/shipped/full'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List ordersJson = data['data'] ?? [];
        return ordersJson.map((e) => ShopeeOrder.fromJson(e)).toList();
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil orders shipped');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<List<ShopeeOrder>> fetchShopeeOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders/full'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final List<dynamic> orders = data['data'];
          return orders.map((json) => ShopeeOrder.fromJson(json)).toList();
        } else {
          throw Exception(
              data['message'] ?? 'Gagal mengambil data order Shopee');
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetchShopeeOrders: $e");
    }
  }

  Future<ShippingParameterModel?> getShippingParameter(String orderSn) async {
    try {
      final url = Uri.parse('$baseUrl/shipping-parameter');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"order_sn": orderSn}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShippingParameterModel.fromJson(data['data']);
      } else {
        print('❌ Gagal mengambil shipping parameter: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error getShippingParameter: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> setPickup({
    required String orderSn,
    required int addressId,
    required String pickupTimeId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/ship-order/pickup');

      // 🔹 Ambil token dari storage dan trim
      final token = box.read("token")?.toString().trim();
      if (token == null || token.isEmpty) {
        print('❌ Token tidak ditemukan, user harus login ulang');
        return null;
      }

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "order_sn": orderSn,
          "address_id": addressId,
          "pickup_time_id": pickupTimeId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        print(
            '❌ Unauthorized, token mungkin kadaluarsa atau salah: ${response.body}');
        return null;
      } else {
        print('❌ Gagal set pickup: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error setPickup: $e');
      return null;
    }
  }

  /// ====== SET DROPOFF ======
  Future<Map<String, dynamic>?> setDropoff(String orderSn) async {
    try {
      final url = Uri.parse('$baseUrl/ship-order/dropoff');

      // 🔹 Ambil token dari storage dan trim
      final token = box.read("token")?.toString().trim();
      if (token == null || token.isEmpty) {
        print('❌ Token tidak ditemukan, user harus login ulang');
        return null;
      }

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"order_sn": orderSn}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        print(
            '❌ Unauthorized, token mungkin kadaluarsa atau salah: ${response.body}');
        return null;
      } else {
        print('❌ Gagal set dropoff: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error setDropoff: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getShippingDocument({
    required String orderSn,
    required String packageNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/print-resi'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "order_sn": orderSn,
        "package_number": packageNumber,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // pastikan ini Map<String, dynamic>
      return data['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Gagal ambil shipping document');
    }
  }

  static Future<Uint8List> printShopeeResi(String orderSn) async {
    final url = Uri.parse('$baseUrl/print-resi');
    print("📦 Request print resi Shopee untuk order_sn: $orderSn");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"order_sn": orderSn}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["success"] == true && data["pdf_base64"] != null) {
        final pdfBytes = base64Decode(data["pdf_base64"]);
        print("✅ Resi PDF diterima dari server (${pdfBytes.length} bytes)");
        return pdfBytes;
      } else {
        throw Exception("❌ Gagal decode PDF dari server (${data["message"]})");
      }
    } else {
      throw Exception("❌ Gagal ambil resi (${response.statusCode})");
    }
  }

  /// Fungsi auto-download sesuai platform
  static Future<void> downloadResi(Uint8List bytes, String filename) async {
    await downloadPdf(bytes, filename);
  }
}
