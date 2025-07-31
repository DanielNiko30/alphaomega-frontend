import 'package:equatable/equatable.dart';
import '../../../../../model/product/konversi_stok.dart';

abstract class ListProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event untuk memuat semua produk
class FetchProducts extends ListProductEvent {}

/// Event untuk melakukan konversi stok
class KonversiStokEvent extends ListProductEvent {
  final KonversiStok konversiStok;

  KonversiStokEvent(this.konversiStok);

  @override
  List<Object?> get props => [konversiStok];
}
