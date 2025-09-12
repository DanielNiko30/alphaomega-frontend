import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../model/product/product_shopee_model.dart';
import '../../../../../model/product/shope_model.dart';
import '../bloc/add_product_shopee_bloc.dart';
import '../bloc/add_product_shopee_event.dart';
import '../bloc/add_product_shopee_state.dart';
import 'package:intl/intl.dart';

class AddProductShopeeScreen extends StatefulWidget {
  final String productId;
  const AddProductShopeeScreen({super.key, required this.productId});

  @override
  State<AddProductShopeeScreen> createState() => _AddProductShopeeScreenState();
}

class _AddProductShopeeScreenState extends State<AddProductShopeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemSkuController = TextEditingController();
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _brandNameController = TextEditingController();

  String _condition = 'NEW';
  int? _selectedCategoryId;
  int? _selectedLogisticId;

  final _currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  @override
  void initState() {
    super.initState();
    context.read<AddProductShopeeBloc>().add(
          LoadAddShopeeData(productId: widget.productId),
        );
  }

  Widget _buildDropdownCard({
    required String label,
    required Widget dropdown,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            dropdown,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: BlocConsumer<AddProductShopeeBloc, AddProductShopeeState>(
        listener: (context, state) {
          if (state is AddProductShopeeSuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is AddProductShopeeFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
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
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red)),
              ),
            );
          }

          if (state is AddProductShopeeLoaded) {
            // default selected
            _selectedCategoryId ??= state.categories.isNotEmpty
                ? state.categories.first.categoryId
                : null;
            _selectedLogisticId ??=
                state.logistics.isNotEmpty ? state.logistics.first.id : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Upload Produk ke Shopee",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Satuan
                    _buildDropdownCard(
                      label: "Pilih Satuan Produk",
                      dropdown: DropdownButtonFormField<StokShopee>(
                        value: state.selectedSatuan,
                        items: state.stokList
                            .map((stok) => DropdownMenuItem(
                                  value: stok,
                                  child: Text(
                                      "${stok.satuan} - ${_currencyFormatter.format(stok.harga)}"),
                                ))
                            .toList(),
                        onChanged: (val) => context
                            .read<AddProductShopeeBloc>()
                            .add(SelectSatuanShopee(selectedSatuan: val!)),
                        validator: (val) =>
                            val == null ? "Satuan harus dipilih" : null,
                      ),
                    ),

                    // Kategori
                    _buildDropdownCard(
                      label: "Kategori Shopee",
                      dropdown: DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        items: state.categories
                            .map((cat) => DropdownMenuItem(
                                  value: cat.categoryId,
                                  child: Text(cat.categoryName),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedCategoryId = val);
                        },
                        validator: (val) =>
                            val == null ? "Kategori harus dipilih" : null,
                      ),
                    ),

                    // Logistic
                    _buildDropdownCard(
                      label: "Logistic",
                      dropdown: DropdownButtonFormField<int>(
                        value: _selectedLogisticId,
                        items: state.logistics
                            .map((log) => DropdownMenuItem(
                                  value: log.id,
                                  child: Text(log.name),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedLogisticId = val);
                        },
                        validator: (val) =>
                            val == null ? "Logistic harus dipilih" : null,
                      ),
                    ),

                    const SizedBox(height: 16),
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
                                value == null || value.isEmpty ? "Wajib" : null,
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
                                value == null || value.isEmpty ? "Wajib" : null,
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
                                value == null || value.isEmpty ? "Wajib" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                      onChanged: (val) => setState(() => _condition = val!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _brandNameController,
                      decoration: const InputDecoration(
                        labelText: "Nama Brand (opsional)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;

                          final selectedCategory = state.categories.firstWhere(
                              (cat) => cat.categoryId == _selectedCategoryId);
                          final selectedLogistic = state.logistics.firstWhere(
                              (log) => log.id == _selectedLogisticId);

                          context.read<AddProductShopeeBloc>().add(
                                SelectCategoryShopee(
                                    selectedCategory: selectedCategory),
                              );
                          context.read<AddProductShopeeBloc>().add(
                                SelectLogisticShopee(
                                    selectedLogistic: selectedLogistic),
                              );
                          context.read<AddProductShopeeBloc>().add(
                                SubmitAddShopeeProduct(
                                  itemSku: _itemSkuController.text,
                                  weight:
                                      int.tryParse(_weightController.text) ?? 0,
                                  dimension: {
                                    "length":
                                        int.tryParse(_lengthController.text) ??
                                            0,
                                    "width":
                                        int.tryParse(_widthController.text) ??
                                            0,
                                    "height":
                                        int.tryParse(_heightController.text) ??
                                            0,
                                  },
                                  condition: _condition,
                                  brandName: _brandNameController.text.isEmpty
                                      ? null
                                      : _brandNameController.text,
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
            );
          }

          return const SizedBox(height: 200);
        },
      ),
    );
  }
}
