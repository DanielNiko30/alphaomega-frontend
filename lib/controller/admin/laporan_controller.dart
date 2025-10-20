import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/laporan/laporan_model.dart';

class LaporanController {
  final String baseUrl =
      "http://localhost:3000/api/laporan"; // ganti sesuai backendmu

  /// =====================================
  /// 📊 LAPORAN PENJUALAN
  /// =====================================
  Future<LaporanResponse<LaporanTransaksi>> fetchLaporanPenjualan({
    required String startDate,
    required String endDate,
    String groupBy = 'day',
  }) async {
    final url = Uri.parse(
        '$baseUrl/penjualan?startDate=$startDate&endDate=$endDate&groupBy=$groupBy');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      return LaporanResponse.fromJson(
        jsonRes,
        (e) => LaporanTransaksi.fromJson(e),
      );
    } else {
      throw Exception('Gagal mengambil laporan penjualan');
    }
  }

  /// 📦 LAPORAN PENJUALAN PER PRODUK
  Future<LaporanResponse<LaporanProduk>> fetchLaporanPenjualanProduk({
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse(
        '$baseUrl/penjualan-produk?startDate=$startDate&endDate=$endDate');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      return LaporanResponse.fromJson(
        jsonRes,
        (e) => LaporanProduk.fromJson(e),
      );
    } else {
      throw Exception('Gagal mengambil laporan penjualan produk');
    }
  }

  /// 🧾 LAPORAN PENJUALAN DETAIL
  Future<LaporanResponse<LaporanDetail>> fetchLaporanPenjualanDetail({
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse(
        '$baseUrl/penjualan-detail?startDate=$startDate&endDate=$endDate');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      return LaporanResponse.fromJson(
        jsonRes,
        (e) => LaporanDetail.fromJson(e),
      );
    } else {
      throw Exception('Gagal mengambil laporan penjualan detail');
    }
  }

  /// =====================================
  /// 🛒 LAPORAN PEMBELIAN
  /// =====================================
  Future<LaporanResponse<LaporanTransaksi>> fetchLaporanPembelian({
    required String startDate,
    required String endDate,
    String groupBy = 'day',
  }) async {
    final url = Uri.parse(
        '$baseUrl/pembelian?startDate=$startDate&endDate=$endDate&groupBy=$groupBy');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      return LaporanResponse.fromJson(
        jsonRes,
        (e) => LaporanTransaksi.fromJson(e),
      );
    } else {
      throw Exception('Gagal mengambil laporan pembelian');
    }
  }

  /// 📦 LAPORAN PEMBELIAN PER PRODUK
  Future<LaporanResponse<LaporanProduk>> fetchLaporanPembelianProduk({
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse(
        '$baseUrl/pembelian-produk?startDate=$startDate&endDate=$endDate');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      return LaporanResponse.fromJson(
        jsonRes,
        (e) => LaporanProduk.fromJson(e),
      );
    } else {
      throw Exception('Gagal mengambil laporan pembelian produk');
    }
  }

  /// 🧾 LAPORAN PEMBELIAN DETAIL
  Future<LaporanResponse<LaporanDetail>> fetchLaporanPembelianDetail({
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse(
        '$baseUrl/pembelian-detail?startDate=$startDate&endDate=$endDate');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      return LaporanResponse.fromJson(
        jsonRes,
        (e) => LaporanDetail.fromJson(e),
      );
    } else {
      throw Exception('Gagal mengambil laporan pembelian detail');
    }
  }
}
