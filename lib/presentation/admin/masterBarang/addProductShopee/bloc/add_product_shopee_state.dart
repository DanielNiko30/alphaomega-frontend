import 'package:equatable/equatable.dart';
import '../../../../../model/product/product_shopee_model.dart';
import '../../../../../model/product/latest_product_model.dart';
import '../../../../../model/product/shope_model.dart';

/// Base abstract state untuk Add Product Shopee
abstract class AddProductShopeeState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// State awal ketika belum ada data yang diload
class AddProductShopeeInitial extends AddProductShopeeState {}

/// State ketika sedang memuat data produk dari backend
class AddProductShopeeLoading extends AddProductShopeeState {}

/// State ketika data berhasil diload
class AddProductShopeeLoaded extends AddProductShopeeState {
  final LatestProduct product; // ✅ Produk dari backend
  final List<StokShopee> stokList; // ✅ List stok yang siap diupload ke Shopee
  final StokShopee? selectedSatuan; // ✅ Satuan yang dipilih

  final List<ShopeeCategory> categories; // ✅ Semua kategori Shopee
  final ShopeeCategory? selectedCategory; // ✅ Kategori yang dipilih

  final List<ShopeeLogistic> logistics; // ✅ Semua logistic Shopee
  final ShopeeLogistic? selectedLogistic; // ✅ Logistic yang dipilih

  AddProductShopeeLoaded({
    required this.product,
    required this.stokList,
    this.selectedSatuan,
    required this.categories,
    this.selectedCategory,
    required this.logistics,
    this.selectedLogistic,
  });

  /// Agar bisa update sebagian field tanpa membuat state baru dari awal
  AddProductShopeeLoaded copyWith({
    LatestProduct? product,
    List<StokShopee>? stokList,
    StokShopee? selectedSatuan,
    List<ShopeeCategory>? categories,
    ShopeeCategory? selectedCategory,
    List<ShopeeLogistic>? logistics,
    ShopeeLogistic? selectedLogistic,
  }) {
    return AddProductShopeeLoaded(
      product: product ?? this.product,
      stokList: stokList ?? this.stokList,
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
        stokList,
        selectedSatuan?.satuan ?? '',
        categories,
        selectedCategory?.categoryName ?? '',
        logistics,
        selectedLogistic?.name ?? '',
      ];
}

/// State ketika sedang submit produk ke Shopee
class AddProductShopeeSubmitting extends AddProductShopeeState {}

/// State ketika berhasil submit produk ke Shopee
class AddProductShopeeSuccess extends AddProductShopeeState {
  final String message;

  AddProductShopeeSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State ketika gagal load data produk atau submit ke Shopee
class AddProductShopeeFailure extends AddProductShopeeState {
  final String message;

  AddProductShopeeFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
