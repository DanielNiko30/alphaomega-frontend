// laporan_model.dart
class DetailTransaksi {
  final String namaProduct;
  final String satuan;
  final int jumlah;
  final int hargaJual;
  final int hargaBeli;
  final int subtotal;
  final int hpp;
  final int untung;

  DetailTransaksi({
    required this.namaProduct,
    required this.satuan,
    required this.jumlah,
    required this.hargaJual,
    required this.hargaBeli,
    required this.subtotal,
    required this.hpp,
    required this.untung,
  });

  factory DetailTransaksi.fromJson(Map<String, dynamic> json) {
    return DetailTransaksi(
      namaProduct: json['nama_product'] ?? "-",
      satuan: json['satuan'] ?? "-",
      jumlah: json['jumlah'] ?? 0,
      hargaJual: json['harga_jual'] ?? 0,
      hargaBeli: json['harga_beli'] ?? 0,
      subtotal: json['subtotal'] ?? 0,
      hpp: json['hpp'] ?? 0,
      untung: json['untung'] ?? 0,
    );
  }
}

class LaporanNota {
  final String idHTransJual;
  final String tanggal;
  final String metodePembayaran;
  final List<LaporanDetail> detail;
  final int totalPenjualan;

  LaporanNota({
    required this.idHTransJual,
    required this.tanggal,
    required this.metodePembayaran,
    required this.detail,
    required this.totalPenjualan,
  });

  factory LaporanNota.fromJson(Map<String, dynamic> json) {
    return LaporanNota(
      idHTransJual: json['id_htrans_jual'],
      tanggal: json['tanggal'],
      metodePembayaran: json['metode_pembayaran'],
      detail: (json['detail'] as List<dynamic>?)
              ?.map((e) => LaporanDetail.fromJson(e))
              .toList() ??
          [],
      totalPenjualan: _toIntSafe(json['total_nota']?['total_penjualan']),
    );
  }

  static int _toIntSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

class LaporanDetail {
  final String namaProduct;
  final String satuan;
  final int jumlah;
  final int hargaJual;
  final int hargaBeli;
  final int subtotal;
  final int hpp;
  final int untung;

  LaporanDetail({
    required this.namaProduct,
    required this.satuan,
    required this.jumlah,
    required this.hargaJual,
    required this.hargaBeli,
    required this.subtotal,
    required this.hpp,
    required this.untung,
  });

  factory LaporanDetail.fromJson(Map<String, dynamic> json) {
    return LaporanDetail(
      namaProduct: json['nama_product'],
      satuan: json['satuan'],
      jumlah: LaporanNota._toIntSafe(json['jumlah']),
      hargaJual: LaporanNota._toIntSafe(json['harga_jual']),
      hargaBeli: LaporanNota._toIntSafe(json['harga_beli']),
      subtotal: LaporanNota._toIntSafe(json['subtotal']),
      hpp: LaporanNota._toIntSafe(json['hpp']),
      untung: LaporanNota._toIntSafe(json['untung']),
    );
  }
}

class LaporanPembelian {
  final String waktu;
  final String barang;
  final String pemasok;
  final int jumlah;
  final String satuan;
  final int hargaBeli;
  final int subtotal;
  final String pembayaran;
  final String invoice;

  LaporanPembelian({
    required this.waktu,
    required this.barang,
    required this.pemasok,
    required this.jumlah,
    required this.satuan,
    required this.hargaBeli,
    required this.subtotal,
    required this.pembayaran,
    required this.invoice,
  });

  factory LaporanPembelian.fromJson(Map<String, dynamic> json) {
    return LaporanPembelian(
      waktu: json['waktu'] ?? "-",
      barang: json['barang'] ?? "-",
      pemasok: json['pemasok'] ?? "-",
      jumlah: json['jumlah'] ?? 0,
      satuan: json['satuan'] ?? "-",
      hargaBeli: json['harga_beli'] ?? 0,
      subtotal: json['subtotal'] ?? 0,
      pembayaran: json['pembayaran'] ?? "-",
      invoice: json['invoice'] ?? "-",
    );
  }
}

class LaporanStokDetail {
  final String tanggal;
  final int jumlah;
  final String invoice;

  LaporanStokDetail({
    required this.tanggal,
    required this.jumlah,
    required this.invoice,
  });

  factory LaporanStokDetail.fromJson(Map<String, dynamic> json) {
    return LaporanStokDetail(
      tanggal: json['tanggal'] ?? "-",
      jumlah: json['jumlah'] ?? 0,
      invoice: json['invoice'] ?? "-",
    );
  }
}

class LaporanStok {
  final String namaProduct;
  final int stokAwal;
  final int totalMasuk;
  final List<LaporanStokDetail> detailMasuk;
  final int totalKeluar;
  final List<LaporanStokDetail> detailKeluar;
  final int stokAkhir;

  LaporanStok({
    required this.namaProduct,
    required this.stokAwal,
    required this.totalMasuk,
    required this.detailMasuk,
    required this.totalKeluar,
    required this.detailKeluar,
    required this.stokAkhir,
  });

  factory LaporanStok.fromJson(Map<String, dynamic> json) {
    var masuk = <LaporanStokDetail>[];
    var keluar = <LaporanStokDetail>[];

    if (json['detail_masuk'] != null) {
      masuk = List<LaporanStokDetail>.from(
          json['detail_masuk'].map((x) => LaporanStokDetail.fromJson(x)));
    }

    if (json['detail_keluar'] != null) {
      keluar = List<LaporanStokDetail>.from(
          json['detail_keluar'].map((x) => LaporanStokDetail.fromJson(x)));
    }

    return LaporanStok(
      namaProduct: json['nama_product'] ?? "-",
      stokAwal: json['stok_awal'] ?? 0,
      totalMasuk: json['total_masuk'] ?? 0,
      detailMasuk: masuk,
      totalKeluar: json['total_keluar'] ?? 0,
      detailKeluar: keluar,
      stokAkhir: json['stok_akhir'] ?? 0,
    );
  }
}
