import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../editProductLazada/ui/edit_product_lazada_screen.dart';
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

  // === Card Wrapper Function ===
  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF93278F), // Lazada Purple
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
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
        child: BlocConsumer<AddProductLazadaBloc, AddProductLazadaState>(
          listener: (context, state) async {
            if (state is AddProductLazadaSuccess) {
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Sukses"),
                  content: Text(state.message),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            } else if (state is AddProductLazadaFailure) {
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Terjadi Kesalahan"),
                  content: Text(state.message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // === Card: Data Produk ===
                      _sectionCard(title: "Data Produk", children: [
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
                          decoration: const InputDecoration(
                            labelText: "Pilih Satuan",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                      ]),

                      // === Card: Detail Barang ===
                      _sectionCard(title: "Detail Barang", children: [
                        TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(
                              labelText: "Brand (misal: Ellenka)",
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _netWeightController,
                          decoration: const InputDecoration(
                              labelText: "Net Weight (misal: 500 g)",
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _lengthController,
                                decoration: const InputDecoration(
                                    labelText: "Panjang",
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _widthController,
                                decoration: const InputDecoration(
                                    labelText: "Lebar",
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _heightController,
                                decoration: const InputDecoration(
                                    labelText: "Tinggi",
                                    border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                              labelText: "Berat Paket (kg)",
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _skuController,
                          decoration: const InputDecoration(
                              labelText: "Seller SKU",
                              border: OutlineInputBorder()),
                        ),
                      ]),

                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF93278F), // Lazada Purple
                          minimumSize: const Size.fromHeight(45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon:
                            const Icon(Icons.cloud_upload, color: Colors.white),
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
      ),
    );
  }
}
