import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthController {
  final String baseUrl = 'http://localhost:3000/api/auth/login'; // Sesuaikan dengan backend

  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login berhasil: ${data['token']}');
        return data['token']; // Kembalikan token saja
      } else {
        print('Login gagal: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
}
