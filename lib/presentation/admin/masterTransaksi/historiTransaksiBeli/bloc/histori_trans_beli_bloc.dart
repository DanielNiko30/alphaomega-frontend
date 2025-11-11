import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/trans_beli_controller.dart';
import '../../../../../controller/admin/trans_jual_controller.dart';
import '../../../../../model/transaksiBeli/htrans_beli_model.dart';
import '../../../../../model/transaksiJual/htrans_jual_model.dart';
import 'histori_trans_beli_event.dart';
import 'histori_trans_beli_state.dart';

class LaporanBeliBloc extends Bloc<LaporanBeliEvent, LaporanBeliState> {
  LaporanBeliBloc() : super(LaporanBeliInitial()) {
    on<FetchLaporanBeli>(_onFetchLaporanBeli);
  }

  Future<void> _onFetchLaporanBeli(
      FetchLaporanBeli event, Emitter<LaporanBeliState> emit) async {
    emit(LaporanBeliLoading());
    try {
      final List<HTransBeli> data =
          await TransaksiBeliController.getAllTransactions();

      // 🔹 Tambahan untuk validasi aman & logging
      for (var item in data) {
        // Jika ada yang null (harusnya gak ada, tapi jaga-jaga)
        item.detail ??= [];

        // 🧾 Cetak log ke console
        print('--------------------------------------------');
        print('📦 Invoice: ${item.nomorInvoice}');
        print('📅 Tanggal: ${item.tanggal}');
        print('💰 Total Harga: Rp ${item.totalHarga}');
        print('🏢 Supplier: ${item.idSupplier}');
        print('💳 Metode Pembayaran: ${item.metodePembayaran}');
        print('🧾 Jumlah Detail Barang: ${item.detail.length}');
        for (var d in item.detail) {
          print(
              '   - Produk: ${d.idProduk} | Qty: ${d.jumlahBarang} | Harga: ${d.hargaSatuan}');
        }
      }

      emit(LaporanBeliLoaded(data));
    } catch (e, stackTrace) {
      // 🔥 Cetak error ke console
      print('❌ Error FetchLaporanBeli: $e');
      print(stackTrace);
      emit(LaporanBeliError(e.toString()));
    }
  }
}
