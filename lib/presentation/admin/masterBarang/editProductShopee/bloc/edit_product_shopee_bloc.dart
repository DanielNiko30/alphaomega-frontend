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

  /// 🔹 Fetch semua data: product info + categories + logistics
  Future<void> _onFetchShopeeProductDetail(FetchShopeeProductDetail event,
      Emitter<EditProductShopeeState> emit) async {
    emit(EditProductShopeeLoading());
    try {
      // 1️⃣ Ambil detail produk Shopee
      final product = await ShopeeController.getShopeeProductInfo(
        idProduct: event.idProduct,
        satuan: event.satuan,
      );

      // 2️⃣ Ambil kategori & logistik langsung dari Shopee
      final categories = await ShopeeController.getCategories();
      final logistics = await ShopeeController.getLogistics();
      print("✅ Logistics fetched: ${logistics.map((l) => l.name).toList()}");

      // 3️⃣ Tentukan kategori yang sesuai
      final selectedCategory = categories.firstWhere(
        (c) => c.categoryId.toString() == product.categoryId,
        orElse: () => categories.first,
      );

      // 4️⃣ Pilih logistic aktif pertama
      final selectedLogistic = logistics.isNotEmpty ? logistics.first : null;

      // 5️⃣ Emit state lengkap
      emit(EditProductShopeeLoaded(
        idProduct: event.idProduct,
        itemId: event.itemId,
        product: product,
        selectedSatuan: event.satuan,
        categories: categories,
        selectedCategory: selectedCategory,
        logistics: logistics,
        selectedLogistic: selectedLogistic,
        brandName: product.brandName,
      ));
    } catch (e, st) {
      emit(EditProductShopeeFailure(
        message: "Gagal memuat detail produk: ${e.toString()}",
      ));
      print("❌ ERROR _onFetchShopeeProductDetail: $e\n$st");
    }
  }

  void _onSelectSatuanShopee(
      SelectSatuanShopee event, Emitter<EditProductShopeeState> emit) {
    if (state is EditProductShopeeLoaded) {
      final current = state as EditProductShopeeLoaded;
      emit(current.copyWith(selectedSatuan: event.selectedSatuan));
    }
  }

  void _onSelectCategoryShopee(
      SelectCategoryShopee event, Emitter<EditProductShopeeState> emit) {
    if (state is EditProductShopeeLoaded) {
      final current = state as EditProductShopeeLoaded;
      emit(current.copyWith(selectedCategory: event.selectedCategory));
    }
  }

  void _onSelectLogisticShopee(
      SelectLogisticShopee event, Emitter<EditProductShopeeState> emit) {
    if (state is EditProductShopeeLoaded) {
      final current = state as EditProductShopeeLoaded;
      emit(current.copyWith(selectedLogistic: event.selectedLogistic));
    }
  }

  /// 🔹 Submit edit produk
  Future<void> _onSubmitEditShopeeProduct(SubmitEditShopeeProduct event,
      Emitter<EditProductShopeeState> emit) async {
    if (state is! EditProductShopeeLoaded) return;
    final current = state as EditProductShopeeLoaded;

    if (current.selectedSatuan == null ||
        current.selectedCategory == null ||
        current.selectedLogistic == null) {
      emit(EditProductShopeeFailure(
        message: "Satuan, kategori, dan logistic harus dipilih",
      ));
      return;
    }

    emit(EditProductShopeeSaving());

    try {
      final logisticIdToSubmit = current.selectedLogistic!.maskChannelId != 0
          ? current.selectedLogistic!.maskChannelId
          : current.selectedLogistic!.id;

      final response = await ShopeeController.editShopeeProduct(
        itemId: current.itemId,
        itemSku: event.itemSku,
        weight: event.weight,
        categoryId: current.selectedCategory!.categoryId,
        length: event.dimension['length'] ?? current.product.length,
        width: event.dimension['width'] ?? current.product.width,
        height: event.dimension['height'] ?? current.product.height,
        condition: event.condition,
        selectedUnit: current.selectedSatuan!,
        logisticId: logisticIdToSubmit,
        brandName: current.brandName,
      );

      emit(EditProductShopeeSuccess(data: response));
    } catch (e, st) {
      print("❌ ERROR _onSubmitEditShopeeProduct: $e\n$st");
      emit(EditProductShopeeFailure(
        message: "Gagal edit produk Shopee: ${e.toString()}",
      ));
    }
  }
}
