import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../model/product/kategori_model.dart';
import '../../../../../model/product/add_product_model.dart';
import 'add_product_event.dart';
import 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  final ProductController productController;

  AddProductBloc(this.productController) : super(AddProductInitial()) {
    on<SubmitProduct>(_onSubmitProduct);
    on<LoadKategori>(_onLoadKategori);
    on<PickImage>(_onPickImage);
  }

  void _onSubmitProduct(
      SubmitProduct event, Emitter<AddProductState> emit) async {
    emit(AddProductLoading());
    try {
      FormData formData = FormData.fromMap({
        "nama_product": event.product.namaProduct,
        "product_kategori": event.product.productKategori,
        "harga": jsonEncode(event.product.harga),
        "deskripsi_product": event.product.deskripsiProduct,
        "satuan_stok": jsonEncode(
            event.product.stokList.map((stok) => stok.satuan).toList()),
      });

      if (event.imageBytes != null && event.fileName != null) {
        formData.files.add(MapEntry(
          "gambar_product",
          MultipartFile.fromBytes(
            event.imageBytes!,
            filename: event.fileName!,
            contentType: MediaType("image", "jpeg"),
          ),
        ));
      }

      final response = await ProductController.addProduct(formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(AddProductSuccess());
      } else {
        emit(AddProductFailure(message: "Gagal menambahkan produk"));
      }
    } catch (e) {
      emit(AddProductFailure(message: "Error: ${e.toString()}"));
    }
  }

  void _onLoadKategori(
      LoadKategori event, Emitter<AddProductState> emit) async {
    emit(KategoriLoading());
    try {
      List<Kategori> kategori = await ProductController.fetchKategori();
      emit(KategoriLoaded(kategori: kategori));
    } catch (e) {
      emit(KategoriFailure(message: e.toString()));
    }
  }

  void _onPickImage(PickImage event, Emitter<AddProductState> emit) async {
    emit(AddProductLoading());
    try {
      if (event.imageBytes.isEmpty) {
        emit(AddProductFailure(message: "Gambar tidak valid"));
        return;
      }

      Uint8List? compressedImage = await FlutterImageCompress.compressWithList(
        event.imageBytes,
        quality: 70, // Sesuaikan kualitas kompresi
      );

      if (compressedImage == null) {
        emit(AddProductFailure(message: "Gagal mengompres gambar"));
        return;
      }

      String base64Image = base64Encode(compressedImage);

      emit(ImagePicked(
        imageBytes: compressedImage,
        base64Image: base64Image,
        fileName: event.fileName,
      ));
    } catch (e) {
      emit(AddProductFailure(message: "Gagal memilih gambar: ${e.toString()}"));
    }
  }
}
