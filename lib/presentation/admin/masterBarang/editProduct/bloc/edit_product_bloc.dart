import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../model/product/edit_productView_model.dart'
    as editProductView;
import '../../../../../model/product/edit_productView_model.dart';
import '../../../../../model/product/stok_model.dart' as stokModel;
import '../../../../../model/product/stok_model.dart';
import '../../../../../model/product/update_product_model.dart';
import '../../../../../model/product/kategori_model.dart';
import '../../../../../model/product/latest_product_model.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../listProduct/bloc/list_product_event.dart';
import 'edit_product_event.dart';
import 'edit_product_state.dart';

class EditProductBloc extends Bloc<EditProductEvent, EditProductState> {
  final ProductController productRepository;

  EditProductBloc({required this.productRepository})
      : super(EditProductInitial()) {
    on<LoadProduct>(_onLoadProduct);
    on<LoadKategori>(_onLoadKategori);
    on<SelectKategori>(_onSelectKategori);
    on<SubmitUpdateProduct>(_onUpdateProduct);
    on<SaveOnlyProduct>(_onSaveOnlyProduct);
    on<LoadSatuanForShopeeEdit>(_onLoadSatuanForShopeeEdit);
    on<SelectSatuanForShopee>(_onSelectSatuanForShopee);
    on<DeleteStokEvent>(_onDeleteStok); // ✅ Tambahan handler baru
  }

  /// ✅ Helper: parse stok list aman
  List<stokModel.StokProduct> parseStokList(List<dynamic> rawStokList) {
    return rawStokList.map((stok) {
      if (stok is stokModel.StokProduct) return stok;
      if (stok is editProductView.Stok) {
        return stokModel.StokProduct(
          idStok: stok.idStok ?? '',
          satuan: stok.satuan,
          harga: stok.harga,
          jumlah: stok.jumlah,
          idProductShopee: stok.idProductShopee,
          idProductLazada: stok.idProductLazada,
        );
      }
      if (stok is LatestProductStok) {
        return stokModel.StokProduct(
          idStok: stok.idStok,
          satuan: stok.satuan,
          harga: stok.harga,
          jumlah: stok.stokQty,
          idProductShopee: stok.idProductShopee,
          idProductLazada: stok.idProductLazada,
        );
      }
      if (stok is Map<String, dynamic>) {
        return stokModel.StokProduct.fromJson(stok);
      }
      throw Exception("Tipe stok tidak dikenali: ${stok.runtimeType}");
    }).toList();
  }

  /// ✅ Load Kategori
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

  /// ✅ Load Product by ID
  Future<void> _onLoadProduct(
      LoadProduct event, Emitter<EditProductState> emit) async {
    emit(EditProductLoading());
    try {
      final product = await ProductController.getProductById(event.productId);
      final kategoriList = await ProductController.fetchKategori();

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
    } catch (e, st) {
      print("TRACE: ERROR load product -> $e");
      print(st);
      emit(EditProductFailure("Gagal memuat produk: ${e.toString()}"));
    }
  }

  /// ✅ Update Product
  Future<void> _onUpdateProduct(
    SubmitUpdateProduct event,
    Emitter<EditProductState> emit,
  ) async {
    emit(EditProductLoading());
    try {
      // Pisahkan stok lama & stok baru
      final oldStokList =
          event.product.stokList.where((s) => s.idStok != null).toList();
      final newStokList =
          event.product.stokList.where((s) => s.idStok == null).toList();

      final combinedStokList = [...oldStokList, ...newStokList];

      final productToSend = event.product.copyWith(stokList: combinedStokList);

      // Kirim ke backend
      final response = await ProductController.updateProduct(
        id: event.product.idProduct,
        product: productToSend,
        imageBytes: event.imageBytes,
      );

      if (response != null && response.statusCode == 200) {
        // Ambil produk terbaru
        final latest = await ProductController.getLatestProduct(
            productId: event.product.idProduct);

        // Pastikan stok selalu list
        final List<dynamic> stokJsonList =
            latest.stok is List ? latest.stok : [];

        final parsedStokList = stokJsonList.map((e) {
          // Jika e adalah object (LatestProductStok), pakai dot
          if (e is LatestProductStok) {
            return StokProduct(
              idStok: e.idStok,
              satuan: e.satuan,
              jumlah: e.stokQty,
              harga: e.harga,
              idProductShopee: e.idProductShopee?.toString(),
              idProductLazada: e.idProductLazada?.toString(),
            );
          } else if (e is Map<String, dynamic>) {
            // fallback kalau Map
            return StokProduct(
              idStok: e['id_stok'],
              satuan: e['satuan'] ?? "",
              jumlah: e['jumlah'] ?? 0,
              harga: e['harga'] ?? 0,
              idProductShopee: e['id_product_shopee']?.toString(),
              idProductLazada: e['id_product_lazada']?.toString(),
            );
          } else {
            throw Exception("Unknown stok type");
          }
        }).toList();

        final updatedProduct = UpdateProduct(
          idProduct: latest.idProduct,
          productKategori: latest.productKategori,
          namaProduct: latest.namaProduct,
          gambarProduct: latest.gambarProduct,
          deskripsiProduct: latest.deskripsiProduct,
          stokList: parsedStokList,
          idProductShopee: latest.idProductShopee,
          idProductLazada: latest.idProductLazada,
        );

        emit(EditProductUpdated(updatedProduct, kategori: state.kategori));
        add(LoadProduct(event.product.idProduct)); // reload
      } else {
        emit(EditProductFailure(
          "Gagal memperbarui produk: ${response?.data?['message'] ?? 'Unknown'}",
          kategori: state.kategori,
        ));
      }
    } catch (e, stacktrace) {
      print("ERROR update -> $e");
      print(stacktrace);
      emit(EditProductFailure(
        "Error: ${e.toString()}",
        kategori: state.kategori,
      ));
    }
  }

