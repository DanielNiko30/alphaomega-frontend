import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../controller/admin/lazada_controller.dart';
import 'detail_order_lazada_event.dart';
import 'detail_order_lazada_state.dart';

class LazadaOrderDetailBloc
    extends Bloc<LazadaOrderDetailEvent, LazadaOrderDetailState> {
  LazadaOrderDetailBloc() : super(LazadaOrderDetailInitial()) {
    on<FetchLazadaOrderDetail>(_onFetchDetail);
  }

  Future<void> _onFetchDetail(
    FetchLazadaOrderDetail event,
    Emitter<LazadaOrderDetailState> emit,
  ) async {
    emit(LazadaOrderDetailLoading());

    try {
      final lazadaController = LazadaController();
      final response =
          await lazadaController.getFullOrderDetailLazada(event.orderId);

      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        final order = data['order'] ?? {};
        final items = data['items'] ?? [];

        if (order.isNotEmpty) {
          emit(LazadaOrderDetailLoaded(order: order, items: items));
        } else {
          emit(
              const LazadaOrderDetailError("Tidak ada detail order ditemukan"));
        }
      } else {
        emit(const LazadaOrderDetailError("Format response tidak valid"));
      }
    } catch (e) {
      emit(LazadaOrderDetailError("Gagal memuat detail: $e"));
    }
  }
}
