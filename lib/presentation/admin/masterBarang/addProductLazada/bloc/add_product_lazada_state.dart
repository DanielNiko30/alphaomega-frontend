import 'package:equatable/equatable.dart';
import '../../../../../model/product/latest_product_model.dart';

abstract class AddProductLazadaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddProductLazadaInitial extends AddProductLazadaState {}

class AddProductLazadaLoading extends AddProductLazadaState {}

class AddProductLazadaLoaded extends AddProductLazadaState {
  final LatestProduct product;
  final List<LatestProductStok> stokList;
  final LatestProductStok? selectedSatuan;
  final List<dynamic> categories;
  final Map<String, dynamic>? selectedCategory; // Ubah jadi Map biar aman

  AddProductLazadaLoaded({
    required this.product,
    required this.stokList,
    this.selectedSatuan,
    required this.categories,
    this.selectedCategory,
  });

  AddProductLazadaLoaded copyWith({
    LatestProduct? product,
    List<LatestProductStok>? stokList,
    LatestProductStok? selectedSatuan,
    List<dynamic>? categories,
    Map<String, dynamic>? selectedCategory,
  }) {
    return AddProductLazadaLoaded(
      product: product ?? this.product,
      stokList: stokList ?? this.stokList,
      selectedSatuan: selectedSatuan ?? this.selectedSatuan,
      categories: categories ?? this.categories,
      // 👇 pastikan copyWith mengganti selectedCategory hanya jika dikirim
      selectedCategory:
          selectedCategory != null ? selectedCategory : this.selectedCategory,
    );
  }

  @override
  List<Object?> get props =>
      [product, stokList, selectedSatuan, categories, selectedCategory];
}

class AddProductLazadaSubmitting extends AddProductLazadaState {}

class AddProductLazadaSuccess extends AddProductLazadaState {
  final String message;
  AddProductLazadaSuccess({required this.message});
}

class AddProductLazadaFailure extends AddProductLazadaState {
  final String message;
  AddProductLazadaFailure({required this.message});
}
