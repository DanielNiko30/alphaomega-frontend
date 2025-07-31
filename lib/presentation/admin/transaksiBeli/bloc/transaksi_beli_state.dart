import 'package:equatable/equatable.dart';

abstract class TransBeliState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Loading & Error State
class TransBeliLoading extends TransBeliState {}

class TransBeliInitial extends TransBeliState {}

class TransBeliError extends TransBeliState {
  final String message;
  TransBeliError(this.message);

  @override
  List<Object?> get props => [message];
}

// State utama
class TransBeliLoaded extends TransBeliState {
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

  TransBeliLoaded({
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

  TransBeliLoaded copyWith({
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
    return TransBeliLoaded(
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
