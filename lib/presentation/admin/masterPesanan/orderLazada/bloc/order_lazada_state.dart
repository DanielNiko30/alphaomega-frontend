import 'package:equatable/equatable.dart';
import '../../../../../model/product/lazada_model.dart';

abstract class LazadaOrdersState extends Equatable {
  const LazadaOrdersState();

  @override
  List<Object?> get props => [];
}

class LazadaOrdersInitial extends LazadaOrdersState {}

class LazadaOrdersLoading extends LazadaOrdersState {}

class LazadaOrdersLoaded extends LazadaOrdersState {
  final List<LazadaOrder> orders;
  final bool hasMore;
  final bool isRefreshing;
  final LazadaOrder? selectedOrder;

  const LazadaOrdersLoaded({
    required this.orders,
    this.hasMore = false,
    this.isRefreshing = false,
    this.selectedOrder,
  });

  LazadaOrdersLoaded copyWith({
    List<LazadaOrder>? orders,
    bool? hasMore,
    bool? isRefreshing,
    LazadaOrder? selectedOrder,
  }) {
    return LazadaOrdersLoaded(
      orders: orders ?? this.orders,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      selectedOrder: selectedOrder ?? this.selectedOrder,
    );
  }

  @override
  List<Object?> get props => [orders, hasMore, isRefreshing, selectedOrder];
}

class LazadaOrdersLoadingMore extends LazadaOrdersState {
  final List<LazadaOrder> currentOrders;

  const LazadaOrdersLoadingMore(this.currentOrders);

  @override
  List<Object?> get props => [currentOrders];
}

class LazadaOrdersError extends LazadaOrdersState {
  final String message;
  final List<LazadaOrder> previousOrders;

  const LazadaOrdersError(this.message, {this.previousOrders = const []});

  @override
  List<Object?> get props => [message, previousOrders];
}
