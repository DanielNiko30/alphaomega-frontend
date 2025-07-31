import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../bloc/list_product_event.dart';
import '../bloc/list_product_state.dart';

class ListProductBloc extends Bloc<ListProductEvent, ListProductState> {
  ListProductBloc() : super(ProductLoading()) {
    /// Event untuk memuat semua produk
    on<FetchProducts>(_onFetchProducts);

    /// Event untuk melakukan konversi stok
    on<KonversiStokEvent>(_onKonversiStok);
  }

  /// Handler untuk FetchProducts
  Future<void> _onFetchProducts(
      FetchProducts event, Emitter<ListProductState> emit) async {
    try {
      emit(ProductLoading());
      final products = await ProductController.getAllProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError("Gagal mengambil data produk: $e"));
    }
  }

  /// Handler untuk KonversiStokEvent
  Future<void> _onKonversiStok(
      KonversiStokEvent event, Emitter<ListProductState> emit) async {
    try {
      emit(KonversiStokLoading());

      // Panggil API konversi stok
      final result = await ProductController.konversiStok(event.konversiStok);

      // Emit sukses
      emit(KonversiStokSuccess(result.message ?? "Konversi stok berhasil"));

      // Refresh produk setelah sukses
      final products = await ProductController.getAllProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(KonversiStokFailed("Konversi stok gagal: ${e.toString()}"));
    }
  }
}
