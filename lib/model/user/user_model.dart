class User {
  final String idUser;
  final String username;
  final String name;
  final String password;
  final String role;
  final String noTelp;
  final String token;

  User({
    required this.idUser,
    required this.username,
    required this.name,
    required this.password,
    required this.role,
    required this.noTelp,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['user']['id_user'],
      username: json['user']['username'],
      name: json['user']['name'],
      password: json['user']['password'],
      role: json['user']['role'],
      noTelp: json['user']['no_telp'].toString(),
      token: json['token'],
    );
  }
}
