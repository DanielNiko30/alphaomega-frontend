class ShopeeCategory {
  final int categoryId;
  final String categoryName;
  final int? parentCategoryId; // tetap sesuai permintaanmu
  final List<ShopeeCategory> children;

  ShopeeCategory({
    required this.categoryId,
    required this.categoryName,
    this.parentCategoryId,
    this.children = const [],
  });

  factory ShopeeCategory.fromJson(Map<String, dynamic> json) {
    return ShopeeCategory(
      categoryId: json['category_id'] ?? 0,
      categoryName: json['display_category_name'] ?? '', // ambil dari field ini
      parentCategoryId: json['parent_category_id'], // ambil dari field ini
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => ShopeeCategory.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ShopeeLogistic {
  final int id;
  final String name;
  final bool enabled;
  final int maskChannelId; // baru

  ShopeeLogistic({
    required this.id,
    required this.name,
    required this.enabled,
    required this.maskChannelId,
  });

  factory ShopeeLogistic.fromJson(Map<String, dynamic> json) {
    return ShopeeLogistic(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      enabled: json['enabled'] ?? true,
      maskChannelId: json['mask_channel_id'] ?? 0,
    );
  }
}

class ShopeeBrand {
  final int brandId;
  final String brandName;

  ShopeeBrand({
    required this.brandId,
    required this.brandName,
  });

  factory ShopeeBrand.fromJson(Map<String, dynamic> json) {
    return ShopeeBrand(
      brandId: json['brand_id'] ?? 0,
      brandName: json['original_brand_name'] ?? 'No Brand',
    );
  }
}

class ShopeeItem {
  final int itemId;
  final String itemName;

  ShopeeItem({
    required this.itemId,
    required this.itemName,
  });

  factory ShopeeItem.fromJson(Map<String, dynamic> json) {
    return ShopeeItem(
      itemId: json['item_id'],
      itemName: json['item_name'],
    );
  }
}
