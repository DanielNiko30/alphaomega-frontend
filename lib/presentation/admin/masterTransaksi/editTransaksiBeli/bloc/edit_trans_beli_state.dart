import 'package:equatable/equatable.dart';

abstract class EditTransBeliState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Loading & Error State
class TransBeliLoading extends EditTransBeliState {}

class TransBeliInitial extends EditTransBeliState {}

class TransBeliError extends EditTransBeliState {
  final String message;
  TransBeliError(this.message);

  @override
  List<Object?> get props => [message];
}

// State utama
class EditTransBeliLoaded extends EditTransBeliState {
  final String? idHtransBeli;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> allProducts;
  final List<Map<String, dynamic>> selectedProducts;
  final List<Map<String, dynamic>> suppliers;
  final String? selectedSupplier;
  final String? paymentMethod;
  final bool isSubmitting;
  final String searchQuery;
  final int pajak;
  final String? nomorInvoice;
  final Map<String, String> formErrors;

  EditTransBeliLoaded({
    this.idHtransBeli,
    this.products = const [],
    this.allProducts = const [],
    this.selectedProducts = const [],
    this.suppliers = const [],
    this.selectedSupplier,
    this.paymentMethod,
    this.isSubmitting = false,
    this.searchQuery = '',
    this.pajak = 11,
    this.nomorInvoice,
    this.formErrors = const {},
  });

  EditTransBeliLoaded copyWith({
    String? idHtransBeli,
    List<Map<String, dynamic>>? products,
    List<Map<String, dynamic>>? allProducts,
    List<Map<String, dynamic>>? selectedProducts,
    List<Map<String, dynamic>>? suppliers,
    String? selectedSupplier,
    String? paymentMethod,
    bool? isSubmitting,
    String? searchQuery,
    int? pajak,
    String? nomorInvoice,
    Map<String, String>? formErrors,
  }) {
    return EditTransBeliLoaded(
      idHtransBeli: idHtransBeli ?? this.idHtransBeli,
      products: products ?? this.products,
      allProducts: allProducts ?? this.allProducts,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      suppliers: suppliers ?? this.suppliers,
      selectedSupplier: selectedSupplier ?? this.selectedSupplier,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      searchQuery: searchQuery ?? this.searchQuery,
      pajak: pajak ?? this.pajak,
      nomorInvoice: nomorInvoice ?? this.nomorInvoice,
      formErrors: formErrors ?? this.formErrors,
    );
  }

  @override
  List<Object?> get props => [
        idHtransBeli,
        products,
        allProducts,
        selectedProducts,
        suppliers,
        selectedSupplier,
        paymentMethod,
        isSubmitting,
        searchQuery,
        pajak,
        nomorInvoice,
        formErrors,
      ];
}

class UpdateTransactionSuccess extends EditTransBeliState {}