import 'package:equatable/equatable.dart';

abstract class LaporanStokEvent extends Equatable {
  const LaporanStokEvent();

  @override
  List<Object?> get props => [];
}

class GetLaporanStokRangeEvent extends LaporanStokEvent {
  final DateTime startDate;
  final DateTime? endDate;

  const GetLaporanStokRangeEvent({required this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class GetLaporanStokHarianEvent extends LaporanStokEvent {
  final DateTime tanggal;

  const GetLaporanStokHarianEvent({required this.tanggal});

  @override
  List<Object?> get props => [tanggal];
}
