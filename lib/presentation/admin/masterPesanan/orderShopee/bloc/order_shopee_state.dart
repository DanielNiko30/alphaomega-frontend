import 'package:equatable/equatable.dart';
import '../../../../../model/orderOnline/shopee_order_model.dart';

abstract class ShopeeOrdersState extends Equatable {
  const ShopeeOrdersState();

  @override
  List<Object?> get props => [];
}

class ShopeeOrdersInitial extends ShopeeOrdersState {}

/// 🔹 Saat loading data awal
class ShopeeOrdersLoading extends ShopeeOrdersState {}

/// 🔹 Saat data berhasil dimuat
class ShopeeOrdersLoaded extends ShopeeOrdersState {
  final List<ShopeeOrder> orders;
  final bool hasMore; // untuk pagination
  final bool isRefreshing;
  final ShopeeOrder? selectedOrder;

  const ShopeeOrdersLoaded({
    required this.orders,
    this.hasMore = false,
    this.isRefreshing = false,
    this.selectedOrder,
  });

  ShopeeOrdersLoaded copyWith({
    List<ShopeeOrder>? orders,
    bool? hasMore,
    bool? isRefreshing,
    ShopeeOrder? selectedOrder,
  }) {
    return ShopeeOrdersLoaded(
      orders: orders ?? this.orders,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      selectedOrder: selectedOrder ?? this.selectedOrder,
    );
  }

  @override
  List<Object?> get props => [orders, hasMore, isRefreshing, selectedOrder];
}

/// 🔹 Saat loading tambahan data (pagination)
class ShopeeOrdersLoadingMore extends ShopeeOrdersState {
  final List<ShopeeOrder> currentOrders;

  const ShopeeOrdersLoadingMore(this.currentOrders);

  @override
  List<Object?> get props => [currentOrders];
}

/// 🔹 Saat terjadi error
class ShopeeOrdersError extends ShopeeOrdersState {
  final String message;
  final List<ShopeeOrder> previousOrders;

  const ShopeeOrdersError(this.message, {this.previousOrders = const []});

  @override
  List<Object?> get props => [message, previousOrders];
}

