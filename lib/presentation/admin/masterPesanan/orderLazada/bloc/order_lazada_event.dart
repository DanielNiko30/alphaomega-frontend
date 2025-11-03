import 'package:equatable/equatable.dart';

abstract class LazadaOrdersEvent extends Equatable {
  const LazadaOrdersEvent();

  @override
  List<Object?> get props => [];
}

/// 🔹 Ambil daftar order pertama kali atau refresh
class FetchLazadaOrders extends LazadaOrdersEvent {
  final bool isRefresh;

  const FetchLazadaOrders({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// 🔹 Load order berikutnya (pagination)
class LoadMoreLazadaOrders extends LazadaOrdersEvent {}

/// 🔹 Pilih order tertentu untuk ditampilkan detailnya
class SelectLazadaOrder extends LazadaOrdersEvent {
  final String orderId;

  const SelectLazadaOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// 🔹 Hapus error dari state agar UI kembali normal
class ClearLazadaOrdersError extends LazadaOrdersEvent {}

/// 🔹 Ganti status order yang ingin ditampilkan
/// Bisa "PENDING" atau "READY_TO_SHIP"
class ChangeLazadaOrderStatus extends LazadaOrdersEvent {
  final String status;

  const ChangeLazadaOrderStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class SetLazadaReadyToShip extends LazadaOrdersEvent {
  final String orderId;

  const SetLazadaReadyToShip(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// 🔹 Print resi Lazada (ambil PDF base64)
class PrintLazadaResi extends LazadaOrdersEvent {
  final String orderId; // 🔹 ganti dari packageId ke orderId

  const PrintLazadaResi(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
