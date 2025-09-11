import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

import '../../../../../model/product/stok_model.dart';
import '../../../../../model/product/product_model.dart';
import '../../../../../widget/sidebar.dart';
import '../../../../../model/product/add_product_model.dart';
import '../../../masterBarang/addProductShopee/ui/add_product_shopee_screen.dart';
import '../bloc/add_product_bloc.dart';
import '../bloc/add_product_event.dart';
import '../bloc/add_product_state.dart';
import '../../../../../controller/admin/product_controller.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  String? selectedKategori;

  File? _image;
  Uint8List? _imageBytes;
  String? fileName;

  List<TextEditingController> satuanControllers = [];
  List<TextEditingController> hargaControllers = [];
  bool isFoto1x1 = true;

  /// Menyimpan product ID terakhir
  String? latestProductId;

  @override
  void initState() {
    super.initState();
    context.read<AddProductBloc>().add(LoadKategori());
  }

  /// **Pilih Gambar Produk**
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

  /// **Tambah Field Satuan dan Harga**
  void _addSatuanField() {
    setState(() {
      satuanControllers.add(TextEditingController());
      hargaControllers.add(TextEditingController());
    });
  }

  /// **Submit Produk ke DB**
  Future<void> _submitProduct({bool goBack = false}) async {
    if (_formKey.currentState!.validate() &&
        (_imageBytes != null || _image != null)) {
      final satuanList = satuanControllers.map((c) => c.text).toList();
      final hargaList = hargaControllers.map((c) => c.text).toList();

      Uint8List? imageToSend = kIsWeb ? _imageBytes : _image!.readAsBytesSync();

      context.read<AddProductBloc>().add(
            SubmitProduct(
              product: AddProduct(
                idProduct: "",
                productKategori: selectedKategori!,
                namaProduct: namaController.text,
                gambarProduct: fileName,
                harga: hargaList,
                deskripsiProduct: deskripsiController.text,
                stokList: List.generate(satuanList.length, (index) {
                  return Stok(
                    idStok: "",
                    satuan: satuanList[index],
                    harga: int.parse(hargaList[index]),
                    jumlah: 0,
                  );
                }),
              ),
              imageBytes: imageToSend,
              fileName: fileName,
            ),
          );

      // ✅ Ambil produk terbaru setelah berhasil disimpan
      try {
        final latestProduct = await ProductController.getLatestProduct();
        setState(() {
          latestProductId = latestProduct.idProduct;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk berhasil disimpan!")),
        );
      } catch (e) {
        print("Gagal mengambil produk terbaru: $e");
      }

      if (goBack) {
        Navigator.pop(context, true); // kembali ke list product
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Harap lengkapi semua data dan pilih gambar")),
      );
    }
  }

  /// **Buka Popup Add to Shopee**
  void _openShopeePopup() {
    if (latestProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Simpan produk terlebih dahulu!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SizedBox(
            width: 600,
            height: 500,
            child: AddProductShopeeScreen(
              productId: latestProductId!, // ✅ kirim productId ke popup
            ),
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
                    child: BlocListener<AddProductBloc, AddProductState>(
                      listener: (context, state) {
                        if (state is AddProductFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            const Text(
                              "Informasi Produk",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),

                            /// Foto Produk
                            const Text(
                              "* Foto Produk",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 100,
                                height: 300,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: _imageBytes != null || _image != null
                                    ? Image.memory(
                                        _imageBytes ?? Uint8List(0),
                                        fit: BoxFit.cover,
                                      )
                                    : const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate,
                                            size: 40,
                                            color: Colors.lightBlue,
                                          ),
                                          Text("Pilih Gambar"),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            /// Nama Produk
                            TextFormField(
                              controller: namaController,
                              decoration: const InputDecoration(
                                labelText: "Nama Produk",
                              ),
                              validator: (value) => value!.isEmpty
                                  ? "Nama tidak boleh kosong"
                                  : null,
                            ),

                            /// Dropdown Kategori
                            BlocBuilder<AddProductBloc, AddProductState>(
                              builder: (context, state) {
                                if (state is KategoriLoaded) {
                                  return DropdownButtonFormField<String>(
                                    value: selectedKategori,
                                    items: state.kategori.map((kategori) {
                                      return DropdownMenuItem<String>(
                                        value: kategori.idKategori,
                                        child: Text(kategori.namaKategori),
                                      );
                                    }).toList(),
                                    onChanged: (value) => setState(
                                        () => selectedKategori = value),
                                    decoration: const InputDecoration(
                                      labelText: "Kategori",
                                    ),
                                    validator: (value) =>
                                        value == null ? "Pilih kategori" : null,
                                  );
                                }
                                return Container();
                              },
                            ),

                            /// Deskripsi Produk
                            TextFormField(
                              controller: deskripsiController,
                              decoration: const InputDecoration(
                                labelText: "Deskripsi",
                              ),
                              maxLines: 5,
                              validator: (value) => value!.isEmpty
                                  ? "Deskripsi tidak boleh kosong"
                                  : null,
                            ),
                            const SizedBox(height: 10),

                            /// Tambah Satuan
                            ElevatedButton(
                              onPressed: _addSatuanField,
                              child: const Text("Tambah Satuan"),
                            ),
                            Column(
                              children: List.generate(
                                satuanControllers.length,
                                (index) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: satuanControllers[index],
                                          decoration: const InputDecoration(
                                              hintText: "Satuan"),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextFormField(
                                          controller: hargaControllers[index],
                                          decoration: const InputDecoration(
                                              hintText: "Harga"),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),

                            /// TOMBOL AKSI
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      _submitProduct(goBack: false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: const Text("Tambahkan Barang"),
                                ),
                                ElevatedButton(
                                  onPressed: () => _submitProduct(goBack: true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text("Simpan & Kembali"),
                                ),
                                ElevatedButton(
                                  onPressed: latestProductId != null
                                      ? _openShopeePopup
                                      : null, // ❌ nonaktif kalau belum ada productId
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: const Text("Add Product to Shopee"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
