import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/product_controller.dart';
import 'add_kategori_event.dart';
import 'add_kategori_state.dart';

class KategoriBloc extends Bloc<KategoriEvent, KategoriState> {
  KategoriBloc(ProductController productController) : super(KategoriInitial()) {
    on<FetchKategori>(_onFetchKategori);
    on<AddKategori>(_onAddKategori);
  }

  Future<void> _onFetchKategori(
      FetchKategori event, Emitter<KategoriState> emit) async {
    emit(KategoriLoading());
    try {
      final kategoriList = await ProductController.fetchKategori();
      emit(KategoriLoaded(kategoriList));
    } catch (e) {
      emit(KategoriError("Gagal memuat data kategori"));
    }
  }

  void _onAddKategori(AddKategori event, Emitter<KategoriState> emit) async {
    emit(KategoriLoading());
    try {
      final success = await ProductController.addKategori(event.namaKategori);
      if (success) {
        final kategoriList = await ProductController.fetchKategori();
        emit(KategoriLoaded(kategoriList));
      } else {
        emit(KategoriError("Gagal menambahkan kategori"));
      }
    } catch (e) {
      emit(KategoriError("Gagal menambahkan kategori: ${e.toString()}"));
    }
  }
}
