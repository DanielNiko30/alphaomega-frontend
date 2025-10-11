class BarangPesanan {
  final String idProduk; // ✅ tambahin id
  final String nama;
  final double qty;
  final int harga;
  final int subtotal;
  final String satuan;
  final bool siap;
  final String? gambar;

  BarangPesanan({
    required this.idProduk,
    required this.nama,
    required this.qty,
    required this.harga,
    required this.subtotal,
    required this.satuan,
    required this.siap,
    this.gambar,
  });

  BarangPesanan copyWith({
    String? idProduk,
    String? nama,
    double? qty,
    int? harga,
    int? subtotal,
    String? satuan,
    bool? siap,
    String? gambar,
  }) {
    return BarangPesanan(
      idProduk: idProduk ?? this.idProduk,
      nama: nama ?? this.nama,
      qty: qty ?? this.qty,
      harga: harga ?? this.harga,
      subtotal: subtotal ?? this.subtotal,
      satuan: satuan ?? this.satuan,
      siap: siap ?? this.siap,
      gambar: gambar ?? this.gambar,
    );
  }
}
