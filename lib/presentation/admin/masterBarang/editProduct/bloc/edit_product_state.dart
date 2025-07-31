import 'package:equatable/equatable.dart';
import '../../../../../model/product/update_product_model.dart';
import '../../../../../model/product/edit_productView_model.dart';
import '../../../../../model/product/kategori_model.dart';

abstract class EditProductState extends Equatable {
  final List<Kategori>? kategori;
  final String? selectedKategoriId;

  const EditProductState({this.kategori, this.selectedKategoriId});

  @override
  List<Object?> get props => [kategori, selectedKategoriId];
}

// 🔹 State Awal
class EditProductInitial extends EditProductState {}

// 🔹 State Loading
class EditProductLoading extends EditProductState {}

// 🔹 State Berhasil Memuat Produk
class EditProductLoaded extends EditProductState {
  final EditProductView product;
  final List<Kategori> kategori;

  const EditProductLoaded(
    this.product, {
    required this.kategori,
    String? selectedKategoriId,
  }) : super(kategori: kategori, selectedKategoriId: selectedKategoriId);

  @override
  List<Object?> get props => [product, kategori, selectedKategoriId];
}

// 🔹 State Berhasil Memuat Kategori
class KategoriLoaded extends EditProductState {
  final List<Kategori> kategori;

  const KategoriLoaded({required this.kategori, String? selectedKategoriId})
      : super(kategori: kategori, selectedKategoriId: selectedKategoriId);

  @override
  List<Object?> get props => [kategori, selectedKategoriId];
}

// 🔹 State Loading Kategori
class KategoriLoading extends EditProductState {
  const KategoriLoading();
}

// 🔹 State Gagal Memuat Kategori
class KategoriFailure extends EditProductState {
  final String message;

  const KategoriFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// 🔹 State Sukses Memperbarui Produk
class EditProductSuccess extends EditProductState {}

// 🔹 State Setelah Produk Berhasil Diupdate
class EditProductUpdated extends EditProductState {
  final UpdateProduct updatedProduct;

  const EditProductUpdated(
    this.updatedProduct, {
    List<Kategori>? kategori,
    String? selectedKategoriId,
  }) : super(kategori: kategori, selectedKategoriId: selectedKategoriId);

  @override
  List<Object?> get props => [updatedProduct, kategori, selectedKategoriId];
}

// 🔹 State Gagal Memuat Produk
class EditProductFailure extends EditProductState {
  final String message;

  const EditProductFailure(
    this.message, {
    List<Kategori>? kategori,
    String? selectedKategoriId,
  }) : super(kategori: kategori, selectedKategoriId: selectedKategoriId);

  @override
  List<Object?> get props => [message, kategori, selectedKategoriId];
}
