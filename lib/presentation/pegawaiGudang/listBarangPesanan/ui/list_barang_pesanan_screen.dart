import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../bloc/list_barang_pesanan_bloc.dart';
import '../bloc/list_barang_pesanan_event.dart';
import '../bloc/list_barang_pesanan_state.dart';
import '../../../../model/transaksiJual/htrans_jual_model.dart';
import '../../../../widget/navbar.dart';

class ListBarangPesananScreen extends StatefulWidget {
  const ListBarangPesananScreen({super.key});

  @override
  State<ListBarangPesananScreen> createState() =>
      _ListBarangPesananScreenState();
}

class _ListBarangPesananScreenState extends State<ListBarangPesananScreen> {
  int _selectedIndex = 0;
  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  @override
  void dispose() {
    socket?.disconnect();
    super.dispose();
  }

  void _initSocket() async {
    final box = GetStorage();
    final String? idUser = box.read("id_user");
    if (idUser == null) return;

    // Connect ke backend Socket.IO
    socket = IO.io(
      'https://tokalphaomegaploso.my.id',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print('✅ Socket connected');
      // Join room khusus pegawai gudang
      socket!.emit('joinRoom', idUser); // kirim langsung ID user
    });

    // Listen event transaksi baru atau update
    socket!.on('newTransaction', (data) {
      print('📌 New transaction received: $data');
      if (mounted) {
        context.read<TransJualPendingBloc>().add(FetchPendingTransaksi(idUser));
      }
    });

    socket!.on('update_transaction', (data) {
      print('📌 Transaction updated: $data');
      if (mounted) {
        context.read<TransJualPendingBloc>().add(FetchPendingTransaksi(idUser));
      }
    });

    socket!.onConnect((_) {
      print('✅ Socket connected');
    });

    socket!.onConnectError((data) {
      print('❌ Socket connect error: $data');
    });

    socket!.onDisconnect((_) {
      print('⚠️ Socket disconnected');
    });
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final String? idUser = box.read("id_user");

    return BlocProvider(
      create: (_) =>
          TransJualPendingBloc()..add(FetchPendingTransaksi(idUser ?? "")),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Transaksi Pending"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () async {
                await box.remove("token");
                await box.remove("user");
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, "/login");
                }
              },
            )
          ],
        ),
        body: BlocBuilder<TransJualPendingBloc, TransJualPendingState>(
          builder: (context, state) {
            if (state is TransJualPendingLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransJualPendingLoaded) {
              final List<HTransJual> transaksi = state.transaksi;

              if (transaksi.isEmpty) {
                return const Center(child: Text("Tidak ada transaksi pending"));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4 / 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: transaksi.length,
                itemBuilder: (context, index) {
                  final trx = transaksi[index];
                  final pembeli = trx.namaPembeli ?? "Unknown";
                  final penjual = trx.namaPegawai ?? "-";
                  final status = trx.status ?? "-";
                  final detail = trx.detail ?? [];

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
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
                    child: Card(
                      elevation: 6,
                      shadowColor: Colors.blue.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Invoice: ${trx.idHTransJual}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text("Pembeli : $pembeli"),
                            Text("Penjual : $penjual"),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Item: ${detail.length}",
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black54,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: status.toLowerCase() == "pending"
                                        ? Colors.orange.shade100
                                        : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: status.toLowerCase() == "pending"
                                          ? Colors.orange.shade800
                                          : Colors.green.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
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
            if (index == 0) {
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, "/masterBarang");
            }
          },
        ),
      ),
    );
  }
}
