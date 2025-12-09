import 'package:equatable/equatable.dart';
import '../../../../model/transaksiJual/htrans_jual_model.dart';

abstract class TransJualPendingState extends Equatable {
  const TransJualPendingState();
  @override
  List<Object?> get props => [];
}

class TransJualPendingInitial extends TransJualPendingState {}

class TransJualPendingLoading extends TransJualPendingState {}

class TransJualPendingLoaded extends TransJualPendingState {
  final List<HTransJual> transaksi;
  const TransJualPendingLoaded(this.transaksi);
  @override
  List<Object?> get props => [transaksi];
}

class TransJualPendingError extends TransJualPendingState {
  final String message;
  const TransJualPendingError(this.message);
  @override
  List<Object?> get props => [message];
}
