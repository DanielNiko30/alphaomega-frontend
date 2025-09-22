import 'package:equatable/equatable.dart';
import '../../../../../model/product/shope_model.dart';
import '../../../../../model/product/product_shopee_model.dart';

abstract class EditProductShopeeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Fetch detail produk dari Shopee berdasarkan id product + satuan
class FetchShopeeProductDetail extends EditProductShopeeEvent {
  final String idProduct;
  final String satuan; // <-- String karena hanya nama satuan yang dipakai

  FetchShopeeProductDetail({
    required this.idProduct,
    required this.satuan,
  });

  @override
  List<Object?> get props => [idProduct, satuan];
}

/// Select satuan dari dropdown
class SelectSatuanShopee extends EditProductShopeeEvent {
  final String selectedSatuan; // <-- sekarang String, bukan StokShopee

  SelectSatuanShopee({required this.selectedSatuan});

  @override
  List<Object?> get props => [selectedSatuan];
}

/// Select category dari dropdown
class SelectCategoryShopee extends EditProductShopeeEvent {
  final ShopeeCategory selectedCategory;

  SelectCategoryShopee({required this.selectedCategory});

  @override
  List<Object?> get props => [selectedCategory];
}

/// Select logistic dari dropdown
class SelectLogisticShopee extends EditProductShopeeEvent {
  final ShopeeLogistic selectedLogistic;

  SelectLogisticShopee({required this.selectedLogistic});

  @override
  List<Object?> get props => [selectedLogistic];
}

/// Submit edit produk Shopee
class SubmitEditShopeeProduct extends EditProductShopeeEvent {
  final String itemId; // <-- update dari int ke String
  final String itemSku;
  final num weight;
  final Map<String, dynamic> dimension; // {length, width, height}
  final String condition;

  SubmitEditShopeeProduct({
    required this.itemId, // tetap String
    required this.itemSku,
    required this.weight,
    required this.dimension,
    required this.condition,
  });

  @override
  List<Object?> get props => [itemId, itemSku, weight, dimension, condition];
}
