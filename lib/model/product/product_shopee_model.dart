class StokShopee {
  final String satuan;
  final int harga;
  final int stokQty;
  final String? idProductShopee; // ← tambahkan ini

  StokShopee({
    required this.satuan,
    required this.harga,
    required this.stokQty,
    this.idProductShopee,
  });

  factory StokShopee.fromJson(Map<String, dynamic> json) {
    return StokShopee(
      satuan: json['satuan'] ?? '',
      harga: json['harga'] ?? 0,
      stokQty: json['stokQty'] ?? 0,
      idProductShopee:
          json['idProductShopee'], // ← pastikan json memiliki key ini
    );
  }

  Map<String, dynamic> toJson() => {
        'satuan': satuan,
        'harga': harga,
        'stokQty': stokQty,
        'idProductShopee': idProductShopee,
      };
}
