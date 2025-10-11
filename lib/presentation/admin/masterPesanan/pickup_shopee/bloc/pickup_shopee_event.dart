import 'package:equatable/equatable.dart';

/// Base class untuk semua event di PickupPopupBloc
abstract class PickupPopupEvent extends Equatable {
  const PickupPopupEvent();

  @override
  List<Object?> get props => [];
}

/// === 1. Load shipping parameter dari backend ===
class LoadShippingParameter extends PickupPopupEvent {
  final String orderSn;
  const LoadShippingParameter(this.orderSn);

  @override
  List<Object?> get props => [orderSn];
}

/// === 2. Pilih metode pengiriman: dropoff atau pickup ===
/// value bisa berupa `"dropoff"` atau `"pickup"`
class SelectPickupOption extends PickupPopupEvent {
  final String option;
  const SelectPickupOption(this.option);

  @override
  List<Object?> get props => [option];
}

/// === 3. Pilih alamat pickup ===
class SelectAddress extends PickupPopupEvent {
  final int addressId;
  const SelectAddress(this.addressId);

  @override
  List<Object?> get props => [addressId];
}

/// === 4. Pilih waktu pickup ===
class SelectPickupTime extends PickupPopupEvent {
  final String pickupTimeId;
  const SelectPickupTime(this.pickupTimeId);

  @override
  List<Object?> get props => [pickupTimeId];
}

/// === 5. Konfirmasi Dropoff ===
class ConfirmDropoff extends PickupPopupEvent {
  final String orderSn;
  const ConfirmDropoff(this.orderSn);

  @override
  List<Object?> get props => [orderSn];
}

/// === 6. Konfirmasi Pickup ===
class ConfirmPickup extends PickupPopupEvent {
  final String orderSn;
  final int addressId;
  final String pickupTimeId;

  const ConfirmPickup({
    required this.orderSn,
    required this.addressId,
    required this.pickupTimeId,
  });

  @override
  List<Object?> get props => [orderSn, addressId, pickupTimeId];
}

/// === 7. Reset popup ke kondisi awal ===
/// Dipanggil ketika popup ditutup atau setelah konfirmasi berhasil
class ResetPickupPopup extends PickupPopupEvent {
  const ResetPickupPopup();
}

class SelectPickupDate extends PickupPopupEvent {
  final int selectedDate; // Unix timestamp
  const SelectPickupDate(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}

