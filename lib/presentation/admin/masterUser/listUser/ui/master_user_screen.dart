import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/master_user_bloc.dart';
import '../bloc/master_user_event.dart';
import '../bloc/master_user_state.dart';
import '../../addUser/bloc/add_user_bloc.dart';
import '../../addUser/ui/add_user_screen.dart';
import '../../../../../controller/user/user_controller.dart';
import '../../../../../widget/sidebar.dart';

class MasterUserScreen extends StatelessWidget {
  const MasterUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MasterUserBloc(UserController())..add(LoadMasterUsers()),
      child: Scaffold(
        body: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 100, top: 60),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Daftar Pegawai",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Builder(
                                builder: (dialogContext) => ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: dialogContext,
                                      builder: (context) {
                                        return BlocProvider.value(
                                          value:
                                              BlocProvider.of<MasterUserBloc>(
                                                  dialogContext),
                                          child: BlocProvider(
                                            create: (context) =>
                                                AddUserBloc(UserController()),
                                            child: AddUser(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text("Tambah Pegawai"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Konten daftar user
                        Expanded(child: MasterUserList()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Sidebar(),
          ],
        ),
      ),
    );
  }
}

class MasterUserList extends StatelessWidget {
  const MasterUserList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.grey[200],
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text("NAMA PEGAWAI",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text("USERNAME",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text("NO. TELEPON",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 24), // Untuk titik tiga menu
              ],
            ),
          ),

          // User List
          Expanded(
            child: BlocBuilder<MasterUserBloc, MasterUserState>(
              builder: (context, state) {
                if (state is MasterUserLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MasterUserLoaded) {
                  return ListView.separated(
                    itemCount: state.users.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(user.name)),
                            Expanded(child: Text(user.username)),
                            Expanded(child: Text(user.noTelp)),
                            const Icon(Icons.more_vert),
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is MasterUserError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text('No data available'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
