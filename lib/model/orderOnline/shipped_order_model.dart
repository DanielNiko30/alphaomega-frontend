class ShippedOrder {
  final String orderSn;
  final String bookingSn;
  final String shippingMethod;
  final String status;
  final List<ShippedOrderItem> items;
  final List<ShippedOrderItem> fullItems;

  ShippedOrder({
    required this.orderSn,
    this.bookingSn = '',
    this.shippingMethod = '',
    this.status = '',
    this.items = const [],
    this.fullItems = const [],
  });

  factory ShippedOrder.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] ?? [];
    final fullItemsJson = json['full_items'] ?? [];

    return ShippedOrder(
      orderSn: json['order_sn'] ?? '',
      bookingSn: json['booking_sn'] ?? '',
      shippingMethod: json['shipping_method'] ?? '',
      status: json['status'] ?? '',
      items:
          (itemsJson as List).map((e) => ShippedOrderItem.fromJson(e)).toList(),
      fullItems: (fullItemsJson as List)
          .map((e) => ShippedOrderItem.fromJson(e))
          .toList(),
    );
  }
}

class ShippedOrderItem {
  final int itemId;
  final String name;
  final String variationName;
  final int quantity;
  final double price;
  final String? imageUrl;
  final bool fromDb;

  ShippedOrderItem({
    required this.itemId,
    required this.name,
    this.variationName = '',
    this.quantity = 0,
    this.price = 0,
    this.imageUrl,
    this.fromDb = false,
  });

  factory ShippedOrderItem.fromJson(Map<String, dynamic> json) {
    return ShippedOrderItem(
      itemId: json['item_id'] ?? 0,
      name: json['name'] ?? 'Produk Tidak Diketahui',
      variationName: json['variation_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
      fromDb: json['from_db'] ?? false,
    );
  }
}
