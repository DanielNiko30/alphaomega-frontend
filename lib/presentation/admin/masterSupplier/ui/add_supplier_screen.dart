import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../controller/supplier/supplier_controller.dart';
import '../../../../../widget/sidebar.dart';
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
                                "Daftar Supplier",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Builder(
                                builder: (dialogContext) => ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: dialogContext,
                                      builder: (context) {
                                        return BlocProvider.value(
                                          value: dialogContext
                                              .read<SupplierBloc>(),
                                          child: AddSupplierDialog(),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text("Tambah Supplier"),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Expanded(child: SupplierList()),
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

class SupplierList extends StatelessWidget {
  const SupplierList({super.key});

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
                    child: Text("NAMA SUPPLIER",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text("NO TELP",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<SupplierBloc, SupplierState>(
              builder: (context, state) {
                if (state is SupplierLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SupplierLoaded) {
                  final supplierList = state.listSupplier;
                  return ListView.separated(
                    itemCount: supplierList.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final supplier = supplierList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(child: Text((index + 1).toString())),
                            Expanded(
                                flex: 3, child: Text(supplier.namaSupplier)),
                            Expanded(flex: 3, child: Text(supplier.noTelp)),
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is SupplierError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text("Belum ada supplier"));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddSupplierDialog extends StatefulWidget {
  @override
  State<AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends State<AddSupplierDialog> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tambah Supplier"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _namaController,
            decoration: const InputDecoration(labelText: "Nama Supplier"),
          ),
          TextField(
            controller: _telpController,
            decoration: const InputDecoration(labelText: "No. Telp"),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () {
            final nama = _namaController.text.trim();
            final telp = _telpController.text.trim();
            if (nama.isNotEmpty && telp.isNotEmpty) {
              context.read<SupplierBloc>().add(AddSupplier(nama, telp));
              Navigator.of(context).pop();
            }
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}
