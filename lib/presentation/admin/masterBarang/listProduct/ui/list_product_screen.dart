import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/list_product_bloc.dart';
import '../bloc/list_product_event.dart';
import '../bloc/list_product_state.dart';
import '../../../../../model/product/konversi_stok.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../widget/sidebar.dart';

class ListProductScreen extends StatelessWidget {
  const ListProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ListProductBloc, ListProductState>(
        listener: (context, state) {
          // Handle success / failed konversi stok
          if (state is KonversiStokSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is KonversiStokFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 100, top: 60),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Daftar Produk",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(
                                      context, '/addProduct');
                                  if (result == true) {
                                    context
                                        .read<ListProductBloc>()
                                        .add(FetchProducts());

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Produk berhasil ditambahkan"),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("Tambah Produk"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Expanded(child: ProductList()),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const Sidebar(),

            /// Overlay loading konversi
            BlocBuilder<ListProductBloc, ListProductState>(
              builder: (context, state) {
                if (state is KonversiStokLoading) {
                  return Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListProductBloc, ListProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductLoaded) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.grey[200],
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "GAMBAR",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          "NAMA PRODUK",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                /// List produk
                Expanded(
                  child: ListView.separated(
                    itemCount: state.products.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      final parentContext = context; // simpan context parent

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: product.gambarProduct != null
                                  ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: Image.memory(
                                        base64Decode(product.gambarProduct!
                                            .split(",")[1]),
                                        height: 50,
                                      ),
                                    )
                                  : const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Icon(Icons.image_not_supported),
                                    ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(product.namaProduct),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      Navigator.pushNamed(
                                        context,
                                        '/editProduct',
                                        arguments: product.idProduct,
                                      );
                                    } else if (value == 'konversi') {
                                      _showKonversiDialog(
                                          parentContext, product.idProduct);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'konversi',
                                      child: Text('Konversi Stok'),
                                    ),
                                  ],
                                  icon: const Icon(Icons.more_vert),
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
          );
        } else if (state is ProductError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('No data available'));
      },
    );
  }

  /// Dialog Konversi Stok
  Future<void> _showKonversiDialog(
      BuildContext parentContext, String productId) async {
    final satuanList = await ProductController.getSatuanByProductId(productId);

    String? dariSatuan;
    String? keSatuan;
    final jumlahDariController = TextEditingController();
    final jumlahKeController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konversi Stok"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Dari Satuan"),
                items: satuanList
                    .where((s) => s.jumlah > 0) // hanya stok > 0
                    .map((s) => DropdownMenuItem(
                          value: s.satuan,
                          child: Text("${s.satuan} (stok: ${s.jumlah})"),
                        ))
                    .toList(),
                onChanged: (val) => dariSatuan = val,
              ),
              TextField(
                controller: jumlahDariController,
                decoration: const InputDecoration(labelText: "Jumlah Dari"),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Ke Satuan"),
                items: satuanList
                    .map((s) => DropdownMenuItem(
                          value: s.satuan,
                          child: Text("${s.satuan} (stok: ${s.jumlah})"),
                        ))
                    .toList(),
                onChanged: (val) => keSatuan = val,
              ),
              TextField(
                controller: jumlahKeController,
                decoration: const InputDecoration(labelText: "Jumlah Ke"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                // Validasi input
                if (dariSatuan == null ||
                    keSatuan == null ||
                    jumlahDariController.text.isEmpty ||
                    jumlahKeController.text.isEmpty) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text("Lengkapi semua field")),
                  );
                  return;
                }

                if (dariSatuan == keSatuan) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text("Satuan tidak boleh sama")),
                  );
                  return;
                }

                // Kirim event konversi stok
                final konversi = KonversiStok(
                  idProduct: productId,
                  dariSatuan: dariSatuan!,
                  jumlahDari: int.parse(jumlahDariController.text),
                  keSatuan: keSatuan!,
                  jumlahKe: int.parse(jumlahKeController.text),
                );

                parentContext
                    .read<ListProductBloc>()
                    .add(KonversiStokEvent(konversi));

                Navigator.pop(context);
              },
              child: const Text("Konversi"),
            ),
          ],
        );
      },
    );
  }
}
