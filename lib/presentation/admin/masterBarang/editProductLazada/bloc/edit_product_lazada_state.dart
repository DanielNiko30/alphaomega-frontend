import 'package:equatable/equatable.dart';
import '../../../../../model/product/latest_product_model.dart';

/// ===== Base State =====
abstract class EditProductLazadaState extends Equatable {
  const EditProductLazadaState();

  @override
  List<Object?> get props => [];
}

/// 🔹 State awal
class EditProductLazadaInitial extends EditProductLazadaState {}

/// 🔹 State loading saat ambil data produk
class EditProductLazadaLoading extends EditProductLazadaState {}

/// 🔹 State loaded (produk + kategori sudah siap)
class EditProductLazadaLoaded extends EditProductLazadaState {
  final String productId; 
  final Map<String, dynamic> lazadaData;
  final List<dynamic> categories;
  final String? selectedCategoryId;
  final LatestProductStok? selectedSatuan;
  final String brand;
  final String netWeight;
  final String packageLength;
  final String packageWidth;
  final String packageHeight;
  final String packageWeight;
  final String sellerSku;

  const EditProductLazadaLoaded({
    required this.productId,
    required this.lazadaData,
    required this.categories,
    this.selectedCategoryId,
    this.selectedSatuan,
    required this.brand,
    required this.netWeight,
    required this.packageLength,
    required this.packageWidth,
    required this.packageHeight,
    required this.packageWeight,
    required this.sellerSku,
  });

  /// 🧩 Buat copy state saat update sebagian (misal ganti kategori/satuan)
  EditProductLazadaLoaded copyWith({
    String? productId,
    Map<String, dynamic>? lazadaData,
    List<dynamic>? categories,
    String? selectedCategoryId,
    LatestProductStok? selectedSatuan,
    String? brand,
    String? netWeight,
    String? packageLength,
    String? packageWidth,
    String? packageHeight,
    String? packageWeight,
    String? sellerSku,
  }) {
    return EditProductLazadaLoaded(
      productId: productId ?? this.productId,
      lazadaData: lazadaData ?? this.lazadaData,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedSatuan: selectedSatuan ?? this.selectedSatuan,
      brand: brand ?? this.brand,
      netWeight: netWeight ?? this.netWeight,
      packageLength: packageLength ?? this.packageLength,
      packageWidth: packageWidth ?? this.packageWidth,
      packageHeight: packageHeight ?? this.packageHeight,
      packageWeight: packageWeight ?? this.packageWeight,
      sellerSku: sellerSku ?? this.sellerSku,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        lazadaData,
        categories,
        selectedCategoryId,
        selectedSatuan,
        brand,
        netWeight,
        packageLength,
        packageWidth,
        packageHeight,
        packageWeight,
        sellerSku,
      ];
}

/// 🔹 State saat proses submit update produk ke Lazada
class EditProductLazadaSubmitting extends EditProductLazadaState {}

/// 🔹 State sukses update produk
class EditProductLazadaSuccess extends EditProductLazadaState {
  final String message;

  const EditProductLazadaSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// 🔹 State gagal update atau gagal load data
class EditProductLazadaFailure extends EditProductLazadaState {
  final String message;

  const EditProductLazadaFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
