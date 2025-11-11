import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../controller/admin/laporan_controller.dart';
import 'laporan_pembelian_event.dart';
import 'laporan_pembelian_state.dart';

class LaporanPembelianBloc
    extends Bloc<LaporanPembelianEvent, LaporanPembelianState> {
  final LaporanController controller;

  LaporanPembelianBloc(this.controller) : super(LaporanPembelianInitial()) {
    on<LoadLaporanPembelian>(_onLoadLaporanPembelian);
  }

  Future<void> _onLoadLaporanPembelian(
      LoadLaporanPembelian event, Emitter<LaporanPembelianState> emit) async {
    emit(LaporanPembelianLoading());
    try {
      List<Map<String, dynamic>> data = [];
      int totalPembelian = 0;
      String periode = "";

      if (event.mode == 'harian') {
        final res = await LaporanController.getLaporanPembelianHarian(
            DateFormat('yyyy-MM-dd').format(event.startDate));
        data = List<Map<String, dynamic>>.from(res['data'] ?? []);
        totalPembelian = res['total']?['pembelian'] ?? 0;
        periode = DateFormat('dd MMM yyyy').format(event.startDate);
      } else if (event.mode == 'per_nota') {
        if (event.endDate == null) throw Exception("End date wajib diisi");
        final res = await LaporanController.getLaporanPembelian(
            DateFormat('yyyy-MM-dd').format(event.startDate),
            DateFormat('yyyy-MM-dd').format(event.endDate!));
        data = List<Map<String, dynamic>>.from(res['data'] ?? []);
        totalPembelian = res['grand_total']?['pembelian'] ?? 0;
        periode = res['periode'] ?? "";
      }

      emit(LaporanPembelianLoaded(
        mode: event.mode,
        data: data,
        totalPembelian: totalPembelian,
        periode: periode,
      ));
    } catch (e) {
      emit(LaporanPembelianError(e.toString()));
    }
  }
}
