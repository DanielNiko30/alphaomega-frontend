import 'package:equatable/equatable.dart';
import '../../../../../model/transaksiBeli/htrans_beli_model.dart';

abstract class LaporanBeliState extends Equatable {
  const LaporanBeliState();

  @override
  List<Object> get props => [];
}

class LaporanBeliInitial extends LaporanBeliState {}

class LaporanBeliLoading extends LaporanBeliState {}

class LaporanBeliLoaded extends LaporanBeliState {
  final List<HTransBeli> listTransaksi;

  const LaporanBeliLoaded(this.listTransaksi);

  @override
  List<Object> get props => [listTransaksi];
}

class LaporanBeliError extends LaporanBeliState {
  final String message;

  const LaporanBeliError(this.message);

  @override
  List<Object> get props => [message];
}
