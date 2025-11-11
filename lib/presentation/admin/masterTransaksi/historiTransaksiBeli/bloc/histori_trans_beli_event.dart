import 'package:equatable/equatable.dart';

abstract class LaporanBeliEvent extends Equatable {
  const LaporanBeliEvent();

  @override
  List<Object> get props => [];
}

class FetchLaporanBeli extends LaporanBeliEvent {}
