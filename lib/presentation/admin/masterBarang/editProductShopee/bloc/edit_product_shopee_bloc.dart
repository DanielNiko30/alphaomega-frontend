import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/shopee_controller.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../model/product/shopee_product_info.dart';
import '../../../../../model/product/shope_model.dart';
import 'edit_product_shopee_event.dart';
import 'edit_product_shopee_state.dart';

class EditProductShopeeBloc
    extends Bloc<EditProductShopeeEvent, EditProductShopeeState> {
  final ProductController productController;

  EditProductShopeeBloc({required this.productController})
      : super(EditProductShopeeInitial()) {
    on<FetchShopeeProductDetail>(_onFetchShopeeProductDetail);
    on<SelectSatuanShopee>(_onSelectSatuanShopee);
    on<SelectCategoryShopee>(_onSelectCategoryShopee);
    on<SelectLogisticShopee>(_onSelectLogisticShopee);
    on<SubmitEditShopeeProduct>(_onSubmitEditShopeeProduct);
  }

  /// Fetch detail produk Shopee + category + logistic
  Future<void> _onFetchShopeeProductDetail(
    FetchShopeeProductDetail event,
    Emitter<EditProductShopeeState> emit,
  ) async {
    emit(EditProductShopeeLoading());
    try {
      final ShopeeProductInfo product =
          await ShopeeController.getShopeeProductInfo(
        idProduct: event.idProduct,
        satuan: event.satuan,
      );

      // Debug log untuk verifikasi
      print("=== DEBUG: Product data from backend ===");
      print(product);

      final categories = await ShopeeController.getCategories();
      final logistics = await ShopeeController.getLogistics();

      // Debug log data kategori & logistic
      print("=== DEBUG: Selected Category & Logistic ===");
      print("Categories: $categories");
      print("Logistics: $logistics");

      emit(EditProductShopeeLoaded(
        product: product,
        selectedSatuan: event.satuan, // langsung String
        categories: categories,
        selectedCategory: categories.isNotEmpty ? categories.first : null,
        logistics: logistics,
        selectedLogistic: logistics.isNotEmpty ? logistics.first : null,
      ));
    } catch (e, st) {
      print("ERROR FetchShopeeProductDetail: $e\n$st");
      emit(EditProductShopeeFailure(
          message: "Gagal memuat detail produk: ${e.toString()}"));
    }
  }

  /// Select satuan
  void _onSelectSatuanShopee(
      SelectSatuanShopee event, Emitter<EditProductShopeeState> emit) {
    if (state is EditProductShopeeLoaded) {
      final current = state as EditProductShopeeLoaded;
      emit(current.copyWith(selectedSatuan: event.selectedSatuan));
    }
  }

  /// Select category
  void _onSelectCategoryShopee(
      SelectCategoryShopee event, Emitter<EditProductShopeeState> emit) {
    if (state is EditProductShopeeLoaded) {
      final current = state as EditProductShopeeLoaded;
      emit(current.copyWith(selectedCategory: event.selectedCategory));
    }
  }

  /// Select logistic
  void _onSelectLogisticShopee(
      SelectLogisticShopee event, Emitter<EditProductShopeeState> emit) {
    if (state is EditProductShopeeLoaded) {
      final current = state as EditProductShopeeLoaded;
      emit(current.copyWith(selectedLogistic: event.selectedLogistic));
    }
  }

  /// Submit edit produk Shopee
  Future<void> _onSubmitEditShopeeProduct(
    SubmitEditShopeeProduct event,
    Emitter<EditProductShopeeState> emit,
  ) async {
    if (state is! EditProductShopeeLoaded) return;

    final current = state as EditProductShopeeLoaded;

    // Validasi
    if (current.selectedSatuan == null ||
        current.selectedCategory == null ||
        current.selectedLogistic == null) {
      emit(EditProductShopeeFailure(
          message: "Satuan, kategori, dan logistic harus dipilih"));
      return;
    }

    emit(EditProductShopeeSaving());

    try {
      // Pilih maskChannelId jika ada
      final logisticIdToSubmit = current.selectedLogistic!.maskChannelId != 0
          ? current.selectedLogistic!.maskChannelId
          : current.selectedLogistic!.id;

      // Kirim request ke controller
      final response = await ShopeeController.editShopeeProduct(
        itemId: event.itemId, // sekarang String
        itemSku: event.itemSku,
        weight: event.weight,
        categoryId: current.selectedCategory!.categoryId,
        length: event.dimension['length'] ?? current.product.length,
        width: event.dimension['width'] ?? current.product.width,
        height: event.dimension['height'] ?? current.product.height,
        condition: event.condition,
        selectedUnit: current.selectedSatuan!,
        logisticId: logisticIdToSubmit,
      );

      emit(EditProductShopeeSuccess(data: response));
    } catch (e, st) {
      print("ERROR SubmitEditShopeeProduct: $e\n$st");
      emit(EditProductShopeeFailure(
          message: "Gagal edit produk Shopee: ${e.toString()}"));
    }
  }
}
