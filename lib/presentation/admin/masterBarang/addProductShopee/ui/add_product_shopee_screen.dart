import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../model/product/product_shopee_model.dart';
import '../../../../../model/product/shope_model.dart';
import '../bloc/add_product_shopee_bloc.dart';
import '../bloc/add_product_shopee_event.dart';
import '../bloc/add_product_shopee_state.dart';

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

  // === Picker Kategori Bertingkat ===
  Future<void> _showCategoryPicker(
      List<ShopeeCategory> categories, int? selectedId) async {
    final Map<int, List<ShopeeCategory>> tree = {};
    for (final cat in categories) {
      tree.putIfAbsent(cat.parentCategoryId ?? 0, () => []).add(cat);
    }

    ShopeeCategory? selectedCat;

    Widget buildLevel(int parentId, {double indent = 0}) {
      final children = tree[parentId] ?? [];
      if (children.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((cat) {
          final hasChildren = tree.containsKey(cat.categoryId);
          return Padding(
            padding: EdgeInsets.only(left: indent),
            child: ExpansionTile(
              key: PageStorageKey(cat.categoryId),
              tilePadding: const EdgeInsets.symmetric(horizontal: 8),
              childrenPadding: const EdgeInsets.only(left: 12),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cat.categoryName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (_selectedCategoryId == cat.categoryId)
                    const Icon(Icons.check, color: Colors.green, size: 18),
                ],
              ),
              children: [
                if (hasChildren)
                  buildLevel(cat.categoryId, indent: indent + 8)
                else
                  ListTile(
                    dense: true,
                    title: Text(cat.categoryName,
                        style: const TextStyle(fontSize: 14)),
                    onTap: () {
                      selectedCat = cat;
                      setState(() => _selectedCategoryId = cat.categoryId);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          );
        }).toList(),
      );
    }

    await showDialog(
      context: context,
      builder: (context) {
        final isMobile = MediaQuery.of(context).size.width < 600;
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal:
                isMobile ? 24 : MediaQuery.of(context).size.width * 0.25,
            vertical: 24,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Pilih Kategori Shopee",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: buildLevel(0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedCat != null) {
      setState(() => _selectedCategoryId = selectedCat!.categoryId);
    }
  }

  // === Card wrapper ===
  Widget _sectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple)),
            const Divider(),
            ...children,
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: BlocConsumer<AddProductShopeeBloc, AddProductShopeeState>(
          listener: (context, state) {
            if (state is AddProductShopeeSuccess) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green),
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
              _selectedLogisticId ??=
                  state.logistics.isNotEmpty ? state.logistics.first.id : null;

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Upload Produk ke Shopee",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),

                          // === Section: Data Produk ===
                          _sectionCard("Data Produk", [
                            DropdownButtonFormField<StokShopee>(
                              value: state.selectedSatuan,
                              decoration: const InputDecoration(
                                labelText: "Pilih Satuan Produk",
                                border: OutlineInputBorder(),
                              ),
                              items: state.stokList
                                  .map((stok) => DropdownMenuItem(
                                        value: stok,
                                        child: Text(
                                            "${stok.satuan} - ${_currencyFormatter.format(stok.harga)}"),
                                      ))
                                  .toList(),
                              onChanged: (val) => context
                                  .read<AddProductShopeeBloc>()
                                  .add(
                                      SelectSatuanShopee(selectedSatuan: val!)),
                              validator: (val) =>
                                  val == null ? "Satuan harus dipilih" : null,
                            ),
                            const SizedBox(height: 16),

                            // Kategori Shopee - dengan border lebih jelas
                            InkWell(
                              onTap: () => _showCategoryPicker(
                                  state.categories, _selectedCategoryId),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.shade400, width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    )
                                  ],
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedCategoryId != null
                                            ? state.categories
                                                .firstWhere((cat) =>
                                                    cat.categoryId ==
                                                    _selectedCategoryId)
                                                .categoryName
                                            : "Pilih Kategori Shopee",
                                        style: TextStyle(
                                          color: _selectedCategoryId != null
                                              ? Colors.black
                                              : Colors.grey.shade600,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down,
                                        color: Colors.deepPurple),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            DropdownButtonFormField<int>(
                              value: _selectedLogisticId,
                              decoration: const InputDecoration(
                                labelText: "Logistic",
                                border: OutlineInputBorder(),
                              ),
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
                          ]),

                          // === Section: Detail Barang ===
                          _sectionCard("Detail Barang", [
                            TextFormField(
                              controller: _itemSkuController,
                              decoration: const InputDecoration(
                                labelText: "Item SKU",
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? "Wajib diisi" : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _weightController,
                              decoration: const InputDecoration(
                                labelText: "Berat (gram)",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v == null || v.isEmpty ? "Wajib diisi" : null,
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
                                    validator: (v) =>
                                        v == null || v.isEmpty ? "Wajib" : null,
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
                                    validator: (v) =>
                                        v == null || v.isEmpty ? "Wajib" : null,
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
                                    validator: (v) =>
                                        v == null || v.isEmpty ? "Wajib" : null,
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
                                DropdownMenuItem(
                                    value: "NEW", child: Text("Baru")),
                                DropdownMenuItem(
                                    value: "USED", child: Text("Bekas")),
                              ],
                              onChanged: (val) =>
                                  setState(() => _condition = val!),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _brandNameController,
                              decoration: const InputDecoration(
                                labelText: "Nama Brand (opsional)",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),

                  // === Floating Submit Button ===
                  Positioned(
                    bottom: 10,
                    right: 20,
                    left: 20,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6600),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;

                          final selectedCategory = state.categories.firstWhere(
                              (cat) => cat.categoryId == _selectedCategoryId);
                          final selectedLogistic = state.logistics.firstWhere(
                              (log) => log.id == _selectedLogisticId);

                          context.read<AddProductShopeeBloc>().add(
                              SelectCategoryShopee(
                                  selectedCategory: selectedCategory));
                          context.read<AddProductShopeeBloc>().add(
                              SelectLogisticShopee(
                                  selectedLogistic: selectedLogistic));
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
                            : const Icon(Icons.cloud_upload_outlined),
                        label: const Text(
                          "Upload ke Shopee",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox(height: 200);
          },
        ),
      ),
    );
  }
}
