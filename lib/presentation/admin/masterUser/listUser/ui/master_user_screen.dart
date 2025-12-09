import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../editUser/bloc/edit_user_bloc.dart';
import '../../editUser/ui/edit_user_screen.dart';
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
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              MasterUserBloc(UserController())..add(LoadMasterUsers()),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: isDesktop ? 100 : 0,
                top: 48,
                right: 24,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Header dan tombol tambah ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Daftar Pegawai",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Builder(
                        builder: (dialogContext) => ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: dialogContext,
                              builder: (context) {
                                return BlocProvider.value(
                                  value: BlocProvider.of<MasterUserBloc>(
                                      dialogContext),
                                  child: BlocProvider(
                                    create: (context) =>
                                        AddUserBloc(UserController()),
                                    child: const AddUser(),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Tambah Pegawai"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // === Header Tabel ===
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Nama",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Username",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "No. Telepon",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                        // === Tambahan Gender ===
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Gender",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                        // === Tambahan Alamat ===
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Alamat",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                        SizedBox(width: 50),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Expanded(child: MasterUserTable()),
                ],
              ),
            ),

            // === Sidebar hanya untuk desktop ===
            if (isDesktop)
              const Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Sidebar(),
              ),
          ],
        ),
      ),
    );
  }
}

class MasterUserTable extends StatefulWidget {
  const MasterUserTable({super.key});

  @override
  State<MasterUserTable> createState() => _MasterUserTableState();
}

class _MasterUserTableState extends State<MasterUserTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MasterUserBloc, MasterUserState>(
      builder: (context, state) {
        if (state is MasterUserLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MasterUserLoaded) {
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            radius: const Radius.circular(10),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                final isEven = index % 2 == 0;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isEven ? Colors.white : Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          user.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          user.username,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          user.noTelp,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),

                      // === Gender ===
                      Expanded(
                        flex: 2,
                        child: Text(
                          user.jenisKelamin ?? "-",
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),

                      // === Alamat ===
                      Expanded(
                        flex: 3,
                        child: Text(
                          user.alamat ?? "-",
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(
                                        value: BlocProvider.of<MasterUserBloc>(
                                            context),
                                      ),
                                      BlocProvider(
                                        create: (_) =>
                                            EditUserBloc(UserController()),
                                      ),
                                    ],
                                    child: EditUser(user: user),
                                  );
                                },
                              );
                            },
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 380),
                                        child: Padding(
                                          padding: const EdgeInsets.all(18),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.red,
                                                size: 48,
                                              ),
                                              const SizedBox(height: 12),
                                              const Text(
                                                "Hapus User",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Yakin ingin menghapus \"${user.name}\"?",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(height: 22),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.grey[300],
                                                        foregroundColor:
                                                            Colors.black87,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child:
                                                          const Text("Batal"),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        context
                                                            .read<
                                                                MasterUserBloc>()
                                                            .add(DeleteUserEvent(
                                                                user.idUser));
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child:
                                                          const Text("Hapus"),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Hapus'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        } else if (state is MasterUserError) {
          return Center(child: Text(state.message));
        } else {
          return const Center(child: Text("Tidak ada data"));
        }
      },
    );
  }
}
