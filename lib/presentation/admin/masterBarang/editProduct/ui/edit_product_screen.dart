import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import '../../../../../controller/admin/lazada_controller.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../widget/sidebar.dart';
import '../../../../../model/product/stok_model.dart';
import '../../../../../model/product/update_product_model.dart';
import '../../../../../model/product/kategori_model.dart';
import '../../addProductLazada/bloc/add_product_lazada_bloc.dart';
import '../../addProductLazada/ui/add_product_lazada_screen.dart';
import '../../addProductShopee/bloc/add_product_shopee_bloc.dart';
import '../../addProductShopee/ui/add_product_shopee_screen.dart';
import '../../editProductLazada/bloc/edit_product_lazada_bloc.dart';
import '../../editProductLazada/ui/edit_product_lazada_screen.dart';
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

  List<StokProduct> parseStokList(dynamic stokList) {
    if (stokList == null) return [];

    if (stokList is List<StokProduct>) return stokList;

    if (stokList is List) {
      return stokList
          .map((e) {
            // Sudah StokProduct
            if (e is StokProduct) return e;

            // Kalau Map<String, dynamic>
            if (e is Map<String, dynamic>) return StokProduct.fromJson(e);

            // Kalau JSObject/JSArray (web)
            try {
              final dyn = e as dynamic;
              final idStok = dyn.idStok ?? dyn.id_stok ?? '';
              final satuan = dyn.satuan ?? '';
              final jumlah = int.tryParse((dyn.jumlah ?? 0).toString()) ?? 0;
              final harga = int.tryParse((dyn.harga ?? 0).toString()) ?? 0;

              return StokProduct(
                idStok: idStok,
                satuan: satuan,
                jumlah: jumlah,
                harga: harga,
              );
            } catch (_) {
              return null;
            }
          })
          .whereType<StokProduct>()
          .toList();
    }

    return [];
  }

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
    final jumlahList = stokControllers.map((c) => c.text).toList();

    // Ambil stok lama dari Bloc
    final currentState = context.read<EditProductBloc>().state;
    List<StokProduct> oldStokList = [];
    if (currentState is EditProductLoaded) {
      oldStokList = parseStokList(currentState.product.stokList);
    } else if (currentState is EditProductUpdated) {
      oldStokList = currentState.updatedProduct.stokList ?? [];
    } else if (currentState is EditProductSavedOnly) {
      oldStokList = currentState.savedProduct.stokList ?? [];
    }

    final oldStokMap = {for (var s in oldStokList) s.satuan: s};

    // Generate stok baru
    final updatedStokList = List.generate(satuanList.length, (index) {
      final satuan = satuanList[index];
      final oldStok = oldStokMap[satuan];

      return StokProduct(
        idStok: oldStok?.idStok, // tetap pakai idStok lama jika ada
        satuan: satuan,
        harga: int.tryParse(hargaList[index]) ?? 0,
        jumlah: int.tryParse(jumlahList[index]) ?? 0,
        // stok lama tetap bawa ID Shopee/Lazada, stok baru null
        idProductShopee: oldStok?.idProductShopee,
        idProductLazada: oldStok?.idProductLazada,
      );
    });

    final updatedProduct = UpdateProduct(
      idProduct: widget.productId,
      productKategori: selectedKategori!,
      namaProduct: namaController.text,
      gambarProduct: fileName ?? existingImageUrl,
      deskripsiProduct: deskripsiController.text,
      stokList: updatedStokList,
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
    final jumlahList = stokControllers.map((c) => c.text).toList();

    final currentState = context.read<EditProductBloc>().state;
    List<StokProduct> oldStokList = [];
    if (currentState is EditProductLoaded) {
      oldStokList = parseStokList(currentState.product.stokList);
    } else if (currentState is EditProductUpdated) {
      oldStokList = currentState.updatedProduct.stokList ?? [];
    } else if (currentState is EditProductSavedOnly) {
      oldStokList = currentState.savedProduct.stokList ?? [];
    }

    final oldStokMap = {for (var s in oldStokList) s.satuan: s};

    final updatedStokList = List.generate(satuanList.length, (index) {
      final satuan = satuanList[index];
      final oldStok = oldStokMap[satuan];

      return StokProduct(
        idStok: oldStok?.idStok, // tetap pakai idStok lama jika ada
        satuan: satuan,
        harga: int.tryParse(hargaList[index]) ?? 0,
        jumlah: int.tryParse(jumlahList[index]) ?? 0,
        // stok lama tetap bawa ID Shopee/Lazada, stok baru null
        idProductShopee: oldStok?.idProductShopee,
        idProductLazada: oldStok?.idProductLazada,
      );
    });

    final updatedProduct = UpdateProduct(
      idProduct: widget.productId,
      productKategori: selectedKategori!,
      namaProduct: namaController.text,
      gambarProduct: fileName ?? existingImageUrl,
      deskripsiProduct: deskripsiController.text,
      stokList: updatedStokList,
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
                            final stokList = product.stokList;
                            final totalSatuan = stokList.length;
                            final jumlahShopee = stokList
                                .where((s) =>
                                    s.idProductShopee != null &&
                                    s.idProductShopee!.trim().isNotEmpty)
                                .length;
                            final semuaSudahShopee =
                                jumlahShopee == totalSatuan;
                            final adaShopee = jumlahShopee > 0;

                            final jumlahLazada = stokList
                                .where((s) =>
                                    s.idProductLazada != null &&
                                    s.idProductLazada!.trim().isNotEmpty)
                                .length;
                            final semuaSudahLazada =
                                jumlahLazada == totalSatuan;
                            final adaLazada = jumlahLazada > 0;
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
                                                        aspectRatio: 1,
                                                        child: Image.network(
                                                          existingImageUrl!,
                                                          fit: BoxFit.contain,
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          errorBuilder: (context,
                                                                  error,
                                                                  stackTrace) =>
                                                              const Icon(Icons
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
                                  Column(
                                    children: List.generate(
                                      satuanControllers.length,
                                      (index) {
                                        final stok =
                                            index < product.stokList.length
                                                ? product.stokList[index]
                                                : null; // null artinya baru

                                        return Card(
                                          elevation: 2,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
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
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red),
                                                  onPressed: () async {
                                                    if (stok != null &&
                                                        stok.idStok != null) {
                                                      // Jika stok sudah ada di DB
                                                      bool success =
                                                          await ProductController
                                                              .deleteStok(
                                                                  stok.idStok!);
                                                      if (success) {
                                                        setState(() {
                                                          satuanControllers
                                                              .removeAt(index);
                                                          stokControllers
                                                              .removeAt(index);
                                                          hargaControllers
                                                              .removeAt(index);
                                                        });
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                              content: Text(
                                                                  "Stok berhasil dihapus")),
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                              content: Text(
                                                                  "Gagal menghapus stok")),
                                                        );
                                                      }
                                                    } else {
                                                      // Jika stok baru (belum ada di DB)
                                                      setState(() {
                                                        satuanControllers
                                                            .removeAt(index);
                                                        stokControllers
                                                            .removeAt(index);
                                                        hargaControllers
                                                            .removeAt(index);
                                                      });
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: _saveOnlyProduct,
                                            icon: const Icon(Icons.save_alt),
                                            label: const Text("Save Only"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              foregroundColor: Colors.black87,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                            ),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: _updateProduct,
                                            icon:
                                                const Icon(Icons.check_circle),
                                            label:
                                                const Text("Simpan Perubahan"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green.shade600,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 12,
                                        runSpacing: 8,
                                        children: [
                                          // === SHOPEE ADD ===
                                          if (!semuaSudahShopee)
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => BlocProvider(
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
                                                                    .productId),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                  Icons.add_business,
                                                  color: Colors.orange),
                                              label: const Text("Add Shopee"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.black87,
                                                side: const BorderSide(
                                                    color: Colors.orange),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                        vertical: 10),
                                              ),
                                            ),

                                          // === SHOPEE EDIT ===
                                          if (adaShopee)
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                final filteredSatuan = stokList
                                                    .where((stok) =>
                                                        stok.idProductShopee !=
                                                            null &&
                                                        stok.idProductShopee!
                                                            .trim()
                                                            .isNotEmpty)
                                                    .toList();

                                                String? selectedSatuan;

                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              "Pilih Satuan Shopee"),
                                                          content:
                                                              DropdownButtonFormField<
                                                                  String>(
                                                            value:
                                                                selectedSatuan,
                                                            decoration:
                                                                const InputDecoration(
                                                                    labelText:
                                                                        "Satuan"),
                                                            items:
                                                                filteredSatuan
                                                                    .map(
                                                                      (stok) =>
                                                                          DropdownMenuItem<
                                                                              String>(
                                                                        value: stok
                                                                            .satuan,
                                                                        child: Text(
                                                                            "${stok.satuan} (Stok: ${stok.jumlah}, Harga: ${stok.harga})"),
                                                                      ),
                                                                    )
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
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                          "Pilih satuan terlebih dahulu"),
                                                                    ),
                                                                  );
                                                                  return;
                                                                }
                                                                Navigator.pop(
                                                                    context);
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
                                                                              widget.productId, // 🟢 id dari DB lokal
                                                                          itemId: filteredSatuan
                                                                              .firstWhere((s) => s.satuan == selectedSatuan)
                                                                              .idProductShopee!, // 🟢 id Shopee dari stok
                                                                          satuan:
                                                                              selectedSatuan!,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: const Text(
                                                                  "OK"),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                              icon: const Icon(Icons.storefront,
                                                  color: Colors.orange),
                                              label: const Text("Edit Shopee"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.black87,
                                                side: const BorderSide(
                                                    color: Colors.orange),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                        vertical: 10),
                                              ),
                                            ),

                                          // === LAZADA ADD ===
                                          if (!semuaSudahLazada)
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => BlocProvider(
                                                    create: (context) =>
                                                        AddProductLazadaBloc(
                                                      productController:
                                                          ProductController(),
                                                      lazadaController:
                                                          LazadaController(),
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
                                                            AddProductLazadaScreen(
                                                                productId: widget
                                                                    .productId),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                  Icons.add_business_outlined,
                                                  color: Colors.purple),
                                              label: const Text("Add Lazada"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.black87,
                                                side: const BorderSide(
                                                    color: Colors.purple),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                        vertical: 10),
                                              ),
                                            ),

                                          if (adaLazada)
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                final filteredLazada = stokList
                                                    .where((stok) =>
                                                        stok.idProductLazada !=
                                                            null &&
                                                        stok.idProductLazada!
                                                            .trim()
                                                            .isNotEmpty)
                                                    .toList();

                                                String? selectedSatuan;

                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              "Pilih Satuan Lazada"),
                                                          content:
                                                              DropdownButtonFormField<
                                                                  String>(
                                                            value:
                                                                selectedSatuan,
                                                            decoration:
                                                                const InputDecoration(
                                                                    labelText:
                                                                        "Satuan"),
                                                            items:
                                                                filteredLazada
                                                                    .map(
                                                                      (stok) =>
                                                                          DropdownMenuItem<
                                                                              String>(
                                                                        value: stok
                                                                            .satuan,
                                                                        child: Text(
                                                                            "${stok.satuan} (Stok: ${stok.jumlah}, Harga: ${stok.harga})"),
                                                                      ),
                                                                    )
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
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                          "Pilih satuan terlebih dahulu"),
                                                                    ),
                                                                  );
                                                                  return;
                                                                }

                                                                Navigator.pop(
                                                                    context);

                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (_) =>
                                                                      BlocProvider(
                                                                    create: (context) =>
                                                                        EditProductLazadaBloc(
                                                                      productController:
                                                                          ProductController(),
                                                                      lazadaController:
                                                                          LazadaController(),
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
                                                                            EditProductLazadaScreen(
                                                                          productId:
                                                                              widget.productId, // 🟢 id dari DB lokal
                                                                          itemId: filteredLazada
                                                                              .firstWhere((s) => s.satuan == selectedSatuan)
                                                                              .idProductLazada!, // 🟣 id Lazada dari stok
                                                                          satuan:
                                                                              selectedSatuan!, // biar bisa load data sesuai satuan
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: const Text(
                                                                  "OK"),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                              icon: const Icon(
                                                Icons
                                                    .store_mall_directory_outlined,
                                                color: Colors.purple,
                                              ),
                                              label: const Text("Edit Lazada"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.black87,
                                                side: const BorderSide(
                                                    color: Colors.purple),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                        vertical: 10),
                                              ),
                                            ),
                                        ],
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
