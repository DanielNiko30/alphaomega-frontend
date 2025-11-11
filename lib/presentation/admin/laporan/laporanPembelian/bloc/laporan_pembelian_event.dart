import 'package:equatable/equatable.dart';

abstract class LaporanPembelianEvent extends Equatable {
  const LaporanPembelianEvent();

  @override
  List<Object?> get props => [];
}

class LoadLaporanPembelian extends LaporanPembelianEvent {
  final String mode; // 'harian' atau 'per_nota'
  final DateTime startDate;
  final DateTime? endDate; // endDate hanya untuk per_nota

  const LoadLaporanPembelian({
    required this.mode,
    required this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [mode, startDate, endDate];
}
