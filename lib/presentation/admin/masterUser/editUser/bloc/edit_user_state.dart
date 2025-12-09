abstract class EditUserState {}

class EditUserInitial extends EditUserState {}

class EditUserLoading extends EditUserState {}

class EditUserLoaded extends EditUserState {
  final String username;
  final String name;
  final String password;
  final String role;
  final String noTelp;
  final String jenisKelamin;
  final String alamat;

  EditUserLoaded({
    required this.username,
    required this.name,
    required this.password,
    required this.role,
    required this.noTelp,
    required this.jenisKelamin,
    required this.alamat,
  });
}

class EditUserSuccess extends EditUserState {}

class EditUserFailure extends EditUserState {
  final String message;
  EditUserFailure(this.message);
}
