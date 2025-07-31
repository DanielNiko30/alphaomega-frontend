import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../controller/user/user_controller.dart';
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
  }
}
