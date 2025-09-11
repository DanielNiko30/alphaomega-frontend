import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../controller/admin/shopee_controller.dart';
import '../../../../../model/product/stok_model.dart' as stok_model;
import '../../../../../model/product/shope_model.dart';
import 'add_product_shopee_event.dart';
import 'add_product_shopee_state.dart';

class AddProductShopeeBloc
    extends Bloc<AddProductShopeeEvent, AddProductShopeeState> {
  final ProductController productController;

  AddProductShopeeBloc({required this.productController})
      : super(AddProductShopeeInitial()) {
    on<LoadSatuanShopee>(_onLoadSatuanShopee);
    on<SelectSatuanShopee>(_onSelectSatuanShopee);
    on<SubmitAddShopeeProduct>(_onSubmitAddShopeeProduct);
  }

  /// 🔹 Load stok yang BELUM masuk Shopee (robust terhadap bentuk response)
  Future<void> _onLoadSatuanShopee(
      LoadSatuanShopee event, Emitter<AddProductShopeeState> emit) async {
    emit(AddProductShopeeLoading());

    try {
      final dynamic productResp =
          await ProductController.getProductById(event.productId);

      // 1) ambil raw list (bisa key 'stok', 'stokList', atau properti product.stokList)
      List<dynamic> rawStokList = [];

      if (productResp == null) {
        emit(AddProductShopeeFailure(message: "Produk tidak ditemukan"));
        return;
      }

      if (productResp is Map<String, dynamic>) {
        // backend sering mengirim { ..., 'stok': [...] }
        rawStokList = (productResp['stok'] ??
            productResp['stokList'] ??
            productResp['stok_list'] ??
            []) as List<dynamic>;
      } else {
        // coba akses property stokList / stok dari object Product
        try {
          final dynamic maybeStok = productResp.stokList ?? productResp.stok;
          if (maybeStok is List) {
            rawStokList = maybeStok as List<dynamic>;
          } else {
            rawStokList = [];
          }
        } catch (_) {
          rawStokList = [];
        }
      }

      // 2) normalisasi menjadi List<stok_model.Stok>
      final List<stok_model.Stok> stokList = rawStokList.map<stok_model.Stok>(
        (s) {
          if (s is stok_model.Stok) return s;
          if (s is Map<String, dynamic>) return stok_model.Stok.fromJson(s);
          // fallback: try convert dynamic to Map
          return stok_model.Stok.fromJson(Map<String, dynamic>.from(s));
        },
      ).toList();

      // 3) filter yang belum punya id_product_shopee
      final availableUnits = stokList
          .where((s) => s.idProductShopee == null || s.idProductShopee!.isEmpty)
          .toList();

      if (availableUnits.isEmpty) {
        emit(AddProductShopeeFailure(
            message: "Semua satuan produk ini sudah ada di Shopee"));
        return;
      }

      emit(AddProductShopeeLoaded(
        stokList: availableUnits,
        selectedSatuan: null,
      ));
    } catch (e, st) {
      // debug print boleh di dev mode
      print("Error _onLoadSatuanShopee: $e\n$st");
      emit(AddProductShopeeFailure(
          message: "Gagal memuat data: ${e.toString()}"));
    }
  }

  /// 🔹 Pilih satuan untuk diupload
  void _onSelectSatuanShopee(
      SelectSatuanShopee event, Emitter<AddProductShopeeState> emit) {
    if (state is AddProductShopeeLoaded) {
      final current = state as AddProductShopeeLoaded;
      emit(current.copyWith(selectedSatuan: event.selectedSatuan));
    }
  }

  /// 🔹 Submit produk ke Shopee
  Future<void> _onSubmitAddShopeeProduct(
      SubmitAddShopeeProduct event, Emitter<AddProductShopeeState> emit) async {
    if (state is! AddProductShopeeLoaded) return;

    final current = state as AddProductShopeeLoaded;

    if (current.selectedSatuan == null) {
      emit(AddProductShopeeFailure(message: "Pilih satuan terlebih dahulu"));
      return;
    }

    emit(AddProductShopeeSubmitting());

    try {
      final response = await ShopeeController.createProduct(
        idProduct: event.productId,
        itemSku: event.itemSku,
        weight: event.weight,
        dimension: event.dimension,
        condition: event.condition,
        logisticId: event.logisticId,
        categoryId: event.categoryId,
        brandName: event.brandName ?? '',
        brandId: event.brandId,
        selectedUnit: current.selectedSatuan!.satuan,
      );

      emit(AddProductShopeeSuccess(
          message: "Produk berhasil ditambahkan ke Shopee"));
    } catch (e) {
      emit(AddProductShopeeFailure(
          message: "Gagal menambahkan ke Shopee: ${e.toString()}"));
    }
  }
}
