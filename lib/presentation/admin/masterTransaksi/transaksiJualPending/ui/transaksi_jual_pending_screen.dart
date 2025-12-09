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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<TransJualPendingBloc>().add(FetchTransJualPendingEvent());

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔍 Search Bar
                  SizedBox(
                    width: 400,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Cari berdasarkan nama pembeli...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 📋 Daftar Transaksi
                  Expanded(
                    child: BlocBuilder<TransJualPendingBloc,
                        TransJualPendingState>(
                      builder: (context, state) {
                        if (state is TransJualPendingLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is TransJualPendingLoaded) {
                          // Filter berdasarkan nama pembeli
                          final filteredList = state.list.where((item) {
                            final nama = item.namaPembeli.toLowerCase();
                            return nama.contains(_searchQuery);
                          }).toList();

                          if (filteredList.isEmpty) {
                            return const Center(
                              child: Text(
                                "Tidak ada transaksi pending.",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            );
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                children: [
                                  // Header
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 16,
                                    ),
                                    color: Colors.blue,
                                    child: Row(
                                      children: const [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            "No",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors
                                                  .white, // <-- ubah warna text
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "Nama Pembeli",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "Penjual",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "Pegawai",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "Tanggal",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: Text(
                                              "Aksi",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Divider(height: 1, thickness: 1),

                                  // List isi tabel
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: filteredList.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final item = filteredList[index];
                                        final isEven = index % 2 == 0;

                                        return Container(
                                          color: isEven
                                              ? Colors.grey[50]
                                              : Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text('${index + 1}'),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(item.namaPembeli),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child:
                                                    Text(item.namaUser ?? '-'),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                    item.namaPegawai ?? '-'),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(item.tanggal),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Center(
                                                  child: IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        color: Colors.blue),
                                                    onPressed: () {
                                                      final idTransaksi =
                                                          item.idHTransJual;
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/editTransaksiJual',
                                                        arguments: idTransaksi,
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
                              ),
                            ),
                          );
                        } else if (state is TransJualPendingError) {
                          return Center(
                              child: Text("Error: ${state.message}",
                                  style: const TextStyle(color: Colors.red)));
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
