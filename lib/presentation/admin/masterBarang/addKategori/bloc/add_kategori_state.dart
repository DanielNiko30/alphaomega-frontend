import '../../../../../model/product/kategori_model.dart';

abstract class KategoriState {}

class KategoriInitial extends KategoriState {}

class KategoriLoading extends KategoriState {}

class KategoriLoaded extends KategoriState {
  final List<Kategori> listKategori;
  final List<Kategori>? filteredList; // 🔹 bisa di-filter

  KategoriLoaded(this.listKategori, {this.filteredList});
}

class KategoriError extends KategoriState {
  final String message;
  KategoriError(this.message);
}
