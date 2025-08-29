import 'package:bloc/bloc.dart';
import '../../../../controller/admin/trans_jual_controller.dart';
import '../../../../model/transaksiJual/htrans_jual_model.dart';
import 'list_barang_pesanan_event.dart';
import 'list_barang_pesanan_state.dart';

class TransJualPendingBloc
    extends Bloc<ListBarangPesananEvent, TransJualPendingState> {
  TransJualPendingBloc() : super(TransJualPendingInitial()) {
    on<FetchPendingTransaksi>(_onFetchPending);
  }

  Future<void> _onFetchPending(
    FetchPendingTransaksi event,
    Emitter<TransJualPendingState> emit,
  ) async {
    emit(TransJualPendingLoading());
    try {
      final List<HTransJual> transaksiList =
          await TransaksiJualController.getPendingTransactionsByPenjual(
        event.idUserPenjual,
      );

      emit(TransJualPendingLoaded(transaksiList));
    } catch (e) {
      emit(TransJualPendingError(e.toString()));
    }
  }
}
