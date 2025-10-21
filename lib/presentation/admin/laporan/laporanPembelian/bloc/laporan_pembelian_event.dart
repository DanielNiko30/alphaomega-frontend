import 'package:equatable/equatable.dart';

abstract class LaporanPembelianEvent extends Equatable {
  const LaporanPembelianEvent();

  @override
  List<Object?> get props => [];
}

class LoadLaporanPembelian extends LaporanPembelianEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String mode; // 'periode', 'produk', 'detail'

  const LoadLaporanPembelian({
    required this.startDate,
    required this.endDate,
    required this.mode,
  });

  @override
  List<Object?> get props => [startDate, endDate, mode];
}
