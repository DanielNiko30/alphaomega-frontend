import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../controller/admin/lazada_controller.dart';
import '../../../../../model/product/latest_product_model.dart';
import 'add_product_lazada_event.dart';
import 'add_product_lazada_state.dart';

class AddProductLazadaBloc
    extends Bloc<AddProductLazadaEvent, AddProductLazadaState> {
  final ProductController productController;
  final LazadaController lazadaController;

  AddProductLazadaBloc({
    required this.productController,
    required this.lazadaController,
  }) : super(AddProductLazadaInitial()) {
    on<LoadAddLazadaData>(_onLoadAddLazadaData);
    on<SelectSatuanLazada>(_onSelectSatuanLazada);
    on<SelectCategoryLazada>(_onSelectCategoryLazada);
    on<SubmitAddLazadaProduct>(_onSubmitAddLazadaProduct);
  }

  Future<void> _onLoadAddLazadaData(
      LoadAddLazadaData event, Emitter<AddProductLazadaState> emit) async {
    emit(AddProductLazadaLoading());
    try {
      print(
          "🔄 [AddProductLazadaBloc] Memuat data produk dan kategori Lazada...");

      final product =
          await ProductController.getLatestProduct(productId: event.productId);
      final stokList = product.stok;

      print("✅ Produk berhasil diambil: ${product.namaProduct}");
      print("📦 Jumlah stok ditemukan: ${stokList.length}");

      final categoriesResponse = await lazadaController.getCategoryTree();
      final categories = categoriesResponse['data'] ?? [];

      print(
          "📂 Jumlah kategori diterima dari Lazada API: ${categories.length}");

      emit(AddProductLazadaLoaded(
        product: product,
        stokList: stokList,
        selectedSatuan: stokList.isNotEmpty ? stokList.first : null,
        categories: categories,
        selectedCategory: null, // kategori dikosongkan dulu, user pilih manual
      ));
    } catch (e) {
      print("❌ [AddProductLazadaBloc] Gagal load data: $e");
      emit(AddProductLazadaFailure(message: e.toString()));
    }
  }

  void _onSelectSatuanLazada(
      SelectSatuanLazada event, Emitter<AddProductLazadaState> emit) {
    if (state is AddProductLazadaLoaded) {
      final current = state as AddProductLazadaLoaded;
      print(
          "🟢 [AddProductLazadaBloc] Satuan dipilih: ${event.selectedSatuan.satuan}");
      emit(current.copyWith(selectedSatuan: event.selectedSatuan));
    }
  }

  void _onSelectCategoryLazada(
      SelectCategoryLazada event, Emitter<AddProductLazadaState> emit) {
    if (state is AddProductLazadaLoaded) {
      final current = state as AddProductLazadaLoaded;
      final cat = event.selectedCategory;

      // validasi kategori leaf
      if (cat == null || cat['leaf'] != true) {
        print(
            "⚠️ [AddProductLazadaBloc] Kategori bukan leaf atau null: ${cat?['name']}");
        emit(current.copyWith(selectedCategory: null));
        return;
      }

      print("🟣 [AddProductLazadaBloc] Kategori dipilih: "
          "${cat['name']} (ID: ${cat['category_id']}) | leaf=${cat['leaf']}");

      final updated = current.copyWith(selectedCategory: cat);
      emit(updated);

      print("✅ [AddProductLazadaBloc] State sekarang category_id: "
          "${updated.selectedCategory?['category_id']}");
    }
  }

  Future<void> _onSubmitAddLazadaProduct(
      SubmitAddLazadaProduct event, Emitter<AddProductLazadaState> emit) async {
    if (state is! AddProductLazadaLoaded) return;
    final current = state as AddProductLazadaLoaded;

    print("🚀 [AddProductLazadaBloc] Mulai submit produk ke Lazada...");
    print("🧾 Data dikirim ke backend:");
    print("   • ID Produk     : ${current.product.idProduct}");
    print("   • Nama Produk   : ${current.product.namaProduct}");
    print("   • Satuan        : ${current.selectedSatuan?.satuan}");
    print("   • Kategori ID   : ${current.selectedCategory?['category_id']}");
    print("   • Leaf Status   : ${current.selectedCategory?['leaf']}");
    print("   • Brand         : ${event.brand}");
    print("   • Net Weight    : ${event.netWeight}");
    print("   • Dimension (LxWxH): "
        "${event.packageLength} x ${event.packageWidth} x ${event.packageHeight}");
    print("   • Package Weight: ${event.packageWeight}");
    print("   • Seller SKU    : ${event.sellerSku}");

    emit(AddProductLazadaSubmitting());

    try {
      // === VALIDASI KATEGORI ===
      if (current.selectedCategory == null ||
          current.selectedCategory?['category_id'] == null) {
        throw Exception("⚠️ Kategori belum dipilih!");
      }

      if (current.selectedCategory?['leaf'] != true) {
        throw Exception("⚠️ Harus memilih kategori terakhir (leaf = true)!");
      }

      final categoryId = current.selectedCategory!['category_id'].toString();

      print(
          "📦 [AddProductLazadaBloc] Final category_id yang dikirim: $categoryId");

      // === KIRIM KE BACKEND ===
      final response = await lazadaController.createProductLazada(
        idProduct: current.product.idProduct,
        categoryId: categoryId,
        selectedUnit: current.selectedSatuan!.satuan,
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

      print("📤 [AddProductLazadaBloc] Response dari backend: $response");

      if (response['success'] == true) {
        print("✅ Produk berhasil dikirim ke Lazada.");
        emit(AddProductLazadaSuccess(
            message:
                response['message'] ?? "Produk berhasil dikirim ke Lazada"));
      } else {
        print("❌ Backend mengembalikan gagal: ${response['message']}");
        emit(AddProductLazadaFailure(
            message: response['message'] ?? "Gagal menambahkan produk"));
      }
    } catch (e, stackTrace) {
      print("❌ [AddProductLazadaBloc] Error saat submit produk ke Lazada: $e");
      print("🧠 Stacktrace: $stackTrace");
      emit(AddProductLazadaFailure(message: e.toString()));
    }
  }
}
