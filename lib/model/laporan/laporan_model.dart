import 'dart:convert';

/// ================================
/// 📊 MODEL LAPORAN PENJUALAN / PEMBELIAN PER PERIODE
/// ================================
class LaporanTransaksi {
  final String periode;
  final int jumlahTransaksi;
  final double total;

  LaporanTransaksi({
    required this.periode,
    required this.jumlahTransaksi,
    required this.total,
  });

  factory LaporanTransaksi.fromJson(Map<String, dynamic> json) {
    return LaporanTransaksi(
      periode: json['periode'] ?? '',
      jumlahTransaksi: int.tryParse(json['jumlah_transaksi'].toString()) ?? 0,
      total: double.tryParse(json['total_penjualan']?.toString() ??
              json['total_pembelian']?.toString() ??
              '0') ??
          0,
    );
  }
}

/// ================================
/// 📦 MODEL LAPORAN PER PRODUK
/// ================================
class LaporanProduk {
  final int idProduk;
  final String namaProduk;
  final double totalJumlah;
  final double totalNominal;

  LaporanProduk({
    required this.idProduk,
    required this.namaProduk,
    required this.totalJumlah,
    required this.totalNominal,
  });

  factory LaporanProduk.fromJson(Map<String, dynamic> json) {
    return LaporanProduk(
      idProduk: int.tryParse(json['id_produk'].toString()) ?? 0,
      namaProduk:
          json['produk.nama_product'] ?? json['produk']?['nama_product'] ?? '',
      totalJumlah: double.tryParse(json['total_terjual']?.toString() ??
              json['total_terbeli']?.toString() ??
              '0') ??
          0,
      totalNominal: double.tryParse(json['total_penjualan']?.toString() ??
              json['total_pembelian']?.toString() ??
              '0') ??
          0,
    );
  }
}

/// ================================
/// 🧾 MODEL DETAIL LAPORAN (Header + Detail)
/// ================================
class LaporanDetail {
  final String tanggal;
  final String noTransaksi;
  final double totalHarga;
  final List<LaporanDetailItem> detail;

  LaporanDetail({
    required this.tanggal,
    required this.noTransaksi,
    required this.totalHarga,
    required this.detail,
  });

  factory LaporanDetail.fromJson(Map<String, dynamic> json) {
    final detailList = (json['detail_transaksi'] as List<dynamic>? ?? [])
        .map((item) => LaporanDetailItem.fromJson(item))
        .toList();

    return LaporanDetail(
      tanggal: json['tanggal'] ?? '',
      noTransaksi:
          json['no_invoice'] ?? json['id_htrans_beli']?.toString() ?? '',
      totalHarga: double.tryParse(json['total_harga']?.toString() ?? '0') ?? 0,
      detail: detailList,
    );
  }
}

class LaporanDetailItem {
  final String namaProduk;
  final double jumlah;
  final double subtotal;

  LaporanDetailItem({
    required this.namaProduk,
    required this.jumlah,
    required this.subtotal,
  });

  factory LaporanDetailItem.fromJson(Map<String, dynamic> json) {
    return LaporanDetailItem(
      namaProduk: json['produk']?['nama_product'] ?? '',
      jumlah: double.tryParse(json['jumlah_barang']?.toString() ?? '0') ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
    );
  }
}

/// ================================
/// 🔁 RESPONSE WRAPPER
/// ================================
class LaporanResponse<T> {
  final bool success;
  final String message;
  final List<T> data;
  final Map<String, dynamic>? summary;

  LaporanResponse({
    required this.success,
    required this.message,
    required this.data,
    this.summary,
  });

  factory LaporanResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return LaporanResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      summary: json['summary'],
    );
  }
}
