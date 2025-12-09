import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import '../bloc/list_barang_pesanan_bloc.dart';
import '../bloc/list_barang_pesanan_event.dart';
import '../bloc/list_barang_pesanan_state.dart';
import '../../../../model/transaksiJual/htrans_jual_model.dart';
import '../../../../widget/navbar_pegawai_gudang.dart';

class ListBarangPesananScreen extends StatefulWidget {
  const ListBarangPesananScreen({super.key});

  @override
  State<ListBarangPesananScreen> createState() =>
      _ListBarangPesananScreenState();
}

class _ListBarangPesananScreenState extends State<ListBarangPesananScreen> {
  int _selectedIndex = 0;
  late String userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ambil userId dari GetStorage
    final box = GetStorage();
    userId = box.read<String>('id_user') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransJualPendingBloc(userId: userId)
        ..add(FetchPendingTransaksi()), // trigger fetch langsung
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Transaksi Pending"),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () async {
                final box = GetStorage();
                await box.remove("token");
                await box.remove("user");
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, "/login");
                }
              },
            ),
          ],
          elevation: 0,
        ),
        body: BlocBuilder<TransJualPendingBloc, TransJualPendingState>(
          builder: (context, state) {
            if (state is TransJualPendingLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransJualPendingLoaded) {
              final transaksi = state.transaksi;
              if (transaksi.isEmpty) {
                return const Center(child: Text("Tidak ada transaksi pending"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: transaksi.length,
                itemBuilder: (context, index) {
                  final trx = transaksi[index];
                  final pembeli = trx.namaPembeli ?? "Unknown";
                  final penjual = trx.namaPegawai ?? "-";
                  final status = trx.status ?? "-";
                  final detail = trx.detail;

                  return _buildTransactionCard(
                      context, trx, pembeli, penjual, status, detail);
                },
              );
            } else if (state is TransJualPendingError) {
              return Center(child: Text("Error: ${state.message}"));
            }

            return const SizedBox();
          },
        ),
        bottomNavigationBar: CustomNavbar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 0) return;
            if (index == 1) {
              Navigator.pushReplacementNamed(context, "/masterBarang");
            }
          },
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, HTransJual trx,
      String pembeli, String penjual, String status, List detail) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          "/detailPesanan",
          arguments: {
            "idPesanan": trx.idHTransJual,
            "namaPembeli": pembeli,
          },
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      trx.nomorInvoice ?? "-",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(status),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // BODY
            Column(
              children: [
                _infoRow(Icons.person, "Pembeli", pembeli),
                const SizedBox(height: 6),
                _infoRow(Icons.store, "Pegawai Gudang", penjual),
                const SizedBox(height: 6),
                _infoRow(Icons.shopping_bag, "Jumlah Item",
                    detail.length.toString()),
              ],
            ),
            const SizedBox(height: 12),
            // FOOTER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Lihat Detail",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final lower = status.toLowerCase();
    Color bgColor;
    if (lower == "pending") {
      bgColor = Colors.orange.shade300;
    } else if (lower == "completed" || lower == "selesai") {
      bgColor = Colors.green.shade300;
    } else {
      bgColor = Colors.grey.shade400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

Widget _infoRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, size: 20, color: Colors.blue),
      const SizedBox(width: 8),
      Text(
        "$label : ",
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
