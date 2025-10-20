import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_product_lazada_bloc.dart';
import '../bloc/add_product_lazada_event.dart';
import '../bloc/add_product_lazada_state.dart';

class AddProductLazadaScreen extends StatefulWidget {
  final String productId;
  const AddProductLazadaScreen({super.key, required this.productId});

  @override
  State<AddProductLazadaScreen> createState() => _AddProductLazadaScreenState();
}

class _AddProductLazadaScreenState extends State<AddProductLazadaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _netWeightController = TextEditingController();
  final _heightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _weightController = TextEditingController();
  final _skuController = TextEditingController();

  Map<String, dynamic>? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context
        .read<AddProductLazadaBloc>()
        .add(LoadAddLazadaData(productId: widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: BlocConsumer<AddProductLazadaBloc, AddProductLazadaState>(
        listener: (context, state) {
          if (state is AddProductLazadaSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AddProductLazadaFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AddProductLazadaLoading) {
            return const SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is AddProductLazadaLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Upload Produk ke Lazada",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // === Dropdown satuan ===
                    DropdownButtonFormField(
                      value: state.selectedSatuan,
                      items: state.stokList
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text("${s.satuan} - ${s.harga}"),
                              ))
                          .toList(),
                      onChanged: (val) => context
                          .read<AddProductLazadaBloc>()
                          .add(SelectSatuanLazada(selectedSatuan: val!)),
                      decoration:
                          const InputDecoration(labelText: "Pilih Satuan"),
                    ),
                    const SizedBox(height: 16),

                    // === Category Picker ===
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

                          // lempar ke bloc
                          context.read<AddProductLazadaBloc>().add(
                              SelectCategoryLazada(
                                  selectedCategory: pickedCategory));
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Kategori Lazada",
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedCategory?['name'] ??
                              state.selectedCategory?['name'] ??
                              'Pilih kategori...',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                          labelText: "Brand (misal: Ellenka)"),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _netWeightController,
                      decoration: const InputDecoration(
                          labelText: "Net Weight (misal: 500 g)"),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                          controller: _lengthController,
                          decoration:
                              const InputDecoration(labelText: "Panjang"),
                        )),
                        const SizedBox(width: 8),
                        Expanded(
                            child: TextFormField(
                          controller: _widthController,
                          decoration: const InputDecoration(labelText: "Lebar"),
                        )),
                        const SizedBox(width: 8),
                        Expanded(
                            child: TextFormField(
                          controller: _heightController,
                          decoration:
                              const InputDecoration(labelText: "Tinggi"),
                        )),
                      ],
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      decoration:
                          const InputDecoration(labelText: "Berat Paket (kg)"),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skuController,
                      decoration:
                          const InputDecoration(labelText: "Seller SKU"),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.cloud_upload, color: Colors.white),
                      label: const Text(
                        "Upload ke Lazada",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;

                        context.read<AddProductLazadaBloc>().add(
                              SubmitAddLazadaProduct(
                                brand: _brandController.text,
                                netWeight: _netWeightController.text,
                                packageHeight: _heightController.text,
                                packageLength: _lengthController.text,
                                packageWidth: _widthController.text,
                                packageWeight: _weightController.text,
                                sellerSku: _skuController.text,
                              ),
                            );
                      },
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

/// === Dialog Kategori (memastikan return category yang dipilih) ===
class CategoryTreeDialog extends StatelessWidget {
  final List<dynamic> categories;

  const CategoryTreeDialog({
    super.key,
    required this.categories,
  });

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

    if (isLeaf) {
      return ListTile(
        title: Text(name),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => Navigator.pop(context, cat), // ✅ return cat langsung
      );
    }

    return ExpansionTile(
      title: Text(name),
      children: children.map((child) => _buildTree(context, child)).toList(),
    );
  }
}
