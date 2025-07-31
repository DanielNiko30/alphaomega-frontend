import '../../../../../model/user/user_model.dart';

abstract class MasterUserState {}

class MasterUserInitial extends MasterUserState {}

class MasterUserLoading extends MasterUserState {}

class MasterUserLoaded extends MasterUserState {
  final List<User> users;
  MasterUserLoaded(this.users);
}

class MasterUserError extends MasterUserState {
  final String message;
  MasterUserError(this.message);
}
