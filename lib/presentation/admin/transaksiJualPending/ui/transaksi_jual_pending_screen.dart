import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/widget/sidebar.dart';
import '../bloc/transaksi_jual_pending_bloc.dart';
import '../bloc/transaksi_jual_pending_event.dart';
import '../bloc/transaksi_jual_pending_state.dart';

class TransJualPendingScreen extends StatefulWidget {
  const TransJualPendingScreen({super.key});

  @override
  State<TransJualPendingScreen> createState() => _TransJualPendingScreenState();
}

class _TransJualPendingScreenState extends State<TransJualPendingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransJualPendingBloc>().add(FetchTransJualPendingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daftar Transaksi Penjualan Pending",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BlocBuilder<TransJualPendingBloc,
                        TransJualPendingState>(
                      builder: (context, state) {
                        if (state is TransJualPendingLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is TransJualPendingLoaded) {
                          if (state.list.isEmpty) {
                            return const Center(
                                child: Text("Tidak ada transaksi pending."));
                          }

                          return Column(
                            children: [
                              // Header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                color: Colors.grey[200],
                                child: Row(
                                  children: const [
                                    Expanded(
                                        flex: 1,
                                        child: Text("NO",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    Expanded(
                                        flex: 2,
                                        child: Text("NAMA PEMBELI",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    Expanded(
                                        flex: 2,
                                        child: Text("PENJUAL",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    Expanded(
                                        flex: 2,
                                        child: Text("PEGAWAI",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    Expanded(
                                        flex: 2,
                                        child: Text("TANGGAL",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    Expanded(
                                        flex: 1,
                                        child: Center(
                                            child: Text("AKSI",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)))),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Data Rows
                              Expanded(
                                child: ListView.separated(
                                  itemCount: state.list.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final item = state.list[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: index % 2 == 0
                                            ? Colors.white
                                            : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Text('${index + 1}')),
                                          Expanded(
                                              flex: 2,
                                              child: Text(item.namaPembeli)),
                                          Expanded(
                                              flex: 2,
                                              child:
                                                  Text(item.namaUser ?? '-')),
                                          Expanded(
                                              flex: 2,
                                              child: Text(
                                                  item.namaPegawai ?? '-')),
                                          Expanded(
                                              flex: 2,
                                              child: Text(item.tanggal)),
                                          Expanded(
                                            flex: 1,
                                            child: Center(
                                              child: IconButton(
                                                icon: const Icon(Icons.edit,
                                                    color: Colors.blue),
                                                onPressed: () {
                                                  final idTransaksi = item
                                                      .idHTransJual; // Ambil ID dari item

                                                  Navigator.pushNamed(
                                                    context,
                                                    '/editTransaksiJual',
                                                    arguments:
                                                        idTransaksi, // lempar ke halaman edit
                                                  );
                                                },
                                                tooltip: 'Edit Transaksi',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        } else if (state is TransJualPendingError) {
                          return Center(child: Text("Error: ${state.message}"));
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
