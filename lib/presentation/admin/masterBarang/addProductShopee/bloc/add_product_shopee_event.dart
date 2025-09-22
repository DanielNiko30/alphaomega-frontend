import 'package:equatable/equatable.dart';
import '../../../../../model/product/product_shopee_model.dart';
import '../../../../../model/product/shope_model.dart';

/// Base abstract event untuk Add Product Shopee
abstract class AddProductShopeeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event untuk load semua data awal (produk, stok, kategori, logistic)
/// - Jika productId dikirim, maka backend akan mengambil produk berdasarkan ID
/// - Jika tidak ada productId, backend mengambil produk terbaru
class LoadAddShopeeData extends AddProductShopeeEvent {
  final String? productId;

  LoadAddShopeeData({this.productId});

  @override
  List<Object?> get props => [productId ?? ''];
}

/// Event untuk memilih satuan produk
class SelectSatuanShopee extends AddProductShopeeEvent {
  final StokShopee selectedSatuan;

  SelectSatuanShopee({required this.selectedSatuan});

  @override
  List<Object?> get props => [selectedSatuan];
}

/// Event untuk memilih kategori Shopee
class SelectCategoryShopee extends AddProductShopeeEvent {
  final ShopeeCategory selectedCategory;

  SelectCategoryShopee({required this.selectedCategory});

  @override
  List<Object?> get props => [selectedCategory];
}

/// Event untuk memilih logistic Shopee
class SelectLogisticShopee extends AddProductShopeeEvent {
  final ShopeeLogistic selectedLogistic;

  SelectLogisticShopee({required this.selectedLogistic});

  @override
  List<Object?> get props => [selectedLogistic];
}

/// Event untuk submit produk ke Shopee
class SubmitAddShopeeProduct extends AddProductShopeeEvent {
  final String itemSku; // SKU item
  final num weight; // Berat produk dalam gram
  final Map<String, dynamic> dimension; // {length, width, height}
  final String condition; // "NEW" atau "USED"
  final String? brandName; // Nama brand (optional)
  final int? brandId; // ID brand (optional)

  SubmitAddShopeeProduct({
    required this.itemSku,
    required this.weight,
    required this.dimension,
    required this.condition,
    this.brandName,
    this.brandId,
  });

  @override
  List<Object?> get props => [
        itemSku,
        weight,
        dimension,
        condition,
        brandName ?? '',
        brandId ?? 0,
      ];
}
