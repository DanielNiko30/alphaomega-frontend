import 'package:equatable/equatable.dart';
import '../../../../../model/product/shope_model.dart';
import '../../../../../model/product/shopee_product_info.dart';

abstract class EditProductShopeeState extends Equatable {
  const EditProductShopeeState();

  @override
  List<Object?> get props => [];
}

/// 🔹 Initial state
class EditProductShopeeInitial extends EditProductShopeeState {}

/// 🔹 Loading state
class EditProductShopeeLoading extends EditProductShopeeState {}

/// 🔹 Loaded state (data berhasil diambil)
class EditProductShopeeLoaded extends EditProductShopeeState {
  final String idProduct;
  final String itemId;
  final ShopeeProductInfo product;
  final String? selectedSatuan;
  final List<ShopeeCategory> categories;
  final ShopeeCategory? selectedCategory;
  final List<ShopeeLogistic> logistics;
  final ShopeeLogistic? selectedLogistic;
  final String brandName; // ✅ baru

  const EditProductShopeeLoaded({
    required this.idProduct,
    required this.itemId,
    required this.product,
    this.selectedSatuan,
    required this.categories,
    this.selectedCategory,
    required this.logistics,
    this.selectedLogistic,
    required this.brandName, // ✅
  });

  EditProductShopeeLoaded copyWith({
    String? idProduct,
    String? itemId,
    ShopeeProductInfo? product,
    String? selectedSatuan,
    List<ShopeeCategory>? categories,
    ShopeeCategory? selectedCategory,
    List<ShopeeLogistic>? logistics,
    ShopeeLogistic? selectedLogistic,
    String? brandName, // ✅
  }) {
    return EditProductShopeeLoaded(
      idProduct: idProduct ?? this.idProduct,
      itemId: itemId ?? this.itemId,
      product: product ?? this.product,
      selectedSatuan: selectedSatuan ?? this.selectedSatuan,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      logistics: logistics ?? this.logistics,
      selectedLogistic: selectedLogistic ?? this.selectedLogistic,
      brandName: brandName ?? this.brandName, // ✅
    );
  }

  @override
  List<Object?> get props => [
        idProduct,
        itemId,
        product,
        selectedSatuan,
        categories,
        selectedCategory,
        logistics,
        selectedLogistic,
        brandName, // ✅
      ];
}

/// 🔹 State saat menyimpan perubahan
class EditProductShopeeSaving extends EditProductShopeeState {}

/// 🔹 State sukses
class EditProductShopeeSuccess extends EditProductShopeeState {
  final Map<String, dynamic> data;

  const EditProductShopeeSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

/// 🔹 State gagal
class EditProductShopeeFailure extends EditProductShopeeState {
  final String message;

  const EditProductShopeeFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
