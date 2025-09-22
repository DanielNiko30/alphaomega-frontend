import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../widget/sidebar.dart';
import '../../../../../model/product/stok_model.dart';
import '../../../../../model/product/update_product_model.dart';
import '../../../../../model/product/kategori_model.dart';
import '../../addProductShopee/bloc/add_product_shopee_bloc.dart';
import '../../addProductShopee/ui/add_product_shopee_screen.dart';
import '../../editProductShopee/bloc/edit_product_shopee_bloc.dart';
import '../../editProductShopee/ui/edit_product_shopee_screen.dart';
import '../bloc/edit_product_bloc.dart';
import '../bloc/edit_product_event.dart';
import '../bloc/edit_product_state.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  String? selectedKategori;
  File? _image;
  Uint8List? _imageBytes;
  String? fileName;
  String? existingImageUrl;

  List<TextEditingController> satuanControllers = [];
  List<TextEditingController> hargaControllers = [];
  List<TextEditingController> stokControllers = [];

  /// Flag untuk cek apakah produk sudah pernah diupload ke Shopee
  bool hasShopeeSatuan = false;

  @override
  void initState() {
    super.initState();
    // Load product dan kategori saat screen dibuka
    context.read<EditProductBloc>().add(LoadProduct(widget.productId));
    context.read<EditProductBloc>().add(LoadKategori());
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        String ext = pickedFile.name.split('.').last.toLowerCase();
        if (!["jpg", "jpeg", "png"].contains(ext)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Format file tidak didukung!")),
          );
          return;
        }

        if (kIsWeb) {
          Uint8List bytes = await pickedFile.readAsBytes();
          setState(() {
            fileName = pickedFile.name;
            _imageBytes = bytes;
            _image = null;
          });
        } else {
          setState(() {
            fileName = pickedFile.name;
            _image = File(pickedFile.path);
            _imageBytes = null;
          });
        }
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _addSatuanField() {
    setState(() {
      satuanControllers.add(TextEditingController());
      stokControllers.add(TextEditingController());
      hargaControllers.add(TextEditingController());
    });
  }

  void _updateProduct() {
    if (_formKey.currentState!.validate()) {
      final satuanList = satuanControllers.map((c) => c.text).toList();
      final hargaList = hargaControllers.map((c) => c.text).toList();
      final stokList = stokControllers.map((c) => c.text).toList();

      final updatedProduct = UpdateProduct(
        idProduct: widget.productId,
        productKategori: selectedKategori!,
        namaProduct: namaController.text,
        gambarProduct: fileName ?? existingImageUrl,
        deskripsiProduct: deskripsiController.text,
        stokList: List.generate(satuanList.length, (index) {
          final stok = StokProduct(
            idStok: "",
            satuan: satuanList[index],
            harga: int.tryParse(hargaList[index]) ?? 0,
            jumlah: int.tryParse(stokList[index]) ?? 0,
          );
          print(
              "DEBUG SUBMIT STOK[$index] -> Satuan: ${stok.satuan}, Harga: ${stok.harga}, Jumlah: ${stok.jumlah}, idShopee: ${stok.idProductShopee ?? 'null'}");
          return stok;
        }),
      );

      Uint8List? imageToSend = kIsWeb ? _imageBytes : _image?.readAsBytesSync();

      context.read<EditProductBloc>().add(
            SubmitUpdateProduct(
              product: updatedProduct,
              imageBytes: imageToSend,
              fileName: fileName,
            ),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua data")),
      );
    }
  }

  void _saveOnlyProduct() {
    final satuanList = satuanControllers.map((c) => c.text).toList();
    final hargaList = hargaControllers.map((c) => c.text).toList();
    final stokList = stokControllers.map((c) => c.text).toList();

    final updatedProduct = UpdateProduct(
      idProduct: widget.productId,
      productKategori: selectedKategori!,
      namaProduct: namaController.text,
      gambarProduct: fileName ?? existingImageUrl,
      deskripsiProduct: deskripsiController.text,
      stokList: List.generate(satuanList.length, (index) {
        final stok = StokProduct(
          idStok: "",
          satuan: satuanList[index],
          harga: int.tryParse(hargaList[index]) ?? 0,
          jumlah: int.tryParse(stokList[index]) ?? 0,
        );
        print(
            "DEBUG SAVE ONLY STOK[$index] -> Satuan: ${stok.satuan}, Harga: ${stok.harga}, Jumlah: ${stok.jumlah}, idShopee: ${stok.idProductShopee ?? 'null'}");
        return stok;
      }),
    );

    Uint8List? imageToSend = kIsWeb ? _imageBytes : _image?.readAsBytesSync();

    context.read<EditProductBloc>().add(
          SaveOnlyProduct(
            product: updatedProduct,
            imageBytes: imageToSend,
            fileName: fileName,
          ),
        );
  }

  void _showShopeePopup(List<StokProduct> satuanList) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Pilih Satuan Shopee"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: satuanList
                .map(
                  (stok) => ListTile(
                    title: Text(stok.satuan),
                    subtitle:
                        Text("Harga: ${stok.harga} | Stok: ${stok.jumlah}"),
                    onTap: () {
                      print(
                          "DEBUG SELECT SHOPEE -> ${stok.satuan}, idProduct: ${stok.idProductShopee ?? 'null'}");
                      context.read<EditProductBloc>().add(
                            SelectSatuanForShopee(
                              selectedSatuan: stok.satuan,
                              idProduct: widget.productId,
                            ),
                          );
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 800,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: Text(
                            "Edit Produk",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child:
                              BlocConsumer<EditProductBloc, EditProductState>(
                            listener: (context, state) {
                              if (state is EditProductUpdated) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Produk berhasil diperbarui")),
                                );
                                Navigator.pushReplacementNamed(
                                    context, "/masterBarang");
                              } else if (state is EditProductFailure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.message)),
                                );
                              } else if (state is EditProductSavedOnly) {
                                final product = state.savedProduct;
                                setState(() {
                                  namaController.text = product.namaProduct;
                                  deskripsiController.text =
                                      product.deskripsiProduct ?? "";
                                  selectedKategori = product.productKategori;
                                  existingImageUrl = product.gambarProduct;

                                  satuanControllers.clear();
                                  stokControllers.clear();
                                  hargaControllers.clear();
                                  for (var stok in product.stokList) {
                                    satuanControllers.add(TextEditingController(
                                        text: stok.satuan));
                                    stokControllers.add(TextEditingController(
                                        text: stok.jumlah.toString()));
                                    hargaControllers.add(TextEditingController(
                                        text: stok.harga.toString()));
                                  }

                                  hasShopeeSatuan = product.stokList.any(
                                    (stok) =>
                                        (stok.idProductShopee?.toString() ?? '')
                                            .isNotEmpty,
                                  );
                                });

                                // reload product setelah save
                                context
                                    .read<EditProductBloc>()
                                    .add(LoadProduct(widget.productId));
                              } else if (state is SatuanShopeeLoaded) {
                                _showShopeePopup(state.satuanList);
                              }
                            },
                            builder: (context, state) {
                              if (state is EditProductLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (state is EditProductLoaded) {
                                final product = state.product;

                                hasShopeeSatuan = product.stokList.any(
                                  (stok) =>
                                      stok.idProductShopee != null &&
                                      stok.idProductShopee!.trim().isNotEmpty,
                                );

                                if (namaController.text.isEmpty) {
                                  namaController.text = product.namaProduct;
                                }
                                if (deskripsiController.text.isEmpty) {
                                  deskripsiController.text =
                                      product.deskripsiProduct ?? "";
                                }
                                selectedKategori ??= product.productKategori;
                                existingImageUrl ??= product.gambarProduct;

                                if (satuanControllers.isEmpty) {
                                  for (var stok in product.stokList) {
                                    satuanControllers.add(TextEditingController(
                                        text: stok.satuan));
                                    stokControllers.add(TextEditingController(
                                        text: stok.jumlah.toString()));
                                    hargaControllers.add(TextEditingController(
                                        text: stok.harga.toString()));
                                  }
                                }

                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Form(
                                    key: _formKey,
                                    child: ListView(
                                      children: [
                                        const Text(
                                          "* Foto Produk",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: _pickImage,
                                          child: Container(
                                            height: 200,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: _imageBytes != null
                                                ? Image.memory(_imageBytes!,
                                                    fit: BoxFit.cover)
                                                : _image != null
                                                    ? Image.file(_image!,
                                                        fit: BoxFit.cover)
                                                    : existingImageUrl != null
                                                        ? Image.network(
                                                            existingImageUrl!,
                                                            fit: BoxFit.cover)
                                                        : const Center(
                                                            child: Icon(
                                                                Icons
                                                                    .add_photo_alternate,
                                                                size: 40,
                                                                color: Colors
                                                                    .blue),
                                                          ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: namaController,
                                          decoration: const InputDecoration(
                                              labelText: "Nama Produk"),
                                          validator: (value) => value!.isEmpty
                                              ? "Nama tidak boleh kosong"
                                              : null,
                                        ),
                                        const SizedBox(height: 16),
                                        DropdownButtonFormField<String>(
                                          value: selectedKategori,
                                          decoration: const InputDecoration(
                                              labelText: "Kategori"),
                                          items: state.kategori
                                              .map(
                                                (kategori) => DropdownMenuItem(
                                                  value: kategori.idKategori,
                                                  child: Text(
                                                      kategori.namaKategori),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) {
                                            setState(() {
                                              selectedKategori = val;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: deskripsiController,
                                          decoration: const InputDecoration(
                                              labelText: "Deskripsi"),
                                          maxLines: 5,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _addSatuanField,
                                          child: const Text("Tambah Satuan"),
                                        ),
                                        const SizedBox(height: 16),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: satuanControllers.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: TextFormField(
                                                      controller:
                                                          satuanControllers[
                                                              index],
                                                      decoration:
                                                          const InputDecoration(
                                                              labelText:
                                                                  "Satuan"),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    flex: 1,
                                                    child: TextFormField(
                                                      controller:
                                                          stokControllers[
                                                              index],
                                                      decoration:
                                                          const InputDecoration(
                                                              labelText:
                                                                  "Stok"),
                                                      keyboardType:
                                                          TextInputType.number,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    flex: 2,
                                                    child: TextFormField(
                                                      controller:
                                                          hargaControllers[
                                                              index],
                                                      decoration:
                                                          const InputDecoration(
                                                              labelText:
                                                                  "Harga"),
                                                      keyboardType:
                                                          TextInputType.number,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                              onPressed: _saveOnlyProduct,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                              ),
                                              child: const Text("Save Only"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (!hasShopeeSatuan) {
                                                  // ✅ Belum ada Shopee product -> langsung buka Add Product popup
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        BlocProvider(
                                                      create: (context) =>
                                                          AddProductShopeeBloc(
                                                        productController:
                                                            ProductController(),
                                                      ),
                                                      child: Dialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: SizedBox(
                                                          width: 600,
                                                          height: 500,
                                                          child:
                                                              AddProductShopeeScreen(
                                                            productId: widget
                                                                .productId,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  // ✅ Sudah ada Shopee product -> pilih satuan dulu
                                                  final filteredSatuan = state
                                                      .product.stokList
                                                      .where((stok) =>
                                                          stok.idProductShopee !=
                                                              null &&
                                                          stok.idProductShopee
                                                              .toString()
                                                              .isNotEmpty)
                                                      .toList();

                                                  if (filteredSatuan.isEmpty) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              "Tidak ada satuan yang terhubung ke Shopee")),
                                                    );
                                                    return;
                                                  }

                                                  String? selectedSatuan;

                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                "Pilih Satuan Shopee"),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                DropdownButtonFormField<
                                                                    String>(
                                                                  value:
                                                                      selectedSatuan,
                                                                  decoration: const InputDecoration(
                                                                      labelText:
                                                                          "Satuan"),
                                                                  items: filteredSatuan
                                                                      .map(
                                                                          (stok) {
                                                                    return DropdownMenuItem<
                                                                        String>(
                                                                      value: stok
                                                                          .satuan,
                                                                      child:
                                                                          Text(
                                                                        "${stok.satuan} (Stok: ${stok.jumlah}, Harga: ${stok.harga})",
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                  onChanged:
                                                                      (val) {
                                                                    setState(
                                                                        () {
                                                                      selectedSatuan =
                                                                          val;
                                                                    });
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context); // Tutup popup satuan
                                                                },
                                                                child: const Text(
                                                                    "Cancel"),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  if (selectedSatuan ==
                                                                      null) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      const SnackBar(
                                                                          content:
                                                                              Text("Pilih satuan terlebih dahulu")),
                                                                    );
                                                                    return;
                                                                  }

                                                                  Navigator.pop(
                                                                      context); // Tutup popup dropdown

                                                                  // ✅ Setelah pilih satuan, buka popup EDIT Shopee
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (_) =>
                                                                        BlocProvider(
                                                                      create: (context) =>
                                                                          EditProductShopeeBloc(
                                                                        productController:
                                                                            ProductController(),
                                                                      ),
                                                                      child:
                                                                          Dialog(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              600,
                                                                          height:
                                                                              500,
                                                                          child:
                                                                              EditProductShopeeScreen(
                                                                            idProduct:
                                                                                widget.productId,
                                                                            satuan:
                                                                                selectedSatuan!, // kirim satuan yang dipilih
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .blue,
                                                                ),
                                                                child:
                                                                    const Text(
                                                                        "OK"),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue),
                                              child: Text(
                                                hasShopeeSatuan
                                                    ? "Edit Shopee"
                                                    : "Add Product to Shopee",
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: _updateProduct,
                                              child: const Text(
                                                  "Simpan Perubahan"),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Sidebar(),
        ],
      ),
    );
  }
}
