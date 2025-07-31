import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../controller/admin/trans_jual_controller.dart';
import 'transaksi_jual_pending_event.dart';
import 'transaksi_jual_pending_state.dart';

class TransJualPendingBloc
    extends Bloc<TransJualPendingEvent, TransJualPendingState> {
  TransJualPendingBloc() : super(TransJualPendingInitial()) {
    on<FetchTransJualPendingEvent>((event, emit) async {
      emit(TransJualPendingLoading());
      try {
        final list = await TransaksiJualController.getPendingTransactions();
        emit(TransJualPendingLoaded(list));
      } catch (e) {
        emit(TransJualPendingError(e.toString()));
      }
    });
  }
}
