class ShipOrderResponse {
  final bool success;
  final String message;
  final String? trackingNumber;
  final String? requestId;

  ShipOrderResponse({
    required this.success,
    required this.message,
    this.trackingNumber,
    this.requestId,
  });

  factory ShipOrderResponse.fromJson(Map<String, dynamic> json) {
    return ShipOrderResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      trackingNumber: json['data']?['tracking_number'],
      requestId: json['shopee_response']?['request_id'],
    );
  }
}
