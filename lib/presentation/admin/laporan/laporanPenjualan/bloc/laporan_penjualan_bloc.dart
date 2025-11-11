import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../controller/admin/laporan_controller.dart';
import 'laporan_penjualan_event.dart';
import 'laporan_penjualan_state.dart';

class LaporanPenjualanBloc
    extends Bloc<LaporanPenjualanEvent, LaporanPenjualanState> {
  final LaporanController laporanController;

  LaporanPenjualanBloc(this.laporanController)
      : super(LaporanPenjualanInitial()) {
    on<GetLaporanPenjualanRangeEvent>(_onGetRange);
  }

  Future<void> _onGetRange(
    GetLaporanPenjualanRangeEvent event,
    Emitter<LaporanPenjualanState> emit,
  ) async {
    emit(LaporanPenjualanLoading());
    try {
      final df = DateFormat('yyyy-MM-dd');
      final start = df.format(event.startDate);
      final end = event.endDate != null ? df.format(event.endDate!) : start;

      final result = await LaporanController.getLaporanPenjualan(start, end);

      // Ambil langsung key "data" dari API response
      final data = result['data'] ?? {};

      // Debug print biar yakin bentuk datanya benar
      print('DEBUG >> CHANNELS: ${data.keys}');
      data.forEach((k, v) {
        print(
            'DEBUG >> $k => laporan: ${(v['laporan'] as List?)?.length ?? 0}');
      });

      // Kirim langsung map data ke state
      emit(LaporanPenjualanLoaded(data));
    } catch (e) {
      emit(LaporanPenjualanError(e.toString()));
    }
  }
}
