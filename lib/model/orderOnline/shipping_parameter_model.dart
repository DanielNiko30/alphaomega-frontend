class ShippingParameterModel {
  final List<String> infoNeededPickup;
  final List<String> infoNeededDropoff;
  final List<PickupAddress> addressList;

  ShippingParameterModel({
    required this.infoNeededPickup,
    required this.infoNeededDropoff,
    required this.addressList,
  });

  factory ShippingParameterModel.fromJson(Map<String, dynamic> json) {
    return ShippingParameterModel(
      infoNeededPickup: List<String>.from(json['info_needed']?['pickup'] ?? []),
      infoNeededDropoff:
          List<String>.from(json['info_needed']?['dropoff'] ?? []),
      addressList: (json['pickup']?['address_list'] as List<dynamic>? ?? [])
          .map((item) => PickupAddress.fromJson(item))
          .toList(),
    );
  }
}

class PickupAddress {
  final int addressId;
  final String region;
  final String state;
  final String city;
  final String district;
  final String address;
  final String zipcode;
  final List<PickupTimeSlot> timeSlotList;

  PickupAddress({
    required this.addressId,
    required this.region,
    required this.state,
    required this.city,
    required this.district,
    required this.address,
    required this.zipcode,
    required this.timeSlotList,
  });

  factory PickupAddress.fromJson(Map<String, dynamic> json) {
    return PickupAddress(
      addressId: json['address_id'],
      region: json['region'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      address: json['address'] ?? '',
      zipcode: json['zipcode'] ?? '',
      timeSlotList: (json['time_slot_list'] as List<dynamic>? ?? [])
          .map((item) => PickupTimeSlot.fromJson(item))
          .toList(),
    );
  }
}

class PickupTimeSlot {
  final int date;
  final String timeText;
  final String pickupTimeId;

  PickupTimeSlot({
    required this.date,
    required this.timeText,
    required this.pickupTimeId,
  });

  factory PickupTimeSlot.fromJson(Map<String, dynamic> json) {
    return PickupTimeSlot(
      date: json['date'],
      timeText: json['time_text'],
      pickupTimeId: json['pickup_time_id'],
    );
  }
}
