import 'package:equatable/equatable.dart';

abstract class TransJualState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Loading & Error State
class TransJualLoading extends TransJualState {}

class TransJualError extends TransJualState {
  final String message;
  TransJualError(this.message);

  @override
  List<Object?> get props => [message];
}

// State utama
class TransJualLoaded extends TransJualState {
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> allProducts;
  final List<Map<String, dynamic>> selectedProducts;
  final String? paymentMethod;
  final bool isSubmitting;
  final String? selectedUserId;
  final List<Map<String, dynamic>> userList;
  final List<Map<String, dynamic>> penjualList;
  final List<Map<String, dynamic>> pegawaiGudangList;
  final String? invoiceNumber;
  final String? namaPembeli;
  final String? idUserPenjual;
  final String? selectedUserPenjualId;
  final Map<String, String>? formErrors;
  final bool isPrintPreview;

  TransJualLoaded({
    this.products = const [],
    this.allProducts = const [],
    this.selectedProducts = const [],
    this.paymentMethod,
    this.isSubmitting = false,
    this.selectedUserId,
    this.userList = const [],
    this.penjualList = const [],
    this.pegawaiGudangList = const [],
    this.invoiceNumber,
    this.namaPembeli,
    this.idUserPenjual,
    this.selectedUserPenjualId,
    this.formErrors,
    this.isPrintPreview = false,
  });

  TransJualLoaded copyWith({
    List<Map<String, dynamic>>? products,
    List<Map<String, dynamic>>? allProducts,
    List<Map<String, dynamic>>? selectedProducts,
    String? paymentMethod,
    bool? isSubmitting,
    String? selectedUserId,
    List<Map<String, dynamic>>? userList,
    List<Map<String, dynamic>>? penjualList,
    List<Map<String, dynamic>>? pegawaiGudangList,
    String? invoiceNumber,
    String? namaPembeli,
    String? idUserPenjual,
    String? selectedUserPenjualId,
    Map<String, String>? formErrors,
    bool? isPrintPreview,
  }) {
    return TransJualLoaded(
      products: products ?? this.products,
      allProducts: allProducts ?? this.allProducts,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      selectedUserId: selectedUserId ?? this.selectedUserId,
      userList: userList ?? this.userList,
      penjualList: penjualList ?? this.penjualList,
      pegawaiGudangList: pegawaiGudangList ?? this.pegawaiGudangList,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      namaPembeli: namaPembeli ?? this.namaPembeli,
      idUserPenjual: idUserPenjual ?? this.idUserPenjual,
      selectedUserPenjualId:
          selectedUserPenjualId ?? this.selectedUserPenjualId,
      formErrors: formErrors ?? this.formErrors,
      isPrintPreview: isPrintPreview ?? this.isPrintPreview,
    );
  }

  @override
  List<Object?> get props => [
        products,
        allProducts,
        selectedProducts,
        paymentMethod,
        isSubmitting,
        selectedUserId,
        userList,
        penjualList,
        pegawaiGudangList,
        invoiceNumber,
        namaPembeli,
        idUserPenjual,
        selectedUserPenjualId,
        formErrors,
        isPrintPreview,
      ];
}
