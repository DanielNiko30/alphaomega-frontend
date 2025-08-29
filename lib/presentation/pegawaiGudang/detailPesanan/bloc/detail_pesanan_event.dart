import 'package:equatable/equatable.dart';

abstract class DetailPesananEvent extends Equatable {
  const DetailPesananEvent();

  @override
  List<Object?> get props => [];
}

/// 🔹 Load detail pesanan by ID
class LoadDetailPesanan extends DetailPesananEvent {
  final String idPesanan;
  const LoadDetailPesanan(this.idPesanan);

  @override
  List<Object?> get props => [idPesanan];
}

/// 🔹 Toggle checkbox barang
class ToggleBarangSiap extends DetailPesananEvent {
  final String idPesanan;
  final int index;
  const ToggleBarangSiap(this.idPesanan, this.index);

  @override
  List<Object?> get props => [idPesanan, index];
}

/// 🔹 Refresh ulang detail tanpa reset state siap
class RefreshDetailPesanan extends DetailPesananEvent {
  final String idPesanan;
  const RefreshDetailPesanan(this.idPesanan);

  @override
  List<Object?> get props => [idPesanan];
}
