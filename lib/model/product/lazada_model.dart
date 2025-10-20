class LazadaCategory {
  final int categoryId;
  final String categoryName;
  final int? parentId;

  LazadaCategory({
    required this.categoryId,
    required this.categoryName,
    this.parentId,
  });

  factory LazadaCategory.fromJson(Map<String, dynamic> json) {
    return LazadaCategory(
      categoryId: (json['category_id'] ?? 0) as int,
      categoryName: json['category_name'] ?? 'Unknown',
      parentId: json['parent_id'] != null ? (json['parent_id'] as int) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'category_name': categoryName,
        'parent_id': parentId,
      };
}

class LazadaUnit {
  final String unitName; // contoh: KG, SAK
  final double price;
  final int stock;

  LazadaUnit({
    required this.unitName,
    required this.price,
    required this.stock,
  });

  factory LazadaUnit.fromJson(Map<String, dynamic> json) {
    return LazadaUnit(
      unitName: json['unit'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: (json['stock'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'unit': unitName,
        'price': price,
        'stock': stock,
      };
}

class LazadaAttribute {
  final String attributeId;
  final String name;
  final String type; // text, select, boolean, dll
  final List<String>? options;

  LazadaAttribute({
    required this.attributeId,
    required this.name,
    required this.type,
    this.options,
  });

  factory LazadaAttribute.fromJson(Map<String, dynamic> json) {
    return LazadaAttribute(
      attributeId: (json['attribute_id'] ?? '').toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? 'text',
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'attribute_id': attributeId,
        'name': name,
        'type': type,
        'options': options,
      };
}

class LazadaBrand {
  final int brandId;
  final String brandName;

  LazadaBrand({
    required this.brandId,
    required this.brandName,
  });

  factory LazadaBrand.fromJson(Map<String, dynamic> json) {
    return LazadaBrand(
      brandId: (json['brand_id'] ?? 0) as int,
      brandName: json['brand_name'] ?? 'No Brand',
    );
  }

  Map<String, dynamic> toJson() => {
        'brand_id': brandId,
        'brand_name': brandName,
      };
}

class LazadaProduct {
  final String id;
  final String name;
  final String sku;
  final int weight;
  final Map<String, int> dimension; // length, width, height
  final String condition; // NEW / USED
  final String? brandName;
  final LazadaCategory category;
  final LazadaUnit selectedUnit;
  final Map<String, dynamic> attributes;

  LazadaProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.weight,
    required this.dimension,
    required this.condition,
    this.brandName,
    required this.category,
    required this.selectedUnit,
    required this.attributes,
  });

  factory LazadaProduct.fromJson(Map<String, dynamic> json) {
    return LazadaProduct(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      weight: (json['weight'] ?? 0) as int,
      dimension: {
        "length": (json['length'] ?? 0) as int,
        "width": (json['width'] ?? 0) as int,
        "height": (json['height'] ?? 0) as int,
      },
      condition: json['condition'] ?? 'NEW',
      brandName: json['brand_name'],
      category: LazadaCategory.fromJson(json['category'] ?? {}),
      selectedUnit: LazadaUnit.fromJson(json['selected_unit'] ?? {}),
      attributes: json['attributes'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'weight': weight,
        'dimension': dimension,
        'condition': condition,
        'brand_name': brandName,
        'category': category.toJson(),
        'selected_unit': selectedUnit.toJson(),
        'attributes': attributes,
      };
}

class LazadaItem {
  final String itemId;
  final String itemName;

  LazadaItem({
    required this.itemId,
    required this.itemName,
  });

  factory LazadaItem.fromJson(Map<String, dynamic> json) {
    return LazadaItem(
      itemId: (json['item_id'] ?? '').toString(),
      itemName: json['item_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'item_name': itemName,
      };
}

class LazadaOrder {
  final String orderId;
  final String orderNumber;
  final String buyerName;
  final double totalAmount;
  final String paymentMethod;
  final String? status;
  final String createdAt;
  final Map<String, dynamic>? recipientAddress;
  final List<LazadaOrderItem> items;

  LazadaOrder({
    required this.orderId,
    required this.orderNumber,
    required this.buyerName,
    required this.totalAmount,
    required this.paymentMethod,
    this.status,
    required this.createdAt,
    this.recipientAddress,
    required this.items,
  });

  factory LazadaOrder.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return LazadaOrder(
      orderId: (json['order_id'] ?? '').toString(),
      orderNumber: (json['order_number'] ?? '').toString(),
      buyerName: json['buyer_name'] ?? '',
      totalAmount: parseDouble(json['total_amount']),
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] != null
          ? json['status'].toString().toUpperCase()
          : null,
      createdAt: json['created_at'] ?? '',
      recipientAddress: json['recipient_address'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => LazadaOrderItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'order_number': orderNumber,
        'buyer_name': buyerName,
        'total_amount': totalAmount,
        'payment_method': paymentMethod,
        'status': status,
        'created_at': createdAt,
        'recipient_address': recipientAddress,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class LazadaOrderItem {
  final String itemId;
  final String productId;
  final String skuId;
  final String name;
  final int quantity;
  final double price;
  final String? status;
  final bool fromDb;
  final String? idProductStok;
  final String? satuan;
  final String? namaProduct;
  final String? imageUrl;

  LazadaOrderItem({
    required this.itemId,
    required this.productId,
    required this.skuId,
    required this.name,
    required this.quantity,
    required this.price,
    this.status,
    this.fromDb = false,
    this.idProductStok,
    this.satuan,
    this.namaProduct,
    this.imageUrl,
  });

  factory LazadaOrderItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return LazadaOrderItem(
      itemId: (json['item_id'] ?? '').toString(),
      productId: (json['product_id'] ?? '').toString(),
      skuId: (json['sku_id'] ?? '').toString(),
      name: json['name'] ?? '',
      quantity: parseInt(json['quantity']),
      price: parseDouble(json['price']),
      status: json['status'],
      fromDb: json['from_db'] ?? false,
      idProductStok: json['id_product_stok']?.toString(),
      satuan: json['satuan'],
      namaProduct: json['nama_product'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'product_id': productId,
        'sku_id': skuId,
        'name': name,
        'quantity': quantity,
        'price': price,
        'status': status,
        'from_db': fromDb,
        'id_product_stok': idProductStok,
        'satuan': satuan,
        'nama_product': namaProduct,
        'image_url': imageUrl,
      };
}
