class Supplier {
  final String idSupplier;
  final String namaSupplier;
  final String noTelp;
  final String? keterangan;

  Supplier({
    required this.idSupplier,
    required this.namaSupplier,
    required this.noTelp,
    this.keterangan,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      idSupplier: json['id_supplier'],
      namaSupplier: json['nama_supplier'],
      noTelp: json['no_telp'],
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_supplier': idSupplier,
      'nama_supplier': namaSupplier,
      'no_telp': noTelp,
      'keterangan': keterangan,
    };
  }
}
