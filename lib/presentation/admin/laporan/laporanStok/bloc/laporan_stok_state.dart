import 'package:equatable/equatable.dart';
import '../../../../../model/laporan/laporan_model.dart';

abstract class LaporanStokState extends Equatable {
  const LaporanStokState();

  @override
  List<Object?> get props => [];
}

class LaporanStokInitial extends LaporanStokState {}

class LaporanStokLoading extends LaporanStokState {}

class LaporanStokLoaded extends LaporanStokState {
  final List<LaporanStok> data;
  final String periode;

  const LaporanStokLoaded({required this.data, required this.periode});

  @override
  List<Object?> get props => [data, periode];
}

class LaporanStokError extends LaporanStokState {
  final String message;

  const LaporanStokError(this.message);

  @override
  List<Object?> get props => [message];
}
