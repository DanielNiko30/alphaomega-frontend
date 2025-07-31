import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/controller/supplier/supplier_controller.dart';
import 'add_supplier_event.dart';
import 'add_supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  SupplierBloc(SupplierController supplierController) : super(SupplierInitial()) {
    on<FetchSupplier>(_onFetchSupplier);
    on<AddSupplier>(_onAddSupplier);
  }

  Future<void> _onFetchSupplier(
      FetchSupplier event, Emitter<SupplierState> emit) async {
    emit(SupplierLoading());
    try {
      final SupplierList = await SupplierController.getAllSuppliers();
      emit(SupplierLoaded(SupplierList));
    } catch (e) {
      emit(SupplierError("Gagal memuat data Supplier"));
    }
  }

  void _onAddSupplier(AddSupplier event, Emitter<SupplierState> emit) async {
    emit(SupplierLoading());
    try {
      final success = await SupplierController.addSupplier(event.namaSupplier, event.noTelp);
      if (success) {
        final SupplierList = await SupplierController.getAllSuppliers();
        emit(SupplierLoaded(SupplierList));
      } else {
        emit(SupplierError("Gagal menambahkan Supplier"));
      }
    } catch (e) {
      emit(SupplierError("Gagal menambahkan Supplier: ${e.toString()}"));
    }
  }
}
