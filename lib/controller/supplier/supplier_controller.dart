import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/supplier/supllier_model.dart';

class SupplierController {
  static const String baseUrl = "http://localhost:3000/api/supplier";

  static Future<List<Supplier>> getAllSuppliers() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Supplier.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil data supplier");
    }
  }

  static Future<Supplier> getSupplierById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return Supplier.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Supplier tidak ditemukan");
    }
  }

  static Future<bool> addSupplier(String namaSupplier, String noTelp) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "nama_supplier": namaSupplier,
          "no_telp": noTelp,
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data["message"] ?? "Gagal menambahkan supplier");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat tambah supplier: $e");
    }
  }

  static Future<bool> updateSupplier(String id, Supplier supplier) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(supplier.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteSupplier(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    return response.statusCode == 200;
  }
}
