import 'package:equatable/equatable.dart';
import '../../../../../model/product/product_shopee_model.dart';
import '../../../../../model/product/latest_product_model.dart';
import '../../../../../model/product/shope_model.dart';

abstract class AddProductShopeeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddProductShopeeInitial extends AddProductShopeeState {}

class AddProductShopeeLoading extends AddProductShopeeState {}

class AddProductShopeeLoaded extends AddProductShopeeState {
  final LatestProduct product;
  final List<StokShopee> stokList;
  final StokShopee? selectedSatuan;
  final List<ShopeeCategory> categories;
  final ShopeeCategory? selectedCategory;
  final List<ShopeeLogistic> logistics;
  final ShopeeLogistic? selectedLogistic;

  AddProductShopeeLoaded({
    required this.product,
    required this.stokList,
    this.selectedSatuan,
    required this.categories,
    this.selectedCategory,
    required this.logistics,
    this.selectedLogistic,
  });

  AddProductShopeeLoaded copyWith({
    List<StokShopee>? stokList,
    StokShopee? selectedSatuan,
    ShopeeCategory? selectedCategory,
    ShopeeLogistic? selectedLogistic,
  }) {
    return AddProductShopeeLoaded(
      product: product,
      stokList: stokList ?? this.stokList,
      selectedSatuan: selectedSatuan ?? this.selectedSatuan,
      categories: categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      logistics: logistics,
      selectedLogistic: selectedLogistic ?? this.selectedLogistic,
    );
  }

  @override
  List<Object?> get props => [
        product,
        stokList,
        selectedSatuan?.satuan ?? '',
        categories,
        selectedCategory?.categoryName ?? '',
        logistics,
        selectedLogistic?.name ?? '',
      ];
}

class AddProductShopeeSubmitting extends AddProductShopeeState {}

class AddProductShopeeSuccess extends AddProductShopeeState {
  final String message;

  AddProductShopeeSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AddProductShopeeFailure extends AddProductShopeeState {
  final String message;

  AddProductShopeeFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
