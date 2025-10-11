class ShopeeOrder {
  final String orderSn;
  final String shippingMethod;
  final List<ShopeeOrderItem> items;

  ShopeeOrder({
    required this.orderSn,
    required this.shippingMethod,
    required this.items,
  });

  factory ShopeeOrder.fromJson(Map<String, dynamic> json) {
    return ShopeeOrder(
      orderSn: json['order_sn'] ?? '',
      shippingMethod: json['shipping_method'] ?? '',
      items: (json['items'] as List<dynamic>)
          .map((item) => ShopeeOrderItem.fromJson(item))
          .toList(),
    );
  }
}

class ShopeeOrderItem {
  final int itemId;
  final String name;
  final String? imageUrl;
  final String variationName;
  final int quantity;
  final double price;
  final bool fromDb;

  ShopeeOrderItem({
    required this.itemId,
    required this.name,
    this.imageUrl,
    required this.variationName,
    required this.quantity,
    required this.price,
    required this.fromDb,
  });

  factory ShopeeOrderItem.fromJson(Map<String, dynamic> json) {
    return ShopeeOrderItem(
      itemId: json['item_id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'],
      variationName: json['variation_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      fromDb: json['from_db'] ?? false,
    );
  }
}
