import 'package:equatable/equatable.dart';

abstract class TransJualEditState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Saat ambil data awal
class TransJualEditLoading extends TransJualEditState {}

/// Error umum
class TransJualEditError extends TransJualEditState {
  final String message;
  TransJualEditError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State utama edit transaksi
class TransJualEditLoaded extends TransJualEditState {
  final String? idHTransJual;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> allProducts;
  final List<Map<String, dynamic>> selectedProducts;
  final String? paymentMethod;
  final bool isSubmitting;
  final String? selectedUserId;
  final String? selectedUserPenjualId;
  final List<Map<String, dynamic>> userList;
  final String? invoiceNumber;
  final String? namaPembeli;
  final String? tanggal;
  final Map<String, String>? formErrors;

  TransJualEditLoaded({
    this.idHTransJual,
    this.products = const [],
    this.allProducts = const [],
    this.selectedProducts = const [],
    this.paymentMethod,
    this.isSubmitting = false,
    this.selectedUserId,
    this.selectedUserPenjualId,
    this.userList = const [],
    this.invoiceNumber,
    this.namaPembeli,
    this.tanggal,
    this.formErrors,
  });

  TransJualEditLoaded copyWith({
    String? idHTransJual,
    List<Map<String, dynamic>>? products,
    List<Map<String, dynamic>>? allProducts,
    List<Map<String, dynamic>>? selectedProducts,
    String? paymentMethod,
    bool? isSubmitting,
    String? selectedUserId,
    String? selectedUserPenjualId,
    List<Map<String, dynamic>>? userList,
    String? invoiceNumber,
    String? namaPembeli,
    String? tanggal,
    Map<String, String>? formErrors,
  }) {
    return TransJualEditLoaded(
      idHTransJual: idHTransJual ?? this.idHTransJual,
      products: products ?? this.products,
      allProducts: allProducts ?? this.allProducts,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      selectedUserId: selectedUserId ?? this.selectedUserId,
      selectedUserPenjualId:
          selectedUserPenjualId ?? this.selectedUserPenjualId,
      userList: userList ?? this.userList,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      namaPembeli: namaPembeli ?? this.namaPembeli,
      tanggal: tanggal ?? this.tanggal,
      formErrors: formErrors ?? this.formErrors,
    );
  }

  @override
  List<Object?> get props => [
        idHTransJual,
        products,
        allProducts,
        selectedProducts,
        paymentMethod,
        isSubmitting,
        selectedUserId,
        selectedUserPenjualId,
        userList,
        invoiceNumber,
        namaPembeli,
        tanggal,
        formErrors,
      ];
}

/// State sukses setelah submit
class TransJualEditSuccess extends TransJualEditState {}
