import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_product_shopee_bloc.dart';
import '../bloc/edit_product_shopee_event.dart';
import '../bloc/edit_product_shopee_state.dart';
import '../../../../../model/product/shope_model.dart';

class EditProductShopeeScreen extends StatefulWidget {
  final String idProduct;
  final String itemId;
  final String satuan;

  const EditProductShopeeScreen({
    super.key,
    required this.idProduct,
    required this.itemId,
    required this.satuan,
  });

  @override
  State<EditProductShopeeScreen> createState() =>
      _EditProductShopeeScreenState();
}

class _EditProductShopeeScreenState extends State<EditProductShopeeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController weightController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController itemSkuController = TextEditingController();
  final TextEditingController brandNameController = TextEditingController();

  String condition = "NEW";
  ShopeeCategory? selectedCategory;
  ShopeeLogistic? selectedLogistic;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    context.read<EditProductShopeeBloc>().add(
          FetchShopeeProductDetail(
            idProduct: widget.idProduct,
            itemId: widget.itemId,
            satuan: widget.satuan,
          ),
        );
  }

  void _submit(EditProductShopeeLoaded state) {
    if (_formKey.currentState!.validate()) {
      final dimension = {
        "length": int.tryParse(lengthController.text) ?? 1,
        "width": int.tryParse(widthController.text) ?? 1,
        "height": int.tryParse(heightController.text) ?? 1,
      };

      final weight = double.tryParse(weightController.text) ?? 0.01;

      context.read<EditProductShopeeBloc>().add(
            SubmitEditShopeeProduct(
              idProduct: widget.idProduct,
              itemId: widget.itemId,
              itemSku: itemSkuController.text,
              weight: weight,
              dimension: dimension,
              condition: condition,
              selectedSatuan: widget.satuan,
              brandName: brandNameController.text,
            ),
          );
    }
  }

  Future<void> _showCategoryPicker(
    List<ShopeeCategory> categories,
    ShopeeCategory? selected,
  ) async {
    final Map<int, List<ShopeeCategory>> tree = {};
    for (final cat in categories) {
      tree.putIfAbsent(cat.parentCategoryId ?? 0, () => []).add(cat);
    }

    ShopeeCategory? picked;

    await showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(24),
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
                        child: _buildCategoryList(tree, 0, (cat) {
                          picked = cat;
                          Navigator.pop(context);
                        }),
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

    if (picked != null) {
      setState(() => selectedCategory = picked);
      context
          .read<EditProductShopeeBloc>()
          .add(SelectCategoryShopee(selectedCategory: picked!));
    }
  }

  Widget _buildCategoryList(Map<int, List<ShopeeCategory>> tree, int parentId,
      void Function(ShopeeCategory) onSelect) {
    final items = tree[parentId] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((cat) {
        final hasChildren = tree.containsKey(cat.categoryId);
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(cat.categoryName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14)),
                ),
                if (selectedCategory?.categoryId == cat.categoryId)
                  const Icon(Icons.check, color: Colors.green, size: 18),
              ],
            ),
            children: [
              if (hasChildren)
                _buildCategoryList(tree, cat.categoryId, onSelect)
              else
                ListTile(
                  dense: true,
                  title: Text(cat.categoryName,
                      style: const TextStyle(fontSize: 14)),
                  onTap: () => onSelect(cat),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

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

  // === Custom Dropdown seperti Add Shopee ===
  Widget _customDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required void Function(T?) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await showDialog<T>(
          context: context,
          builder: (_) => SimpleDialog(
            title: Text(label),
            children: items
                .map(
                  (e) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, e),
                    child: Text(labelBuilder(e)),
                  ),
                )
                .toList(),
          ),
        );
        if (selected != null) onChanged(selected);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 3,
              offset: const Offset(0, 1),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value != null ? labelBuilder(value) : "Pilih $label",
                style: TextStyle(
                  color: value != null ? Colors.black : Colors.grey.shade600,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
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
        child: BlocConsumer<EditProductShopeeBloc, EditProductShopeeState>(
          listener: (context, state) {
            if (state is EditProductShopeeFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is EditProductShopeeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Berhasil edit produk Shopee")));
              Future.delayed(const Duration(milliseconds: 100), () {
                Navigator.pop(context, true);
              });
            }
          },
          builder: (context, state) {
            if (state is EditProductShopeeLoading ||
                state is EditProductShopeeSaving) {
              return const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is EditProductShopeeLoaded) {
              final product = state.product;

              if (!_controllersInitialized) {
                weightController.text =
                    (product.weight > 0 ? product.weight : 0.01).toString();
                lengthController.text =
                    (product.length > 0 ? product.length : 1).toString();
                widthController.text =
                    (product.width > 0 ? product.width : 1).toString();
                heightController.text =
                    (product.height > 0 ? product.height : 1).toString();
                itemSkuController.text = product.itemSku;
                brandNameController.text =
                    product.brandName.isNotEmpty ? product.brandName : "-";
                condition = product.condition;
                selectedCategory ??= state.selectedCategory;
                selectedLogistic ??= state.selectedLogistic;
                _controllersInitialized = true;
              }

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
                            "Edit Produk Shopee",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),

                          // --- DETAIL PRODUK ---
                          _sectionCard("Detail Produk", [
                            TextFormField(
                              controller: weightController,
                              decoration: const InputDecoration(
                                labelText: "Berat (Kg)",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (val) => val == null || val.isEmpty
                                  ? "Wajib diisi"
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: lengthController,
                                    decoration: const InputDecoration(
                                      labelText: "Panjang (cm)",
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: widthController,
                                    decoration: const InputDecoration(
                                      labelText: "Lebar (cm)",
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: heightController,
                                    decoration: const InputDecoration(
                                      labelText: "Tinggi (cm)",
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: condition,
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
                              onChanged: (val) {
                                setState(() => condition = val!);
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: itemSkuController,
                              decoration: const InputDecoration(
                                labelText: "Item SKU",
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? "Wajib diisi"
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: brandNameController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: "Nama Brand",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ]),

                          // --- KATEGORI & LOGISTIK ---
                          _sectionCard("Kategori & Pengiriman", [
                            GestureDetector(
                              onTap: () => _showCategoryPicker(
                                  state.categories, selectedCategory),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: "Kategori",
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: TextEditingController(
                                    text: selectedCategory != null
                                        ? selectedCategory!.categoryName
                                        : "Pilih kategori",
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ✅ Custom Dropdown Logistic
                            _customDropdown<ShopeeLogistic>(
                              label: "Logistik",
                              value: selectedLogistic,
                              items: state.logistics,
                              labelBuilder: (e) => e.name,
                              onChanged: (val) {
                                setState(() => selectedLogistic = val);
                                if (val != null) {
                                  context.read<EditProductShopeeBloc>().add(
                                      SelectLogisticShopee(
                                          selectedLogistic: val));
                                }
                              },
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),

                  // --- Tombol simpan ---
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
                        ),
                        onPressed: () => _submit(state),
                        icon: const Icon(Icons.save_outlined),
                        label: const Text(
                          "Simpan Perubahan",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox(height: 250);
          },
        ),
      ),
    );
  }
}
