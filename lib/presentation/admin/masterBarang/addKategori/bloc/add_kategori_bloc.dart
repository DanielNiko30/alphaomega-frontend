import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/product_controller.dart';
import 'add_kategori_event.dart';
import 'add_kategori_state.dart';

class KategoriBloc extends Bloc<KategoriEvent, KategoriState> {
  KategoriBloc(ProductController productController) : super(KategoriInitial()) {
    on<FetchKategori>(_onFetchKategori);
    on<AddKategori>(_onAddKategori);
    on<EditKategori>(_onEditKategori);
    on<SearchKategoriByName>(_onSearchKategoriByName);
    on<DeleteKategori>(_onDeleteKategori);
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

  Future<void> _onAddKategori(
      AddKategori event, Emitter<KategoriState> emit) async {
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

  Future<void> _onEditKategori(
      EditKategori event, Emitter<KategoriState> emit) async {
    emit(KategoriLoading());
    try {
      final success = await ProductController.updateKategori(
        event.idKategori,
        event.namaBaru,
      );
      if (success) {
        final kategoriList = await ProductController.fetchKategori();
        emit(KategoriLoaded(kategoriList));
      } else {
        emit(KategoriError("Gagal memperbarui kategori"));
      }
    } catch (e) {
      emit(KategoriError("Gagal memperbarui kategori: ${e.toString()}"));
    }
  }

  // 🔹 Handler search
  void _onSearchKategoriByName(
      SearchKategoriByName event, Emitter<KategoriState> emit) {
    if (state is KategoriLoaded) {
      final currentState = state as KategoriLoaded;
      final filtered = currentState.listKategori
          .where((k) =>
              k.namaKategori.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(KategoriLoaded(currentState.listKategori, filteredList: filtered));
    }
  }

  Future<void> _onDeleteKategori(
      DeleteKategori event, Emitter<KategoriState> emit) async {
    emit(KategoriLoading());
    try {
      final success = await ProductController.deleteKategori(event.idKategori);

      if (success) {
        final kategoriList = await ProductController.fetchKategori();
        emit(KategoriLoaded(kategoriList));
      } else {
        emit(KategoriError("Gagal menghapus kategori"));
      }
    } catch (e) {
      emit(KategoriError("Gagal menghapus kategori: ${e.toString()}"));
    }
  }
}
