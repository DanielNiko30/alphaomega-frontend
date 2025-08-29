import 'package:equatable/equatable.dart';
import '../../../../model/pegawaiGudang/barang_pesanan_model.dart';

class DetailPesananState extends Equatable {
  final String namaPembeli;
  final List<BarangPesanan> barang;

  const DetailPesananState({
    required this.namaPembeli,
    required this.barang,
  });

  DetailPesananState copyWith({
    String? namaPembeli,
    List<BarangPesanan>? barang,
  }) {
    return DetailPesananState(
      namaPembeli: namaPembeli ?? this.namaPembeli,
      barang: barang ?? this.barang,
    );
  }

  @override
  List<Object?> get props => [namaPembeli, barang];
}
