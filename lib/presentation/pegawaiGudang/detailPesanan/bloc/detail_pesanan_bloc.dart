import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../model/pegawaiGudang/barang_pesanan_model.dart';
import 'detail_pesanan_event.dart';
import 'detail_pesanan_state.dart';
import '../../../../controller/admin/trans_jual_controller.dart';
import '../../../../controller/admin/product_controller.dart';
import '../../../../helper/pesanan_local_storage.dart'; // ⬅️ import helper

class DetailPesananBloc extends Bloc<DetailPesananEvent, DetailPesananState> {
  DetailPesananBloc()
      : super(const DetailPesananState(namaPembeli: "", barang: [])) {
    on<LoadDetailPesanan>(_onLoadPesanan);
    on<RefreshDetailPesanan>(_onRefreshPesanan);
    on<ToggleBarangSiap>(_onToggleBarangSiap);
  }

  /// 🔹 Pertama kali load pesanan
  Future<void> _onLoadPesanan(
      LoadDetailPesanan event, Emitter<DetailPesananState> emit) async {
    await _fetchData(event.idPesanan, emit, keepSiap: false);
  }

  /// 🔹 Refresh data dari backend tapi pertahankan centang siap
  Future<void> _onRefreshPesanan(
      RefreshDetailPesanan event, Emitter<DetailPesananState> emit) async {
    await _fetchData(event.idPesanan, emit, keepSiap: true);
  }

  /// 🔹 Helper untuk ambil data transaksi
  Future<void> _fetchData(
    String idPesanan,
    Emitter<DetailPesananState> emit, {
    required bool keepSiap,
  }) async {
    try {
      final transaksi =
          await TransaksiJualController.getTransactionById(idPesanan);

      final products = await ProductController.getAllProducts();
      final productMap = {
        for (var p in products)
          p.idProduct: {
            "nama": p.namaProduct,
            "gambar": p.gambarProduct,
          },
      };

      // 🔹 load status siap dari local storage
      final savedStatus = await PesananLocalStorage.loadStatus(idPesanan);

      final barangList = transaksi.detail.map((item) {
        final product = productMap[item.idProduk];

        return BarangPesanan(
          idProduk: item.idProduk, // ✅ simpan idProduk
          nama: product?["nama"] ?? item.idProduk,
          qty: item.jumlahBarang.toInt(),
          harga: item.hargaSatuan,
          subtotal: item.subtotal,
          satuan: item.satuan,
          siap: keepSiap
              ? (savedStatus[item.idProduk] ??
                  state.barang
                      .firstWhere(
                        (b) => b.idProduk == item.idProduk, // ✅ pake id
                        orElse: () => BarangPesanan(
                          idProduk: item.idProduk,
                          nama: "",
                          qty: 0,
                          harga: 0,
                          subtotal: 0,
                          satuan: "",
                          siap: false,
                          gambar: null,
                        ),
                      )
                      .siap)
              : (savedStatus[item.idProduk] ?? false),
          gambar: product?["gambar"],
        );
      }).toList();

      emit(DetailPesananState(
        namaPembeli: transaksi.namaPembeli ?? "Tanpa Nama",
        barang: barangList,
      ));
    } catch (e) {
      emit(const DetailPesananState(namaPembeli: "Error", barang: []));
    }
  }

  /// 🔹 Update checkbox barang
  Future<void> _onToggleBarangSiap(
      ToggleBarangSiap event, Emitter<DetailPesananState> emit) async {
    final updatedBarang = List<BarangPesanan>.from(state.barang);
    final item = updatedBarang[event.index];
    updatedBarang[event.index] = item.copyWith(siap: !item.siap);

    emit(state.copyWith(barang: updatedBarang));

// ✅ simpan ke local storage pakai idProduk
    final statusMap = {
      for (var b in updatedBarang) b.idProduk: b.siap,
    };
    await PesananLocalStorage.saveStatus(event.idPesanan, statusMap);
  }
}
