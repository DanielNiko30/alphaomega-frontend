import 'package:equatable/equatable.dart';

abstract class LaporanBeliEvent extends Equatable {
  const LaporanBeliEvent();

  @override
  List<Object?> get props => [];
}

/// 🔹 Event untuk fetch semua transaksi pembelian
class FetchLaporanBeli extends LaporanBeliEvent {}

/// 🔍 Event untuk pencarian nomor invoice
class SearchLaporanBeli extends LaporanBeliEvent {
  final String query;

  const SearchLaporanBeli(this.query);

  @override
  List<Object?> get props => [query];
}
