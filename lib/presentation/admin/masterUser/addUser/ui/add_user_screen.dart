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

  bool _obscurePassword = true;

  void clearFields() {
    usernameController.clear();
    nameController.clear();
    passwordController.clear();
    roleController.clear();
    noTelpController.clear();
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
          Icon(Icons.person_add_alt_1_rounded, color: accent, size: 26),
          const SizedBox(width: 8),
          Text(
            "Tambah Pegawai",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: BlocListener<AddUserBloc, AddUserState>(
          listener: (context, state) {
            if (state is AddUserSuccess) {
              BlocProvider.of<MasterUserBloc>(context).add(LoadMasterUsers());
              clearFields();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pegawai berhasil ditambahkan")),
              );
            } else if (state is AddUserFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: Scrollbar(
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
                  ],
                ),
              ),
            ),
          ),
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
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text("Tambah"),
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            context.read<AddUserBloc>().add(
                  SubmitAddUser(
                    username: usernameController.text.trim(),
                    name: nameController.text.trim(),
                    password: passwordController.text.trim(),
                    role: roleController.text.trim(),
                    noTelp: noTelpController.text.trim(),
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
