class User {
  final String idUser;
  final String username;
  final String name;
  final String password;
  final String role;
  final String noTelp;

  // 🟢 Nullable karena user lama masih null
  final String? alamat;
  final String? jenisKelamin;

  // Token hanya ada di login
  final String? token;

  User({
    required this.idUser,
    required this.username,
    required this.name,
    required this.password,
    required this.role,
    required this.noTelp,
    this.alamat,
    this.jenisKelamin,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Jika bentuk json = { user: {...}, token: ... } (login)
    final data = json['user'] ?? json;

    return User(
      idUser: data['id_user'].toString(),
      username: data['username'] ?? "",
      name: data['name'] ?? "",
      password: data['password'] ?? "",
      role: data['role'] ?? "",
      noTelp: data['no_telp']?.toString() ?? "",

      // 🟢 Aman dari null
      alamat: data['alamat']?.toString(),
      jenisKelamin: data['jenis_kelamin']?.toString(),

      // Token mungkin null kalau bukan login
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'username': username,
      'name': name,
      'password': password,
      'role': role,
      'no_telp': noTelp,
      'alamat': alamat,
      'jenis_kelamin': jenisKelamin,
      'token': token,
    };
  }
}
