import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../../model/transaksiBeli/htrans_beli_model.dart';

class TransaksiBeliController {
  static const String baseUrl = "http://localhost:3000/api/transaksiBeli";

  // Ambil semua transaksi beli
  static Future<List<HTransBeli>> getAllTransactions() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => HTransBeli.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil data transaksi beli");
    }
  }

  // Ambil transaksi berdasarkan ID
  static Future<HTransBeli> getTransactionById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        return HTransBeli.fromJson(jsonData);
      } catch (e) {
        throw Exception(
            "Gagal memuat transaksi: Format data tidak sesuai (${e.toString()})");
      }
    } else if (response.statusCode == 404) {
      throw Exception("Transaksi tidak ditemukan");
    } else {
      throw Exception(
          "Terjadi kesalahan (${response.statusCode}): ${response.body}");
    }
  }

  // Tambah transaksi beli
  static Future<Response> createTransaction(HTransBeli transaction) async {
    try {
      final List<Map<String, dynamic>> detailJsonList =
          transaction.detail.map((d) => d.toJson()).toList();

      FormData formData = FormData.fromMap({
        "id_supplier": transaction.idSupplier,
        "tanggal": transaction.tanggal,
        "total_harga": transaction.totalHarga,
        "metode_pembayaran": transaction.metodePembayaran,
        "nomor_invoice": transaction.nomorInvoice,
        "ppn": transaction.ppn,
        "detail": jsonEncode(detailJsonList), // Format JSON String
      });

      print("⚡ Data dikirim ke API: ${formData.fields}");

      final response = await Dio().post(
        baseUrl,
        data: transaction.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print("⚡ Response API: ${response.data}");

      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception(
            "⚠️ Gagal menambahkan transaksi: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("⚠️ Error menambahkan transaksi: ${e.toString()}");
    }
  }

  // Update transaksi beli
  static Future<Response> updateTransaction({
    required String id,
    required HTransBeli transaction,
  }) async {
    try {
      final List<Map<String, dynamic>> detailJsonList =
          transaction.detail.map((d) => d.toJson()).toList();

      FormData formData = FormData.fromMap({
        "id_supplier": transaction.idSupplier,
        "tanggal": transaction.tanggal,
        "total_harga": transaction.totalHarga,
        "metode_pembayaran": transaction.metodePembayaran,
        "nomor_invoice": transaction.nomorInvoice,
        "ppn": transaction.ppn,
        "detail": jsonEncode(detailJsonList), // Format JSON String
      });

      print("⚡ Data update dikirim ke API: ${formData.fields}");

      final response = await Dio().put(
        "$baseUrl/$id",
        data: transaction.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print("⚡ Response API: ${response.data}");

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception("⚠️ Gagal update transaksi: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("⚠️ Error update transaksi: ${e.toString()}");
    }
  }

  // Hapus transaksi beli
  static Future<bool> deleteTransaction(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    return response.statusCode == 200;
  }
}
