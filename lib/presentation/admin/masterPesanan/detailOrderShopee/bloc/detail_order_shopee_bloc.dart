import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/shopee_controller.dart';
import 'detail_order_shopee_event.dart';
import 'detail_order_shopee_state.dart';

class ShopeeOrderDetailBloc
    extends Bloc<ShopeeOrderDetailEvent, ShopeeOrderDetailState> {
  ShopeeOrderDetailBloc() : super(ShopeeOrderDetailInitial()) {
    on<FetchShopeeOrderDetail>(_onFetchDetail);
  }

  Future<void> _onFetchDetail(
    FetchShopeeOrderDetail event,
    Emitter<ShopeeOrderDetailState> emit,
  ) async {
    emit(ShopeeOrderDetailLoading());
    try {
      // ✅ Controller sudah return Map satuan (bukan list)
      final order = await ShopeeController.getOrderDetail(event.orderSn);

      if (order.isNotEmpty) {
        print('✅ Bloc menerima order detail: ${order['order_sn']}');
        emit(ShopeeOrderDetailLoaded(order));
      } else {
        emit(const ShopeeOrderDetailError("Tidak ada data order ditemukan"));
      }
    } catch (e, st) {
      print("❌ Bloc error: $e\n$st");
      emit(ShopeeOrderDetailError("Gagal memuat detail: $e"));
    }
  }
}
