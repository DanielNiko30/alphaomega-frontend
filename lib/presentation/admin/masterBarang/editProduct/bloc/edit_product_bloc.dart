import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../model/product/edit_productView_model.dart'
    as editProductView;
import '../../../../../model/product/edit_productView_model.dart';
import '../../../../../model/product/stok_model.dart' as stokModel;
import '../../../../../model/product/update_product_model.dart';
import '../../../../../model/product/kategori_model.dart';
import '../../../../../model/product/latest_product_model.dart';
import '../../../../../controller/admin/product_controller.dart';
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
  }

  /// ✅ Helper: Parse stokList supaya aman + trace
  List<stokModel.StokProduct> parseStokList(List<dynamic> rawStokList) {
    print("=== TRACE: RAW STOK LIST ===");
    print(rawStokList);
    print("============================");

    return rawStokList.asMap().entries.map((entry) {
      final index = entry.key;
      final stok = entry.value;

      print("TRACE: Parsing stok index $index -> $stok");

      if (stok is stokModel.StokProduct) {
        print(
            "TRACE: Already StokProduct -> idShopee: ${stok.idProductShopee}");
        return stok;
      } else if (stok is editProductView.Stok) {
        print("TRACE: Stok object -> idShopee: ${stok.idProductShopee}");
        return stokModel.StokProduct(
          idStok: stok.idStok ?? '',
          satuan: stok.satuan,
          harga: stok.harga,
          jumlah: stok.jumlah,
          idProductShopee: stok.idProductShopee,
          idProductLazada: null,
        );
      } else if (stok is LatestProductStok) {
        print("TRACE: LatestProductStok -> idShopee: ${stok.idProductShopee}");
        return stokModel.StokProduct(
          idStok: stok.idStok,
          satuan: stok.satuan,
          harga: stok.harga,
          jumlah: stok.stokQty,
          idProductShopee: stok.idProductShopee,
          idProductLazada: null,
        );
      } else if (stok is Map<String, dynamic>) {
        print("TRACE: Stok Map JSON -> ${jsonEncode(stok)}");
        final parsed = stokModel.StokProduct.fromJson(stok);
        print(
            "TRACE: Map parsed -> satuan: ${parsed.satuan}, idShopee: ${parsed.idProductShopee}");
        return parsed;
      } else if (stok is String) {
        final parsedJson = jsonDecode(stok);
        if (parsedJson is Map<String, dynamic>) {
          final parsed = stokModel.StokProduct.fromJson(parsedJson);
          print(
              "TRACE: JSON string parsed -> satuan: ${parsed.satuan}, idShopee: ${parsed.idProductShopee}");
          return parsed;
        } else {
          throw Exception("JSON stok bukan Map: $parsedJson");
        }
      } else {
        throw Exception(
            "Tipe stok tidak dikenali di index $index -> ${stok.runtimeType}");
      }
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
      print("TRACE: ERROR load kategori -> $e");
      emit(KategoriFailure(message: "Gagal memuat kategori: ${e.toString()}"));
    }
  }

  /// ✅ Load Produk by ID
  Future<void> _onLoadProduct(
      LoadProduct event, Emitter<EditProductState> emit) async {
    emit(EditProductLoading());
    try {
      final product = await ProductController.getProductById(event.productId);
      final kategoriList = await ProductController.fetchKategori();

      print("=== TRACE: Loaded product ===");
      print(product.toJson());
      print("============================");

      for (var s in product.stokList) {
        print(
            "TRACE: Stok -> satuan: ${s.satuan}, harga: ${s.harga}, jumlah: ${s.jumlah}, idShopee: ${s.idProductShopee}");
      }

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

  /// ✅ Update Produk + return idShopee dan idLazada
  Future<void> _onUpdateProduct(
      SubmitUpdateProduct event, Emitter<EditProductState> emit) async {
    emit(EditProductLoading());
    try {
      print("DEBUG: Update Product Dipanggil!");
      print("DEBUG: ID Produk -> ${event.product.idProduct}");
      print("DEBUG: Data Produk -> ${event.product.toJson()}");
      print(
          "DEBUG: Image Bytes -> ${event.imageBytes?.lengthInBytes ?? 0} bytes");

      final response = await ProductController.updateProduct(
        id: event.product.idProduct,
        product: event.product,
        imageBytes: event.imageBytes,
      );

      print("DEBUG: Response status -> ${response?.statusCode}");
      print("DEBUG: Response data -> ${response?.data}");

      if (response != null && response.statusCode == 200) {
        // ✅ Ambil latest product setelah update
        final latest = await ProductController.getLatestProduct(
            productId: event.product.idProduct);

        final parsedStokList = parseStokList(latest.stok);

        final updatedProduct = UpdateProduct(
          idProduct: latest.idProduct,
          productKategori: latest.productKategori,
          namaProduct: latest.namaProduct,
          gambarProduct: latest.gambarProduct,
          deskripsiProduct: latest.deskripsiProduct,
          stokList: parsedStokList,
          idProductShopee: latest.idProductShopee, // ✅ tambahan
          idProductLazada: latest.idProductLazada, // ✅ tambahan
        );

        print("DEBUG: Product berhasil diupdate -> $updatedProduct");
        emit(EditProductUpdated(updatedProduct, kategori: state.kategori));

        // ✅ Reload halaman
        add(LoadProduct(event.product.idProduct));
      } else {
        emit(EditProductFailure(
          "Gagal memperbarui produk: ${response?.data?['message'] ?? 'Unknown error'}",
          kategori: state.kategori,
        ));
      }
    } catch (e, stacktrace) {
      print("DEBUG: ERROR saat update -> $e");
      print("DEBUG: STACKTRACE -> $stacktrace");
      emit(EditProductFailure("Error: ${e.toString()}",
          kategori: state.kategori));
    }
  }

  /// ✅ Save Only Product
  Future<void> _onSaveOnlyProduct(
      SaveOnlyProduct event, Emitter<EditProductState> emit) async {
    emit(EditProductLoading());
    try {
      final response = await ProductController.updateProduct(
        id: event.product.idProduct,
        product: event.product,
        imageBytes: event.imageBytes,
      );

      if (response != null && response.statusCode == 200) {
        final latest = await ProductController.getLatestProduct(
            productId: event.product.idProduct);

        final parsedStokList = parseStokList(latest.stok);

        final updatedProduct = UpdateProduct(
          idProduct: latest.idProduct,
          productKategori: latest.productKategori,
          namaProduct: latest.namaProduct,
          gambarProduct: latest.gambarProduct,
          deskripsiProduct: latest.deskripsiProduct,
          stokList: parsedStokList,
          idProductShopee: latest.idProductShopee, // ✅ tambahan
          idProductLazada: latest.idProductLazada, // ✅ tambahan
        );

        print(
            "DEBUG LOAD AFTER SAVE ONLY -> idProduct: ${updatedProduct.idProduct}");
        for (var s in updatedProduct.stokList) {
          print(
              "DEBUG LOAD AFTER SAVE ONLY STOK -> Satuan: ${s.satuan}, Harga: ${s.harga}, Jumlah: ${s.jumlah}, idShopee: ${s.idProductShopee ?? 'null'}");
        }

        emit(EditProductSavedOnly(updatedProduct, kategori: state.kategori));

        // ✅ Reload halaman
        add(LoadProduct(event.product.idProduct));
      } else {
        emit(EditProductFailure(
          "Gagal save produk: ${response?.data?['message'] ?? 'Unknown error'}",
          kategori: state.kategori,
        ));
      }
    } catch (e) {
      print("DEBUG: ERROR saat save only -> $e");
      emit(EditProductFailure("Error save produk: ${e.toString()}",
          kategori: state.kategori));
    }
  }

  /// ✅ Load Satuan Shopee (button edit Shopee)
  Future<void> _onLoadSatuanForShopeeEdit(
      LoadSatuanForShopeeEdit event, Emitter<EditProductState> emit) async {
    emit(SatuanShopeeLoading());
    try {
      final latest =
          await ProductController.getLatestProduct(productId: event.productId);

      print("=== TRACE: Stok RAW FROM LATEST PRODUCT ===");
      print(latest.stok);
      print("==========================================");

      final List<stokModel.StokProduct> stokList = parseStokList(latest.stok);

      print("=== TRACE: Parsed stok with idShopee ===");
      for (var s in stokList) {
        print(
            "TRACE: Stok -> satuan: ${s.satuan}, harga: ${s.harga}, jumlah: ${s.jumlah}, idShopee: ${s.idProductShopee}");
      }

      final availableSatuan =
          stokList.where((s) => s.idProductShopee != null).toList();

      if (availableSatuan.isEmpty) {
        print("TRACE: Tidak ada satuan dengan idShopee");
        emit(const SatuanShopeeFailure(
            "Tidak ada satuan yang terhubung ke Shopee"));
      } else {
        emit(SatuanShopeeLoaded(satuanList: availableSatuan));
      }
    } catch (e, st) {
      print("TRACE: ERROR load satuan Shopee -> $e");
      print(st);
      emit(SatuanShopeeFailure("Gagal memuat satuan: ${e.toString()}"));
    }
  }

  /// ✅ Select Satuan Shopee
  void _onSelectSatuanForShopee(
      SelectSatuanForShopee event, Emitter<EditProductState> emit) {
    print(
        "TRACE: Satuan Shopee dipilih -> ${event.selectedSatuan} | ProductID: ${event.idProduct}");
    emit(SatuanShopeeSelected(
      selectedSatuan: event.selectedSatuan,
      idProduct: event.idProduct,
    ));
  }

  /// ✅ Select Kategori
  void _onSelectKategori(SelectKategori event, Emitter<EditProductState> emit) {
    if (state is EditProductLoaded) {
      final currentState = state as EditProductLoaded;
      print("TRACE: Kategori dipilih -> ${event.kategoriId}");
      emit(EditProductLoaded(
        currentState.product,
        kategori: currentState.kategori,
        selectedKategoriId: event.kategoriId,
      ));
    }
  }
}
