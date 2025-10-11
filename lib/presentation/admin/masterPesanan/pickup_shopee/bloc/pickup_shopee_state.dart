import 'package:equatable/equatable.dart';
import '../../../../../model/orderOnline/shipping_parameter_model.dart';

class PickupPopupState extends Equatable {
  /// Menandakan data sedang di-load (fetch shipping parameter)
  final bool isLoading;

  /// Data shipping parameter hasil fetch API
  final ShippingParameterModel? shippingParameter;

  /// Opsi yang dipilih user: `"dropoff"` atau `"pickup"`
  final String? selectedOption;

  final int? selectedPickupDate; // Untuk menyimpan tanggal yang dipilih

  /// ID alamat pickup yang dipilih (jika opsi "pickup")
  final int? selectedAddressId;

  /// ID waktu pickup yang dipilih (jika opsi "pickup")
  final String? selectedPickupTimeId;

  /// Sukses konfirmasi dropoff/pickup
  final String? successMessage;

  /// Error saat fetch atau konfirmasi
  final String? errorMessage;

  /// Menandakan tombol konfirmasi sedang diproses
  final bool isConfirming;

  /// Menandakan popup sudah tertutup setelah sukses
  final bool isPopupClosed;

  /// Menyimpan semua error validasi form, misalnya
  /// `{"selectedAddressId": "Alamat harus dipilih"}`
  final Map<String, String>? formErrors;

  const PickupPopupState({
    this.isLoading = false,
    this.shippingParameter,
    this.selectedOption,
    this.selectedPickupDate,
    this.selectedAddressId,
    this.selectedPickupTimeId,
    this.successMessage,
    this.errorMessage,
    this.isConfirming = false,
    this.isPopupClosed = false,
    this.formErrors,
  });

  /// Membuat salinan state dengan perubahan hanya di field tertentu
  PickupPopupState copyWith({
    bool? isLoading,
    ShippingParameterModel? shippingParameter,
    String? selectedOption,
    int? selectedAddressId,
    String? selectedPickupTimeId,
    String? successMessage,
    String? errorMessage,
    bool? isConfirming,
    bool? isPopupClosed,
    Map<String, String>? formErrors,
  }) {
    return PickupPopupState(
      isLoading: isLoading ?? this.isLoading,
      shippingParameter: shippingParameter ?? this.shippingParameter,
      selectedOption: selectedOption ?? this.selectedOption,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      selectedPickupTimeId: selectedPickupTimeId ?? this.selectedPickupTimeId,
      successMessage: successMessage,
      errorMessage: errorMessage,
      isConfirming: isConfirming ?? this.isConfirming,
      isPopupClosed: isPopupClosed ?? this.isPopupClosed,
      formErrors: formErrors ?? this.formErrors,
    );
  }

  /// State awal
  factory PickupPopupState.initial() {
    return const PickupPopupState(
      isLoading: false,
      shippingParameter: null,
      selectedOption: null,
      selectedAddressId: null,
      selectedPickupTimeId: null,
      successMessage: null,
      errorMessage: null,
      isConfirming: false,
      isPopupClosed: false,
      formErrors: null,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        shippingParameter,
        selectedOption,
        selectedAddressId,
        selectedPickupTimeId,
        successMessage,
        errorMessage,
        isConfirming,
        isPopupClosed,
        formErrors,
      ];
}