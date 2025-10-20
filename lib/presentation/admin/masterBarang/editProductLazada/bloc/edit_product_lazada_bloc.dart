import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/lazada_controller.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../model/product/latest_product_model.dart';
import 'edit_product_lazada_event.dart';
import 'edit_product_lazada_state.dart';

class EditProductLazadaBloc
    extends Bloc<EditProductLazadaEvent, EditProductLazadaState> {
  final ProductController productController;
  final LazadaController lazadaController;

  EditProductLazadaBloc({
    required this.productController,
    required this.lazadaController,
  }) : super(EditProductLazadaInitial()) {
    on<LoadEditLazadaData>(_onLoadEditLazadaData);
    on<SelectSatuanLazada>(_onSelectSatuanLazada);
    on<SelectCategoryLazada>(_onSelectCategoryLazada);
    on<SubmitEditLazadaProduct>(_onSubmitEditLazadaProduct);
  }

  /// 🔹 Muat data produk dari Lazada + daftar kategori
  Future<void> _onLoadEditLazadaData(
    LoadEditLazadaData event,
    Emitter<EditProductLazadaState> emit,
  ) async {
    emit(EditProductLazadaLoading());
    try {
      print("🔄 Memuat data produk Lazada (item_id: ${event.itemId})");

      // === Ambil data produk dari API ===
      final productResponse =
          await lazadaController.getProductItem(event.itemId);
      final productData = productResponse['lazada_response']?['data'];

      if (productData == null) {
        throw Exception("Data produk Lazada tidak ditemukan atau null");
      }

      print(
        "✅ Data produk diterima: ${productData['attributes']?['name'] ?? '(tanpa nama)'}",
      );

      // === Ambil kategori dari Lazada ===
      final categoryResponse = await lazadaController.getCategoryTree();
      final List<dynamic> rawCategories =
          (categoryResponse['data'] ?? []) as List<dynamic>;

      // === Rekursif ambil kategori leaf ===
      final List<Map<String, dynamic>> categories = [];
      void extractLeafs(List<dynamic> items) {
        for (var item in items) {
          if (item['leaf'] == true) {
            categories.add({
              'category_id': item['category_id'].toString(),
              'name': item['name'] ?? '',
            });
          } else if (item['children'] != null) {
            extractLeafs(item['children']);
          }
        }
      }

      extractLeafs(rawCategories);

      // === Ambil data SKU pertama ===
      final skuData = (productData['skus'] as List).isNotEmpty
          ? productData['skus'][0]
          : {};

      // === Ambil category id (pastikan string & valid) ===
      final selectedCategoryId =
          productData['primary_category']?.toString() ?? '';

      // Validasi agar selectedCategoryId benar-benar ada di dropdown
      final validSelectedCategory =
          categories.any((cat) => cat['category_id'] == selectedCategoryId)
              ? selectedCategoryId
              : null;

      emit(EditProductLazadaLoaded(
        productId: event.productId,
        lazadaData: productData,
        categories: categories,
        selectedCategoryId: validSelectedCategory,
        selectedSatuan: null,
        brand: productData['attributes']?['brand'] ?? '',
        netWeight: productData['attributes']?['Net_Weight']?.toString() ?? '',
        packageLength: skuData['package_length']?.toString() ?? '',
        packageWidth: skuData['package_width']?.toString() ?? '',
        packageHeight: skuData['package_height']?.toString() ?? '',
        packageWeight: skuData['package_weight']?.toString() ?? '',
        sellerSku: skuData['SellerSku']?.toString() ?? '',
      ));

      print("✅ Data produk dan kategori berhasil dimuat");
    } catch (e, st) {
      print("❌ Gagal load produk Lazada: $e");
      print(st);
      emit(EditProductLazadaFailure(message: e.toString()));
    }
  }

  /// 🔹 Ganti satuan (jika digunakan untuk mapping stok lokal)
  void _onSelectSatuanLazada(
      SelectSatuanLazada event, Emitter<EditProductLazadaState> emit) {
    if (state is EditProductLazadaLoaded) {
      final current = state as EditProductLazadaLoaded;
      emit(current.copyWith(selectedSatuan: event.selectedSatuan));
    }
  }

  /// 🔹 Ganti kategori Lazada
  void _onSelectCategoryLazada(
      SelectCategoryLazada event, Emitter<EditProductLazadaState> emit) {
    if (state is EditProductLazadaLoaded) {
      final current = state as EditProductLazadaLoaded;
      emit(current.copyWith(selectedCategoryId: event.selectedCategoryId));
    }
  }

  /// 🔹 Submit perubahan ke Lazada
  Future<void> _onSubmitEditLazadaProduct(
    SubmitEditLazadaProduct event,
    Emitter<EditProductLazadaState> emit,
  ) async {
    if (state is! EditProductLazadaLoaded) return;
    final current = state as EditProductLazadaLoaded;

    emit(EditProductLazadaSubmitting());
    try {
      print("🚀 Mengirim update produk ke Lazada...");

      // 🔹 Gunakan productId lokal
      final localProductId = current.productId;

      // 🔹 Kirim request ke LazadaController
      final response = await lazadaController.updateProductLazada(
        idProduct: localProductId,
        categoryId: current.selectedCategoryId ?? '',
        selectedUnit: current.selectedSatuan?.satuan ?? '',
        attributes: {
          "brand": event.brand,
          "Net_Weight": event.netWeight,
          "package_height": event.packageHeight,
          "package_length": event.packageLength,
          "package_width": event.packageWidth,
          "package_weight": event.packageWeight,
          "SellerSku": event.sellerSku,
        },
      );

      if (response['success'] == true) {
        emit(EditProductLazadaSuccess(
          message: response['message'] ?? "Produk berhasil diupdate!",
        ));
      } else {
        emit(EditProductLazadaFailure(
          message: response['message'] ?? "Gagal update produk Lazada",
        ));
      }
    } catch (e, st) {
      print("❌ Error update produk Lazada: $e");
      print(st);
      emit(EditProductLazadaFailure(message: e.toString()));
    }
  }
}
