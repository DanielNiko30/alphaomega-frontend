import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/controller/supplier/supplier_controller.dart';
import '../../../../model/supplier/supllier_model.dart';
import 'add_supplier_event.dart';
import 'add_supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  SupplierBloc(SupplierController supplierController)
      : super(SupplierInitial()) {
    on<FetchSupplier>(_onFetchSupplier);
    on<AddSupplier>(_onAddSupplier);
    on<UpdateSupplier>(_onEditSupplier);
    on<SearchSupplierByName>(_onSearchSupplierByName);
  }

  Future<void> _onFetchSupplier(
      FetchSupplier event, Emitter<SupplierState> emit) async {
    emit(SupplierLoading());
    try {
      final supplierList = await SupplierController.getAllSuppliers();
      emit(SupplierLoaded(supplierList));
    } catch (e) {
      emit(SupplierError("Gagal memuat data supplier"));
    }
  }

  Future<void> _onAddSupplier(
      AddSupplier event, Emitter<SupplierState> emit) async {
    emit(SupplierLoading());
    try {
      final success = await SupplierController.addSupplier(
        event.namaSupplier,
        event.noTelp,
      );
      if (success) {
        final supplierList = await SupplierController.getAllSuppliers();
        emit(SupplierLoaded(supplierList));
      } else {
        emit(SupplierError("Gagal menambahkan supplier"));
      }
    } catch (e) {
      emit(SupplierError("Gagal menambahkan supplier: ${e.toString()}"));
    }
  }

  // 🛠️ === UPDATE SUPPLIER HANDLER ===
  Future<void> _onEditSupplier(
      UpdateSupplier event, Emitter<SupplierState> emit) async {
    emit(SupplierLoading());
    try {
      final supplier = Supplier(
        idSupplier: event.id,
        namaSupplier: event.namaSupplier,
        noTelp: event.noTelp,
      );

      final success = await SupplierController.updateSupplier(
        event.id.toString(),
        supplier,
      );

      if (success) {
        final supplierList = await SupplierController.getAllSuppliers();
        emit(SupplierLoaded(supplierList));
      } else {
        emit(SupplierError("Gagal memperbarui supplier"));
      }
    } catch (e) {
      emit(SupplierError("Gagal memperbarui supplier: ${e.toString()}"));
    }
  }

  void _onSearchSupplierByName(
      SearchSupplierByName event, Emitter<SupplierState> emit) {
    if (state is SupplierLoaded) {
      final currentState = state as SupplierLoaded;
      final filtered = currentState.listSupplier
          .where((s) =>
              s.namaSupplier.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(SupplierLoaded(currentState.listSupplier, filteredList: filtered));
    }
  }
}
