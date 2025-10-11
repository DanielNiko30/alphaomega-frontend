import 'package:equatable/equatable.dart';

abstract class ShopeeOrdersEvent extends Equatable {
  const ShopeeOrdersEvent();

  @override
  List<Object?> get props => [];
}

/// 🔹 Ambil daftar order pertama kali
class FetchShopeeOrders extends ShopeeOrdersEvent {
  final bool isRefresh;

  /// [isRefresh] = true → data lama akan dihapus dan load ulang dari awal
  const FetchShopeeOrders({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// 🔹 Load order berikutnya (pagination)
class LoadMoreShopeeOrders extends ShopeeOrdersEvent {}

/// 🔹 Pilih order tertentu untuk ditampilkan detailnya
class SelectShopeeOrder extends ShopeeOrdersEvent {
  final String orderSn;

  const SelectShopeeOrder(this.orderSn);

  @override
  List<Object?> get props => [orderSn];
}

/// 🔹 Hapus error dari state agar UI kembali normal
class ClearShopeeOrdersError extends ShopeeOrdersEvent {}


