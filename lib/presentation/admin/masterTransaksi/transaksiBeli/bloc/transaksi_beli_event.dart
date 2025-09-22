import 'package:equatable/equatable.dart';

abstract class TransBeliEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSuppliers extends TransBeliEvent {}

class FetchProducts extends TransBeliEvent {}

class SelectSupplier extends TransBeliEvent {
  final String supplierId;
  SelectSupplier(this.supplierId);

  @override
  List<Object?> get props => [supplierId];
}

class AddProduct extends TransBeliEvent {
  final String id;
  final String name;
  final String image;
  final int quantity;
  final String unit;
  final double price;

  AddProduct({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
    required this.unit,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, image, quantity, unit, price];
}

class RemoveProduct extends TransBeliEvent {
  final String id;
  RemoveProduct(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateProductQuantity extends TransBeliEvent {
  final String id;
  final int quantity;
  UpdateProductQuantity(this.id, this.quantity);

  @override
  List<Object?> get props => [id, quantity];
}

class UpdateProductPrice extends TransBeliEvent {
  final String id;
  final double price;
  UpdateProductPrice(this.id, this.price);

  @override
  List<Object?> get props => [id, price];
}

class SelectPaymentMethod extends TransBeliEvent {
  final String method;
  SelectPaymentMethod(this.method);

  @override
  List<Object?> get props => [method];
}

class SubmitTransaction extends TransBeliEvent {}

class FetchSatuanByProductId extends TransBeliEvent {
  final String productId;
  FetchSatuanByProductId(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateProductUnit extends TransBeliEvent {
  final String productId;
  final String unit;
  UpdateProductUnit(this.productId, this.unit);

  @override
  List<Object?> get props => [productId, unit];
}

// ✅ Tambahan Baru
class SearchProductByName extends TransBeliEvent {
  final String query;
  SearchProductByName(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateProductDiscount extends TransBeliEvent {
  final String id;
  final double discount;

  UpdateProductDiscount(this.id, this.discount);
}

class UpdateInvoiceNumber extends TransBeliEvent {
  final String nomorInvoice;
  UpdateInvoiceNumber(this.nomorInvoice);
}

class UpdatePajak extends TransBeliEvent {
  final int pajak;
  UpdatePajak(this.pajak);
}

class ValidateTransactionForm extends TransBeliEvent {}


