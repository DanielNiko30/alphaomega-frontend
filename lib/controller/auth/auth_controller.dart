import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class AuthController {
  final String baseUrl = 'https://tokalphaomegaploso.my.id/api/auth/login';
  final GetStorage box = GetStorage();

  /// ===== LOGIN =====
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔹 Pastikan token valid dan trim
        final token = data['token']?.toString().trim();
        if (token != null && token.isNotEmpty) {
          await box.write('token', token);
        } else {
          print('⚠️ Token dari backend kosong atau tidak valid: $token');
        }

        // 🔹 Simpan user data
        if (data['user'] != null) {
          await box.write('user', data['user']);
        }

        print('✅ Login berhasil: $data');
        return data;
      } else {
        print('❌ Login gagal: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Login error: $e');
      return null;
    }
  }

  /// ===== GET TOKEN =====
  String? getToken() {
    final token = box.read('token')?.toString().trim();
    if (token == null || token.isEmpty) {
      print('⚠️ Token tidak ditemukan di storage');
      return null;
    }
    return token;
  }

  /// ===== GET USER =====
  Map<String, dynamic>? getUser() {
    final user = box.read('user');
    return user != null ? Map<String, dynamic>.from(user) : null;
  }

  /// ===== LOGOUT =====
  Future<void> logout() async {
    await box.remove('token');
    await box.remove('user');
    print('✅ User logout, token dan data user dihapus');
  }

  /// ===== DEBUG TOKEN =====
  void debugToken() {
    final token = getToken();
    if (token != null) {
      print('🔹 Token saat ini: "$token" (panjang: ${token.length})');
    } else {
      print('⚠️ Tidak ada token tersimpan');
    }
  }
}
