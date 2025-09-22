class ShopeeProductInfo {
  final String itemId; // ID besar aman pakai String
  final int weight;
  final String categoryId; // ID besar aman pakai String
  final int length;
  final int width;
  final int height;
  final String condition;
  final String itemSku;
  final String brandName;

  ShopeeProductInfo({
    required this.itemId,
    required this.weight,
    required this.categoryId,
    required this.length,
    required this.width,
    required this.height,
    required this.condition,
    required this.itemSku,
    required this.brandName,
  });

  factory ShopeeProductInfo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    final dimension = json['dimension'] ?? {};

    return ShopeeProductInfo(
      itemId: json['item_id'].toString(),
      weight: parseInt(json['weight']),
      categoryId: json['category_id'].toString(),
      length: parseInt(dimension['package_length']),
      width: parseInt(dimension['package_width']),
      height: parseInt(dimension['package_height']),
      condition: json['condition'] ?? 'UNKNOWN',
      itemSku: json['item_sku'] ?? '',
      brandName: json['brand']?['original_brand_name'] ?? 'No Brand',
    );
  }
}
