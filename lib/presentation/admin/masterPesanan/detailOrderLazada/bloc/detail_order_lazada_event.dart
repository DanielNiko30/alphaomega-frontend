import 'package:equatable/equatable.dart';

abstract class LazadaOrderDetailEvent extends Equatable {
  const LazadaOrderDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchLazadaOrderDetail extends LazadaOrderDetailEvent {
  final String orderId;

  const FetchLazadaOrderDetail(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
