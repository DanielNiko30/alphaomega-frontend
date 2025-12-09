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
    // =======================
    // 1️⃣ VALIDASI FIELD KOSONG
    // =======================
    Map<String, String> errors = {};

    if (event.username.trim().isEmpty) {
      errors["username"] = "Username wajib diisi";
    }
    if (event.name.trim().isEmpty) {
      errors["name"] = "Nama lengkap wajib diisi";
    }
    if (event.password.trim().isEmpty) {
      errors["password"] = "Password wajib diisi";
    }
    if (event.role.trim().isEmpty) {
      errors["role"] = "Role wajib dipilih";
    }
    if (event.noTelp.trim().isEmpty) {
      errors["noTelp"] = "Nomor telepon wajib diisi";
    }
    if (event.alamat.trim().isEmpty) {
      errors["alamat"] = "Alamat wajib diisi";
    }
    if (event.jenisKelamin.trim().isEmpty) {
      errors["jenisKelamin"] = "Jenis kelamin wajib dipilih";
    }

    // Jika ada error, kirimkan state failure khusus validasi
    if (errors.isNotEmpty) {
      emit(AddUserValidationError(errors: errors));
      return;
    }

    // =======================
    // 2️⃣ PROSES SUBMIT
    // =======================
    emit(AddUserLoading());

    try {
      final user = await userController.createUser(
        username: event.username,
        name: event.name,
        password: event.password,
        role: event.role,
        noTelp: event.noTelp,
        alamat: event.alamat,
        jenisKelamin: event.jenisKelamin,
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
