import '../../../../model/supplier/supllier_model.dart';

abstract class SupplierState {}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SupplierLoaded extends SupplierState {
  final List<Supplier> listSupplier;

  SupplierLoaded(this.listSupplier);
}

class SupplierError extends SupplierState {
  final String message;

  SupplierError(this.message);
}