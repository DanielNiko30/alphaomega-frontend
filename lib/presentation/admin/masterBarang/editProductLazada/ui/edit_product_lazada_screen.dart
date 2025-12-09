import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_product_lazada_bloc.dart';
import '../bloc/edit_product_lazada_event.dart';
import '../bloc/edit_product_lazada_state.dart';

class EditProductLazadaScreen extends StatefulWidget {
  final String itemId;
  final String productId;
  final String satuan;

  const EditProductLazadaScreen({
    super.key,
    required this.itemId,
    required this.productId,
    required this.satuan,
  });

  @override
  State<EditProductLazadaScreen> createState() =>
      _EditProductLazadaScreenState();
}

class _EditProductLazadaScreenState extends State<EditProductLazadaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _netWeightController = TextEditingController();
  final TextEditingController _packageLengthController =
      TextEditingController();
  final TextEditingController _packageWidthController = TextEditingController();
  final TextEditingController _packageHeightController =
      TextEditingController();
  final TextEditingController _packageWeightController =
      TextEditingController();
  final TextEditingController _sellerSkuController = TextEditingController();

  Map<String, dynamic>? _selectedCategory;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    context.read<EditProductLazadaBloc>().add(LoadEditLazadaData(
          productId: widget.productId,
          itemId: widget.itemId,
          satuan: widget.satuan,
        ));
  }

  @override
  void dispose() {
    _brandController.dispose();
    _netWeightController.dispose();
    _packageLengthController.dispose();
    _packageWidthController.dispose();
    _packageHeightController.dispose();
    _packageWeightController.dispose();
    _sellerSkuController.dispose();
    super.dispose();
  }

  void _submit(EditProductLazadaLoaded state) {
    if (_formKey.currentState!.validate()) {
      // trigger the same event as before
      context.read<EditProductLazadaBloc>().add(SubmitEditLazadaProduct(
            brand: _brandController.text,
            netWeight: _netWeightController.text,
            packageHeight: _packageHeightController.text,
            packageLength: _packageLengthController.text,
            packageWidth: _packageWidthController.text,
            packageWeight: _packageWeightController.text,
            sellerSku: _sellerSkuController.text,
          ));
    }
  }

  Future<void> _showCategoryPicker(List<dynamic> categories) async {
    final pickedCategory = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => CategoryTreeDialog(categories: categories),
    );

    if (pickedCategory != null) {
      setState(() => _selectedCategory = pickedCategory);
      context.read<EditProductLazadaBloc>().add(SelectCategoryLazada(
            selectedCategoryId: pickedCategory['category_id'].toString(),
          ));
    }
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFF93278F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // tulisan putih
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

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
        child: BlocConsumer<EditProductLazadaBloc, EditProductLazadaState>(
          listener: (context, state) {
            if (state is EditProductLazadaLoaded) {
              // populate controllers only once
              if (!_controllersInitialized) {
                _brandController.text = state.brand;
                _netWeightController.text = state.netWeight;
                _packageLengthController.text = state.packageLength;
                _packageWidthController.text = state.packageWidth;
                _packageHeightController.text = state.packageHeight;
                _packageWeightController.text = state.packageWeight;
                _sellerSkuController.text = state.sellerSku;

                if (state.selectedCategoryId != null &&
                    state.selectedCategoryId!.isNotEmpty) {
                  _selectedCategory = {
                    'category_id': state.selectedCategoryId,
                    'name': _findCategoryName(
                      state.categories,
                      state.selectedCategoryId!,
                    ),
                  };
                }

                _controllersInitialized = true;
              }
            }

            if (state is EditProductLazadaSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              Future.delayed(const Duration(milliseconds: 150), () {
                Navigator.pop(context, true);
              });
            }

            if (state is EditProductLazadaFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is EditProductLazadaLoading) {
              return const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is EditProductLazadaLoaded) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Edit Produk Lazada",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),

                          // DETAIL PRODUK (mirip Shopee)
                          _sectionCard("Detail Produk", [
                            TextFormField(
                              controller: _netWeightController,
                              decoration: const InputDecoration(
                                  labelText: "Net Weight (gram/isi)",
                                  border: OutlineInputBorder()),
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
                                    controller: _packageLengthController,
                                    decoration: const InputDecoration(
                                      labelText: "Package Length (cm)",
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _packageWidthController,
                                    decoration: const InputDecoration(
                                      labelText: "Package Width (cm)",
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _packageHeightController,
                                    decoration: const InputDecoration(
                                      labelText: "Package Height (cm)",
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _packageWeightController,
                              decoration: const InputDecoration(
                                  labelText: "Package Weight (Kg)",
                                  border: OutlineInputBorder()),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _sellerSkuController,
                              decoration: const InputDecoration(
                                labelText: "Seller SKU",
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? "Wajib diisi"
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _brandController,
                              decoration: const InputDecoration(
                                labelText: "Brand",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ]),

                          // KATEGORI
                          _sectionCard("Kategori & Pengiriman", [
                            GestureDetector(
                              onTap: () =>
                                  _showCategoryPicker(state.categories),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: "Kategori Lazada",
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: TextEditingController(
                                      text: _selectedCategory != null
                                          ? _selectedCategory!['name']
                                          : "Pilih kategori"),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // If you later want to add logistic dropdown like Shopee,
                            // keep the custom dropdown pattern available.
                            // For now Lazada doesn't need logistics in this UI but the widget is available.
                          ]),
                        ],
                      ),
                    ),
                  ),

                  // Tombol simpan fixed di bawah (mirip Shopee)
                  Positioned(
                    bottom: 12,
                    right: 20,
                    left: 20,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF93278F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _submit(state),
                        icon: const Icon(Icons.save_outlined),
                        label: const Text(
                          "Update ke Lazada",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is EditProductLazadaFailure) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    "Gagal memuat produk: ${state.message}",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            return const SizedBox(
              height: 200,
              child: Center(child: Text("Memuat data produk...")),
            );
          },
        ),
      ),
    );
  }

  String _findCategoryName(List<dynamic> categories, String id) {
    for (var cat in categories) {
      if (cat['category_id'].toString() == id) {
        return cat['name'] ?? 'Kategori tidak ditemukan';
      }
      if (cat['children'] != null && cat['children'] is List) {
        final name = _findCategoryName(cat['children'], id);
        if (name != 'Kategori tidak ditemukan') return name;
      }
    }
    return 'Kategori tidak ditemukan';
  }
}

class CategoryTreeDialog extends StatelessWidget {
  final List<dynamic> categories;

  const CategoryTreeDialog({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 450,
        height: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Pilih Kategori Lazada",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildTree(context, category);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTree(BuildContext context, Map<String, dynamic> cat) {
    final String name = cat['name'] ?? 'Tanpa Nama';
    final bool isLeaf = cat['leaf'] == true;
    final List<dynamic> children = (cat['children'] ?? []) as List<dynamic>;

    if (isLeaf || children.isEmpty) {
      return ListTile(
        title: Text(name),
        trailing: const Icon(Icons.check, size: 16, color: Colors.grey),
        onTap: () => Navigator.pop(context, cat),
      );
    }

    return ExpansionTile(
      title: Text(name),
      children: children.map((child) => _buildTree(context, child)).toList(),
    );
  }
}
