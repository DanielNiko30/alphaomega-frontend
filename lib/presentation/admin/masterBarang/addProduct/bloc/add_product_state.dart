import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../../../model/product/kategori_model.dart';

abstract class AddProductState extends Equatable {
  const AddProductState();

  @override
  List<Object?> get props => [];
}

class AddProductInitial extends AddProductState {
  const AddProductInitial();
}

class AddProductLoading extends AddProductState {
  const AddProductLoading();
}

class AddProductSuccess extends AddProductState {
  const AddProductSuccess();
}

class AddProductFailure extends AddProductState {
  final String message;
  const AddProductFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class KategoriLoaded extends AddProductState {
  final List<Kategori> kategori;
  const KategoriLoaded({required this.kategori});

  @override
  List<Object?> get props => [kategori];
}

class KategoriLoading extends AddProductState {
  const KategoriLoading();
}

class KategoriFailure extends AddProductState {
  final String message;
  const KategoriFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class KategoriInitial extends AddProductState {
  const KategoriInitial();
}

class ImagePicked extends AddProductState {
  final Uint8List imageBytes;
  final String base64Image;
  final String fileName;

  const ImagePicked(
      {required this.imageBytes,
      required this.base64Image,
      required this.fileName});

  @override
  List<Object?> get props => [imageBytes, base64Image, fileName];
}
