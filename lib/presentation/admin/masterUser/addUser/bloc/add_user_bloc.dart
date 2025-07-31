import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_user_event.dart';
import 'add_user_state.dart';
import '../../../../../controller/user/user_controller.dart';

class AddUserBloc extends Bloc<AddUserEvent, AddUserState> {
  final UserController userController;

  AddUserBloc(this.userController) : super(AddUserInitial()) {
    on<SubmitAddUser>(_onSubmitAddUser);
  }

  Future<void> _onSubmitAddUser(
      SubmitAddUser event, Emitter<AddUserState> emit) async {
    emit(AddUserLoading());
    try {
      final user = await userController.createUser(
        username: event.username,
        name: event.name,
        password: event.password,
        role: event.role,
        noTelp: event.noTelp,
      );
      if (user != null) {
        emit(AddUserSuccess());
      } else {
        emit(AddUserFailure(message: "Gagal menambahkan user"));
      }
    } catch (e) {
      emit(AddUserFailure(message: e.toString()));
    }
  }
}
