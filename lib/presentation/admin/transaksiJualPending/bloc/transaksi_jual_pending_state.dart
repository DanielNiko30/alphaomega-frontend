import '../../../../model/transaksiJual/htrans_jual_model.dart';

abstract class TransJualPendingState {}

class TransJualPendingInitial extends TransJualPendingState {}

class TransJualPendingLoading extends TransJualPendingState {}

class TransJualPendingLoaded extends TransJualPendingState {
  final List<HTransJual> list;
  TransJualPendingLoaded(this.list);
}

class TransJualPendingError extends TransJualPendingState {
  final String message;
  TransJualPendingError(this.message);
}
