class AddUser {
  final String idUser;
  final String username;
  final String name;
  final String role;
  final String noTelp;
  final String? alamat;
  final String? jenisKelamin;
  final String? token;

  AddUser({
    required this.idUser,
    required this.username,
    required this.name,
    required this.role,
    required this.noTelp,
    this.alamat,
    this.jenisKelamin,
    this.token,
  });

  factory AddUser.fromJson(Map<String, dynamic> json) {
    final data = json['user'] ?? json;

    return AddUser(
      idUser: data['id_user'] ?? "",
      username: data['username'] ?? "",
      name: data['name'] ?? "",
      role: data['role'] ?? "",
      noTelp: data['no_telp']?.toString() ?? "",

      // 🟢 tambahan baru
      alamat: data['alamat']?.toString(),
      jenisKelamin: data['jenis_kelamin']?.toString(),

      token: json['token'],
    );
  }
}
