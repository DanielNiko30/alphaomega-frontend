import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class AuthController {
  final String baseUrl =
      'http://192.168.18.18:3000/api/auth/login'; // ganti sesuai backend
  final box = GetStorage();

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Simpan token dan data user ke local storage
        if (data['token'] != null) {
          await box.write('token', data['token']);
        }
        if (data['user'] != null) {
          await box.write('user', data['user']);
        }

        print('Login berhasil: $data');
        return data; // return token + user
      } else {
        print('Login gagal: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // ✅ Ambil token dari local storage
  String? getToken() {
    return box.read('token');
  }

  // ✅ Ambil data user dari local storage
  Map<String, dynamic>? getUser() {
    final user = box.read('user');
    return user != null ? Map<String, dynamic>.from(user) : null;
  }

  // ✅ Logout -> hapus data di local storage
  Future<void> logout() async {
    await box.remove('token');
    await box.remove('user');
  }
}
