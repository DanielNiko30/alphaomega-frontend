import 'package:equatable/equatable.dart';
import '../../../../../model/product/shope_model.dart';
import '../../../../../model/product/shopee_product_info.dart';
import '../../../../../model/product/product_shopee_model.dart';

abstract class EditProductShopeeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EditProductShopeeInitial extends EditProductShopeeState {}

class EditProductShopeeLoading extends EditProductShopeeState {}

class EditProductShopeeLoaded extends EditProductShopeeState {
  final ShopeeProductInfo product;
  final String? selectedSatuan; // sekarang cuma String
  final List<ShopeeCategory> categories;
  final ShopeeCategory? selectedCategory;
  final List<ShopeeLogistic> logistics;
  final ShopeeLogistic? selectedLogistic;

  EditProductShopeeLoaded({
    required this.product,
    this.selectedSatuan,
    required this.categories,
    this.selectedCategory,
    required this.logistics,
    this.selectedLogistic,
  });

  EditProductShopeeLoaded copyWith({
    ShopeeProductInfo? product,
    String? selectedSatuan,
    List<ShopeeCategory>? categories,
    ShopeeCategory? selectedCategory,
    List<ShopeeLogistic>? logistics,
    ShopeeLogistic? selectedLogistic,
  }) {
    return EditProductShopeeLoaded(
      product: product ?? this.product,
      selectedSatuan: selectedSatuan ?? this.selectedSatuan,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      logistics: logistics ?? this.logistics,
      selectedLogistic: selectedLogistic ?? this.selectedLogistic,
    );
  }

  @override
  List<Object?> get props => [
        product,
        selectedSatuan,
        categories,
        selectedCategory,
        logistics,
        selectedLogistic
      ];
}

class EditProductShopeeSaving extends EditProductShopeeState {}

class EditProductShopeeSuccess extends EditProductShopeeState {
  final Map<String, dynamic> data;

  EditProductShopeeSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class EditProductShopeeFailure extends EditProductShopeeState {
  final String message;

  EditProductShopeeFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
