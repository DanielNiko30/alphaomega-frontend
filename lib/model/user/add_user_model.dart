class AddUser {
  final String idUser;
  final String username;
  final String name;
  final String role;
  final String noTelp;
  final String token;

  AddUser({
    required this.idUser,
    required this.username,
    required this.name,
    required this.role,
    required this.noTelp,
    required this.token,
  });

  factory AddUser.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? {}; // Hindari error jika null
    return AddUser(
      idUser: userData['id_user'] ?? 'Unknown',
      username: userData['username'] ?? 'Unknown',
      name: userData['name'] ?? 'Unknown',
      role: userData['role'] ?? 'Unknown',
      noTelp: userData['no_telp']?.toString() ?? '',
      token: json['token'] ?? '',
    );
  }
}
