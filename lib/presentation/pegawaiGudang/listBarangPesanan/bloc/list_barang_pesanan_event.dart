import 'package:equatable/equatable.dart';

abstract class ListBarangPesananEvent extends Equatable {
  const ListBarangPesananEvent();

  @override
  List<Object?> get props => [];
}

class FetchPendingTransaksi extends ListBarangPesananEvent {
  final String idUserPenjual;

  const FetchPendingTransaksi(this.idUserPenjual);

  @override
  List<Object?> get props => [idUserPenjual];
}
