import 'package:equatable/equatable.dart';

abstract class ShopeeOrderDetailState extends Equatable {
  const ShopeeOrderDetailState();

  @override
  List<Object?> get props => [];
}

class ShopeeOrderDetailInitial extends ShopeeOrderDetailState {}

class ShopeeOrderDetailLoading extends ShopeeOrderDetailState {}

class ShopeeOrderDetailLoaded extends ShopeeOrderDetailState {
  final Map<String, dynamic> order;

  const ShopeeOrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class ShopeeOrderDetailError extends ShopeeOrderDetailState {
  final String message;

  const ShopeeOrderDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
