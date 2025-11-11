import 'package:equatable/equatable.dart';

abstract class LaporanPembelianState extends Equatable {
  const LaporanPembelianState();

  @override
  List<Object?> get props => [];
}

class LaporanPembelianInitial extends LaporanPembelianState {}

class LaporanPembelianLoading extends LaporanPembelianState {}

class LaporanPembelianLoaded extends LaporanPembelianState {
  final String mode;
  final List<Map<String, dynamic>> data;
  final int totalPembelian;
  final String periode; // hanya untuk per_nota

  const LaporanPembelianLoaded({
    required this.mode,
    required this.data,
    required this.totalPembelian,
    required this.periode,
  });

  @override
  List<Object?> get props => [mode, data, totalPembelian, periode];
}

class LaporanPembelianError extends LaporanPembelianState {
  final String message;

  const LaporanPembelianError(this.message);

  @override
  List<Object?> get props => [message];
}
