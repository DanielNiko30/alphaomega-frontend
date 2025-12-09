import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helper/socket_io_helper.dart';
import '../../../../model/pegawaiGudang/barang_pesanan_model.dart';
import 'detail_pesanan_event.dart';
import 'detail_pesanan_state.dart';
import '../../../../controller/admin/trans_jual_controller.dart';
import '../../../../controller/admin/product_controller.dart';
import '../../../../helper/pesanan_local_storage.dart';
import 'package:get_storage/get_storage.dart';

class DetailPesananBloc extends Bloc<DetailPesananEvent, DetailPesananState> {
  final String idPesanan;
  final SocketService _socketService = SocketService();

  DetailPesananBloc({required this.idPesanan})
      : super(const DetailPesananState(namaPembeli: "", barang: [])) {
    on<LoadDetailPesanan>(_onLoadPesanan);
    on<RefreshDetailPesanan>(_onRefreshPesanan);
    on<ToggleBarangSiap>(_onToggleBarangSiap);
    on<NewTransactionReceived>(_onNewTransaction);
    on<UpdateTransactionReceived>(_onUpdateTransaction);
    on<UpdateStatusTransactionReceived>(_onUpdateStatusTransaction);

    // Ambil userId dari storage saat login
    final box = GetStorage();
    final userId = box.read<String>('userId') ?? '';

    // 🔹 Connect Socket.IO
    if (userId.isNotEmpty) {
      _socketService.connect(userId);

      // 🔹 Listen event socket dan dispatch ke Bloc
      _socketService.socket.on('newTransaction', (data) {
        if (data['id_htrans_jual'] == idPesanan) {
          add(NewTransactionReceived(data));
        }
      });

      _socketService.socket.on('updateTransaction', (data) {
        if (data['id_htrans_jual'] == idPesanan) {
          add(UpdateTransactionReceived(data));
        }
      });

      _socketService.socket.on('updateStatusTransaction', (data) {
        if (data['id_htrans_jual'] == idPesanan) {
          add(UpdateStatusTransactionReceived(data));
        }
      });
    }
  }

  @override
  Future<void> close() {
    _socketService.disconnect();
    return super.close();
  }

  /// 🔹 Pertama kali load pesanan
  Future<void> _onLoadPesanan(
      LoadDetailPesanan event, Emitter<DetailPesananState> emit) async {
    await _fetchData(event.idPesanan, emit, keepSiap: false);
  }

  /// 🔹 Refresh data tapi pertahankan centang siap
  Future<void> _onRefreshPesanan(
      RefreshDetailPesanan event, Emitter<DetailPesananState> emit) async {
    await _fetchData(event.idPesanan, emit, keepSiap: true);
  }

  /// 🔹 Ambil data transaksi dari backend
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

      final savedStatus = await PesananLocalStorage.loadStatus(idPesanan);

      final barangList = transaksi.detail.map((item) {
        final product = productMap[item.idProduk];
        return BarangPesanan(
          idProduk: item.idProduk,
          nama: product?["nama"] ?? item.idProduk,
          qty: item.jumlahBarang,
          harga: item.hargaSatuan.toInt(),
          subtotal: item.subtotal.toInt(),
          satuan: item.satuan,
          siap: keepSiap
              ? (savedStatus[item.idProduk] ??
                  state.barang
                      .firstWhere(
                        (b) => b.idProduk == item.idProduk,
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

    final statusMap = {
      for (var b in updatedBarang) b.idProduk: b.siap,
    };
    await PesananLocalStorage.saveStatus(event.idPesanan, statusMap);
  }

  /// 🔹 Event baru dari socket
  Future<void> _onNewTransaction(
      NewTransactionReceived event, Emitter<DetailPesananState> emit) async {
    await _fetchData(idPesanan, emit, keepSiap: true);
  }

  Future<void> _onUpdateTransaction(
      UpdateTransactionReceived event, Emitter<DetailPesananState> emit) async {
    await _fetchData(idPesanan, emit, keepSiap: true);
  }

  Future<void> _onUpdateStatusTransaction(UpdateStatusTransactionReceived event,
      Emitter<DetailPesananState> emit) async {
    await _fetchData(idPesanan, emit, keepSiap: true);
  }
}
