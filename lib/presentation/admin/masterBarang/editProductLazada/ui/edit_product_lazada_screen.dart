import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_product_lazada_bloc.dart';
import '../bloc/edit_product_lazada_event.dart';
import '../bloc/edit_product_lazada_state.dart';

class EditProductLazadaScreen extends StatefulWidget {
  final String itemId;
  final String productId;
  final String satuan;

  const EditProductLazadaScreen(
      {super.key,
      required this.itemId,
      required this.productId,
      required this.satuan});

  @override
  State<EditProductLazadaScreen> createState() =>
      _EditProductLazadaScreenState();
}

class _EditProductLazadaScreenState extends State<EditProductLazadaScreen> {
  final _brandController = TextEditingController();
  final _netWeightController = TextEditingController();
  final _packageLengthController = TextEditingController();
  final _packageWidthController = TextEditingController();
  final _packageHeightController = TextEditingController();
  final _packageWeightController = TextEditingController();
  final _sellerSkuController = TextEditingController();

  Map<String, dynamic>? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context
        .read<EditProductLazadaBloc>()
        .add(LoadEditLazadaData(
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProductLazadaBloc, EditProductLazadaState>(
      listener: (context, state) {
        if (state is EditProductLazadaLoaded) {
          _brandController.text = state.brand;
          _netWeightController.text = state.netWeight;
          _packageLengthController.text = state.packageLength;
          _packageWidthController.text = state.packageWidth;
          _packageHeightController.text = state.packageHeight;
          _packageWeightController.text = state.packageWeight;
          _sellerSkuController.text = state.sellerSku;

          // ✅ Auto select category
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
        }

        if (state is EditProductLazadaSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is EditProductLazadaLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Edit Produk Lazada"),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField("Brand", _brandController),
                  const SizedBox(height: 12),
                  _buildTextField("Net Weight", _netWeightController),
                  const SizedBox(height: 12),
                  _buildTextField("Package Length", _packageLengthController),
                  const SizedBox(height: 12),
                  _buildTextField("Package Width", _packageWidthController),
                  const SizedBox(height: 12),
                  _buildTextField("Package Height", _packageHeightController),
                  const SizedBox(height: 12),
                  _buildTextField("Package Weight", _packageWeightController),
                  const SizedBox(height: 12),
                  _buildTextField("Seller SKU", _sellerSkuController),
                  const SizedBox(height: 16),

                  /// === Category Picker ===
                  GestureDetector(
                    onTap: () async {
                      final pickedCategory =
                          await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (_) => CategoryTreeDialog(
                          categories: state.categories,
                        ),
                      );

                      if (pickedCategory != null) {
                        setState(() {
                          _selectedCategory = pickedCategory;
                        });

                        context.read<EditProductLazadaBloc>().add(
                              SelectCategoryLazada(
                                selectedCategoryId:
                                    pickedCategory['category_id'].toString(),
                              ),
                            );
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Kategori Lazada",
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedCategory?['name'] ?? 'Pilih kategori...',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_rounded, color: Colors.white),
                      label: const Text(
                        "Update ke Lazada",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        context.read<EditProductLazadaBloc>().add(
                              SubmitEditLazadaProduct(
                                brand: _brandController.text,
                                netWeight: _netWeightController.text,
                                packageHeight: _packageHeightController.text,
                                packageLength: _packageLengthController.text,
                                packageWidth: _packageWidthController.text,
                                packageWeight: _packageWeightController.text,
                                sellerSku: _sellerSkuController.text,
                              ),
                            );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is EditProductLazadaFailure) {
          return Scaffold(
            body: Center(
              child: Text(
                "Gagal memuat produk: ${state.message}",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text("Memuat data produk...")),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  /// 🔍 Helper: Cari nama kategori berdasarkan ID
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

/// === Category Tree Dialog ===
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
