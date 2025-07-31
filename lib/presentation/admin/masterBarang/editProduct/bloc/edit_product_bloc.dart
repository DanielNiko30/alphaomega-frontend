import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../model/product/edit_productView_model.dart'
    as editProductView;
import '../../../../../model/product/stok_model.dart';
import '../../../../../model/product/stok_model.dart' as stokModel;
import '../../../../../model/product/update_product_model.dart';
import '../../../../../model/product/kategori_model.dart';
import '../../../../../controller/admin/product_controller.dart';
import 'edit_product_event.dart';
import 'edit_product_state.dart';

class EditProductBloc extends Bloc<EditProductEvent, EditProductState> {
  final ProductController productRepository;

  EditProductBloc({required this.productRepository})
      : super(EditProductInitial()) {
    on<LoadProduct>(_onLoadProduct);
    on<LoadKategori>(_onLoadKategori);
    on<SubmitUpdateProduct>(_onUpdateProduct);
    on<SelectKategori>(_onSelectKategori);
  }

  /// 🔹 **Memuat Data Kategori**
  Future<void> _onLoadKategori(
      LoadKategori event, Emitter<EditProductState> emit) async {
    emit(KategoriLoading());

    try {
      final kategoriList = await ProductController.fetchKategori();
      emit(KategoriLoaded(kategori: kategoriList));
    } catch (e) {
      emit(KategoriFailure(message: "Gagal memuat kategori: ${e.toString()}"));
    }
  }

  /// 🔹 **Memuat Data Produk berdasarkan ID**
  Future<void> _onLoadProduct(
      LoadProduct event, Emitter<EditProductState> emit) async {
    emit(EditProductLoading());
    try {
      final product = await ProductController.getProductById(event.productId);
      final kategoriList = await ProductController.fetchKategori();

      // Cari kategori yang sesuai
      String? selectedKategoriId = kategoriList
          .firstWhere(
            (kategori) => kategori.idKategori == product.kategori,
            orElse: () => Kategori(idKategori: '', namaKategori: ''),
          )
          .idKategori;

      emit(EditProductLoaded(
        product,
        kategori: kategoriList,
        selectedKategoriId:
            selectedKategoriId.isNotEmpty ? selectedKategoriId : null,
      ));
    } catch (e) {
      emit(EditProductFailure("Gagal memuat produk: ${e.toString()}"));
    }
  }

  /// 🔹 **Mengupdate Produk**
  Future<void> _onUpdateProduct(
      SubmitUpdateProduct event, Emitter<EditProductState> emit) async {
    emit(EditProductLoading());
    try {
      print("DEBUG: Data produk sebelum update -> ${event.product.toJson()}");
      final response = await ProductController.updateProduct(
        id: event.product.idProduct,
        product: event.product,
        imageBytes: event.imageBytes,
      );

      if (response != null && response.statusCode == 200) {
        // 🔹 Ambil ulang produk yang telah diperbarui
        final updatedProductResponse =
            await ProductController.getProductById(event.product.idProduct);

        // 🔹 Pastikan `stokList` sudah dalam bentuk List<Stok>
        final updatedStokList = updatedProductResponse.stokList
            .map(
                (stok) => stokModel.Stok.fromJson(stok as Map<String, dynamic>))
            .toList();

        final updatedProduct = UpdateProduct(
          idProduct: updatedProductResponse.idProduct,
          productKategori: updatedProductResponse.productKategori,
          namaProduct: updatedProductResponse.namaProduct,
          gambarProduct: updatedProductResponse.gambarProduct,
          deskripsiProduct: updatedProductResponse.deskripsiProduct,
          stokList: updatedProductResponse.stokList
              .map((stok) =>
                  stokModel.Stok.fromJson(stok as Map<String, dynamic>))
              .toList(), // ✅ Convert to correct Stok type
        );

        emit(EditProductUpdated(updatedProduct, kategori: state.kategori));
      } else {
        emit(EditProductFailure(
          "Gagal memperbarui produk: ${response?.data?['message'] ?? 'Unknown error'}",
          kategori: state.kategori,
        ));
      }
    } catch (e) {
      emit(EditProductFailure("Error: ${e.toString()}",
          kategori: state.kategori));
    }
  }

  /// 🔹 **Memperbarui Kategori yang Dipilih**
  void _onSelectKategori(SelectKategori event, Emitter<EditProductState> emit) {
    if (state is EditProductLoaded) {
      final currentState = state as EditProductLoaded;
      emit(EditProductLoaded(
        currentState.product,
        kategori: currentState.kategori,
        selectedKategoriId: event.kategoriId,
      ));
    }
  }
}
