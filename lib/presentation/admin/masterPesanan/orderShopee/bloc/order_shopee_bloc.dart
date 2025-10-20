import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/shopee_controller.dart';
import '../../../../../model/orderOnline/shopee_order_model.dart';
import 'order_shopee_event.dart';
import 'order_shopee_state.dart';

class ShopeeOrdersBloc extends Bloc<ShopeeOrdersEvent, ShopeeOrdersState> {
  final ShopeeController _controller = ShopeeController();
  String currentStatus = "READY_TO_SHIP"; // default toggle

  ShopeeOrdersBloc() : super(ShopeeOrdersInitial()) {
    on<FetchShopeeOrders>(_onFetchOrders);
    on<ChangeShopeeOrderStatus>(_onChangeStatus);
  }

  Future<void> _onChangeStatus(
      ChangeShopeeOrderStatus event, Emitter<ShopeeOrdersState> emit) async {
    print("=== ChangeShopeeOrderStatus event received ===");
    print("Old status: $currentStatus");
    print("New status: ${event.status}");

    currentStatus = event.status;

    print("Current status after change: $currentStatus");

    add(FetchShopeeOrders(isRefresh: true)); // reload sesuai toggle
  }

  Future<void> _onFetchOrders(
      FetchShopeeOrders event, Emitter<ShopeeOrdersState> emit) async {
    print("=== FetchShopeeOrders event ===");
    print("CurrentStatus: $currentStatus");
    emit(ShopeeOrdersLoading());
    try {
      List<ShopeeOrder> orders = [];

      if (currentStatus == "READY_TO_SHIP") {
        print("Fetching READY_TO_SHIP orders...");
        orders = await _controller.fetchShopeeOrders();
      } else if (currentStatus == "PROCESSED") {
        print("Fetching PROCESSED orders...");
        orders = await _controller.getShippedOrders();
      }

      print("Fetched ${orders.length} orders");
      emit(ShopeeOrdersLoaded(
        orders: orders,
        hasMore: orders.length >= 10,
        isRefreshing: event.isRefresh,
      ));
    } catch (e) {
      print("Error fetching orders: $e");
      emit(ShopeeOrdersError(e.toString()));
    }
  }
}
