import 'dart:io';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../model/product/stok_model.dart';
import '../../../../../model/product/add_product_model.dart';
import '../../../../../widget/sidebar.dart';
import '../bloc/add_product_bloc.dart';
import '../bloc/add_product_event.dart';
import '../bloc/add_product_state.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<AddProductBloc>().add(const LoadKategori());
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _image = null;
          fileName = pickedFile.name;
        });
      } else {
        setState(() {
          _image = File(pickedFile.path);
          _imageBytes = null;
          fileName = pickedFile.name;
        });
      }
    }
  }

  void _addSatuanField() {
    setState(() {
      satuanControllers.add(TextEditingController());
      hargaControllers.add(TextEditingController());
    });
  }

  Future<void> _submitProduct() async {
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
                namaProduct: namaController.text.trim(),
                gambarProduct: fileName,
                harga: hargaList,
                deskripsiProduct: deskripsiController.text.trim(),
                stokList: List.generate(satuanList.length, (index) {
                  return StokProduct(
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
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Perhatian"),
          content:
              const Text("Harap lengkapi semua data dan pilih gambar produk."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      body: BlocListener<AddProductBloc, AddProductState>(
        listener: (context, state) {
          if (state is ProductSaved) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Sukses"),
                content: const Text("Produk berhasil disimpan!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pushReplacementNamed('/masterBarang');
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          } else if (state is AddProductFailure) {
            showDialog(
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
        child: Stack(
          children: [
            Row(
              children: [
                const Sidebar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 30),
                    child: Center(
                      child: Container(
                        width: 900,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "🛒 Tambah Produk Baru",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // === FOTO PRODUK ===
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Foto Produk",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: _pickImage,
                                        child: Container(
                                          height: 250,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: const Color(0xfff4f6f8),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                          ),
                                          child: _imageBytes != null ||
                                                  _image != null
                                              ? AspectRatio(
                                                  aspectRatio: 1,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: kIsWeb
                                                        ? Image.memory(
                                                            _imageBytes!,
                                                            fit: BoxFit.contain,
                                                          )
                                                        : Image.file(
                                                            _image!,
                                                            fit: BoxFit.contain,
                                                          ),
                                                  ),
                                                )
                                              : const Center(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .add_photo_alternate_outlined,
                                                        color: Colors.blue,
                                                        size: 48,
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        "Klik untuk memilih gambar",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // === INFORMASI PRODUK ===
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Informasi Produk",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: namaController,
                                        decoration: const InputDecoration(
                                          labelText: "Nama Produk",
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (v) => v!.isEmpty
                                            ? "Nama produk wajib diisi"
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      BlocBuilder<AddProductBloc,
                                          AddProductState>(
                                        builder: (context, state) {
                                          if (state is KategoriLoaded) {
                                            return DropdownButtonFormField<
                                                String>(
                                              value: selectedKategori,
                                              items: state.kategori
                                                  .map((kategori) {
                                                return DropdownMenuItem<String>(
                                                  value: kategori.idKategori,
                                                  child: Text(
                                                      kategori.namaKategori),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() =>
                                                    selectedKategori = value);
                                              },
                                              decoration: const InputDecoration(
                                                labelText: "Kategori",
                                                border: OutlineInputBorder(),
                                              ),
                                              validator: (value) =>
                                                  value == null
                                                      ? "Pilih kategori"
                                                      : null,
                                            );
                                          }
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: deskripsiController,
                                        maxLines: 5,
                                        decoration: const InputDecoration(
                                          labelText: "Deskripsi Produk",
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (v) => v!.isEmpty
                                            ? "Deskripsi wajib diisi"
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // === SATUAN & HARGA ===
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Satuan & Harga",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        onPressed: _addSatuanField,
                                        icon: const Icon(Icons.add),
                                        label: const Text("Tambah Satuan"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade600,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ...List.generate(
                                        satuanControllers.length,
                                        (index) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      satuanControllers[index],
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: "Satuan",
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  validator: (v) => v!.isEmpty
                                                      ? "Satuan wajib diisi"
                                                      : null,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      hargaControllers[index],
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: "Harga",
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  validator: (v) => v!.isEmpty
                                                      ? "Harga wajib diisi"
                                                      : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // === TOMBOL SIMPAN ===
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _submitProduct,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: const Text(
                                    "💾 Simpan Produk",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
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

            // === LOADING OVERLAY ===
            BlocBuilder<AddProductBloc, AddProductState>(
              builder: (context, state) {
                if (state is AddProductLoading) {
                  return Container(
                    color: Colors.black38,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
