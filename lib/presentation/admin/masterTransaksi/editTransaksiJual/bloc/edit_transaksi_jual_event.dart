import 'package:equatable/equatable.dart';

abstract class TransJualEditEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load transaksi dari backend dan prefill form
class LoadTransactionForEdit extends TransJualEditEvent {
  final String transactionId;
  LoadTransactionForEdit(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

/// Tambah produk ke keranjang edit
class AddProductEdit extends TransJualEditEvent {
  final String id;
  final String name;
  final String image;
  final int quantity;
  final String unit;
  final double price;
  final int stok;

  AddProductEdit({
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

/// Hapus produk
class RemoveProductEdit extends TransJualEditEvent {
  final String id;
  RemoveProductEdit(this.id);

  @override
  List<Object?> get props => [id];
}

/// Update jumlah produk
class UpdateProductQuantityEdit extends TransJualEditEvent {
  final String id;
  final int quantity;
  UpdateProductQuantityEdit(this.id, this.quantity);

  @override
  List<Object?> get props => [id, quantity];
}

/// Update harga produk
class UpdateProductPriceEdit extends TransJualEditEvent {
  final String id;
  final double price;
  UpdateProductPriceEdit(this.id, this.price);

  @override
  List<Object?> get props => [id, price];
}

/// Update satuan produk
class UpdateProductUnitEdit extends TransJualEditEvent {
  final String productId;
  final String unit;
  UpdateProductUnitEdit(this.productId, this.unit);

  @override
  List<Object?> get props => [productId, unit];
}

/// Fetch satuan untuk produk tertentu
class FetchSatuanByProductIdEdit extends TransJualEditEvent {
  final String productId;
  FetchSatuanByProductIdEdit(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Update user pembeli
class SelectUserEdit extends TransJualEditEvent {
  final String userId;
  SelectUserEdit(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Update user penjual
class SelectUserPenjualEdit extends TransJualEditEvent {
  final String userId;
  SelectUserPenjualEdit(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Update nama pembeli
class UpdateNamaPembeliEdit extends TransJualEditEvent {
  final String name;
  UpdateNamaPembeliEdit(this.name);

  @override
  List<Object?> get props => [name];
}

/// Update metode pembayaran
class SelectPaymentMethodEdit extends TransJualEditEvent {
  final String method;
  SelectPaymentMethodEdit(this.method);

  @override
  List<Object?> get props => [method];
}

/// Simpan transaksi hasil edit
class SubmitEditTransaction extends TransJualEditEvent {}

/// Ambil user list
class FetchAllUsersEdit extends TransJualEditEvent {}

/// Cari produk
class SearchProductByNameEdit extends TransJualEditEvent {
  final String query;
  SearchProductByNameEdit(this.query);

  @override
  List<Object?> get props => [query];
}

/// === Tambahan baru ===
/// Event ketika submit berhasil → untuk trigger navigasi balik
class EditTransactionSuccess extends TransJualEditEvent {}

/// Event untuk reset state setelah navigasi
class ResetEditTransactionState extends TransJualEditEvent {}

class UpdateStatusTransaksiEdit extends TransJualEditEvent {
  final String idHtransJual;

  UpdateStatusTransaksiEdit(this.idHtransJual);
}
