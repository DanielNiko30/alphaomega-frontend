import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/shopee_controller.dart';
import '../../../../../model/orderOnline/shopee_order_model.dart';
import 'order_shopee_event.dart';
import 'order_shopee_state.dart';

class ShopeeOrdersBloc extends Bloc<ShopeeOrdersEvent, ShopeeOrdersState> {
  final ShopeeController _controller = ShopeeController();

  ShopeeOrdersBloc() : super(ShopeeOrdersInitial()) {
    on<FetchShopeeOrders>(_onFetchOrders);
  }

  Future<void> _onFetchOrders(
      FetchShopeeOrders event, Emitter<ShopeeOrdersState> emit) async {
    emit(ShopeeOrdersLoading());
    try {
      final orders = await _controller.fetchShopeeOrders();

      emit(ShopeeOrdersLoaded(
        orders: orders, // ✅ pakai named parameter
        hasMore: orders.length >= 10, // contoh untuk pagination
        isRefreshing: event.isRefresh,
      ));
    } catch (e) {
      emit(ShopeeOrdersError(e.toString()));
    }
  }
}
