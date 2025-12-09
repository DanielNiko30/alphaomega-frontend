import 'package:equatable/equatable.dart';

abstract class ListBarangPesananEvent extends Equatable {
  const ListBarangPesananEvent();

  @override
  List<Object?> get props => [];
}

// ❌ Hapus const, supaya bisa hot reload
class FetchPendingTransaksi extends ListBarangPesananEvent {
  final String? userId; // optional, bisa dipakai nanti
  FetchPendingTransaksi([this.userId]);

  @override
  List<Object?> get props => [userId];
}

class NewTransactionReceived extends ListBarangPesananEvent {
  final Map<String, dynamic> data;
  const NewTransactionReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateTransactionReceived extends ListBarangPesananEvent {
  final Map<String, dynamic> data;
  const UpdateTransactionReceived(this.data);

  @override
  List<Object?> get props => [data];
}
