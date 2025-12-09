import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/trans_beli_controller.dart';
import '../../../../../model/transaksiBeli/htrans_beli_model.dart';
import 'histori_trans_beli_event.dart';
import 'histori_trans_beli_state.dart';

class LaporanBeliBloc extends Bloc<LaporanBeliEvent, LaporanBeliState> {
  /// 🔹 Menyimpan data asli untuk search
  List<HTransBeli> originalList = [];

  LaporanBeliBloc() : super(LaporanBeliInitial()) {
    on<FetchLaporanBeli>(_onFetchLaporanBeli);
    on<SearchLaporanBeli>(_onSearchLaporanBeli);
  }

  // ---------------------------------------------------
  // FETCH TRANSAKSI
  // ---------------------------------------------------
  Future<void> _onFetchLaporanBeli(
      FetchLaporanBeli event, Emitter<LaporanBeliState> emit) async {
    emit(LaporanBeliLoading());

    try {
      final List<HTransBeli> data =
          await TransaksiBeliController.getAllTransactions();

      // Simpan data asli untuk search
      originalList = data;

      emit(LaporanBeliLoaded(data));
    } catch (e, stackTrace) {
      print("❌ Error FetchLaporanBeli: $e");
      print(stackTrace);
      emit(LaporanBeliError(e.toString()));
    }
  }

  // ---------------------------------------------------
  // SEARCH TRANSAKSI BY NOMOR INVOICE
  // ---------------------------------------------------
  void _onSearchLaporanBeli(
      SearchLaporanBeli event, Emitter<LaporanBeliState> emit) {
    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      // Jika search kosong, tampilkan seluruh data
      emit(LaporanBeliLoaded(originalList));
      return;
    }

    final filtered = originalList.where((trx) {
      final invoice = (trx.nomorInvoice ?? '').toLowerCase();
      return invoice.contains(query);
    }).toList();

    emit(LaporanBeliLoaded(filtered));
  }
}
