import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/admin/shopee_controller.dart';
import 'pickup_shopee_event.dart';
import 'pickup_shopee_state.dart';

class PickupPopupBloc extends Bloc<PickupPopupEvent, PickupPopupState> {
  final ShopeeController controller;

  PickupPopupBloc({required this.controller})
      : super(PickupPopupState.initial()) {
    /// === 1. Load Shipping Parameter ===
    on<LoadShippingParameter>((event, emit) async {
      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
        formErrors: {},
      ));

      try {
        final data = await controller.getShippingParameter(event.orderSn);
        emit(state.copyWith(
          isLoading: false,
          shippingParameter: data,
        ));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    });

    /// === 2. Pilih opsi dropoff/pickup ===
    on<SelectPickupOption>((event, emit) {
      emit(state.copyWith(
        selectedOption: event.option,
        // reset error dan pilihan lama
        selectedAddressId: null,
        selectedPickupTimeId: null,
        formErrors: {},
      ));
    });

    /// === 3. Pilih alamat pickup ===
    on<SelectAddress>((event, emit) {
      emit(state.copyWith(
        selectedAddressId: event.addressId,
        selectedPickupTimeId: null, // reset time slot saat ganti alamat
        formErrors: {},
      ));
    });

    /// === 4. Pilih waktu pickup ===
    on<SelectPickupTime>((event, emit) {
      emit(state.copyWith(
        selectedPickupTimeId: event.pickupTimeId,
        formErrors: {},
      ));
    });

    /// === 5. Konfirmasi Dropoff ===
    on<ConfirmDropoff>((event, emit) async {
      emit(state.copyWith(
        isConfirming: true,
        errorMessage: null,
        successMessage: null,
      ));

      try {
        await controller.setDropoff(event.orderSn);

        emit(state.copyWith(
          isConfirming: false,
          successMessage: "Dropoff berhasil dikonfirmasi!",
          isPopupClosed: true, // otomatis tutup popup
        ));
      } catch (e) {
        emit(state.copyWith(
          isConfirming: false,
          errorMessage: e.toString(),
        ));
      }
    });

    /// === 6. Konfirmasi Pickup ===
    on<ConfirmPickup>((event, emit) async {
      // Validasi sebelum submit
      if (state.selectedAddressId == null) {
        emit(state.copyWith(formErrors: {
          "selectedAddressId": "Silakan pilih alamat pickup",
        }));
        return;
      }
      if (state.selectedPickupTimeId == null) {
        emit(state.copyWith(formErrors: {
          "selectedPickupTimeId": "Silakan pilih waktu pickup",
        }));
        return;
      }

      emit(state.copyWith(
        isConfirming: true,
        errorMessage: null,
        successMessage: null,
        formErrors: {},
      ));

      try {
        await controller.setPickup(
          orderSn: event.orderSn,
          addressId: state.selectedAddressId!,
          pickupTimeId: state.selectedPickupTimeId!,
        );

        emit(state.copyWith(
          isConfirming: false,
          successMessage: "Pickup berhasil dikonfirmasi!",
          isPopupClosed: true, // otomatis tutup popup
        ));
      } catch (e) {
        emit(state.copyWith(
          isConfirming: false,
          errorMessage: e.toString(),
        ));
      }
    });

    /// === 7. Reset State Popup ===
    on<ResetPickupPopup>((event, emit) {
      emit(PickupPopupState.initial());
    });
  }
}
