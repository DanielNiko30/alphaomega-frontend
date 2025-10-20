import 'package:equatable/equatable.dart';
import '../../../../../model/product/update_product_model.dart';
import '../../../../../model/product/edit_productView_model.dart';
import '../../../../../model/product/kategori_model.dart';
import '../../../../../model/product/stok_model.dart';

/// 🔹 State utama Edit Product
abstract class EditProductState extends Equatable {
  final List<Kategori>? kategori;
  final String? selectedKategoriId;

  const EditProductState({this.kategori, this.selectedKategoriId});

  @override
  List<Object?> get props => [kategori, selectedKategoriId];
}

//
// 🔹 Initial & Loading
//
class EditProductInitial extends EditProductState {}

class EditProductLoading extends EditProductState {}

class KategoriLoading extends EditProductState {
  const KategoriLoading();
}

//
// 🔹 Produk Loaded
//
class EditProductLoaded extends EditProductState {
  final EditProductView product;
  final List<Kategori> kategori;
  final bool isSavedToDB;

  const EditProductLoaded(
    this.product, {
    required this.kategori,
    String? selectedKategoriId,
    this.isSavedToDB = false,
  }) : super(kategori: kategori, selectedKategoriId: selectedKategoriId);

  EditProductLoaded copyWith({
    EditProductView? product,
    List<Kategori>? kategori,
    String? selectedKategoriId,
    bool? isSavedToDB,
  }) {
    return EditProductLoaded(
      product ?? this.product,
      kategori: kategori ?? this.kategori,
      selectedKategoriId: selectedKategoriId ?? this.selectedKategoriId,
      isSavedToDB: isSavedToDB ?? this.isSavedToDB,
    );
  }

  @override
  List<Object?> get props =>
      [product, kategori, selectedKategoriId, isSavedToDB];
}

class EditProductSuccess extends EditProductState {
  final String message;

  const EditProductSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class KategoriLoaded extends EditProductState {
  final List<Kategori> kategori;

  const KategoriLoaded({required this.kategori, String? selectedKategoriId})
      : super(kategori: kategori, selectedKategoriId: selectedKategoriId);

  @override
  List<Object?> get props => [kategori, selectedKategoriId];
}

class KategoriFailure extends EditProductState {
  final String message;

  const KategoriFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

//
// 🔹 Update / Save Status
//
class EditProductSavingToDB extends EditProductState {}

class EditProductSavedOnly extends EditProductState {
  final UpdateProduct savedProduct;

  const EditProductSavedOnly(
    this.savedProduct, {
    List<Kategori>? kategori,
    String? selectedKategoriId,
  }) : super(kategori: kategori, selectedKategoriId: selectedKategoriId);

  @override
  List<Object?> get props => [savedProduct, kategori, selectedKategoriId];
}

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

//
// 🔹 Popup Pilih Satuan untuk Shopee
//
class SatuanShopeeLoading extends EditProductState {}

class SatuanShopeeLoaded extends EditProductState {
  final List<StokProduct> satuanList;

  const SatuanShopeeLoaded({required this.satuanList});

  @override
  List<Object?> get props => [satuanList];
}

class SatuanShopeeSelected extends EditProductState {
  final String selectedSatuan;
  final String idProduct;

  const SatuanShopeeSelected({
    required this.selectedSatuan,
    required this.idProduct,
  });

  @override
  List<Object?> get props => [selectedSatuan, idProduct];
}

class SatuanShopeeFailure extends EditProductState {
  final String message;

  const SatuanShopeeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
