abstract class SupplierEvent {}

class FetchSupplier extends SupplierEvent {}

class AddSupplier extends SupplierEvent {
  final String namaSupplier;
  final String noTelp;
  final String? keterangan;

  AddSupplier(this.namaSupplier, this.noTelp, this.keterangan);
}

class UpdateSupplier extends SupplierEvent {
  final String id;
  final String namaSupplier;
  final String noTelp;
  final String? keterangan;

  UpdateSupplier(this.id, this.namaSupplier, this.noTelp, this.keterangan);
}

class SearchSupplierByName extends SupplierEvent {
  final String query;
  SearchSupplierByName(this.query);
}

class DeleteSupplier extends SupplierEvent {
  final String idSupplier;

  DeleteSupplier(this.idSupplier);
}
