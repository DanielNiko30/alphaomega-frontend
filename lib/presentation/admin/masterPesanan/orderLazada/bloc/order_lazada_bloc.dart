import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/lazada_controller.dart';
import '../../../../../model/product/lazada_model.dart';
import 'order_lazada_event.dart';
import 'order_lazada_state.dart';

class LazadaOrdersBloc extends Bloc<LazadaOrdersEvent, LazadaOrdersState> {
  final LazadaController _controller = LazadaController();
  String currentStatus = "PENDING"; // default toggle

  LazadaOrdersBloc() : super(LazadaOrdersInitial()) {
    on<FetchLazadaOrders>(_onFetchOrders);
    on<ChangeLazadaOrderStatus>(_onChangeStatus);
  }

  Future<void> _onChangeStatus(
      ChangeLazadaOrderStatus event, Emitter<LazadaOrdersState> emit) async {
    currentStatus = event.status;
    add(FetchLazadaOrders(isRefresh: true)); // reload sesuai toggle
  }

  Future<void> _onFetchOrders(
      FetchLazadaOrders event, Emitter<LazadaOrdersState> emit) async {
    emit(LazadaOrdersLoading());
    try {
      List<LazadaOrder> orders = [];

      if (currentStatus == "PENDING") {
        orders = await _controller.getPendingOrders();
      } else if (currentStatus == "READY_TO_SHIP") {
        orders = await _controller.getReadyToShipOrders();
      }

      emit(LazadaOrdersLoaded(
        orders: orders,
        hasMore: orders.length >= 10,
        isRefreshing: event.isRefresh,
      ));
    } catch (e) {
      emit(LazadaOrdersError(e.toString()));
    }
  }
}
