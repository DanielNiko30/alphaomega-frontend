import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../controller/admin/shopee_controller.dart';
import '../../../../../model/product/latest_product_model.dart';
import '../../../../../model/product/product_shopee_model.dart';
import '../../../../../model/product/shope_model.dart';
import 'add_product_shopee_event.dart';
import 'add_product_shopee_state.dart';

class AddProductShopeeBloc
    extends Bloc<AddProductShopeeEvent, AddProductShopeeState> {
  final ProductController productController;

  AddProductShopeeBloc({required this.productController})
      : super(AddProductShopeeInitial()) {
    on<LoadAddShopeeData>(_onLoadAddShopeeData);
    on<SelectSatuanShopee>(_onSelectSatuanShopee);
    on<SelectCategoryShopee>(_onSelectCategoryShopee);
    on<SelectLogisticShopee>(_onSelectLogisticShopee);
    on<SubmitAddShopeeProduct>(_onSubmitAddShopeeProduct);
  }

  /// Load data: stok, kategori, logistic
  Future<void> _onLoadAddShopeeData(
      LoadAddShopeeData event, Emitter<AddProductShopeeState> emit) async {
    emit(AddProductShopeeLoading());

    try {
      // === PERUBAHAN DISINI ===
      // Sekarang ambil product berdasarkan ID jika diberikan,
      // kalau tidak, ambil produk terbaru
      final LatestProduct latestProduct =
          await ProductController.getLatestProduct(
        productId: event.productId, // <-- param opsional
      );

      if (latestProduct.stok.isEmpty) {
        emit(AddProductShopeeFailure(message: "Produk tidak memiliki stok"));
        return;
      }

      final List<StokShopee> stokList = latestProduct.stok.map((s) {
        return StokShopee(
          satuan: s.satuan,
          harga: s.harga,
          stokQty: s.stokQty,
          idProductShopee: s.idProductShopee, // ✅ ambil dari LatestProductStok
        );
      }).toList();

      final categories = await ShopeeController.getCategories();
      final logistics = await ShopeeController.getLogistics();

      print("=== DEBUG LoadAddShopeeData ===");
      print("Stok List: $stokList");
      print("Categories: ${categories.map((c) => c.categoryName).toList()}");
      print("Logistics: ${logistics.map((l) => l.name).toList()}");

      emit(AddProductShopeeLoaded(
        product: latestProduct,
        stokList: stokList,
        selectedSatuan: stokList.isNotEmpty ? stokList.first : null,
        categories: categories,
        selectedCategory: categories.isNotEmpty ? categories.first : null,
        logistics: logistics,
        selectedLogistic: logistics.isNotEmpty ? logistics.first : null,
      ));
    } catch (e, st) {
      print("ERROR LoadAddShopeeData: $e\n$st");
      emit(AddProductShopeeFailure(
          message: "Gagal memuat data Shopee: ${e.toString()}"));
    }
  }

  /// Update satuan
  void _onSelectSatuanShopee(
      SelectSatuanShopee event, Emitter<AddProductShopeeState> emit) {
    if (state is AddProductShopeeLoaded) {
      final current = state as AddProductShopeeLoaded;
      emit(current.copyWith(selectedSatuan: event.selectedSatuan));
      print("Selected Satuan: ${event.selectedSatuan.satuan}");
    }
  }

  /// Update kategori
  void _onSelectCategoryShopee(
      SelectCategoryShopee event, Emitter<AddProductShopeeState> emit) {
    if (state is AddProductShopeeLoaded) {
      final current = state as AddProductShopeeLoaded;
      emit(current.copyWith(selectedCategory: event.selectedCategory));
      print("Selected Category: ${event.selectedCategory.categoryName}");
    }
  }

  /// Update logistic
  void _onSelectLogisticShopee(
      SelectLogisticShopee event, Emitter<AddProductShopeeState> emit) {
    if (state is AddProductShopeeLoaded) {
      final current = state as AddProductShopeeLoaded;
      emit(current.copyWith(selectedLogistic: event.selectedLogistic));
      print("Selected Logistic: ${event.selectedLogistic.name}");
    }
  }

  /// Submit produk ke Shopee
  Future<void> _onSubmitAddShopeeProduct(
      SubmitAddShopeeProduct event, Emitter<AddProductShopeeState> emit) async {
    if (state is! AddProductShopeeLoaded) return;

    final current = state as AddProductShopeeLoaded;

    if (current.selectedSatuan == null ||
        current.selectedCategory == null ||
        current.selectedLogistic == null) {
      emit(AddProductShopeeFailure(
          message: "Satuan, kategori, dan logistic harus dipilih"));
      return;
    }

    emit(AddProductShopeeSubmitting());

    try {
      // Pilih maskChannelId jika ada
      final logisticIdToSubmit = current.selectedLogistic!.maskChannelId != 0
          ? current.selectedLogistic!.maskChannelId
          : current.selectedLogistic!.id;

      final response = await ShopeeController.createProduct(
        idProduct: current.product.idProduct,
        itemSku: event.itemSku,
        weight: event.weight,
        dimension: event.dimension,
        condition: event.condition,
        logisticId: logisticIdToSubmit, // pakai maskChannelId
        categoryId: current.selectedCategory!.categoryId,
        brandName: event.brandName ?? 'No Brand',
        brandId: 0,
        selectedUnit: current.selectedSatuan!.satuan,
      );

      print("Shopee Response: $response");

      if (response['success'] == true) {
        emit(AddProductShopeeSuccess(
            message: "Produk berhasil ditambahkan ke Shopee"));
      } else {
        emit(AddProductShopeeFailure(
            message: response['message'] ?? "Gagal menambahkan ke Shopee"));
      }
    } catch (e, st) {
      print("ERROR SubmitAddShopeeProduct: $e\n$st");
      emit(AddProductShopeeFailure(
          message: "Error submit Shopee: ${e.toString()}"));
    }
  }
}
