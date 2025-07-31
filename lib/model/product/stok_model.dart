class Stok {
  final String idStok;
  final String satuan;
  final int harga;
  final int jumlah;

  Stok({
    required this.idStok,
    required this.satuan,
    required this.harga,
    required this.jumlah,
  });

  factory Stok.fromJson(Map<String, dynamic> json) {
    return Stok(
      idStok: json['id_stok'] ?? '',
      satuan: json['satuan'] ?? '',
      harga: (json['harga'] is String)
          ? int.tryParse(json['harga']) ?? 0
          : json['harga'] ?? 0,
      jumlah: (json['jumlah'] is String)
          ? int.tryParse(json['jumlah']) ?? 0
          : json['jumlah'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_stok': idStok,
      'satuan': satuan,
      'harga': harga,
      'jumlah': jumlah, // Bukan 'stok'!
    };
  }
}
