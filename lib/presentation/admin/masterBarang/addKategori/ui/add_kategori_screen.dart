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
      child: Builder(
        builder: (context) {
          final kategoriBloc = context.read<KategoriBloc>();
          final isDesktop = MediaQuery.of(context).size.width > 700;

          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: isDesktop ? 100 : 0,
                    top: 48,
                    right: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== HEADER TITLE =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Daftar Kategori Produk",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => BlocProvider.value(
                                  value: kategoriBloc,
                                  child: const AddKategoriDialog(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Tambah Kategori"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ===== SEARCH BAR =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: TextField(
                          onChanged: (value) {
                            kategoriBloc.add(SearchKategoriByName(value));
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: "Cari kategori...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ===== LIST TABLE =====
                      const Expanded(child: KategoriList()),
                    ],
                  ),
                ),

                // ===== SIDEBAR (desktop) =====
                const Sidebar(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== KATEGORI LIST ====================
class KategoriList extends StatefulWidget {
  const KategoriList({super.key});

  @override
  State<KategoriList> createState() => _KategoriListState();
}

class _KategoriListState extends State<KategoriList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kategoriBloc = context.read<KategoriBloc>();

    return BlocBuilder<KategoriBloc, KategoriState>(
      builder: (context, state) {
        if (state is KategoriLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is KategoriLoaded) {
          final kategoriList = state.filteredList ?? state.listKategori;

          if (kategoriList.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada kategori yang ditambahkan.",
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                // ==== HEADER FIXED ====
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "NO",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          "NAMA KATEGORI",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            "AKSI",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ==== BODY SCROLLABLE ====
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: kategoriList.length,
                      itemBuilder: (context, index) {
                        final kategori = kategoriList[index];
                        final isEven = index % 2 == 0;
                        return Container(
                          color: isEven ? Colors.white : Colors.grey[50],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text("${index + 1}",
                                    style:
                                        const TextStyle(color: Colors.black87)),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  kategori.namaKategori,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blueAccent),
                                      tooltip: "Edit",
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => BlocProvider.value(
                                            value: kategoriBloc,
                                            child: EditKategoriDialog(
                                              idKategori: kategori.idKategori
                                                  .toString(),
                                              namaKategori:
                                                  kategori.namaKategori,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      tooltip: "Hapus",
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<KategoriBloc>(),
                                            child: DeleteKategoriDialog(
                                              idKategori: kategori.idKategori
                                                  .toString(),
                                              namaKategori:
                                                  kategori.namaKategori,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (state is KategoriError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}

// ==================== DIALOG TAMBAH ====================
class AddKategoriDialog extends StatefulWidget {
  const AddKategoriDialog({super.key});

  @override
  State<AddKategoriDialog> createState() => _AddKategoriDialogState();
}

class _AddKategoriDialogState extends State<AddKategoriDialog> {
  final TextEditingController _namaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final kategoriBloc = context.read<KategoriBloc>();

    return AlertDialog(
      title: const Text("Tambah Kategori"),
      content: TextField(
        controller: _namaController,
        decoration: const InputDecoration(
          labelText: "Nama Kategori",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Batal"),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text("Simpan"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            final nama = _namaController.text.trim();
            if (nama.isEmpty) return;

            // ✅ Validasi nama sudah ada di list
            final state = kategoriBloc.state;
            List<String> existingNames = [];
            if (state is KategoriLoaded) {
              existingNames = state.listKategori
                  .map((e) => e.namaKategori.toLowerCase())
                  .toList();
            }

            if (existingNames.contains(nama.toLowerCase())) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Perhatian"),
                  content: Text("Nama kategori '$nama' sudah terdaftar."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
              return;
            }

            kategoriBloc.add(AddKategori(nama));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

// ==================== DIALOG EDIT ====================
class EditKategoriDialog extends StatefulWidget {
  final String idKategori;
  final String namaKategori;

  const EditKategoriDialog({
    super.key,
    required this.idKategori,
    required this.namaKategori,
  });

  @override
  State<EditKategoriDialog> createState() => _EditKategoriDialogState();
}

class _EditKategoriDialogState extends State<EditKategoriDialog> {
  late TextEditingController _namaController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.namaKategori);
  }

  @override
  Widget build(BuildContext context) {
    final kategoriBloc = context.read<KategoriBloc>();

    return AlertDialog(
      title: const Text("Edit Kategori"),
      content: TextField(
        controller: _namaController,
        decoration: const InputDecoration(
          labelText: "Nama Kategori",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Batal"),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text("Simpan Perubahan"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            final namaBaru = _namaController.text.trim();
            if (namaBaru.isEmpty) return;

            final state = kategoriBloc.state;
            List<String> existingNames = [];
            if (state is KategoriLoaded) {
              existingNames = state.listKategori
                  .where((e) => e.idKategori != widget.idKategori)
                  .map((e) => e.namaKategori.toLowerCase())
                  .toList();
            }

            if (existingNames.contains(namaBaru.toLowerCase())) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Perhatian"),
                  content: Text("Nama kategori '$namaBaru' sudah terdaftar."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
              return;
            }

            kategoriBloc.add(EditKategori(widget.idKategori, namaBaru));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class DeleteKategoriDialog extends StatelessWidget {
  final String idKategori;
  final String namaKategori;

  const DeleteKategoriDialog({
    super.key,
    required this.idKategori,
    required this.namaKategori,
  });

  @override
  Widget build(BuildContext context) {
    final kategoriBloc = context.read<KategoriBloc>();

    return AlertDialog(
      title: const Text("Hapus Kategori"),
      content: Text(
        "Apakah Anda yakin ingin menghapus kategori '$namaKategori'?",
        style: const TextStyle(fontSize: 15),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete_forever),
          label: const Text("Hapus"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            // Kirim event delete ke bloc
            kategoriBloc.add(DeleteKategori(idKategori));
            Navigator.pop(context); // tutup dialog
          },
        ),
      ],
    );
  }
}
