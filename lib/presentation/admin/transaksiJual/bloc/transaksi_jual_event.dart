import 'package:equatable/equatable.dart';

abstract class TransJualEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProductsJual extends TransJualEvent {}

// Pilih supplier
class SelectSupplier extends TransJualEvent {
  final String supplierId;
  SelectSupplier(this.supplierId);

  @override
  List<Object?> get props => [supplierId];
}

// Tambah & Hapus Produk dari Transaksi
class AddProduct extends TransJualEvent {
  final String id;
  final String name;
  final String image;
  final int quantity;
  final String unit;
  final double price;
  final int stok;

  AddProduct({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.stok,
  });

  @override
  List<Object?> get props => [id, name, image, quantity, unit, price, stok];
}

class RemoveProduct extends TransJualEvent {
  final String id;
  RemoveProduct(this.id);

  @override
  List<Object?> get props => [id];
}

// Update jumlah atau harga produk
class UpdateProductQuantity extends TransJualEvent {
  final String id;
  final int quantity;
  UpdateProductQuantity(this.id, this.quantity);

  @override
  List<Object?> get props => [id, quantity];
}

class UpdateProductPrice extends TransJualEvent {
  final String id;
  final double price;
  UpdateProductPrice(this.id, this.price);

  @override
  List<Object?> get props => [id, price];
}

// Pilih metode pembayaran
class SelectPaymentMethod extends TransJualEvent {
  final String method;
  SelectPaymentMethod(this.method);

  @override
  List<Object?> get props => [method];
}

// Kirim transaksi
class SubmitTransaction extends TransJualEvent {}

// Ambil satuan produk berdasarkan ID produk
class FetchSatuanByProductId extends TransJualEvent {
  final String productId;
  FetchSatuanByProductId(this.productId);

  @override
  List<Object?> get props => [productId];
}

// Update satuan produk yang dipilih
class UpdateProductUnit extends TransJualEvent {
  final String productId;
  final String unit;
  UpdateProductUnit(this.productId, this.unit);

  @override
  List<Object?> get props => [productId, unit];
}

class SearchProductByNameJual extends TransJualEvent {
  final String query;
  SearchProductByNameJual(this.query);
}

class FetchAllUsers extends TransJualEvent {}

class SelectUser extends TransJualEvent {
  final String userId;
  SelectUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FetchLatestInvoice extends TransJualEvent {}

class InitializeTransJual extends TransJualEvent {}

class ResetSelectedProducts extends TransJualEvent {}

class SelectUserPenjual extends TransJualEvent {
  final String userId;
  SelectUserPenjual(this.userId);
}

class UpdateNamaPembeli extends TransJualEvent {
  final String name;
  UpdateNamaPembeli(this.name);
}

class TogglePrintPreview extends TransJualEvent {}

class CetakNota extends TransJualEvent {}
