import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_user_bloc.dart';
import '../bloc/edit_user_event.dart';
import '../bloc/edit_user_state.dart';
import '../../../../../model/user/user_model.dart';
import '../../listUser/bloc/master_user_bloc.dart';
import '../../listUser/bloc/master_user_event.dart';

class EditUser extends StatefulWidget {
  final User user;
  const EditUser({super.key, required this.user});

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController noTelpController = TextEditingController();

  // 🔹 Field baru
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController jenisKelaminController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    context.read<EditUserBloc>().add(LoadEditUser(widget.user));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = Colors.teal.shade600;
    final screenWidth = MediaQuery.of(context).size.width;

    final dialogWidth = screenWidth < 600 ? screenWidth * 0.9 : 600.0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.grey[50],
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      title: Row(
        children: [
          Icon(Icons.edit, color: accent, size: 26),
          const SizedBox(width: 8),
          Text(
            "Edit Pegawai",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: BlocConsumer<EditUserBloc, EditUserState>(
          listener: (context, state) {
            if (state is EditUserSuccess) {
              BlocProvider.of<MasterUserBloc>(context).add(LoadMasterUsers());
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User berhasil diperbarui")),
              );
            } else if (state is EditUserFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is EditUserLoading) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (state is EditUserLoaded) {
              usernameController.text = state.username;
              nameController.text = state.name;
              passwordController.text = state.password;
              roleController.text = state.role;
              noTelpController.text = state.noTelp;

              // 🔹 Isi field baru
              alamatController.text = state.alamat;
              jenisKelaminController.text = state.jenisKelamin;

              return Scrollbar(
                thumbVisibility: true,
                radius: const Radius.circular(12),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                          controller: usernameController,
                          label: "Username",
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: nameController,
                          label: "Nama",
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: passwordController,
                          label: "Password",
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: roleController,
                          label: "Role",
                          icon: Icons.work_outline,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: noTelpController,
                          label: "No Telepon",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        // 🔹 FIELD BARU: ALAMAT
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: alamatController,
                          label: "Alamat",
                          icon: Icons.home_outlined,
                        ),

                        // 🔹 FIELD BARU: JENIS KELAMIN
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: jenisKelaminController,
                          label: "Jenis Kelamin",
                          icon: Icons.wc_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox(height: 100);
          },
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
          child: const Text("Batal"),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text("Simpan"),
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            context.read<EditUserBloc>().add(
                  SubmitEditUser(
                    idUser: widget.user.idUser,
                    username: usernameController.text.trim(),
                    name: nameController.text.trim(),
                    password: passwordController.text.trim(),
                    role: roleController.text.trim(),
                    noTelp: noTelpController.text.trim(),

                    // 🔹 Tambahan baru
                    alamat: alamatController.text.trim(),
                    jenisKelamin: jenisKelaminController.text.trim(),
                  ),
                );
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.teal) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade400, width: 1.5),
        ),
      ),
    );
  }
}
