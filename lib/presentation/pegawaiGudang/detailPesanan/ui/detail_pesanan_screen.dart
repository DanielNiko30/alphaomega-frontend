import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/detail_pesanan_bloc.dart';
import '../bloc/detail_pesanan_event.dart';
import '../bloc/detail_pesanan_state.dart';
import '../../../../model/pegawaiGudang/barang_pesanan_model.dart';

class DetailPesananScreen extends StatelessWidget {
  final String idPesanan;

  const DetailPesananScreen({
    super.key,
    required this.idPesanan,
    required String namaPembeli,
  });

  Future<void> _saveBarangSiap(List<BarangPesanan> barang) async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan status siap barang ke local storage
    for (int i = 0; i < barang.length; i++) {
      await prefs.setBool("pesanan_${idPesanan}_barang_$i", barang[i].siap);
    }
  }

  Future<List<bool>> _loadBarangSiap(int count) async {
    final prefs = await SharedPreferences.getInstance();
    return List.generate(
        count, (i) => prefs.getBool("pesanan_${idPesanan}_barang_$i") ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DetailPesananBloc>();

    // hanya load sekali
    if (bloc.state.barang.isEmpty) {
      bloc.add(LoadDetailPesanan(idPesanan));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pesanan"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // back normal
          },
        ),
      ),
      body: BlocConsumer<DetailPesananBloc, DetailPesananState>(
        listener: (context, state) {
          if (state.barang.isNotEmpty) {
            // setiap kali state berubah, simpan ke local storage
            _saveBarangSiap(state.barang);
          }
        },
        builder: (context, state) {
          if (state.barang.isEmpty && state.namaPembeli != "Error") {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.namaPembeli == "Error") {
            return const Center(child: Text("Gagal memuat data pesanan"));
          }

          return FutureBuilder<List<bool>>(
            future: _loadBarangSiap(state.barang.length),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final localSiap = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pembeli: ${state.namaPembeli}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.barang.length,
                        itemBuilder: (context, index) {
                          final BarangPesanan item = state.barang[index];
                          final bool isChecked = localSiap[index] || item.siap;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isChecked
                                  ? Colors.green.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.25),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.gambar != null &&
                                        item.gambar!.isNotEmpty
                                    ? Image.network(
                                        item.gambar!,
                                        width: 55,
                                        height: 55,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) =>
                                            const Icon(Icons.broken_image,
                                                color: Colors.grey),
                                      )
                                    : Container(
                                        width: 55,
                                        height: 55,
                                        color: Colors.blue.shade100,
                                        child: const Icon(Icons.shopping_bag,
                                            color: Colors.blue),
                                      ),
                              ),
                              title: Text(
                                item.nama,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Qty: ${item.qty} ${item.satuan}"),
                                  Text("Harga: Rp${item.harga}"),
                                  Text(
                                    "Subtotal: Rp${item.subtotal}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Checkbox(
                                value: item.siap, // langsung ambil dari state
                                activeColor: Colors.green,
                                onChanged: (_) {
                                  context.read<DetailPesananBloc>().add(
                                        ToggleBarangSiap(
                                          idPesanan,
                                          index,
                                        ),
                                      );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
