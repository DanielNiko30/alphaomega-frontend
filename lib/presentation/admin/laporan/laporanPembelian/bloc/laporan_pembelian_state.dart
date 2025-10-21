import 'package:equatable/equatable.dart';

abstract class LaporanPembelianState extends Equatable {
  const LaporanPembelianState();

  @override
  List<Object?> get props => [];
}

class LaporanPembelianInitial extends LaporanPembelianState {}

class LaporanPembelianLoading extends LaporanPembelianState {}

class LaporanPembelianLoaded<T> extends LaporanPembelianState {
  final List<T> data;
  final Map<String, dynamic>? summary;
  final String mode;

  const LaporanPembelianLoaded({
    required this.data,
    this.summary,
    required this.mode,
  });

  @override
  List<Object?> get props => [data, summary ?? {}, mode];
}

class LaporanPembelianError extends LaporanPembelianState {
  final String message;

  const LaporanPembelianError(this.message);

  @override
  List<Object?> get props => [message];
}
