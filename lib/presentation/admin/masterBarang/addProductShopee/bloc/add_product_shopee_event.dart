import 'package:equatable/equatable.dart';
import '../../../../../model/product/stok_model.dart';

/// Base class untuk semua event
abstract class AddProductShopeeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// 🔹 Load satuan yang belum masuk Shopee
class LoadSatuanShopee extends AddProductShopeeEvent {
  final String productId;

  LoadSatuanShopee(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// 🔹 Pilih satuan produk
class SelectSatuanShopee extends AddProductShopeeEvent {
  final Stok selectedSatuan;

  SelectSatuanShopee({required this.selectedSatuan});

  @override
  List<Object?> get props => [selectedSatuan];
}

/// 🔹 Submit produk ke Shopee
class SubmitAddShopeeProduct extends AddProductShopeeEvent {
  final String productId; // ID produk di database
  final String itemSku; // SKU unik
  final num weight; // Berat produk (gram)
  final Map<String, dynamic> dimension; // Panjang, lebar, tinggi
  final String condition; // Baru / Bekas
  final int logisticId; // ID kurir Shopee
  final int categoryId; // ID kategori Shopee
  final String? brandName; // Nama brand opsional
  final int? brandId; // ID brand opsional

  SubmitAddShopeeProduct({
    required this.productId,
    required this.itemSku,
    required this.weight,
    required this.dimension,
    required this.condition,
    required this.logisticId,
    required this.categoryId,
    this.brandName,
    this.brandId,
  });

  @override
  List<Object?> get props => [
        productId,
        itemSku,
        weight,
        dimension,
        condition,
        logisticId,
        categoryId,
        brandName,
        brandId,
      ];
}
