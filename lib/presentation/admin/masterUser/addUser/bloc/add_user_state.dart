import 'package:equatable/equatable.dart';

abstract class AddUserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddUserInitial extends AddUserState {}

class AddUserLoading extends AddUserState {}

class AddUserSuccess extends AddUserState {}

class AddUserFailure extends AddUserState {
  final String message;
  
  AddUserFailure({required this.message});
  
  @override
  List<Object?> get props => [message];
}
