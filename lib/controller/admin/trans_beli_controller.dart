import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../../model/transaksiBeli/htrans_beli_model.dart';

class TransaksiBeliController {
  static const String baseUrl =
      "https://tokalphaomegaploso.my.id/api/transaksiBeli";

  static Future<List<HTransBeli>> getAllTransactions() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // 🔍 Cek kalau bukan List, langsung lempar List kosong
      if (decoded == null) {
        print("⚠️ Response body null");
        return [];
      }

      if (decoded is! List) {
        print("⚠️ Response bukan List, isi: $decoded");
        return [];
      }

      // ✅ Kalau benar List
      List<dynamic> data = decoded;
      return data.map((json) {
        // Pastikan key detail_transaksi aman
        if (json["detail_transaksi"] == null ||
            json["detail_transaksi"] is! List) {
          json["detail_transaksi"] = [];
        }

        try {
          final transaksi = HTransBeli.fromJson(json);
          print(
              "✅ Loaded transaksi: ${transaksi.nomorInvoice} (${transaksi.detail.length} detail)");
          return transaksi;
        } catch (e, stack) {
          print("❌ Error parsing transaksi: ${json["id_htrans_beli"]}");
          print("Error: $e");
          print(stack);
          rethrow;
        }
      }).toList();
    } else {
      throw Exception(
          "Gagal mengambil data transaksi beli (${response.statusCode})");
    }
  }

  static Future<HTransBeli> getTransactionById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);

        // 🔹 Pastikan semua field penting tidak null
        jsonData["id_htrans_beli"] ??= '';
        jsonData["id_supplier"] ??= '';
        jsonData["tanggal"] ??= '';
        jsonData["total_harga"] ??= 0;
        jsonData["metode_pembayaran"] ??= '';
        jsonData["nomor_invoice"] ??= '';
        jsonData["ppn"] ??= 0;

        // 🔹 Pastikan detail_transaksi selalu list
        if (jsonData["detail_transaksi"] == null ||
            jsonData["detail_transaksi"] is! List) {
          jsonData["detail_transaksi"] = [];
        } else {
          jsonData["detail_transaksi"] =
              (jsonData["detail_transaksi"] as List).map((d) {
            // Pastikan setiap field DTransBeli aman
            d['id_produk'] ??= '';
            d['jumlah_barang'] ??= 0;
            d['satuan'] ??= '';
            d['subtotal'] ??= 0;
            d['diskon_barang'] ??= 0;
            d['harga_satuan'] ??= 0;
            return d;
          }).toList();
        }

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

  static Future<Response> updateTransaction({
    required String id,
    required HTransBeli transaction,
  }) async {
    try {
      // 🔹 Detail transaksi sebagai List<Map>
      final List<Map<String, dynamic>> detailJsonList =
          transaction.detail.map((d) => d.toJson()).toList();

      // 🔹 Kirim JSON langsung, bukan FormData
      final Map<String, dynamic> body = {
        "id_htrans_beli": transaction.idHTransBeli,
        "id_supplier": transaction.idSupplier,
        "tanggal": transaction.tanggal,
        "total_harga": transaction.totalHarga,
        "metode_pembayaran": transaction.metodePembayaran,
        "nomor_invoice": transaction.nomorInvoice,
        "ppn": transaction.ppn,
        "detail": detailJsonList, // array object
      };

      print("⚡ Data update dikirim ke API: $body");

      final response = await Dio().put(
        "$baseUrl/$id",
        data: body,
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      print("⚡ Response API: ${response.data}");

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception("⚠️ Gagal update transaksi: ${response.statusMessage}");
      }
    } catch (e, stack) {
      print("❌ Error update transaksi: $e");
      print(stack);
      throw Exception("⚠️ Error update transaksi: ${e.toString()}");
    }
  }

  static Future<bool> deleteTransaction(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    return response.statusCode == 200;
  }
}
