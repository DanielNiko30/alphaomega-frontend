import 'package:equatable/equatable.dart';
import '../../../../../model/product/stok_model.dart';

/// Base class untuk semua state
abstract class AddProductShopeeState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// 🔹 State awal
class AddProductShopeeInitial extends AddProductShopeeState {}

/// 🔹 Sedang memuat data
class AddProductShopeeLoading extends AddProductShopeeState {}

/// 🔹 Data satuan berhasil dimuat
class AddProductShopeeLoaded extends AddProductShopeeState {
  final List<Stok> stokList; // Semua stok yang belum diupload ke Shopee
  final Stok? selectedSatuan; // Satuan yang dipilih user

  AddProductShopeeLoaded({
    required this.stokList,
    this.selectedSatuan,
  });

  AddProductShopeeLoaded copyWith({
    List<Stok>? stokList,
    Stok? selectedSatuan,
  }) {
    return AddProductShopeeLoaded(
      stokList: stokList ?? this.stokList,
      selectedSatuan: selectedSatuan ?? this.selectedSatuan,
    );
  }

  @override
  List<Object?> get props => [
        stokList,
        selectedSatuan ?? '',
      ];
}

/// 🔹 Sedang submit ke Shopee
class AddProductShopeeSubmitting extends AddProductShopeeState {}

/// 🔹 Submit berhasil
class AddProductShopeeSuccess extends AddProductShopeeState {
  final String message;

  AddProductShopeeSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// 🔹 Submit gagal
class AddProductShopeeFailure extends AddProductShopeeState {
  final String message;

  AddProductShopeeFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
