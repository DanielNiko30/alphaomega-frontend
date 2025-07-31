import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/user/user_model.dart';
import '../../model/user/add_user_model.dart';

class UserController {
  final String baseUrl = 'http://localhost:3000/api/user';

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
}
