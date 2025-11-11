import 'package:equatable/equatable.dart';

abstract class LazadaOrderDetailState extends Equatable {
  const LazadaOrderDetailState();

  @override
  List<Object?> get props => [];
}

class LazadaOrderDetailInitial extends LazadaOrderDetailState {}

class LazadaOrderDetailLoading extends LazadaOrderDetailState {}

class LazadaOrderDetailLoaded extends LazadaOrderDetailState {
  final Map<String, dynamic> order;
  final List<dynamic> items;

  const LazadaOrderDetailLoaded({
    required this.order,
    required this.items,
  });

  @override
  List<Object?> get props => [order, items];
}

class LazadaOrderDetailError extends LazadaOrderDetailState {
  final String message;

  const LazadaOrderDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
