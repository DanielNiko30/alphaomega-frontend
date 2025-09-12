import 'package:equatable/equatable.dart';
import '../../../../../model/product/product_shopee_model.dart';
import '../../../../../model/product/shope_model.dart';

abstract class AddProductShopeeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load semua data untuk add product Shopee (stok, kategori, logistic)
class LoadAddShopeeData extends AddProductShopeeEvent {
  final String productId;

  LoadAddShopeeData({required this.productId});

  @override
  List<Object?> get props => [productId];
}

/// Pilih satuan produk
class SelectSatuanShopee extends AddProductShopeeEvent {
  final StokShopee selectedSatuan;

  SelectSatuanShopee({required this.selectedSatuan});

  @override
  List<Object?> get props => [selectedSatuan];
}

/// Pilih kategori Shopee
class SelectCategoryShopee extends AddProductShopeeEvent {
  final ShopeeCategory selectedCategory;

  SelectCategoryShopee({required this.selectedCategory});

  @override
  List<Object?> get props => [selectedCategory];
}

/// Pilih logistic Shopee
class SelectLogisticShopee extends AddProductShopeeEvent {
  final ShopeeLogistic selectedLogistic;

  SelectLogisticShopee({required this.selectedLogistic});

  @override
  List<Object?> get props => [selectedLogistic];
}

/// Submit produk ke Shopee
class SubmitAddShopeeProduct extends AddProductShopeeEvent {
  final String itemSku;
  final num weight;
  final Map<String, dynamic> dimension;
  final String condition;
  final String? brandName;
  final int? brandId;

  SubmitAddShopeeProduct({
    required this.itemSku,
    required this.weight,
    required this.dimension,
    required this.condition,
    this.brandName,
    this.brandId,
  });

  @override
  List<Object?> get props => [
        itemSku,
        weight,
        dimension,
        condition,
        brandName,
        brandId,
      ];
}
