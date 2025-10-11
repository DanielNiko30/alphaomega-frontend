class ShippingDocument {
  final String trackingNumber;
  final String downloadUrl;

  ShippingDocument({
    required this.trackingNumber,
    required this.downloadUrl,
  });

  factory ShippingDocument.fromJson(Map<String, dynamic> json) {
    return ShippingDocument(
      trackingNumber: json['tracking_number'] ?? '',
      downloadUrl: json['download_url'] ?? '',
    );
  }
}
