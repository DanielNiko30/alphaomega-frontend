import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../../model/transaksiJual/htrans_jual_model.dart';

class TransaksiJualController {
  static const String baseUrl =
      "https://tokalphaomegaploso.my.id/api/transaksiJual";

  /// 🔹 Ambil semua transaksi jual
  static Future<List<HTransJual>> getAllTransactions() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => HTransJual.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil data transaksi jual");
    }
  }

  /// 🔹 Ambil transaksi jual berdasarkan ID
  static Future<HTransJual> getTransactionById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return HTransJual.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception("Transaksi tidak ditemukan");
    } else {
      throw Exception("Gagal memuat transaksi: ${response.body}");
    }
  }

  /// 🔹 Ambil invoice number terbaru
  static Future<String> getLatestInvoiceNumber() async {
    final response = await http.get(Uri.parse("$baseUrl/invoice/latest"));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData["nomor_invoice"];
    } else {
      throw Exception("Gagal mengambil nomor invoice");
    }
  }

  /// 🔹 Ambil transaksi pending
  static Future<List<HTransJual>> getPendingTransactions() async {
    final response = await http.get(Uri.parse("$baseUrl/status/pending"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => HTransJual.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil transaksi pending");
    }
  }

  /// 🔹 Ambil transaksi lunas
  static Future<List<HTransJual>> getLunasTransactions() async {
    final response = await http.get(Uri.parse("$baseUrl/status/lunas"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => HTransJual.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil transaksi lunas");
    }
  }

  /// 🔹 Tambah transaksi baru
  static Future<Response> createTransaction(HTransJual transaction) async {
    try {
      final response = await Dio().post(
        baseUrl,
        data: transaction.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception(
            "Gagal menambahkan transaksi: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Error saat membuat transaksi: $e");
    }
  }

  /// 🔹 Update transaksi
  static Future<Response> updateTransaction(
      String id, HTransJual updatedTransaction) async {
    try {
      final response = await Dio().put(
        "$baseUrl/$id", // ✅ disesuaikan
        data: updatedTransaction.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(
            "Gagal memperbarui transaksi: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Error saat update transaksi: $e");
    }
  }

  /// 🔹 Hapus transaksi
  static Future<void> deleteTransaction(String id) async {
    try {
      final response = await Dio().delete("$baseUrl/$id");

      if (response.statusCode != 200) {
        throw Exception("Gagal menghapus transaksi: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Error saat menghapus transaksi: $e");
    }
  }

  /// 🔹 Ambil transaksi pending berdasarkan penjual
  static Future<List<HTransJual>> getPendingTransactionsByPenjual(
      String idUserPenjual) async {
    try {
      final response = await Dio().post(
        "$baseUrl/status/pending/penjual",
        data: {"id_user_penjual": idUserPenjual},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => HTransJual.fromJson(json)).toList();
      } else {
        throw Exception(
            "Gagal mengambil transaksi pending penjual: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Error mengambil transaksi pending penjual: $e");
    }
  }

  /// 🔹 Ambil semua transaksi berdasarkan penjual
  static Future<List<HTransJual>> getTransactionsByPenjual(
      String idUserPenjual) async {
    try {
      final response = await Dio().post(
        "$baseUrl/penjual",
        data: {"id_user_penjual": idUserPenjual},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => HTransJual.fromJson(json)).toList();
      } else {
        throw Exception(
            "Gagal mengambil transaksi penjual: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Error mengambil transaksi penjual: $e");
    }
  }

  /// 🔹 Ambil transaksi berdasarkan range tanggal
  static Future<List<HTransJual>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final response = await Dio().post(
        "$baseUrl/date-range",
        data: {
          "start_date": startDate.toIso8601String(),
          "end_date": endDate.toIso8601String(),
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => HTransJual.fromJson(json)).toList();
      } else {
        throw Exception(
            "Gagal mengambil transaksi berdasarkan tanggal: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Error mengambil transaksi berdasarkan tanggal: $e");
    }
  }
}
