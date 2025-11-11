import 'package:equatable/equatable.dart';

abstract class ShopeeOrderDetailEvent extends Equatable {
  const ShopeeOrderDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchShopeeOrderDetail extends ShopeeOrderDetailEvent {
  final String orderSn;

  const FetchShopeeOrderDetail(this.orderSn);

  @override
  List<Object?> get props => [orderSn];
}
