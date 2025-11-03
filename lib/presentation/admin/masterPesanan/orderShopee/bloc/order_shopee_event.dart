import 'package:equatable/equatable.dart';

abstract class ShopeeOrdersEvent extends Equatable {
  const ShopeeOrdersEvent();

  @override
  List<Object?> get props => [];
}

/// 🔹 Ambil daftar order pertama kali atau refresh
class FetchShopeeOrders extends ShopeeOrdersEvent {
  final bool isRefresh;

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

/// 🔹 Ganti status order yang ingin ditampilkan
/// Bisa "READY_TO_SHIP" atau "PROCESSED"
class ChangeShopeeOrderStatus extends ShopeeOrdersEvent {
  final String status;

  const ChangeShopeeOrderStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// 🔹 Hapus error dari state agar UI kembali normal
class ClearShopeeOrdersError extends ShopeeOrdersEvent {}

/// 🧾 Cetak resi Shopee
class PrintShopeeResi extends ShopeeOrdersEvent {
  final String orderSn;

  const PrintShopeeResi(this.orderSn);

  @override
  List<Object?> get props => [orderSn];
}
