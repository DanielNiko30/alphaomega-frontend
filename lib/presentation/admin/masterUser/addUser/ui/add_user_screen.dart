import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_user_bloc.dart';
import '../bloc/add_user_event.dart';
import '../bloc/add_user_state.dart';
import '../../listUser/bloc/master_user_bloc.dart';
import '../../listUser/bloc/master_user_event.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController noTelpController = TextEditingController();

  void clearFields() {
    usernameController.clear();
    nameController.clear();
    passwordController.clear();
    roleController.clear();
    noTelpController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tambah Pegawai"),
      content: BlocListener<AddUserBloc, AddUserState>(
        listener: (context, state) {
          if (state is AddUserSuccess) {
            // ⬇⬇⬇ Tambahkan event LoadMasterUsers setelah sukses
            BlocProvider.of<MasterUserBloc>(context).add(LoadMasterUsers());

            clearFields();
            Future.delayed(const Duration(milliseconds: 300), () {
              Navigator.of(context).pop();
            });
          } else if (state is AddUserFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username")),
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nama")),
            TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true),
            TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: "Role")),
            TextField(
                controller: noTelpController,
                decoration: const InputDecoration(labelText: "No Telepon")),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<AddUserBloc>().add(
                  SubmitAddUser(
                    username: usernameController.text,
                    name: nameController.text,
                    password: passwordController.text,
                    role: roleController.text,
                    noTelp: noTelpController.text,
                  ),
                );
          },
          child: const Text("Tambah"),
        ),
      ],
    );
  }
}
