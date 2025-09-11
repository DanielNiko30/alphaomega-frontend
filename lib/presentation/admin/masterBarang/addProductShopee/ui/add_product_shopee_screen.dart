import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../model/product/stok_model.dart';
import '../bloc/add_product_shopee_bloc.dart';
import '../bloc/add_product_shopee_event.dart';
import '../bloc/add_product_shopee_state.dart';

class AddProductShopeeScreen extends StatefulWidget {
  final String productId;

  const AddProductShopeeScreen({
    super.key,
    required this.productId,
  });

  @override
  State<AddProductShopeeScreen> createState() => _AddProductShopeeScreenState();
}

class _AddProductShopeeScreenState extends State<AddProductShopeeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _itemSkuController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();

  String _condition = 'NEW';
  int? _selectedLogisticId;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Load satuan stok yang belum di Shopee
    context
        .read<AddProductShopeeBloc>()
        .add(LoadSatuanShopee(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: BlocConsumer<AddProductShopeeBloc, AddProductShopeeState>(
        listener: (context, state) {
          if (state is AddProductShopeeSuccess) {
            Navigator.of(context).pop(); // Tutup popup
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AddProductShopeeFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AddProductShopeeLoading) {
            return const SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is AddProductShopeeFailure) {
            return SizedBox(
              height: 250,
              child: Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (state is AddProductShopeeLoaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Upload Produk ke Shopee",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Dropdown pilih satuan stok
                      DropdownButtonFormField<Stok>(
                        value: state.selectedSatuan,
                        decoration: const InputDecoration(
                          labelText: "Pilih Satuan Produk",
                          border: OutlineInputBorder(),
                        ),
                        items: state.stokList.map((stok) {
                          return DropdownMenuItem(
                            value: stok,
                            child: Text("${stok.satuan} - Rp ${stok.harga}"),
                          );
                        }).toList(),
                        onChanged: (val) {
                          context.read<AddProductShopeeBloc>().add(
                                SelectSatuanShopee(selectedSatuan: val!),
                              );
                        },
                        validator: (val) =>
                            val == null ? "Satuan harus dipilih" : null,
                      ),
                      const SizedBox(height: 16),

                      /// SKU
                      TextFormField(
                        controller: _itemSkuController,
                        decoration: const InputDecoration(
                          labelText: "Item SKU",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "SKU wajib diisi"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      /// Berat
                      TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: "Berat (gram)",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? "Berat wajib diisi"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      /// Dimensi
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _lengthController,
                              decoration: const InputDecoration(
                                labelText: "Panjang (cm)",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Wajib"
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _widthController,
                              decoration: const InputDecoration(
                                labelText: "Lebar (cm)",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Wajib"
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              decoration: const InputDecoration(
                                labelText: "Tinggi (cm)",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Wajib"
                                      : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// Kondisi
                      DropdownButtonFormField<String>(
                        value: _condition,
                        decoration: const InputDecoration(
                          labelText: "Kondisi",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: "NEW", child: Text("Baru")),
                          DropdownMenuItem(value: "USED", child: Text("Bekas")),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _condition = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      /// Brand Name
                      TextFormField(
                        controller: _brandNameController,
                        decoration: const InputDecoration(
                          labelText: "Nama Brand (opsional)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Tombol Submit
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;

                            context.read<AddProductShopeeBloc>().add(
                                  SubmitAddShopeeProduct(
                                    productId: widget.productId,
                                    itemSku: _itemSkuController.text,
                                    weight:
                                        int.tryParse(_weightController.text) ??
                                            0,
                                    dimension: {
                                      "length": int.tryParse(
                                              _lengthController.text) ??
                                          0,
                                      "width":
                                          int.tryParse(_widthController.text) ??
                                              0,
                                      "height": int.tryParse(
                                              _heightController.text) ??
                                          0,
                                    },
                                    condition: _condition,
                                    logisticId: _selectedLogisticId ?? 0,
                                    categoryId: _selectedCategoryId ?? 0,
                                    brandName: _brandNameController.text.isEmpty
                                        ? null
                                        : _brandNameController.text,
                                    brandId: null, // opsional
                                  ),
                                );
                          },
                          icon: state is AddProductShopeeSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload),
                          label: const Text("Upload ke Shopee"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox(height: 200);
        },
      ),
    );
  }
}
