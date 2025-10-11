import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/user/user_controller.dart';
import 'edit_user_event.dart';
import 'edit_user_state.dart';

class EditUserBloc extends Bloc<EditUserEvent, EditUserState> {
  final UserController userController;

  EditUserBloc(this.userController) : super(EditUserInitial()) {
    /// 🔹 Load data user ke form
    on<LoadEditUser>((event, emit) {
      emit(EditUserLoaded(
        username: event.user.username,
        name: event.user.name,
        password: event.user.password ?? '', // jaga-jaga null
        role: event.user.role,
        noTelp: event.user.noTelp,
      ));
    });

    /// 🔹 Submit update user
    on<SubmitEditUser>((event, emit) async {
      emit(EditUserLoading());
      try {
        final success = await userController.updateUser(
          idUser: event.idUser,
          username: event.username,
          name: event.name,
          password: event.password,
          role: event.role,
          noTelp: event.noTelp,
        );

        if (success) {
          emit(EditUserSuccess());
        } else {
          emit(EditUserFailure("Gagal update data user"));
        }
      } catch (e) {
        emit(EditUserFailure("Terjadi kesalahan: $e"));
      }
    });
  }
}
