import 'package:equatable/equatable.dart';

abstract class AddUserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitAddUser extends AddUserEvent {
  final String username;
  final String name;
  final String password;
  final String role;
  final String noTelp;

  SubmitAddUser({
    required this.username,
    required this.name,
    required this.password,
    required this.role,
    required this.noTelp,
  });

  @override
  List<Object?> get props => [username, name, password, role, noTelp];
}
