import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../../../model/product/kategori_model.dart';
import '../../../../../model/product/latest_product_model.dart';

/// Base state
abstract class AddProductState extends Equatable {
  const AddProductState();

  @override
  List<Object?> get props => [];
}

/// State awal saat screen pertama kali dibuka
class AddProductInitial extends AddProductState {
  const AddProductInitial();
}

/// State saat proses loading (submit, load kategori, dll)
class AddProductLoading extends AddProductState {
  const AddProductLoading();
}

/// State ketika produk berhasil ditambahkan
class AddProductSuccess extends AddProductState {
  const AddProductSuccess();
}

/// State ketika terjadi error saat proses apapun
class AddProductFailure extends AddProductState {
  final String message;
  const AddProductFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State membawa informasi produk yang baru saja berhasil disimpan
class ProductSaved extends AddProductState {
  final String productId;
  const ProductSaved({required this.productId});

  @override
  List<Object?> get props => [productId];
}

/// State saat kategori produk berhasil dimuat dari backend
class KategoriLoaded extends AddProductState {
  final List<Kategori> kategori;
  const KategoriLoaded({required this.kategori});

  @override
  List<Object?> get props => [kategori];
}

/// State saat kategori masih dalam proses loading
class KategoriLoading extends AddProductState {
  const KategoriLoading();
}

/// State jika gagal memuat kategori
class KategoriFailure extends AddProductState {
  final String message;
  const KategoriFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State default kategori
class KategoriInitial extends AddProductState {
  const KategoriInitial();
}

/// State ketika gambar berhasil dipilih dari gallery/file picker
class ImagePicked extends AddProductState {
  final Uint8List imageBytes;
  final String base64Image;
  final String fileName;

  const ImagePicked({
    required this.imageBytes,
    required this.base64Image,
    required this.fileName,
  });

  @override
  List<Object?> get props => [imageBytes, base64Image, fileName];
}

/// State yang membawa produk terbaru lengkap dengan list stok
/// Digunakan setelah sukses submit produk
class LatestProductLoaded extends AddProductState {
  final LatestProduct latestProduct;
  const LatestProductLoaded({required this.latestProduct});

  @override
  List<Object?> get props => [latestProduct];
}
