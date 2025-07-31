import '../../../../../model/product/kategori_model.dart';

abstract class KategoriState {}

class KategoriInitial extends KategoriState {}

class KategoriLoading extends KategoriState {}

class KategoriLoaded extends KategoriState {
  final List<Kategori> listKategori;

  KategoriLoaded(this.listKategori);
}

class KategoriError extends KategoriState {
  final String message;

  KategoriError(this.message);
}
