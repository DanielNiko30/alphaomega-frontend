import 'package:equatable/equatable.dart';

abstract class LaporanPenjualanEvent extends Equatable {
  const LaporanPenjualanEvent();

  @override
  List<Object?> get props => [];
}

class GetLaporanPenjualanRangeEvent extends LaporanPenjualanEvent {
  final DateTime startDate;
  final DateTime? endDate;
  final String mode; // "harian" atau "per_nota"

  const GetLaporanPenjualanRangeEvent({
    required this.startDate,
    this.endDate,
    required this.mode,
  });

  @override
  List<Object?> get props => [startDate, endDate, mode];
}
