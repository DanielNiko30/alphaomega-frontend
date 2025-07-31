import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import '../../../../../model/product/stok_model.dart';
import '../bloc/add_product_bloc.dart';
import '../bloc/add_product_event.dart';
import '../bloc/add_product_state.dart';
import '../../../../../widget/sidebar.dart';
import '../../../../../model/product/add_product_model.dart';

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
  void initState() {
    super.initState();
    context.read<AddProductBloc>().add(LoadKategori());
  }

  File? _image;
  Uint8List? _imageBytes;
  String? fileName;
  List<TextEditingController> satuanControllers = [];
  List<TextEditingController> hargaControllers = [];
  bool isFoto1x1 = true;

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
      hargaControllers.add(TextEditingController());
    });
  }

  void _submitProduct() {
    if (_formKey.currentState!.validate() &&
        (_imageBytes != null || _image != null)) {
      final satuanList = satuanControllers.map((c) => c.text).toList();
      final hargaList = hargaControllers.map((c) => c.text).toList();

      Uint8List? imageToSend = kIsWeb ? _imageBytes : _image!.readAsBytesSync();

      context.read<AddProductBloc>().add(SubmitProduct(
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
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Harap lengkapi semua data dan pilih gambar")),
      );
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
                  child: BlocListener<AddProductBloc, AddProductState>(
                    listener: (context, state) {
                      if (state is AddProductSuccess) {
                        Navigator.pop(
                            context, true); 
                      } else if (state is AddProductFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message)),
                        );
                      }
                    },
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          const Text("Informasi Produk",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          const Text("* Foto Produk",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 100,
                              height: 600,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: _imageBytes != null || _image != null
                                  ? Image.memory(_imageBytes ?? Uint8List(0),
                                      fit: BoxFit.cover)
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.add_photo_alternate,
                                            size: 40, color: Colors.lightBlue),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: namaController,
                            decoration:
                                const InputDecoration(labelText: "Nama Produk"),
                            validator: (value) => value!.isEmpty
                                ? "Nama tidak boleh kosong"
                                : null,
                          ),
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
                                  onChanged: (value) =>
                                      setState(() => selectedKategori = value),
                                  decoration: const InputDecoration(
                                      labelText: "Kategori"),
                                  validator: (value) =>
                                      value == null ? "Pilih kategori" : null,
                                );
                              }
                              return Container();
                            },
                          ),
                          TextFormField(
                            controller: deskripsiController,
                            decoration:
                                const InputDecoration(labelText: "Deskripsi"),
                            maxLines: 5,
                            validator: (value) => value!.isEmpty
                                ? "Deskripsi tidak boleh kosong"
                                : null,
                          ),
                          ElevatedButton(
                              onPressed: _addSatuanField,
                              child: const Text("Tambah Satuan")),
                          Column(
                            children: List.generate(satuanControllers.length,
                                (index) {
                              return Row(
                                children: [
                                  Expanded(
                                      child: TextFormField(
                                          controller: satuanControllers[index],
                                          decoration: const InputDecoration(
                                              hintText: "Satuan"))),
                                  Expanded(
                                      child: TextFormField(
                                          controller: hargaControllers[index],
                                          decoration: const InputDecoration(
                                              hintText: "Harga"),
                                          keyboardType: TextInputType.number)),
                                ],
                              );
                            }),
                          ),
                          ElevatedButton(
                              onPressed: _submitProduct,
                              child: const Text("Simpan Produk")),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
            ],
          ),
          Sidebar(),
        ],
      ),
    );
  }
}
