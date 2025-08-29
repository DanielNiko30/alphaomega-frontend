import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/user/user_model.dart';
import '../../model/user/add_user_model.dart';

class UserController {
  final String baseUrl = 'http://192.168.18.18:3000/api/user';

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data
          .map((user) => User.fromJson({'user': user, 'token': ''}))
          .toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<AddUser?> createUser({
    required String username,
    required String name,
    required String password,
    required String role,
    required String noTelp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'name': name,
          'password': password,
          'role': role,
          'no_telp': noTelp,
        }),
      );

      if (response.statusCode == 201) {
        return AddUser.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error creating user: $e');
    }
    return null;
  }

  /// 🔹 Fungsi untuk update role user
  Future<bool> updateUserRole({
    required String idUser, // harus "USR001", bukan 1
    required String newRole,
  }) async {
    try {
      print("DEBUG: Update role for user $idUser"); // 🔹 cek dulu
      final response = await http.put(
        Uri.parse('$baseUrl/$idUser/role'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'role': newRole}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update role: ${response.body}');
      }
    } catch (e) {
      print('Error updating role: $e');
    }
    return false;
  }

  /// 🔹 Ambil semua user role = penjual
  Future<List<User>> fetchPenjual() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/role/penjual'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data
            .map((user) => User.fromJson({'user': user, 'token': ''}))
            .toList();
      } else {
        throw Exception('Failed to load penjual');
      }
    } catch (e) {
      print('Error fetching penjual: $e');
      return [];
    }
  }

  /// 🔹 Ambil semua user role = pegawai gudang
  Future<List<User>> fetchPegawaiGudang() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/role/gudang'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data
            .map((user) => User.fromJson({'user': user, 'token': ''}))
            .toList();
      } else {
        throw Exception('Failed to load pegawai gudang');
      }
    } catch (e) {
      print('Error fetching pegawai gudang: $e');
      return [];
    }
  }
}
