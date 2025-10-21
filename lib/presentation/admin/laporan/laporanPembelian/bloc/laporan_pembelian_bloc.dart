import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/laporan_controller.dart';
import '../../../../../model/laporan/laporan_model.dart';
import 'laporan_pembelian_event.dart';
import 'laporan_pembelian_state.dart';

class LaporanPembelianBloc
    extends Bloc<LaporanPembelianEvent, LaporanPembelianState> {
  final LaporanController laporanController;

  LaporanPembelianBloc(this.laporanController)
      : super(LaporanPembelianInitial()) {
    on<LoadLaporanPembelian>(_onLoadLaporanPembelian);
  }

  Future<void> _onLoadLaporanPembelian(
    LoadLaporanPembelian event,
    Emitter<LaporanPembelianState> emit,
  ) async {
    emit(LaporanPembelianLoading());

    try {
      final String start =
          event.startDate.toIso8601String().substring(0, 10); // yyyy-MM-dd
      final String end =
          event.endDate.toIso8601String().substring(0, 10); // yyyy-MM-dd

      print('📅 [DEBUG] Load laporan pembelian');
      print('Start: $start | End: $end | Mode: ${event.mode}');

      switch (event.mode) {
        case 'periode':
          print('🛒 Fetch laporan pembelian per periode...');
          final res = await laporanController.fetchLaporanPembelian(
            startDate: start,
            endDate: end,
          );
          print('✅ [SUCCESS] Data periode: ${res.data.length} item');
          emit(LaporanPembelianLoaded<LaporanTransaksi>(
            data: res.data,
            summary: res.summary,
            mode: event.mode,
          ));
          break;

        case 'produk':
          print('📦 Fetch laporan pembelian per produk...');
          final res = await laporanController.fetchLaporanPembelianProduk(
            startDate: start,
            endDate: end,
          );
          print('✅ [SUCCESS] Data produk: ${res.data.length} item');
          emit(LaporanPembelianLoaded<LaporanProduk>(
            data: res.data,
            summary: res.summary,
            mode: event.mode,
          ));
          break;

        case 'detail':
          print('🧾 Fetch laporan pembelian detail...');
          final res = await laporanController.fetchLaporanPembelianDetail(
            startDate: start,
            endDate: end,
          );
          print('✅ [SUCCESS] Data detail: ${res.data.length} item');
          emit(LaporanPembelianLoaded<LaporanDetail>(
            data: res.data,
            summary: res.summary,
            mode: event.mode,
          ));
          break;

        default:
          print('⚠️ Mode laporan tidak dikenali: ${event.mode}');
          emit(const LaporanPembelianError('Mode laporan tidak dikenali.'));
      }
    } catch (e, stack) {
      print('❌ [ERROR] Gagal memuat laporan: $e');
      print('📜 Stacktrace:\n$stack');
      emit(LaporanPembelianError('Gagal memuat laporan: $e'));
    }
  }
}
