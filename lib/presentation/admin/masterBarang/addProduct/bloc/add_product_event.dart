import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../../../model/product/add_product_model.dart';

/// Base event
abstract class AddProductEvent extends Equatable {
  const AddProductEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk submit produk baru ke backend
class SubmitProduct extends AddProductEvent {
  final AddProduct product;
  final Uint8List? imageBytes;
  final String? fileName;

  const SubmitProduct({
    required this.product,
    this.imageBytes,
    this.fileName,
  });

  @override
  List<Object?> get props => [product, imageBytes, fileName];
}

/// Event untuk memuat semua kategori produk dari backend
class LoadKategori extends AddProductEvent {
  const LoadKategori();
}

/// Event untuk memilih gambar dari gallery/file picker
class PickImage extends AddProductEvent {
  final Uint8List imageBytes;
  final String fileName;

  const PickImage({
    required this.imageBytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [imageBytes, fileName];
}

/// Event yang dipanggil setelah produk berhasil disimpan
/// Digunakan agar UI bisa mengupdate state dengan productId terbaru
class ProductSavedEvent extends AddProductEvent {
  final String productId;

  const ProductSavedEvent({required this.productId});

  @override
  List<Object?> get props => [productId];
}

/// Event untuk reset state ke kondisi awal
class ResetAddProduct extends AddProductEvent {
  const ResetAddProduct();
}
