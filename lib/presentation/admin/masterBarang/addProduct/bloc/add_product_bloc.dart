import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../../controller/admin/product_controller.dart';
import '../../../../../model/product/kategori_model.dart';
import '../../../../../model/product/latest_product_model.dart';
import 'add_product_event.dart';
import 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  final ProductController productController;

  AddProductBloc(this.productController) : super(const AddProductInitial()) {
    on<SubmitProduct>(_onSubmitProduct);
    on<LoadKategori>(_onLoadKategori);
    on<PickImage>(_onPickImage);
    on<ProductSavedEvent>(_onProductSavedEvent);
  }

  /// ===============================
  /// SUBMIT PRODUCT KE BACKEND
  /// ===============================
  Future<void> _onSubmitProduct(
    SubmitProduct event,
    Emitter<AddProductState> emit,
  ) async {
    emit(const AddProductLoading());

    try {
      print("==== [DEBUG] Submit Product ====");
      print("Nama Produk    : ${event.product.namaProduct}");
      print("Kategori       : ${event.product.productKategori}");
      print("Harga List     : ${event.product.harga}");
      print("Deskripsi      : ${event.product.deskripsiProduct}");
      print(
          "Stok List      : ${event.product.stokList.map((e) => e.toJson()).toList()}");
      print("File Name      : ${event.fileName}");
      print("Image Bytes    : ${event.imageBytes?.length ?? 0}");

      // Validasi field wajib
      if (event.product.namaProduct.isEmpty ||
          event.product.productKategori.isEmpty ||
          event.product.harga.isEmpty ||
          event.product.stokList.isEmpty) {
        emit(const AddProductFailure(message: "Semua field wajib diisi"));
        return;
      }

      // ===============================
      // FORM DATA UNTUK API
      // ===============================
      final formData = FormData.fromMap({
        "nama_product": event.product.namaProduct,
        "product_kategori": event.product.productKategori,
        "harga": jsonEncode(event.product.harga),
        "deskripsi_product": event.product.deskripsiProduct ?? '',
        "satuan_stok": jsonEncode(
          event.product.stokList.map((stok) => stok.satuan).toList(),
        ),
      });

      // Jika ada gambar yang dipilih
      if (event.imageBytes != null && event.fileName != null) {
        print("==== [DEBUG] Menambahkan file gambar ke FormData ====");
        formData.files.add(
          MapEntry(
            "gambar_product",
            MultipartFile.fromBytes(
              event.imageBytes!,
              filename: event.fileName!,
              contentType: MediaType("image", "jpeg"),
            ),
          ),
        );
      } else {
        print("==== [WARNING] Tidak ada gambar yang dikirim ====");
      }

      print("==== [DEBUG] Mengirim FormData ke backend ====");
      final response = await ProductController.addProduct(formData);

      print("==== [DEBUG] Response Backend ====");
      print("Status Code : ${response.statusCode}");
      final responseData = Map<String, dynamic>.from(response.data);

      // Jangan print base64 panjang
      if (responseData['gambarProduct'] != null) {
        responseData['gambarProduct'] =
            '[BASE64 length: ${responseData['gambarProduct'].length}]';
      }
      print("Data (no full image) : $responseData");

      // ===============================
      // CEK RESPONSE BACKEND
      // ===============================
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(
            "==== [DEBUG] Produk berhasil disimpan, ambil produk terbaru ====");
        final latestProduct = await ProductController.getLatestProduct();

        print("==== [DEBUG] Latest Product ====");
        print("ID Product : ${latestProduct.idProduct}");
        print("Nama       : ${latestProduct.namaProduct}");
        print(
            "Stok       : ${latestProduct.stok.map((e) => e.toJson()).toList()}");

        // Emit state ProductSaved agar UI update otomatis
        emit(ProductSaved(productId: latestProduct.idProduct));
      } else {
        print("==== [ERROR] Gagal menambahkan produk ====");
        emit(const AddProductFailure(message: "Gagal menambahkan produk"));
      }
    } catch (e, stack) {
      print("==== [EXCEPTION] Terjadi error saat submit ====");
      print("Error: $e");
      print("Stacktrace: $stack");
      emit(AddProductFailure(message: "Error: ${e.toString()}"));
    }
  }

  /// ===============================
  /// LOAD KATEGORI PRODUK
  /// ===============================
  Future<void> _onLoadKategori(
    LoadKategori event,
    Emitter<AddProductState> emit,
  ) async {
    emit(const KategoriLoading());
    try {
      print("==== [DEBUG] Memuat kategori produk ====");
      final kategori = await ProductController.fetchKategori();
      print("==== [DEBUG] Kategori Loaded ====");
      for (var k in kategori) {
        print("Kategori: ${k.idKategori} - ${k.namaKategori}");
      }
      emit(KategoriLoaded(kategori: kategori));
    } catch (e, stack) {
      print("==== [ERROR] Gagal memuat kategori ====");
      print("Error: $e");
      print("Stacktrace: $stack");
      emit(KategoriFailure(message: e.toString()));
    }
  }

  /// ===============================
  /// PICK IMAGE DAN KOMPRES
  /// ===============================
  Future<void> _onPickImage(
    PickImage event,
    Emitter<AddProductState> emit,
  ) async {
    emit(const AddProductLoading());
    try {
      print("==== [DEBUG] Pick Image ====");
      print("Original Image Bytes: ${event.imageBytes.length}");
      print("File Name: ${event.fileName}");

      if (event.imageBytes.isEmpty) {
        emit(const AddProductFailure(message: "Gambar tidak valid"));
        return;
      }

      // Kompres gambar
      final compressedImage = await FlutterImageCompress.compressWithList(
        event.imageBytes,
        quality: 70,
      );

      print("Compressed Image Bytes: ${compressedImage.length}");

      if (compressedImage.isEmpty) {
        emit(const AddProductFailure(message: "Gagal mengompres gambar"));
        return;
      }

      emit(ImagePicked(
        imageBytes: compressedImage,
        base64Image: base64Encode(compressedImage),
        fileName: event.fileName,
      ));
    } catch (e, stack) {
      print("==== [ERROR] Gagal memilih gambar ====");
      print("Error: $e");
      print("Stacktrace: $stack");
      emit(AddProductFailure(message: "Gagal memilih gambar: ${e.toString()}"));
    }
  }

  /// ===============================
  /// EVENT SETELAH PRODUK BERHASIL DISIMPAN
  /// ===============================
  Future<void> _onProductSavedEvent(
    ProductSavedEvent event,
    Emitter<AddProductState> emit,
  ) async {
    print("==== [DEBUG] ProductSavedEvent diterima ====");
    print("Product ID: ${event.productId}");
    emit(ProductSaved(productId: event.productId));
  }
}
