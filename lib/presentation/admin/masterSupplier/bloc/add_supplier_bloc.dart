import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/controller/supplier/supplier_controller.dart';
import '../../../../model/supplier/supllier_model.dart';
import 'add_supplier_event.dart';
import 'add_supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final SupplierController supplierController;
  List<Supplier> _allSupplier = []; // simpan full list

  SupplierBloc(this.supplierController) : super(SupplierInitial()) {
    on<FetchSupplier>(_onFetchSupplier);
    on<AddSupplier>(_onAddSupplier);
    on<UpdateSupplier>(_onEditSupplier);
    on<SearchSupplierByName>(_onSearchSupplierByName);
    on<DeleteSupplier>(_onDeleteSupplier);
  }

  Future<void> _onFetchSupplier(
      FetchSupplier event, Emitter<SupplierState> emit) async {
    emit(SupplierLoading());
    try {
      _allSupplier = await SupplierController.getAllSuppliers();
      emit(SupplierLoaded(_allSupplier, filteredList: _allSupplier));
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
        event.keterangan,
      );
      if (success) {
        _allSupplier = await SupplierController.getAllSuppliers();
        emit(SupplierLoaded(_allSupplier, filteredList: _allSupplier));
      } else {
        emit(SupplierError("Gagal menambahkan supplier"));
      }
    } catch (e) {
      emit(SupplierError("Gagal menambahkan supplier: ${e.toString()}"));
    }
  }

  Future<void> _onEditSupplier(
      UpdateSupplier event, Emitter<SupplierState> emit) async {
    emit(SupplierLoading());
    try {
      final supplier = Supplier(
        idSupplier: event.id,
        namaSupplier: event.namaSupplier,
        noTelp: event.noTelp,
        keterangan: event.keterangan,
      );
      final success =
          await SupplierController.updateSupplier(event.id, supplier);

      if (success) {
        _allSupplier = await SupplierController.getAllSuppliers();
        emit(SupplierLoaded(_allSupplier, filteredList: _allSupplier));
      } else {
        emit(SupplierError("Gagal memperbarui supplier"));
      }
    } catch (e) {
      emit(SupplierError("Gagal memperbarui supplier: ${e.toString()}"));
    }
  }

  void _onSearchSupplierByName(
      SearchSupplierByName event, Emitter<SupplierState> emit) {
    final query = event.query.toLowerCase();
    final filtered = _allSupplier
        .where((s) => s.namaSupplier.toLowerCase().contains(query))
        .toList();
    emit(SupplierLoaded(_allSupplier, filteredList: filtered));
  }

  Future<void> _onDeleteSupplier(
      DeleteSupplier event, Emitter<SupplierState> emit) async {
    emit(SupplierLoading());
    try {
      final success = await SupplierController.deleteSupplier(event.idSupplier);

      if (success) {
        _allSupplier = await SupplierController.getAllSuppliers();
        emit(SupplierLoaded(_allSupplier, filteredList: _allSupplier));
      } else {
        emit(SupplierError("Gagal menghapus supplier"));
      }
    } catch (e) {
      emit(SupplierError("Gagal menghapus supplier: ${e.toString()}"));
    }
  }
}
