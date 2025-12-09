import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/user/user_controller.dart';
import '../../../../../model/user/user_model.dart';
import 'master_user_event.dart';
import 'master_user_state.dart';

class MasterUserBloc extends Bloc<MasterUserEvent, MasterUserState> {
  final UserController userRepository;

  MasterUserBloc(this.userRepository) : super(MasterUserInitial()) {
    on<LoadMasterUsers>((event, emit) async {
      print("🔄 Fetching user data...");
      emit(MasterUserLoading());
      try {
        final users = await userRepository.fetchUsers();
        emit(MasterUserLoaded(users));
      } catch (e) {
        emit(MasterUserError(e.toString()));
      }
    });

    on<DeleteUserEvent>((event, emit) async {
      print("🗑️ Deleting user ${event.idUser}");

      try {
        // Ambil list saat ini di state
        List<User> currentList = [];
        if (state is MasterUserLoaded) {
          currentList = List.from((state as MasterUserLoaded).users);
        }

        // Hapus di backend
        final success = await userRepository.deleteUser(event.idUser);

        if (!success) {
          emit(MasterUserError("Failed to delete user"));
          return;
        }

        print("✅ User deleted, updating UI...");

        // Hapus dari list lokal dulu → supaya UI langsung update
        currentList.removeWhere((u) => u.idUser == event.idUser);

        // Emit list yang sudah terhapus
        emit(MasterUserLoaded(currentList));

        // Fetch ulang untuk memastikan sinkron dengan DB
        final updatedUsers = await userRepository.fetchUsers();
        emit(MasterUserLoaded(updatedUsers));
      } catch (e) {
        emit(MasterUserError(e.toString()));
      }
    });
  }
}
