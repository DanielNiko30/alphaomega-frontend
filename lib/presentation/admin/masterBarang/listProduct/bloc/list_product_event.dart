import 'package:equatable/equatable.dart';
import '../../../../../model/product/konversi_stok.dart';
import '../../editProduct/bloc/edit_product_event.dart';

/// ===== Base Event =====
abstract class ListProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event untuk memuat semua produk (tanpa stok)
class FetchProducts extends ListProductEvent {}

/// Event untuk memuat semua produk dengan stok (gabungan product + stok)
class FetchProductsWithStok extends ListProductEvent {}

/// Event untuk melakukan konversi stok
class KonversiStokEvent extends ListProductEvent {
  final KonversiStok konversiStok;

  KonversiStokEvent(this.konversiStok);

  @override
  List<Object?> get props => [konversiStok];
}

class DeleteStokEvent extends EditProductEvent {
  final String idStok;

  DeleteStokEvent({required this.idStok});

  @override
  List<Object?> get props => [idStok];
}


