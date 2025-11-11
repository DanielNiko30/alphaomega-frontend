import 'package:equatable/equatable.dart';

abstract class LaporanPenjualanState extends Equatable {
  const LaporanPenjualanState();

  @override
  List<Object?> get props => [];
}

class LaporanPenjualanInitial extends LaporanPenjualanState {}

class LaporanPenjualanLoading extends LaporanPenjualanState {}

class LaporanPenjualanLoaded extends LaporanPenjualanState {
  final Map<String, dynamic> data;
  const LaporanPenjualanLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class LaporanPenjualanError extends LaporanPenjualanState {
  final String message;
  const LaporanPenjualanError(this.message);

  @override
  List<Object?> get props => [message];
}
