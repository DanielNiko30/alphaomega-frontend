import 'package:frontend/model/product/shope_model.dart';

class ShopeeProductInfo {
  final int itemId;
  final String itemSku;
  final double weight;
  final int length;
  final int width;
  final int height;
  final int categoryId;
  final String condition;
  final String brandName; // ✅ tambahkan brandName
  final List<ShopeeLogistic> logistics;

  ShopeeProductInfo({
    required this.itemId,
    required this.itemSku,
    required this.weight,
    required this.length,
    required this.width,
    required this.height,
    required this.categoryId,
    required this.condition,
    required this.brandName, // ✅ inisialisasi brandName
    required this.logistics,
  });

  factory ShopeeProductInfo.fromJson(Map<String, dynamic> json) {
    final dimension = json['dimension'] ?? {};
    final logisticsJson = json['logistic_info'] as List<dynamic>? ?? [];

    return ShopeeProductInfo(
      itemId: json['item_id'] ?? 0,
      itemSku: json['item_sku'] ?? '',
      weight: double.tryParse(json['weight']?.toString() ?? '0') ?? 0,
      length: dimension['package_length'] ?? 0,
      width: dimension['package_width'] ?? 0,
      height: dimension['package_height'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      condition: json['condition'] ?? 'NEW',
      brandName: json['brand_name'] ?? 'No Brand', // ✅ ambil dari backend
      logistics: logisticsJson
          .map((e) => ShopeeLogistic.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
