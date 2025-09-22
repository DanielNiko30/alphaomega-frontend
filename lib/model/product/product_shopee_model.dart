class StokShopee {
  final String satuan;
  final int harga;
  final int stokQty;
  final String? idProductShopee; // ← tambahkan ini
  final String? idProductLazada; // ← tambahkan ini

  StokShopee({
    required this.satuan,
    required this.harga,
    required this.stokQty,
    this.idProductShopee,
    this.idProductLazada,
  });

  factory StokShopee.fromJson(Map<String, dynamic> json) {
    return StokShopee(
      satuan: json['satuan'] ?? '',
      harga: json['harga'] ?? 0,
      stokQty: json['stokQty'] ?? 0,
      idProductShopee: json['idProductShopee'],
      idProductLazada: json['idProductLazada'],
    );
  }

  Map<String, dynamic> toJson() => {
        'satuan': satuan,
        'harga': harga,
        'stokQty': stokQty,
        'idProductShopee': idProductShopee,
        'idProductLazada': idProductLazada,
      };
}
