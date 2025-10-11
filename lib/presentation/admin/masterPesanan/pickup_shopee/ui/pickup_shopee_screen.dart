import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pickup_shopee_bloc.dart';
import '../bloc/pickup_shopee_event.dart';
import '../bloc/pickup_shopee_state.dart';

class PickupPopupScreen extends StatelessWidget {
  final String orderSn;
  const PickupPopupScreen({super.key, required this.orderSn});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<PickupPopupBloc>()
        ..add(LoadShippingParameter(orderSn)),
      child: BlocConsumer<PickupPopupBloc, PickupPopupState>(
        listener: (context, state) {
          /// Jika sukses → tutup popup dan tampilkan snackbar
          if (state.successMessage != null && state.isPopupClosed) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );

            /// Reset state setelah popup ditutup
            context.read<PickupPopupBloc>().add(ResetPickupPopup());
          }

          /// Jika error
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return WillPopScope(
            /// Saat tombol back ditekan → reset popup juga
            onWillPop: () async {
              context.read<PickupPopupBloc>().add(ResetPickupPopup());
              return true;
            },
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Atur Pickup",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 400,
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent(context, state),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    /// Tutup popup dan reset state
                    context.read<PickupPopupBloc>().add(ResetPickupPopup());
                    Navigator.pop(context);
                  },
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: state.isConfirming
                      ? null
                      : () {
                          if (state.selectedOption == "dropoff") {
                            context
                                .read<PickupPopupBloc>()
                                .add(ConfirmDropoff(orderSn));
                          } else if (state.selectedOption == "pickup") {
                            if (state.selectedAddressId == null ||
                                state.selectedPickupTimeId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Alamat dan waktu harus dipilih"),
                                ),
                              );
                              return;
                            }
                            context.read<PickupPopupBloc>().add(ConfirmPickup(
                                  orderSn: orderSn,
                                  addressId: state.selectedAddressId!,
                                  pickupTimeId: state.selectedPickupTimeId!,
                                ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Pilih metode Dropoff atau Pickup"),
                              ),
                            );
                          }
                        },
                  child: state.isConfirming
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("Konfirmasi"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// UI utama popup
  Widget _buildContent(BuildContext context, PickupPopupState state) {
    final bloc = context.read<PickupPopupBloc>();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Pilihan Dropoff / Pickup
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text("Dropoff"),
                  value: "dropoff",
                  groupValue: state.selectedOption,
                  onChanged: (val) => bloc.add(SelectPickupOption("dropoff")),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text("Pickup"),
                  value: "pickup",
                  groupValue: state.selectedOption,
                  onChanged: (val) => bloc.add(SelectPickupOption("pickup")),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// Jika Pickup dipilih → tampilkan dropdown alamat dan radio button waktu
          if (state.selectedOption == "pickup")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pilih Alamat",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                /// Dropdown alamat
                DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text("Pilih alamat"),
                  value: state.selectedAddressId,
                  items: (state.shippingParameter?.addressList ?? [])
                      .map((address) => DropdownMenuItem<int>(
                            value: address.addressId,
                            child: Text(
                              "${address.address} (${address.city})",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    bloc.add(SelectAddress(value!));
                  },
                ),
                const SizedBox(height: 16),

                /// Jika alamat sudah dipilih, tampilkan pilihan waktu
                if (state.selectedAddressId != null)
                  _buildPickupTimeOptions(state, bloc),
              ],
            ),
        ],
      ),
    );
  }

  /// Radio button list untuk waktu pickup
  Widget _buildPickupTimeOptions(PickupPopupState state, PickupPopupBloc bloc) {
    final selectedAddress = state.shippingParameter?.addressList.firstWhere(
      (addr) => addr.addressId == state.selectedAddressId,
    );

    if (selectedAddress == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text("Alamat tidak ditemukan."),
      );
    }

    if (selectedAddress.timeSlotList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text("Tidak ada jadwal pickup yang tersedia."),
      );
    }

    // --- 1. Group by Date ---
    final Map<int, List<dynamic>> groupedByDate = {};
    for (var slot in selectedAddress.timeSlotList) {
      groupedByDate.putIfAbsent(slot.date, () => []);
      groupedByDate[slot.date]!.add(slot);
    }

    final sortedDates = groupedByDate.keys.toList()..sort();

    // Jika belum pilih tanggal, pilih otomatis tanggal pertama
    final selectedDate = state.selectedPickupDate ?? sortedDates.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pilih Tanggal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // --- Dropdown untuk pilih tanggal ---
        DropdownButton<int>(
          value: selectedDate,
          isExpanded: true,
          items: sortedDates.map((dateTs) {
            final date = DateTime.fromMillisecondsSinceEpoch(dateTs * 1000);
            final formatted = "${date.day}-${date.month}-${date.year}";
            return DropdownMenuItem<int>(
              value: dateTs,
              child: Text(formatted),
            );
          }).toList(),
          onChanged: (value) {
            bloc.add(SelectPickupDate(value!)); // Buat event baru untuk tanggal
          },
        ),

        const SizedBox(height: 16),

        const Text(
          "Pilih Waktu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // --- Filter time slot hanya untuk tanggal yang dipilih ---
        ...groupedByDate[selectedDate]!.map(
          (timeSlot) => RadioListTile<String>(
            title: Text(timeSlot.timeText),
            value: timeSlot.pickupTimeId,
            groupValue: state.selectedPickupTimeId,
            onChanged: (val) => bloc.add(SelectPickupTime(val!)),
          ),
        ),
      ],
    );
  }
}
