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

  Future<void> _onSubmitProduct(
    SubmitProduct event,
    Emitter<AddProductState> emit,
  ) async {
    emit(const AddProductLoading());

    try {
      if (event.product.namaProduct.isEmpty ||
          event.product.productKategori.isEmpty ||
          event.product.harga.isEmpty ||
          event.product.stokList.isEmpty) {
        emit(const AddProductFailure(message: "Semua field wajib diisi"));
        return;
      }

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
      }

      final response = await ProductController.addProduct(formData);
      final responseData = Map<String, dynamic>.from(response.data);

      // Jangan print base64 panjang
      if (responseData['gambarProduct'] != null) {
        responseData['gambarProduct'] =
            '[BASE64 length: ${responseData['gambarProduct'].length}]';
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final latestProduct = await ProductController.getLatestProduct();
        // Emit state ProductSaved agar UI update otomatis
        emit(ProductSaved(productId: latestProduct.idProduct));
      } else {
        emit(const AddProductFailure(message: "Gagal menambahkan produk"));
      }
    } catch (e, stack) {
      emit(AddProductFailure(message: "Error: ${e.toString()}"));
    }
  }

  Future<void> _onLoadKategori(
    LoadKategori event,
    Emitter<AddProductState> emit,
  ) async {
    emit(const KategoriLoading());
    try {
      final kategori = await ProductController.fetchKategori();
      for (var k in kategori) {
        print("Kategori: ${k.idKategori} - ${k.namaKategori}");
      }
      emit(KategoriLoaded(kategori: kategori));
    } catch (e, stack) {
      emit(KategoriFailure(message: e.toString()));
    }
  }

  Future<void> _onPickImage(
    PickImage event,
    Emitter<AddProductState> emit,
  ) async {
    emit(const AddProductLoading());
    try {
      if (event.imageBytes.isEmpty) {
        emit(const AddProductFailure(message: "Gambar tidak valid"));
        return;
      }

      final compressedImage = await FlutterImageCompress.compressWithList(
        event.imageBytes,
        quality: 70,
      );

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
      emit(AddProductFailure(message: "Gagal memilih gambar: ${e.toString()}"));
    }
  }

  Future<void> _onProductSavedEvent(
    ProductSavedEvent event,
    Emitter<AddProductState> emit,
  ) async {
    emit(ProductSaved(productId: event.productId));
  }
}
