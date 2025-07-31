import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../../../model/product/update_product_model.dart';

abstract class EditProductEvent extends Equatable {
  const EditProductEvent();

  @override
  List<Object?> get props => [];
}

/// 🔹 **Memuat Produk berdasarkan ID**
class LoadProduct extends EditProductEvent {
  final String productId;

  const LoadProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// 🔹 **Memuat Kategori Produk**
class LoadKategori extends EditProductEvent {
  const LoadKategori();
}

/// 🔹 **Memilih Kategori dalam Dropdown**
class SelectKategori extends EditProductEvent {
  final String kategoriId;

  const SelectKategori(this.kategoriId);

  @override
  List<Object?> get props => [kategoriId];
}

/// 🔹 **Mengupdate Produk**
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
