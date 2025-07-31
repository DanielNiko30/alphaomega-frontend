import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/model/product/kategori_model.dart';
import 'package:frontend/model/product/update_product_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import '../bloc/edit_product_bloc.dart';
import '../bloc/edit_product_event.dart';
import '../bloc/edit_product_state.dart';
import '../../../../../widget/sidebar.dart';
import '../../../../../model/product/stok_model.dart';

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

  List<Kategori> kategoriList = [];

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
          return Stok(
            idStok: "",
            satuan: satuanList[index],
            harga: int.parse(hargaList[index]),
            jumlah: int.parse(stokList[index]),
          );
        }),
      );

      Uint8List? imageToSend = kIsWeb ? _imageBytes : _image?.readAsBytesSync();

      context.read<EditProductBloc>().add(SubmitUpdateProduct(
          product: updatedProduct,
          imageBytes: imageToSend,
          fileName: fileName));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Harap lengkapi semua data")));
    }
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Text("Edit Produk",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: BlocConsumer<EditProductBloc, EditProductState>(
                          listener: (context, state) {
                            if (state is EditProductSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Produk berhasil diperbarui")));
                              Navigator.pushReplacementNamed(
                                  context, "/masterBarang");
                            } else if (state is EditProductFailure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Produk berhasil diperbarui")));
                              Navigator.pushReplacementNamed(
                                  context, "/masterBarang");
                            }
                          },
                          builder: (context, state) {
                            if (state is EditProductLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (state is EditProductLoaded) {
                              namaController.text = state.product.namaProduct;
                              deskripsiController.text =
                                  state.product.deskripsiProduct ?? "";
                              selectedKategori = state.product.productKategori;
                              existingImageUrl = state.product.gambarProduct;
                              if (satuanControllers.isEmpty) {
                                for (var stok in state.product.stokList) {
                                  satuanControllers.add(
                                      TextEditingController(text: stok.satuan));
                                  hargaControllers.add(TextEditingController(
                                      text: stok.harga.toString()));
                                  stokControllers.add(TextEditingController(
                                      text: stok.jumlah.toString()));
                                }
                              }
                              return Padding(                    
                                padding: const EdgeInsets.all(16),
                                child: Form(
                                  key: _formKey,
                                  child: ListView(
                                    children: [
                                      const SizedBox(height: 10),
                                      const Text("* Foto Produk",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      GestureDetector(
                                        onTap: _pickImage,
                                        child: Container(
                                          width: 100,
                                          height: 600,
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
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
                                                      : Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: const [
                                                            Icon(
                                                                Icons
                                                                    .add_photo_alternate,
                                                                size: 40,
                                                                color: Colors
                                                                    .lightBlue),
                                                          ],
                                                        ),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: namaController,
                                        decoration: const InputDecoration(
                                            labelText: "Nama Produk"),
                                        validator: (value) => value!.isEmpty
                                            ? "Nama tidak boleh kosong"
                                            : null,
                                      ),
                                      BlocBuilder<EditProductBloc,
                                          EditProductState>(
                                        builder: (context, state) {
                                          if (state is EditProductLoaded) {
                                            // Pastikan hanya inisialisasi pertama kali
                                            if (satuanControllers.isEmpty) {
                                              for (var stok
                                                  in state.product.stokList) {
                                                satuanControllers.add(
                                                    TextEditingController(
                                                        text: stok.satuan));
                                                stokControllers.add(
                                                    TextEditingController(
                                                        text: stok.jumlah
                                                            .toString()));
                                                hargaControllers.add(
                                                    TextEditingController(
                                                        text: stok.harga
                                                            .toString()));
                                              }
                                            }
                                          }
                                          if (state is EditProductLoading) {
                                            return CircularProgressIndicator();
                                          } else if (state
                                              is EditProductLoaded) {
                                            String? selectedKategoriId =
                                                state.selectedKategoriId;

                                            return DropdownButton<String>(
                                              value: (selectedKategoriId !=
                                                          null &&
                                                      state.kategori.any((kat) =>
                                                          kat.idKategori ==
                                                          selectedKategoriId))
                                                  ? selectedKategoriId
                                                  : state.kategori.isNotEmpty
                                                      ? state.kategori.first
                                                          .idKategori // Set default ke kategori pertama jika tidak ada yang cocok
                                                      : null,
                                              items: state.kategori
                                                  .map((kategori) {
                                                return DropdownMenuItem<String>(
                                                  value: kategori.idKategori,
                                                  child: Text(
                                                      kategori.namaKategori),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                if (value != null) {
                                                  context
                                                      .read<EditProductBloc>()
                                                      .add(SelectKategori(
                                                          value));
                                                }
                                              },
                                            );
                                          } else {
                                            return Text(
                                                "Gagal memuat kategori");
                                          }
                                        },
                                      ),
                                      TextFormField(
                                        controller: deskripsiController,
                                        decoration: const InputDecoration(
                                            labelText: "Deskripsi"),
                                        maxLines: 5,
                                      ),
                                      ElevatedButton(
                                          onPressed: _addSatuanField,
                                          child: const Text("Tambah Satuan")),
                                      SizedBox(
                                        height: 200,
                                        child: ListView.builder(
                                          itemCount: satuanControllers.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: TextFormField(
                                                      controller:
                                                          satuanControllers[
                                                              index],
                                                      decoration:
                                                          InputDecoration(
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
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "Stok"),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    flex: 2,
                                                    child: TextFormField(
                                                      controller:
                                                          hargaControllers[
                                                              index],
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          InputDecoration(
                                                              labelText:
                                                                  "Harga"),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      ElevatedButton(
                                          onPressed: _updateProduct,
                                          child:
                                              const Text("Simpan Perubahan")),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
                    ],
                  ),
                )),
              ),
            ],
          ),
          Sidebar(),
        ],
      ),
    );
  }
}