  Future<void> _onSaveOnlyProduct(
    SaveOnlyProduct event,
    Emitter<EditProductState> emit,
  ) async {
    emit(EditProductLoading());
    try {
      final oldStokList =
          event.product.stokList.where((s) => s.idStok != null).toList();
      final newStokList =
          event.product.stokList.where((s) => s.idStok == null).toList();

      final combinedStokList = [...oldStokList, ...newStokList];

      final productToSend = event.product.copyWith(stokList: combinedStokList);

      final response = await ProductController.updateProduct(
        id: event.product.idProduct,
        product: productToSend,
        imageBytes: event.imageBytes,
      );

      if (response != null && response.statusCode == 200) {
        final latest = await ProductController.getLatestProduct(
            productId: event.product.idProduct);

        final List<dynamic> stokJsonList =
            latest.stok is List ? latest.stok : [];

        final parsedStokList = stokJsonList.map((e) {
          if (e is LatestProductStok) {
            return StokProduct(
              idStok: e.idStok,
              satuan: e.satuan,
              jumlah: e.stokQty,
              harga: e.harga,
              idProductShopee: e.idProductShopee?.toString(),
              idProductLazada: e.idProductLazada?.toString(),
            );
          } else if (e is Map<String, dynamic>) {
            return StokProduct(
              idStok: e['id_stok'],
              satuan: e['satuan'] ?? "",
              jumlah: e['jumlah'] ?? 0,
              harga: e['harga'] ?? 0,
              idProductShopee: e['id_product_shopee']?.toString(),
              idProductLazada: e['id_product_lazada']?.toString(),
            );
          } else {
            throw Exception("Unknown stok type");
          }
        }).toList();

        final updatedProduct = UpdateProduct(
          idProduct: latest.idProduct,
          productKategori: latest.productKategori,
          namaProduct: latest.namaProduct,
          gambarProduct: latest.gambarProduct,
          deskripsiProduct: latest.deskripsiProduct,
          stokList: parsedStokList,
          idProductShopee: latest.idProductShopee,
          idProductLazada: latest.idProductLazada,
        );

        emit(EditProductSavedOnly(updatedProduct, kategori: state.kategori));
        add(LoadProduct(event.product.idProduct));
      } else {
        emit(EditProductFailure(
          "Gagal save produk: ${response?.data?['message'] ?? 'Unknown'}",
          kategori: state.kategori,
        ));
      }
    } catch (e, stacktrace) {
      print("ERROR saveOnly -> $e");
      print(stacktrace);
      emit(EditProductFailure(
        "Error save produk: ${e.toString()}",
        kategori: state.kategori,
      ));
    }
  }

  Future<void> _onDeleteStok(
    DeleteStokEvent event,
    Emitter<EditProductState> emit,
  ) async {
    try {
      emit(EditProductLoading());

      final success = await ProductController.deleteStok(event.idStok);

      if (success) {
        print("TRACE: Stok berhasil di-nonaktifkan di backend");
        emit(EditProductSuccess("Stok berhasil dihapus"));

        // reload product agar tampilan update
        if (state is EditProductLoaded) {
          final currentState = state as EditProductLoaded;
          add(LoadProduct(currentState.product.idProduct));
        }
      } else {
        emit(EditProductFailure("Gagal menghapus stok"));
      }
    } catch (e) {
      emit(EditProductFailure("Terjadi kesalahan: ${e.toString()}"));
    }
  }

  /// ✅ Load satuan Shopee
  Future<void> _onLoadSatuanForShopeeEdit(
      LoadSatuanForShopeeEdit event, Emitter<EditProductState> emit) async {
    emit(SatuanShopeeLoading());
    try {
      final latest =
          await ProductController.getLatestProduct(productId: event.productId);
      final stokList = parseStokList(latest.stok);
      final availableSatuan =
          stokList.where((s) => s.idProductShopee != null).toList();

      if (availableSatuan.isEmpty) {
        emit(const SatuanShopeeFailure("Tidak ada satuan Shopee"));
      } else {
        emit(SatuanShopeeLoaded(satuanList: availableSatuan));
      }
    } catch (e) {
      emit(SatuanShopeeFailure("Gagal load satuan: ${e.toString()}"));
    }
  }

  /// ✅ Select satuan Shopee
  void _onSelectSatuanForShopee(
      SelectSatuanForShopee event, Emitter<EditProductState> emit) {
    emit(SatuanShopeeSelected(
      selectedSatuan: event.selectedSatuan,
      idProduct: event.idProduct,
    ));
  }

  /// ✅ Select kategori
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
