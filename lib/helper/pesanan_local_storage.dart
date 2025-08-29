import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PesananLocalStorage {
  static const String key = "barang_siap";

  /// Simpan list barang siap ke local storage
  static Future<void> saveStatus(String idPesanan, Map<String, bool> status) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(status);
    await prefs.setString("$key-$idPesanan", data);
  }

  /// Ambil status dari local storage
  static Future<Map<String, bool>> loadStatus(String idPesanan) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("$key-$idPesanan");
    if (data == null) return {};
    return Map<String, bool>.from(jsonDecode(data));
  }
}
