import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/supplier/supplier_controller.dart';
import '../../../../../widget/sidebar.dart';
import '../../../../model/supplier/supllier_model.dart';
import '../bloc/add_supplier_bloc.dart';
import '../bloc/add_supplier_event.dart';
import '../bloc/add_supplier_state.dart';

class AddSupplierScreen extends StatelessWidget {
  const AddSupplierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SupplierBloc(SupplierController())..add(FetchSupplier()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 100, top: 60, right: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// === Header ===
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Daftar Supplier",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2C3E50),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Builder(
                              builder: (dialogContext) => ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.greenAccent,
                                ),
                                icon: const Icon(Icons.add_rounded, size: 22),
                                label: const Text(
                                  "Tambah Supplier",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: dialogContext,
                                    builder: (context) {
                                      return BlocProvider.value(
                                        value:
                                            dialogContext.read<SupplierBloc>(),
                                        child: const SupplierDialog(),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        const SupplierSearchBar(),
                        const SizedBox(height: 25),
                        const Expanded(child: SupplierTable()),
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

/// 🌿 Search Bar
class SupplierSearchBar extends StatefulWidget {
  const SupplierSearchBar({super.key});

  @override
  State<SupplierSearchBar> createState() => _SupplierSearchBarState();
}

class _SupplierSearchBarState extends State<SupplierSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearchChanged() {
    context
        .read<SupplierBloc>()
        .add(SearchSupplierByName(_searchController.text));
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [
          BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
              offset: Offset(0, 3),
              spreadRadius: 1)
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Cari supplier berdasarkan nama...",
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}

/// 🌿 Supplier Table
class SupplierTable extends StatelessWidget {
  const SupplierTable({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupplierBloc, SupplierState>(
      builder: (context, state) {
        if (state is SupplierLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SupplierLoaded) {
          final supplierList = state.filteredList ?? state.listSupplier;
          if (supplierList.isEmpty) {
            return const Center(child: Text("Tidak ada supplier ditemukan."));
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                    spreadRadius: 1)
              ],
            ),
            child: Column(
              children: [
                /// === HEADER ===
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text("No",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text("Nama Supplier",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text("No. Telepon",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),

                      /// NEW — tampilkan keterangan
                      Expanded(
                        flex: 4,
                        child: Text("Keterangan",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),

                      Expanded(
                        flex: 2,
                        child: Text("Aksi",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                /// === BODY ===
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    radius: const Radius.circular(10),
                    child: ListView.separated(
                      itemCount: supplierList.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Colors.grey),
                      itemBuilder: (context, index) {
                        final supplier = supplierList[index];
                        return Container(
                          color:
                              index.isEven ? Colors.grey[50] : Colors.grey[100],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 18),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1, child: Text((index + 1).toString())),
                              Expanded(
                                  flex: 3, child: Text(supplier.namaSupplier)),
                              Expanded(flex: 3, child: Text(supplier.noTelp)),

                              /// ✅ UPDATED — Keterangan rapi + wrap + tooltip
                              /// ✅ Tooltip mewah + lebar dibatasi + teks tidak mepet aksi
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right:
                                          20), // ➜ kasih jarak dari tombol aksi
                                  child: Tooltip(
                                    margin: const EdgeInsets.all(10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                          offset: Offset(2, 2),
                                        )
                                      ],
                                    ),

                                    // ★ Lewat richMessage biar bisa wrap + maxWidth
                                    richMessage: WidgetSpan(
                                      child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 300),
                                        child: Text(
                                          supplier.keterangan?.isNotEmpty ==
                                                  true
                                              ? supplier.keterangan!
                                              : "-",
                                          softWrap: true,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),

                                    child: Text(
                                      supplier.keterangan ?? "-",
                                      maxLines: 3,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    IconButton(
                                      tooltip: "Edit Supplier",
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blueAccent),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<SupplierBloc>(),
                                            child: SupplierDialog(
                                                supplier: supplier),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      tooltip: "Hapus Supplier",
                                      icon: const Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<SupplierBloc>(),
                                            child: DeleteSupplierDialog(
                                                supplier: supplier),
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
                )
              ],
            ),
          );
        } else if (state is SupplierError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text("Belum ada supplier"));
      },
    );
  }
}

/// 🌿 Dialog Tambah/Edit Supplier
class SupplierDialog extends StatefulWidget {
  final Supplier? supplier;
  const SupplierDialog({this.supplier, super.key});

  @override
  State<SupplierDialog> createState() => _SupplierDialogState();
}

class _SupplierDialogState extends State<SupplierDialog> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  final TextEditingController _ketController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _namaController.text = widget.supplier!.namaSupplier;
      _telpController.text = widget.supplier!.noTelp;
      _ketController.text = widget.supplier!.keterangan ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;
    final supplierBloc = context.read<SupplierBloc>();

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 120,
        vertical: isMobile ? 30 : 80,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.all(25),
        width: isMobile ? double.maxFinite : 540, // ⬅ popup lebih lebar
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// === TITLE BAR ===
            Row(
              children: [
                Icon(
                  isEdit ? Icons.edit : Icons.add,
                  color: isEdit ? Colors.blueAccent : Colors.green,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Text(
                  isEdit ? "Edit Supplier" : "Tambah Supplier",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            /// === INPUT FORM ===
            TextField(
              controller: _namaController,
              decoration: _inputStyle("Nama Supplier"),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _telpController,
              decoration: _inputStyle("No. Telp"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            /// 🌿 KETERANGAN — Bigger TextArea
            SizedBox(
              height: 140, // ⬅ lebih tinggi biar enak lihat teks panjang
              child: TextField(
                controller: _ketController,
                maxLines: null,
                expands: true,
                decoration: _inputStyle("Keterangan"),
              ),
            ),

            const SizedBox(height: 25),

            /// === ACTIONS ===
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.black87, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEdit ? Colors.blueAccent : Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final nama = _namaController.text.trim();
                    final telp = _telpController.text.trim();
                    final ket = _ketController.text.trim();

                    if (nama.isEmpty || telp.isEmpty) return;

                    // cek duplikasi nama
                    List<String> existingNames = [];
                    final state = supplierBloc.state;
                    if (state is SupplierLoaded) {
                      existingNames = state.listSupplier
                          .where((s) =>
                              !isEdit ||
                              s.idSupplier != widget.supplier!.idSupplier)
                          .map((s) => s.namaSupplier.toLowerCase())
                          .toList();
                    }

                    if (existingNames.contains(nama.toLowerCase())) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Perhatian"),
                          content:
                              Text("Nama supplier '$nama' sudah terdaftar."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            )
                          ],
                        ),
                      );
                      return;
                    }

                    if (isEdit) {
                      supplierBloc.add(UpdateSupplier(
                        widget.supplier!.idSupplier.toString(),
                        nama,
                        telp,
                        ket,
                      ));
                    } else {
                      supplierBloc.add(AddSupplier(
                        nama,
                        telp,
                        ket,
                      ));
                    }

                    Navigator.of(context).pop();
                  },
                  child: Text(
                    isEdit ? "Update" : "Simpan",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Reusable modern input style
  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
      ),
    );
  }
}

class DeleteSupplierDialog extends StatelessWidget {
  final Supplier supplier;

  const DeleteSupplierDialog({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    final supplierBloc = context.read<SupplierBloc>();

    return AlertDialog(
      title: const Text("Hapus Supplier"),
      content: Text(
        "Apakah Anda yakin ingin menghapus supplier '${supplier.namaSupplier}'?",
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
            supplierBloc.add(DeleteSupplier(supplier.idSupplier.toString()));
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
