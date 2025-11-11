import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class EditTransBeliEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSuppliers extends EditTransBeliEvent {}

class FetchProducts extends EditTransBeliEvent {}

class SelectSupplier extends EditTransBeliEvent {
  final String supplierId;
  SelectSupplier(this.supplierId);

  @override
  List<Object?> get props => [supplierId];
}

class AddProduct extends EditTransBeliEvent {
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

class RemoveProduct extends EditTransBeliEvent {
  final String id;
  RemoveProduct(this.id);

  @override
  List<Object?> get props => [id];
}

class FetchTransactionById extends EditTransBeliEvent {
  final String transactionId;
  FetchTransactionById(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class UpdateProductQuantity extends EditTransBeliEvent {
  final String id;
  final int quantity;
  UpdateProductQuantity(this.id, this.quantity);

  @override
  List<Object?> get props => [id, quantity];
}

class UpdateProductPrice extends EditTransBeliEvent {
  final String id;
  final double price;
  UpdateProductPrice(this.id, this.price);

  @override
  List<Object?> get props => [id, price];
}

class SelectPaymentMethod extends EditTransBeliEvent {
  final String method;
  SelectPaymentMethod(this.method);

  @override
  List<Object?> get props => [method];
}

class SubmitTransaction extends EditTransBeliEvent {}

class FetchSatuanByProductId extends EditTransBeliEvent {
  final String productId;
  FetchSatuanByProductId(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateProductUnit extends EditTransBeliEvent {
  final String productId;
  final String unit;
  UpdateProductUnit(this.productId, this.unit);

  @override
  List<Object?> get props => [productId, unit];
}

// ✅ Tambahan Baru
class SearchProductByName extends EditTransBeliEvent {
  final String query;
  SearchProductByName(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateProductDiscount extends EditTransBeliEvent {
  final String id;
  final double discount;

  UpdateProductDiscount(this.id, this.discount);
}

class UpdateInvoiceNumber extends EditTransBeliEvent {
  final String nomorInvoice;
  UpdateInvoiceNumber(this.nomorInvoice);
}

class UpdatePajak extends EditTransBeliEvent {
  final int pajak;
  UpdatePajak(this.pajak);
}

class UpdateTransaction extends EditTransBeliEvent {
  final String id;
  final BuildContext context;

  UpdateTransaction(this.id, this.context);
}

class ValidateTransactionForm extends EditTransBeliEvent {}
