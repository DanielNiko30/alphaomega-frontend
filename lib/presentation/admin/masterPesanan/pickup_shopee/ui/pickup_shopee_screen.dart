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
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return BlocProvider.value(
      value: context.read<PickupPopupBloc>()
        ..add(LoadShippingParameter(orderSn)),
      child: BlocConsumer<PickupPopupBloc, PickupPopupState>(
        listener: (context, state) {
          if (state.successMessage != null && state.isPopupClosed) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            context.read<PickupPopupBloc>().add(ResetPickupPopup());
          }

          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              context.read<PickupPopupBloc>().add(ResetPickupPopup());
              return true;
            },
            child: isDesktop
                ? _buildDesktopDialog(context, state)
                : _buildMobileDialog(context, state),
          );
        },
      ),
    );
  }

  /// Desktop (AlertDialog)
  Widget _buildDesktopDialog(BuildContext context, PickupPopupState state) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      actions: _buildActions(context, state),
    );
  }

  /// Mobile (fullscreen dialog)
  Widget _buildMobileDialog(BuildContext context, PickupPopupState state) {
    return Dialog(
      insetPadding: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Atur Pickup",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      context.read<PickupPopupBloc>().add(ResetPickupPopup());
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: _buildContent(context, state)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _buildActions(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tombol Actions (tidak ubah logika)
  List<Widget> _buildActions(BuildContext context, PickupPopupState state) {
    final bloc = context.read<PickupPopupBloc>();
    return [
      TextButton(
        onPressed: () {
          bloc.add(ResetPickupPopup());
          Navigator.pop(context);
        },
        child: const Text("Batal"),
      ),
      ElevatedButton(
        onPressed: state.isConfirming
            ? null
            : () {
                if (state.selectedOption == "dropoff") {
                  bloc.add(ConfirmDropoff(orderSn));
                } else if (state.selectedOption == "pickup") {
                  if (state.selectedAddressId == null ||
                      state.selectedPickupTimeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Alamat dan waktu harus dipilih")),
                    );
                    return;
                  }
                  bloc.add(ConfirmPickup(
                    orderSn: orderSn,
                    addressId: state.selectedAddressId!,
                    pickupTimeId: state.selectedPickupTimeId!,
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Pilih metode Dropoff atau Pickup")),
                  );
                }
              },
        child: state.isConfirming
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text("Konfirmasi"),
      ),
    ];
  }

  /// Konten utama (tetap sama)
  Widget _buildContent(BuildContext context, PickupPopupState state) {
    final bloc = context.read<PickupPopupBloc>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        if (state.selectedOption == "pickup")
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pilih Alamat",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButton<int>(
                isExpanded: true,
                hint: const Text("Pilih alamat"),
                value: state.selectedAddressId,
                items: (state.shippingParameter?.addressList ?? [])
                    .map((address) => DropdownMenuItem<int>(
                          value: address.addressId,
                          child: Text("${address.address} (${address.city})",
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (value) => bloc.add(SelectAddress(value!)),
              ),
              const SizedBox(height: 16),
              if (state.selectedAddressId != null)
                _buildPickupTimeOptions(state, bloc),
            ],
          ),
      ],
    );
  }

  Widget _buildPickupTimeOptions(PickupPopupState state, PickupPopupBloc bloc) {
    final selectedAddress = state.shippingParameter?.addressList.firstWhere(
      (addr) => addr.addressId == state.selectedAddressId,
      orElse: () => state.shippingParameter!.addressList.isNotEmpty
          ? state.shippingParameter!.addressList.first
          : throw Exception("No address found"),
    );
    if (selectedAddress == null) return const Text("Alamat tidak ditemukan.");
    if (selectedAddress.timeSlotList.isEmpty)
      return const Text("Tidak ada jadwal pickup yang tersedia.");

    final Map<int, List<dynamic>> groupedByDate = {};
    for (var slot in selectedAddress.timeSlotList) {
      groupedByDate.putIfAbsent(slot.date, () => []);
      groupedByDate[slot.date]!.add(slot);
    }

    final sortedDates = groupedByDate.keys.toList()..sort();
    final selectedDate = state.selectedPickupDate ?? sortedDates.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pilih Tanggal",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButton<int>(
          value: selectedDate,
          isExpanded: true,
          items: sortedDates.map((dateTs) {
            final date = DateTime.fromMillisecondsSinceEpoch(dateTs * 1000);
            return DropdownMenuItem<int>(
              value: dateTs,
              child: Text("${date.day}-${date.month}-${date.year}"),
            );
          }).toList(),
          onChanged: (value) => bloc.add(SelectPickupDate(value!)),
        ),
        const SizedBox(height: 16),
        const Text("Pilih Waktu",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
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
