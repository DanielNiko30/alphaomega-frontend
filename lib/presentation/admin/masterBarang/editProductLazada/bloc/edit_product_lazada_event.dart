import 'package:equatable/equatable.dart';
import '../../../../../model/product/latest_product_model.dart';

/// ===== Base Event =====
abstract class EditProductLazadaEvent extends Equatable {
  const EditProductLazadaEvent();

  @override
  List<Object?> get props => [];
}

/// 🔹 Load data produk Lazada berdasarkan item_id
class LoadEditLazadaData extends EditProductLazadaEvent {
  final String productId; // DB lokal
  final String itemId; // Lazada
  final String satuan; // satuan

  LoadEditLazadaData({
    required this.productId,
    required this.itemId,
    required this.satuan,
  });

  @override
  List<Object?> get props => [productId, itemId, satuan];
}

/// 🔹 Pilih satuan lokal (jika digunakan untuk sinkron stok)
class SelectSatuanLazada extends EditProductLazadaEvent {
  final LatestProductStok selectedSatuan;

  const SelectSatuanLazada({required this.selectedSatuan});

  @override
  List<Object?> get props => [selectedSatuan];
}

/// 🔹 Pilih kategori Lazada (category_id)
class SelectCategoryLazada extends EditProductLazadaEvent {
  final String selectedCategoryId;

  const SelectCategoryLazada({required this.selectedCategoryId});

  @override
  List<Object?> get props => [selectedCategoryId];
}

/// 🔹 Submit perubahan ke Lazada
class SubmitEditLazadaProduct extends EditProductLazadaEvent {
  final String brand;
  final String netWeight;
  final String packageHeight;
  final String packageLength;
  final String packageWidth;
  final String packageWeight;
  final String sellerSku;

  const SubmitEditLazadaProduct({
    required this.brand,
    required this.netWeight,
    required this.packageHeight,
    required this.packageLength,
    required this.packageWidth,
    required this.packageWeight,
    required this.sellerSku,
  });

  @override
  List<Object?> get props => [
        brand,
        netWeight,
        packageHeight,
        packageLength,
        packageWidth,
        packageWeight,
        sellerSku,
      ];
}
