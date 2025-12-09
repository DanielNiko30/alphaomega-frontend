import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../controller/admin/laporan_controller.dart';
import '../../../../model/laporan/laporan_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
      LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());

    try {
      final penjualanData = await LaporanController.getLaporanPenjualan(
          event.startDate, event.endDate);
      final pembelianData = await LaporanController.getLaporanPembelian(
          event.startDate, event.endDate);
      final stokData = await LaporanController.getLaporanStok(
          event.startDate, event.endDate);

      // parsing aman: cek struktur sesuai contoh JSON kamu
      List<LaporanNota> offline = [];
      List<LaporanNota> shopee = [];
      List<LaporanNota> lazada = [];

      if (penjualanData != null &&
          penjualanData is Map &&
          penjualanData['data'] != null) {
        final data = penjualanData['data'];

        // Offline
        try {
          final offlineList =
              (data['offline']?['laporan'] as List?) ?? <dynamic>[];
          offline = offlineList
              .map((e) => LaporanNota.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (_) {
          offline = [];
        }

        // Shopee
        try {
          final shopeeList =
              (data['shopee']?['laporan'] as List?) ?? <dynamic>[];
          shopee = shopeeList
              .map((e) => LaporanNota.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (_) {
          shopee = [];
        }

        // Lazada
        try {
          final lazadaList =
              (data['lazada']?['laporan'] as List?) ?? <dynamic>[];
          lazada = lazadaList
              .map((e) => LaporanNota.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (_) {
          lazada = [];
        }
      }

      // pembelian
      List<LaporanPembelian> pembelianList = [];
      if (pembelianData != null &&
          pembelianData is Map &&
          pembelianData['data'] != null) {
        final raw = pembelianData['data'] as List?;
        if (raw != null) {
          pembelianList = raw
              .map((e) => LaporanPembelian.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      // stok
      List<LaporanStok> stokList = [];
      if (stokData != null && stokData is Map && stokData['data'] != null) {
        final raw = stokData['data'] as List?;
        if (raw != null) {
          stokList = raw
              .map((e) => LaporanStok.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      // gabungkan penjualan
      final allPenjualan = [...offline, ...shopee, ...lazada];

      // totalPenjualan (menggunakan field LaporanNota.totalPenjualan sesuai model)
      int totalPenjualan =
          allPenjualan.fold(0, (sum, e) => sum + (e.totalPenjualan ?? 0));

      // totalUntung: LaporanDetail punya field 'untung' -> tapi model LaporanNota tidak punya totalUntung
      // Karena model LaporanNota hanya punya totalPenjualan, kita coba hitung untung dari detail jika tersedia.
      int totalUntung = 0;
      for (var nota in allPenjualan) {
        for (var d in nota.detail) {
          // d.untung di model LaporanDetail
          totalUntung += (d.untung);
        }
      }

      // totalPembelian (field subtotal di LaporanPembelian)
      int totalPembelian = pembelianList.fold(0, (s, e) => s + (e.subtotal));

      // penjualan per hari (yyyy-MM-dd)
      final Map<String, int> penjualanPerHari = {};
      for (var nota in allPenjualan) {
        final tgl = (nota.tanggal ?? "").toString();
        final value = nota.totalPenjualan ?? 0;
        if (tgl.isEmpty) continue;
        penjualanPerHari[tgl] = (penjualanPerHari[tgl] ?? 0) + value;
      }
      // sort by key (date)
      final sortedPerHari = Map.fromEntries(
        penjualanPerHari.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      );

      // penjualan per bulan (yyyy-MM)
      final Map<String, int> penjualanPerBulan = {};
      for (var entry in sortedPerHari.entries) {
        try {
          final date = DateTime.parse(entry.key);
          final monthKey =
              "${date.year}-${date.month.toString().padLeft(2, '0')}";
          penjualanPerBulan[monthKey] =
              (penjualanPerBulan[monthKey] ?? 0) + entry.value;
        } catch (_) {
          // jika format tanggal aneh, abaikan
        }
      }
      final sortedPerBulan = Map.fromEntries(
        penjualanPerBulan.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      );

      emit(DashboardLoaded(
        penjualanOffline: offline,
        penjualanShopee: shopee,
        penjualanLazada: lazada,
        pembelian: pembelianList,
        stok: stokList,
        summaryPenjualanPerHari: sortedPerHari,
        summaryPenjualanPerBulan: sortedPerBulan,
        totalPenjualan: totalPenjualan,
        totalPembelian: totalPembelian,
        totalUntung: totalUntung,
      ));
    } catch (e, stack) {
      print("ERROR in DashboardBloc._onLoadDashboard: $e");
      print(stack);
      emit(DashboardError(e.toString()));
    }
  }
}
