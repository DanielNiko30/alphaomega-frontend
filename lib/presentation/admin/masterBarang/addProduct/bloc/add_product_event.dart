import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../model/product/kategori_model.dart';
import '../../../../../model/product/add_product_model.dart';

abstract class AddProductEvent extends Equatable {
  const AddProductEvent();

  @override
  List<Object?> get props => [];
}

class SubmitProduct extends AddProductEvent {
  final AddProduct product;
  final Uint8List? imageBytes;
  final String? fileName;

  const SubmitProduct({required this.product, this.imageBytes, this.fileName});

  @override
  List<Object?> get props => [product, imageBytes, fileName];
}

class LoadKategori extends AddProductEvent {
  const LoadKategori();
}

class PickImage extends AddProductEvent {
  final Uint8List imageBytes;
  final String fileName;

  const PickImage({required this.imageBytes, required this.fileName});

  @override
  List<Object?> get props => [imageBytes, fileName];
}
