import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../../../model/product/update_product_model.dart';
import '../../../../../model/product/stok_model.dart';

/// 🔹 Event utama Edit Product
abstract class EditProductEvent extends Equatable {
  const EditProductEvent();

  @override
  List<Object?> get props => [];
}

//
// 🔹 Load Data
//

/// Memuat produk berdasarkan ID
class LoadProduct extends EditProductEvent {
  final String productId;

  const LoadProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Memuat kategori produk
class LoadKategori extends EditProductEvent {
  const LoadKategori();
}

//
// 🔹 Dropdown / Selection
//

/// Memilih kategori dari dropdown
class SelectKategori extends EditProductEvent {
  final String kategoriId;

  const SelectKategori(this.kategoriId);

  @override
  List<Object?> get props => [kategoriId];
}

//
// 🔹 Save / Update Product
//

/// Submit update product (Simpan perubahan + Shopee)
class SubmitUpdateProduct extends EditProductEvent {
  final UpdateProduct product;
  final Uint8List? imageBytes;
  final String? fileName;

  const SubmitUpdateProduct({
    required this.product,
    this.imageBytes,
    this.fileName,
  });

  @override
  List<Object?> get props => [product, imageBytes, fileName];
}

/// SaveOnlyProduct: Menyimpan perubahan produk ke DB lokal saja
class SaveOnlyProduct extends EditProductEvent {
  final UpdateProduct product;
  final Uint8List? imageBytes;
  final String? fileName;

  const SaveOnlyProduct({
    required this.product,
    this.imageBytes,
    this.fileName,
  });

  @override
  List<Object?> get props => [product, imageBytes, fileName];
}

//
// 🔹 Popup Pilih Satuan untuk Shopee
//

/// Memuat daftar satuan untuk ditampilkan di popup Shopee
class LoadSatuanForShopeeEdit extends EditProductEvent {
  final String productId;

  const LoadSatuanForShopeeEdit(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Memilih satuan Shopee dari popup
class SelectSatuanForShopee extends EditProductEvent {
  final String selectedSatuan;
  final String idProduct; // id product lokal

  const SelectSatuanForShopee({
    required this.selectedSatuan,
    required this.idProduct,
  });

  @override
  List<Object?> get props => [selectedSatuan, idProduct];
}
