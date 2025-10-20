import 'package:equatable/equatable.dart';
import '../../../../../model/product/shope_model.dart';

/// 🔹 Base abstract event class
abstract class EditProductShopeeEvent extends Equatable {
  const EditProductShopeeEvent();

  @override
  List<Object?> get props => [];
}

/// 🔹 Fetch detail produk Shopee berdasarkan id product + satuan
class FetchShopeeProductDetail extends EditProductShopeeEvent {
  final String idProduct; // dari DB lokal
  final String itemId; // dari Shopee marketplace
  final String satuan;

  const FetchShopeeProductDetail({
    required this.idProduct,
    required this.itemId,
    required this.satuan,
  });

  @override
  List<Object?> get props => [idProduct, itemId, satuan];
}

/// 🔹 Pilih satuan dari dropdown
class SelectSatuanShopee extends EditProductShopeeEvent {
  final String selectedSatuan;

  const SelectSatuanShopee({required this.selectedSatuan});

  @override
  List<Object?> get props => [selectedSatuan];
}

/// 🔹 Pilih kategori Shopee
class SelectCategoryShopee extends EditProductShopeeEvent {
  final ShopeeCategory selectedCategory;

  const SelectCategoryShopee({required this.selectedCategory});

  @override
  List<Object?> get props => [selectedCategory];
}

/// 🔹 Pilih logistic Shopee
class SelectLogisticShopee extends EditProductShopeeEvent {
  final ShopeeLogistic selectedLogistic;

  const SelectLogisticShopee({required this.selectedLogistic});

  @override
  List<Object?> get props => [selectedLogistic];
}


/// 🔹 Submit perubahan produk Shopee ke backend
class SubmitEditShopeeProduct extends EditProductShopeeEvent {
  final String idProduct;
  final String itemId;
  final String itemSku;
  final double weight;
  final Map<String, int> dimension;
  final String condition;
  final String selectedSatuan;
  final String brandName; // ✅ baru

  const SubmitEditShopeeProduct({
    required this.idProduct,
    required this.itemId,
    required this.itemSku,
    required this.weight,
    required this.dimension,
    required this.condition,
    required this.selectedSatuan,
    required this.brandName, // ✅
  });

  @override
  List<Object?> get props => [
        idProduct,
        itemId,
        itemSku,
        weight,
        dimension,
        condition,
        selectedSatuan,
        brandName, // ✅
      ];
}
