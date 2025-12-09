import 'package:equatable/equatable.dart';
import '../../../../../model/user/user_model.dart';

abstract class MasterUserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MasterUserInitial extends MasterUserState {}

class MasterUserLoading extends MasterUserState {}

class MasterUserLoaded extends MasterUserState {
  final List<User> users;

  MasterUserLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class MasterUserError extends MasterUserState {
  final String message;

  MasterUserError(this.message);

  @override
  List<Object?> get props => [message];
}
