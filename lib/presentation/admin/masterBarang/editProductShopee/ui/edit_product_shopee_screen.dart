import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_product_shopee_bloc.dart';
import '../bloc/edit_product_shopee_event.dart';
import '../bloc/edit_product_shopee_state.dart';
import '../../../../../model/product/shope_model.dart';

class EditProductShopeeScreen extends StatefulWidget {
  final String idProduct;
  final String satuan;

  const EditProductShopeeScreen({
    super.key,
    required this.idProduct,
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
  String? selectedUnit;
  ShopeeCategory? selectedCategory;
  ShopeeLogistic? selectedLogistic;

  @override
  void initState() {
    super.initState();
    context.read<EditProductShopeeBloc>().add(
          FetchShopeeProductDetail(
            idProduct: widget.idProduct,
            satuan: widget.satuan,
          ),
        );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final dimension = {
        "length": int.tryParse(lengthController.text) ?? 0,
        "width": int.tryParse(widthController.text) ?? 0,
        "height": int.tryParse(heightController.text) ?? 0,
      };

      context.read<EditProductShopeeBloc>().add(
            SubmitEditShopeeProduct(
              itemId: widget.idProduct,
              itemSku: itemSkuController.text,
              weight: num.tryParse(weightController.text) ?? 0,
              dimension: dimension,
              condition: condition,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProductShopeeBloc, EditProductShopeeState>(
      listener: (context, state) {
        if (state is EditProductShopeeFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is EditProductShopeeSuccess) {
          FocusScope.of(context).unfocus();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Berhasil edit produk Shopee")),
          );
          Future.delayed(const Duration(milliseconds: 100), () {
            Navigator.pop(context, true);
          });
        }
      },
      builder: (context, state) {
        // Loading indicator saat fetch atau submit
        if (state is EditProductShopeeLoading ||
            state is EditProductShopeeSaving) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is EditProductShopeeLoaded) {
          final product = state.product;

          weightController.text = product.weight.toString();
          lengthController.text = product.length.toString();
          widthController.text = product.width.toString();
          heightController.text = product.height.toString();
          itemSkuController.text = product.itemSku;
          brandNameController.text = product.brandName;
          condition = product.condition;
          selectedUnit = state.selectedSatuan;
          selectedCategory = state.selectedCategory;
          selectedLogistic = state.selectedLogistic;

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              "Edit Produk Shopee",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: weightController,
                      decoration:
                          const InputDecoration(labelText: "Berat (Kg)"),
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val == null || val.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: lengthController,
                            decoration:
                                const InputDecoration(labelText: "Panjang"),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: widthController,
                            decoration:
                                const InputDecoration(labelText: "Lebar"),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: heightController,
                            decoration:
                                const InputDecoration(labelText: "Tinggi"),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: condition,
                      decoration: const InputDecoration(labelText: "Kondisi"),
                      items: const [
                        DropdownMenuItem(value: "NEW", child: Text("Baru")),
                        DropdownMenuItem(value: "USED", child: Text("Bekas")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          condition = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: itemSkuController,
                      decoration: const InputDecoration(labelText: "Item SKU"),
                      validator: (val) =>
                          val == null || val.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: brandNameController,
                      decoration: const InputDecoration(labelText: "Brand"),
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: const InputDecoration(labelText: "Satuan"),
                      items: [
                        DropdownMenuItem(
                          value: widget.satuan,
                          child: Text(widget.satuan),
                        )
                      ],
                      onChanged: (val) {
                        setState(() {
                          selectedUnit = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ShopeeCategory>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: "Kategori"),
                      items: state.categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat.categoryName),
                              ))
                          .toList(),
                      onChanged: (val) {
                        context.read<EditProductShopeeBloc>().add(
                              SelectCategoryShopee(selectedCategory: val!),
                            );
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ShopeeLogistic>(
                      value: selectedLogistic,
                      decoration: const InputDecoration(labelText: "Logistic"),
                      items: state.logistics
                          .map((logistic) => DropdownMenuItem(
                                value: logistic,
                                child: Text(logistic.name),
                              ))
                          .toList(),
                      onChanged: (val) {
                        context.read<EditProductShopeeBloc>().add(
                              SelectLogisticShopee(selectedLogistic: val!),
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Simpan"),
              ),
            ],
          );
        }

        // State lain sementara tampil loading
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
