class Supplier {
  final String idSupplier;
  final String namaSupplier;
  final String noTelp;

  Supplier({
    required this.idSupplier,
    required this.namaSupplier,
    required this.noTelp,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      idSupplier: json['id_supplier'],
      namaSupplier: json['nama_supplier'],
      noTelp: json['no_telp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_supplier': idSupplier,
      'nama_supplier': namaSupplier,
      'no_telp': noTelp,
    };
  }
}
