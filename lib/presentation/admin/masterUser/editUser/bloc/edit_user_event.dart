import '../../../../../model/user/user_model.dart';

abstract class EditUserEvent {}

class LoadEditUser extends EditUserEvent {
  final User user;
  LoadEditUser(this.user);
}

class SubmitEditUser extends EditUserEvent {
  final String idUser;
  final String username;
  final String name;
  final String password;
  final String role;
  final String noTelp;
  final String jenisKelamin;
  final String alamat;

  SubmitEditUser({
    required this.idUser,
    required this.username,
    required this.name,
    required this.password,
    required this.role,
    required this.noTelp,
    required this.jenisKelamin,
    required this.alamat,
  });
}
