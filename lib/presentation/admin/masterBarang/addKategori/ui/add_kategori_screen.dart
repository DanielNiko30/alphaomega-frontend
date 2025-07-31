import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../controller/admin/product_controller.dart';
import '../../../../../widget/sidebar.dart';
import '../bloc/add_kategori_bloc.dart';
import '../bloc/add_kategori_event.dart';
import '../bloc/add_kategori_state.dart';

class AddKategoriScreen extends StatelessWidget {
  const AddKategoriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          KategoriBloc(ProductController())..add(FetchKategori()),
      child: Scaffold(
        body: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 100, top: 60),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Daftar Kategori Produk",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Builder(
                                builder: (dialogContext) => ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context:
                                          dialogContext, // GUNAKAN dialogContext di sini!
                                      builder: (context) {
                                        return BlocProvider.value(
                                          value: dialogContext
                                              .read<KategoriBloc>(), // dan ini
                                          child: AddKategoriDialog(),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text("Tambah Kategori"),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Expanded(child: KategoriList()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Sidebar(),
          ],
        ),
      ),
    );
  }
}

class KategoriList extends StatelessWidget {
  const KategoriList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.grey[200],
            child: const Row(
              children: [
                Expanded(
                    child: Text("NO",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text("NAMA KATEGORI",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<KategoriBloc, KategoriState>(
              builder: (context, state) {
                if (state is KategoriLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is KategoriLoaded) {
                  final kategoriList = state.listKategori;
                  return ListView.separated(
                    itemCount: kategoriList.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final kategori = kategoriList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(child: Text((index + 1).toString())),
                            Expanded(
                                flex: 3, child: Text(kategori.namaKategori)),
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is KategoriError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text("Belum ada kategori"));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddKategoriDialog extends StatefulWidget {
  @override
  State<AddKategoriDialog> createState() => _AddKategoriDialogState();
}

class _AddKategoriDialogState extends State<AddKategoriDialog> {
  final TextEditingController _namaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tambah Kategori"),
      content: TextField(
        controller: _namaController,
        decoration: const InputDecoration(labelText: "Nama Kategori"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () {
            final nama = _namaController.text.trim();
            if (nama.isNotEmpty) {
              context.read<KategoriBloc>().add(AddKategori(nama));
              Navigator.of(context).pop();
            }
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}
