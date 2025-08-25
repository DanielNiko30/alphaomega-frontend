import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../controller/user/user_controller.dart';

class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

  Future<void> _setRole(BuildContext context, String role) async {
    final userController = UserController();
    final box = GetStorage();

    // 🔹 Ambil id_user dari local storage
    final String? currentUserId = box.read("id_user");

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User belum login")),
      );
      return;
    }

    bool success = await userController.updateUserRole(
      idUser: currentUserId,
      newRole: role,
    );

    if (success) {
      // ✅ Simpan role terbaru ke local storage
      await box.write("role", role);

      // ✅ Arahkan ke halaman sesuai role
      if (role == "penjual") {
        Navigator.pushReplacementNamed(context, '/transaksiPenjualan');
      } else if (role == "pegawai_gudang") {
        Navigator.pushReplacementNamed(context, '/gudang');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengubah role")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Card Penjual
              _roleCard(
                context,
                title: "Penjual",
                icon: Icons.store,
                bgColor: Colors.white,
                borderColor: Colors.blue.shade800,
                textColor: Colors.blue.shade800,
                onTap: () => _setRole(context, "penjual"),
              ),
              const SizedBox(width: 80),

              // 🔹 Card Gudang
              _roleCard(
                context,
                title: "Gudang",
                icon: Icons.warehouse,
                bgColor: Colors.blue.shade800,
                borderColor: Colors.white,
                textColor: Colors.white,
                onTap: () => _setRole(context, "pegawai_gudang"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 500,
        height: 500,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(2, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: textColor),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
