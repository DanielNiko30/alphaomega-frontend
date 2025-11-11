import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../controller/admin/laporan_controller.dart';
import '../../../../../model/laporan/laporan_model.dart';
import 'laporan_stok_event.dart';
import 'laporan_stok_state.dart';

class LaporanStokBloc extends Bloc<LaporanStokEvent, LaporanStokState> {
  LaporanStokBloc(LaporanController laporanController) : super(LaporanStokInitial()) {
    on<GetLaporanStokRangeEvent>(_onGetRange);
    on<GetLaporanStokHarianEvent>(_onGetHarian);
  }

  Future<void> _onGetRange(
      GetLaporanStokRangeEvent event, Emitter<LaporanStokState> emit) async {
    emit(LaporanStokLoading());
    try {
      final start = DateFormat('yyyy-MM-dd').format(event.startDate);
      final end = event.endDate != null
          ? DateFormat('yyyy-MM-dd').format(event.endDate!)
          : start;

      final response = await LaporanController.getLaporanStok(start, end);
      final List<LaporanStok> list = (response['data'] as List)
          .map((e) => LaporanStok.fromJson(e))
          .toList();

      emit(LaporanStokLoaded(
          data: list, periode: response['periode'] ?? '$start s.d $end'));
    } catch (e) {
      emit(LaporanStokError(e.toString()));
    }
  }

  Future<void> _onGetHarian(
      GetLaporanStokHarianEvent event, Emitter<LaporanStokState> emit) async {
    emit(LaporanStokLoading());
    try {
      final tanggal = DateFormat('yyyy-MM-dd').format(event.tanggal);

      final response = await LaporanController.getLaporanStokHarian(tanggal);
      final List<LaporanStok> list = (response['data'] as List)
          .map((e) => LaporanStok.fromJson(e))
          .toList();

      emit(LaporanStokLoaded(
          data: list, periode: response['tanggal'] ?? tanggal));
    } catch (e) {
      emit(LaporanStokError(e.toString()));
    }
  }
}
