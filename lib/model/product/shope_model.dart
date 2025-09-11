class ShopeeCategory {
  final int categoryId;
  final String categoryName;

  ShopeeCategory({
    required this.categoryId,
    required this.categoryName,
  });

  factory ShopeeCategory.fromJson(Map<String, dynamic> json) {
    return ShopeeCategory(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
    );
  }
}

class ShopeeLogistic {
  final int id;
  final String name;
  final bool enabled;

  ShopeeLogistic({
    required this.id,
    required this.name,
    required this.enabled,
  });

  factory ShopeeLogistic.fromJson(Map<String, dynamic> json) {
    return ShopeeLogistic(
      id: json['id'],
      name: json['name'],
      enabled: json['enabled'] ?? true,
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
