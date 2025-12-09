import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../bloc/list_product_event.dart';
import '../bloc/list_product_state.dart';

class ListProductBloc extends Bloc<ListProductEvent, ListProductState> {
  // default timeout untuk request jaringan
  static const Duration requestTimeout = Duration(seconds: 8);

  ListProductBloc() : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<FetchProductsWithStok>(_onFetchProductsWithStok);
    on<KonversiStokEvent>(_onKonversiStok);
  }

  /// === Ambil semua produk ===
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

  /// === Ambil semua produk + stok ===
  Future<void> _onFetchProductsWithStok(
      FetchProductsWithStok event, Emitter<ListProductState> emit) async {
    try {
      emit(ProductLoading());
      final products = await ProductController.getAllProductsWithStok();

      if (products.isEmpty) {
        emit(ProductError("Tidak ada produk ditemukan"));
      } else {
        emit(ProductWithStokLoaded(products));
      }
    } catch (e) {
      emit(ProductError("Gagal mengambil data produk dengan stok: $e"));
    }
  }

  /// === Konversi stok antar satuan ===
  Future<void> _onKonversiStok(
      KonversiStokEvent event, Emitter<ListProductState> emit) async {
    try {
      emit(KonversiStokLoading());

      final result = await ProductController.konversiStok(event.konversiStok);
      emit(KonversiStokSuccess(result.message ?? "Konversi stok berhasil"));
      emit(ProductLoading());
      final products = await ProductController.getAllProductsWithStok()
          .timeout(requestTimeout, onTimeout: () {
        throw Exception(
            "Request timeout saat memuat ulang produk setelah konversi");
      });

      emit(ProductWithStokLoaded(products));
    } catch (e) {
      emit(KonversiStokFailed("Konversi stok gagal: ${e.toString()}"));
    }
  }
}
