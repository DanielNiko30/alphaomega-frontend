import 'package:dio/dio.dart';
import '../../model/laporan/laporan_model.dart';

class LaporanController {
  static const String baseUrl = "https://tokalphaomegaploso.my.id/api/laporan";

  /// =========================
  /// LAPORAN PENJUALAN
  /// =========================
  static Future<Map<String, dynamic>> getLaporanPenjualan(
      String startDate, String endDate) async {
    try {
      final response = await Dio().get(
        "$baseUrl/penjualan",
        queryParameters: {"startDate": startDate, "endDate": endDate},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Gagal mengambil laporan penjualan");
      }
    } catch (e) {
      throw Exception("Error getLaporanPenjualan: $e");
    }
  }

  static Future<Map<String, dynamic>> getLaporanPenjualanHarian(
      String tanggal) async {
    try {
      final response = await Dio().get(
        "$baseUrl/penjualan/harian",
        queryParameters: {"tanggal": tanggal},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Gagal mengambil laporan penjualan harian");
      }
    } catch (e) {
      throw Exception("Error getLaporanPenjualanHarian: $e");
    }
  }

  /// =========================
  /// LAPORAN PEMBELIAN
  /// =========================
  static Future<Map<String, dynamic>> getLaporanPembelian(
      String startDate, String endDate) async {
    try {
      final response = await Dio().get(
        "$baseUrl/pembelian",
        queryParameters: {"startDate": startDate, "endDate": endDate},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Gagal mengambil laporan pembelian");
      }
    } catch (e) {
      throw Exception("Error getLaporanPembelian: $e");
    }
  }

  static Future<Map<String, dynamic>> getLaporanPembelianHarian(
      String tanggal) async {
    try {
      final response = await Dio().get(
        "$baseUrl/pembelian/harian",
        queryParameters: {"tanggal": tanggal},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Gagal mengambil laporan pembelian harian");
      }
    } catch (e) {
      throw Exception("Error getLaporanPembelianHarian: $e");
    }
  }

  /// =========================
  /// LAPORAN STOK
  /// =========================
  static Future<Map<String, dynamic>> getLaporanStok(
      String startDate, String endDate) async {
    try {
      final response = await Dio().get(
        "$baseUrl/stok",
        queryParameters: {"startDate": startDate, "endDate": endDate},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Gagal mengambil laporan stok");
      }
    } catch (e) {
      throw Exception("Error getLaporanStok: $e");
    }
  }

  static Future<Map<String, dynamic>> getLaporanStokHarian(
      String tanggal) async {
    try {
      final response = await Dio().get(
        "$baseUrl/stok/harian",
        queryParameters: {"tanggal": tanggal},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Gagal mengambil laporan stok harian");
      }
    } catch (e) {
      throw Exception("Error getLaporanStokHarian: $e");
    }
  }
}
