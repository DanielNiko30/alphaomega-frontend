import 'package:equatable/equatable.dart';
import '../../../../model/laporan/laporan_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<LaporanNota> penjualanOffline;
  final List<LaporanNota> penjualanShopee;
  final List<LaporanNota> penjualanLazada;
  final List<LaporanPembelian> pembelian;
  final List<LaporanStok> stok;

  // summary untuk grafik & UI
  final Map<String, int> summaryPenjualanPerHari; // TIDAK NULL
  final Map<String, int> summaryPenjualanPerBulan;

  // totals
  final int totalPenjualan;
  final int totalPembelian;
  final int totalUntung;

  const DashboardLoaded({
    required this.penjualanOffline,
    required this.penjualanShopee,
    required this.penjualanLazada,
    required this.pembelian,
    required this.stok,
    this.summaryPenjualanPerHari = const {}, // default aman
    this.summaryPenjualanPerBulan = const {},
    required this.totalPenjualan,
    required this.totalPembelian,
    required this.totalUntung,
  });

  @override
  List<Object?> get props => [
        penjualanOffline,
        penjualanShopee,
        penjualanLazada,
        pembelian,
        stok,
        summaryPenjualanPerHari,
        summaryPenjualanPerBulan,
        totalPenjualan,
        totalPembelian,
        totalUntung,
      ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
