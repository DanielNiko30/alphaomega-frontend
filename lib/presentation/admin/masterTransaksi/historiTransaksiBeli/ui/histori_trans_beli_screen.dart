import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/presentation/admin/masterTransaksi/editTransaksiBeli/bloc/edit_trans_beli_event.dart';
import '../../../../../widget/sidebar.dart';
import '../../../../../model/transaksiBeli/htrans_beli_model.dart';
import '../../editTransaksiBeli/bloc/edit_trans_beli_bloc.dart';
import '../../editTransaksiBeli/ui/edit_trans_beli_screen.dart';
import '../bloc/histori_trans_beli_bloc.dart';
import '../bloc/histori_trans_beli_event.dart';
import '../bloc/histori_trans_beli_state.dart';

class LaporanBeliScreen extends StatelessWidget {
  const LaporanBeliScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return BlocProvider(
      create: (_) => LaporanBeliBloc()..add(FetchLaporanBeli()),
      child: Builder(
        builder: (context) {
          // Context baru, sudah di bawah BlocProvider
          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: isDesktop ? 100 : 0,
                    top: 48,
                    right: 24,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Histori Transaksi Pembelian",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ======================
                      // 🔍 SEARCH BAR
                      // ======================
                      SizedBox(
                        child: TextField(
                          onChanged: (keyword) {
                            // Panggil event search realtime
                            context
                                .read<LaporanBeliBloc>()
                                .add(SearchLaporanBeli(keyword));
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: "Cari nomor invoice...",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ======================
                      // HEADER KOLOM
                      // ======================
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Nomor Invoice",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Tanggal",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Supplier",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Total Harga",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Metode Pembayaran",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ======================
                      // LIST VIEW
                      // ======================
                      const Expanded(child: LaporanBeliList()),
                    ],
                  ),
                ),
                if (isDesktop)
                  const Positioned(
                      left: 0, top: 0, bottom: 0, child: Sidebar()),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ===============================================================
// LIST VIEW
// ===============================================================
class LaporanBeliList extends StatefulWidget {
  const LaporanBeliList({super.key});

  @override
  State<LaporanBeliList> createState() => _LaporanBeliListState();
}

class _LaporanBeliListState extends State<LaporanBeliList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LaporanBeliBloc, LaporanBeliState>(
      builder: (context, state) {
        if (state is LaporanBeliLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LaporanBeliLoaded) {
          if (state.listTransaksi.isEmpty) {
            return const Center(child: Text("Belum ada transaksi pembelian."));
          }

          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            radius: const Radius.circular(10),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.listTransaksi.length,
              itemBuilder: (context, index) {
                final HTransBeli trx = state.listTransaksi[index];

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.white : Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(trx.nomorInvoice ?? '-')),
                      Expanded(flex: 2, child: Text(trx.tanggal ?? '-')),
                      Expanded(flex: 2, child: Text(trx.idSupplier ?? '-')),
                      Expanded(
                          flex: 2,
                          child:
                              Text("Rp ${trx.totalHarga?.toString() ?? '0'}")),
                      Expanded(
                          flex: 2, child: Text(trx.metodePembayaran ?? '-')),

                      // 🔵 tombol edit
                      IconButton(
                        onPressed: () {
                          final id = trx.idHTransBeli;

                          if (id == null || id.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ID transaksi tidak ditemukan.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (_) => EditTransBeliBloc()
                                  ..add(FetchTransactionById(id)),
                                child: EditTransBeliScreen(idTransaksi: id),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit Transaksi',
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        if (state is LaporanBeliError) {
          return Center(
            child: Text(
              "Terjadi kesalahan:\n${state.message}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
