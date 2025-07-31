abstract class SupplierEvent {}

class FetchSupplier extends SupplierEvent {}

class AddSupplier extends SupplierEvent {
  final String namaSupplier;
  final String noTelp;

  AddSupplier(this.namaSupplier, this.noTelp);
}
