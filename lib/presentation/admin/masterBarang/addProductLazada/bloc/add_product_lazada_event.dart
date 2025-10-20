import 'package:equatable/equatable.dart';
import '../../../../../model/product/latest_product_model.dart';

abstract class AddProductLazadaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAddLazadaData extends AddProductLazadaEvent {
  final String productId;
  LoadAddLazadaData({required this.productId});
}

class SelectSatuanLazada extends AddProductLazadaEvent {
  final LatestProductStok selectedSatuan;
  SelectSatuanLazada({required this.selectedSatuan});
}

class SelectCategoryLazada extends AddProductLazadaEvent {
  final dynamic selectedCategory;
  SelectCategoryLazada({required this.selectedCategory});
}

class SubmitAddLazadaProduct extends AddProductLazadaEvent {
  final String brand;
  final String netWeight;
  final String packageHeight;
  final String packageLength;
  final String packageWidth;
  final String packageWeight;
  final String sellerSku;

  SubmitAddLazadaProduct({
    required this.brand,
    required this.netWeight,
    required this.packageHeight,
    required this.packageLength,
    required this.packageWidth,
    required this.packageWeight,
    required this.sellerSku,
  });
}
