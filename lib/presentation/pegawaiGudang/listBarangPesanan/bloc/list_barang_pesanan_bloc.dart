import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helper/socket_io_helper.dart';
import '../../../../model/transaksiJual/htrans_jual_model.dart';
import 'list_barang_pesanan_event.dart';
import 'list_barang_pesanan_state.dart';
import '../../../../controller/admin/trans_jual_controller.dart';
import 'package:get_storage/get_storage.dart';

class TransJualPendingBloc
    extends Bloc<ListBarangPesananEvent, TransJualPendingState> {
  final SocketService _socketService = SocketService();
  final String userId;

  TransJualPendingBloc({required this.userId})
      : super(TransJualPendingInitial()) {
    on<FetchPendingTransaksi>(_onFetchPending);
    on<NewTransactionReceived>(_onNewTransaction);
    on<UpdateTransactionReceived>(_onUpdateTransaction);

    // 🔹 Connect Socket.IO
    if (userId.isNotEmpty) {
      _socketService.connect(userId);

      _socketService.socket.on('newTransaction', (data) {
        add(NewTransactionReceived(data));
      });

      _socketService.socket.on('updateTransaction', (data) {
        add(UpdateTransactionReceived(data));
      });
    }
  }

  Future<void> _onFetchPending(
      FetchPendingTransaksi event, Emitter<TransJualPendingState> emit) async {
    emit(TransJualPendingLoading());
    try {
      final transaksi =
          await TransaksiJualController.getPendingTransactionsByPenjual(userId);
      emit(TransJualPendingLoaded(transaksi));
    } catch (e) {
      emit(TransJualPendingError(e.toString()));
    }
  }

  Future<void> _onNewTransaction(
      NewTransactionReceived event, Emitter<TransJualPendingState> emit) async {
    add(FetchPendingTransaksi());
  }

  Future<void> _onUpdateTransaction(UpdateTransactionReceived event,
      Emitter<TransJualPendingState> emit) async {
    add(FetchPendingTransaksi());
  }

  @override
  Future<void> close() {
    _socketService.disconnect();
    return super.close();
  }
}
