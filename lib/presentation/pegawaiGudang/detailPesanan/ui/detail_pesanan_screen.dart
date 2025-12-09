import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../helper/socket_io_helper.dart';
import '../bloc/detail_pesanan_bloc.dart';
import '../bloc/detail_pesanan_event.dart';
import '../bloc/detail_pesanan_state.dart';
import '../../../../model/pegawaiGudang/barang_pesanan_model.dart';

class DetailPesananScreen extends StatefulWidget {
  final String idPesanan;
  final String namaPembeli;

  const DetailPesananScreen({
    super.key,
    required this.idPesanan,
    required this.namaPembeli,
  });

  @override
  State<DetailPesananScreen> createState() => _DetailPesananScreenState();
}

class _DetailPesananScreenState extends State<DetailPesananScreen> {
  late SocketService socketService;

  @override
  void initState() {
    super.initState();

    final bloc = context.read<DetailPesananBloc>();
    bloc.add(LoadDetailPesanan(widget.idPesanan));

    // 🔹 Connect Socket.IO
    socketService = SocketService();
    socketService.connect("user_id_here"); // ganti dengan id user penjual

    // 🔹 Listen realtime events
    socketService.socket.on("newTransaction", (data) {
      bloc.add(NewTransactionReceived(data));
    });

    socketService.socket.on("updateTransaction", (data) {
      bloc.add(UpdateTransactionReceived(data));
    });

    socketService.socket.on("updateStatusTransaction", (data) {
      bloc.add(UpdateStatusTransactionReceived(data));
    });
  }

  @override
  void dispose() {
    socketService.disconnect();
    super.dispose();
  }

  String formatRupiah(num number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Detail Pesanan"),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<DetailPesananBloc, DetailPesananState>(
        builder: (context, state) {
          if (state.barang.isEmpty && state.namaPembeli != "Error") {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.namaPembeli == "Error") {
            return const Center(
              child: Text(
                "Gagal memuat data pesanan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(state.namaPembeli),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: state.barang.length,
                    itemBuilder: (context, index) {
                      final BarangPesanan item = state.barang[index];
                      return _modernItemCard(
                        context: context,
                        item: item,
                        index: index,
                        isChecked: item.siap,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(String namaPembeli) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.blue, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              namaPembeli.isEmpty ? "Pembeli Tidak Diketahui" : namaPembeli,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernItemCard({
    required BuildContext context,
    required BarangPesanan item,
    required int index,
    required bool isChecked,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// PHOTO
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: item.gambar != null && item.gambar!.isNotEmpty
                ? Image.network(
                    item.gambar!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.inventory_2,
                        color: Colors.blue, size: 32),
                  ),
          ),

          const SizedBox(width: 16),

          /// TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.shopping_cart,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text("Qty: ${item.qty} • ${item.satuan}",
                        style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Harga: ${formatRupiah(item.harga)}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Subtotal: ${formatRupiah(item.subtotal)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// CHECKBOX MODERN
          Transform.scale(
            scale: 1.25,
            child: Checkbox(
              value: isChecked,
              activeColor: Colors.green,
              side: BorderSide(color: Colors.grey.shade400, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onChanged: (_) {
                context
                    .read<DetailPesananBloc>()
                    .add(ToggleBarangSiap(widget.idPesanan, index));
              },
            ),
          ),
        ],
      ),
    );
  }
}
