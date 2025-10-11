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

  bool hasShopeeSatuan = false;

  @override
  void initState() {
    super.initState();
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua data")),
      );
      return;
    }

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
        return StokProduct(
          idStok: "",
          satuan: satuanList[index],
          harga: int.tryParse(hargaList[index]) ?? 0,
          jumlah: int.tryParse(stokList[index]) ?? 0,
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      body: Stack(
        children: [
          Row(
            children: [
              const Sidebar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Container(
                      width: 850,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: BlocConsumer<EditProductBloc, EditProductState>(
                        listener: (context, state) {
                          if (state is EditProductUpdated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Produk berhasil diperbarui!")),
                            );
                            Navigator.pushReplacementNamed(
                                context, "/masterBarang");
                          } else if (state is EditProductFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is EditProductLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (state is EditProductLoaded) {
                            final product = state.product;
                            namaController.text = product.namaProduct;
                            deskripsiController.text =
                                product.deskripsiProduct ?? "";
                            selectedKategori ??= product.productKategori;
                            existingImageUrl ??= product.gambarProduct;

                            if (satuanControllers.isEmpty) {
                              for (var stok in product.stokList) {
                                satuanControllers.add(
                                    TextEditingController(text: stok.satuan));
                                stokControllers.add(TextEditingController(
                                    text: stok.jumlah.toString()));
                                hargaControllers.add(TextEditingController(
                                    text: stok.harga.toString()));
                              }
                            }

                            hasShopeeSatuan = product.stokList.any(
                              (stok) =>
                                  stok.idProductShopee != null &&
                                  stok.idProductShopee!.trim().isNotEmpty,
                            );

                            return Form(
                              key: _formKey,
                              child: ListView(
                                children: [
                                  const Text(
                                    "✏️ Edit Produk",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 24),
                                  // Foto Produk
                                  const Text(
                                    "Foto Produk *",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      height: 220,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[100],
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: _imageBytes != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.memory(_imageBytes!,
                                                  fit: BoxFit.cover))
                                          : _image != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.file(_image!,
                                                      fit: BoxFit.cover))
                                              : existingImageUrl != null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: AspectRatio(
                                                        aspectRatio:
                                                            1, // biar persegi dan proporsional
                                                        child: Image.network(
                                                          existingImageUrl!,
                                                          fit: BoxFit
                                                              .contain, // penting: biar gambar gak ketarik atau ke-zoom
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          errorBuilder: (context,
                                                                  error,
                                                                  stackTrace) =>
                                                              Icon(Icons
                                                                  .broken_image),
                                                        ),
                                                      ),
                                                    )
                                                  : const Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .add_photo_alternate,
                                                              size: 48,
                                                              color:
                                                                  Colors.blue),
                                                          Text(
                                                            "Klik untuk memilih gambar",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blueGrey),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Nama
                                  TextFormField(
                                    controller: namaController,
                                    decoration: InputDecoration(
                                      labelText: "Nama Produk",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    validator: (v) => v!.isEmpty
                                        ? "Nama produk wajib diisi"
                                        : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Kategori
                                  DropdownButtonFormField<String>(
                                    value: selectedKategori,
                                    decoration: InputDecoration(
                                      labelText: "Kategori",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    items: state.kategori.map((kategori) {
                                      return DropdownMenuItem(
                                        value: kategori.idKategori,
                                        child: Text(kategori.namaKategori),
                                      );
                                    }).toList(),
                                    onChanged: (val) =>
                                        setState(() => selectedKategori = val),
                                  ),
                                  const SizedBox(height: 16),

                                  // Deskripsi
                                  TextFormField(
                                    controller: deskripsiController,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      labelText: "Deskripsi Produk",
                                      alignLabelWithHint: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Tombol tambah satuan
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Daftar Satuan & Harga",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: _addSatuanField,
                                        icon: const Icon(Icons.add),
                                        label: const Text("Tambah Satuan"),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Card list satuan
                                  Column(
                                    children: List.generate(
                                      satuanControllers.length,
                                      (index) => Card(
                                        elevation: 2,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: TextFormField(
                                                  controller:
                                                      satuanControllers[index],
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText: "Satuan"),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                flex: 1,
                                                child: TextFormField(
                                                  controller:
                                                      stokControllers[index],
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText: "Stok"),
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                flex: 2,
                                                child: TextFormField(
                                                  controller:
                                                      hargaControllers[index],
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText: "Harga"),
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Tombol aksi bawah
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _saveOnlyProduct,
                                        icon: const Icon(Icons.save_alt),
                                        label: const Text("Save Only"),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          if (!hasShopeeSatuan) {
                                            showDialog(
                                              context: context,
                                              builder: (_) => BlocProvider(
                                                create: (context) =>
                                                    AddProductShopeeBloc(
                                                  productController:
                                                      ProductController(),
                                                ),
                                                child: Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: SizedBox(
                                                    width: 600,
                                                    height: 500,
                                                    child:
                                                        AddProductShopeeScreen(
                                                      productId:
                                                          widget.productId,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            final filteredSatuan = state
                                                .product.stokList
                                                .where((stok) =>
                                                    stok.idProductShopee !=
                                                        null &&
                                                    stok.idProductShopee!
                                                        .trim()
                                                        .isNotEmpty)
                                                .toList();

                                            if (filteredSatuan.isEmpty) {
                                              ScaffoldMessenger.of(context)
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
                                              builder: (context) {
                                                return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          "Pilih Satuan Shopee"),
                                                      content:
                                                          DropdownButtonFormField<
                                                              String>(
                                                        value: selectedSatuan,
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    "Satuan"),
                                                        items: filteredSatuan
                                                            .map((stok) =>
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value: stok
                                                                      .satuan,
                                                                  child: Text(
                                                                      "${stok.satuan} (Stok: ${stok.jumlah}, Harga: ${stok.harga})"),
                                                                ))
                                                            .toList(),
                                                        onChanged: (val) =>
                                                            setState(() =>
                                                                selectedSatuan =
                                                                    val),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: const Text(
                                                              "Batal"),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            if (selectedSatuan ==
                                                                null) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        "Pilih satuan terlebih dahulu")),
                                                              );
                                                              return;
                                                            }
                                                            Navigator.pop(
                                                                context);
                                                            showDialog(
                                                              context: context,
                                                              builder: (_) =>
                                                                  BlocProvider(
                                                                create: (context) =>
                                                                    EditProductShopeeBloc(
                                                                  productController:
                                                                      ProductController(),
                                                                ),
                                                                child: Dialog(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12)),
                                                                  child:
                                                                      SizedBox(
                                                                    width: 600,
                                                                    height: 500,
                                                                    child:
                                                                        EditProductShopeeScreen(
                                                                      idProduct:
                                                                          widget
                                                                              .productId,
                                                                      satuan:
                                                                          selectedSatuan!,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child:
                                                              const Text("OK"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.storefront),
                                        label: Text(hasShopeeSatuan
                                            ? "Edit Shopee"
                                            : "Add Product to Shopee"),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: _updateProduct,
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text("Simpan Perubahan"),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.green.shade600),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }

                          return const Center(
                              child: Text("Gagal memuat data produk"));
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
