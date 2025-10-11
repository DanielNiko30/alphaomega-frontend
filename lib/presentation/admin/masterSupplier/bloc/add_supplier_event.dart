abstract class SupplierEvent {}

class FetchSupplier extends SupplierEvent {}

class AddSupplier extends SupplierEvent {
  final String namaSupplier;
  final String noTelp;

  AddSupplier(this.namaSupplier, this.noTelp);
}

class UpdateSupplier extends SupplierEvent {
  final String id;
  final String namaSupplier;
  final String noTelp;

  UpdateSupplier(this.id, this.namaSupplier, this.noTelp);
}

class SearchSupplierByName extends SupplierEvent {
  final String query;
  SearchSupplierByName(this.query);
}

