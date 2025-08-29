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
      } else if (role == "pegawai gudang") {
        Navigator.pushReplacementNamed(context, '/listPesanan');
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;

          // 🔹 Tentukan layout responsif
          bool isMobile = screenWidth < 600;
          bool isTablet = screenWidth >= 600 && screenWidth < 1024;
          bool isDesktop = screenWidth >= 1024;

          double cardWidth;
          double cardHeight;

          if (isMobile) {
            cardWidth = screenWidth * 0.7;
            cardHeight = 200;
          } else if (isTablet) {
            cardWidth = 300;
            cardHeight = 300;
          } else {
            cardWidth = 400;
            cardHeight = 400;
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: isMobile
                  // 🔹 HP → tampil vertikal
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _roleCard(
                          context,
                          title: "Penjual",
                          icon: Icons.store,
                          bgColor: Colors.white,
                          borderColor: Colors.blue.shade800,
                          textColor: Colors.blue.shade800,
                          width: cardWidth,
                          height: cardHeight,
                          onTap: () => _setRole(context, "penjual"),
                        ),
                        const SizedBox(height: 40),
                        _roleCard(
                          context,
                          title: "Gudang",
                          icon: Icons.warehouse,
                          bgColor: Colors.blue.shade800,
                          borderColor: Colors.white,
                          textColor: Colors.white,
                          width: cardWidth,
                          height: cardHeight,
                          onTap: () => _setRole(context, "pegawai gudang"),
                        ),
                      ],
                    )
                  // 🔹 Tablet & PC → tampil horizontal
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _roleCard(
                          context,
                          title: "Penjual",
                          icon: Icons.store,
                          bgColor: Colors.white,
                          borderColor: Colors.blue.shade800,
                          textColor: Colors.blue.shade800,
                          width: cardWidth,
                          height: cardHeight,
                          onTap: () => _setRole(context, "penjual"),
                        ),
                        const SizedBox(width: 80),
                        _roleCard(
                          context,
                          title: "Gudang",
                          icon: Icons.warehouse,
                          bgColor: Colors.blue.shade800,
                          borderColor: Colors.white,
                          textColor: Colors.white,
                          width: cardWidth,
                          height: cardHeight,
                          onTap: () => _setRole(context, "pegawai gudang"),
                        ),
                      ],
                    ),
            ),
          );
        },
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
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
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
            Icon(icon, size: height * 0.3, color: textColor),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: height * 0.12,
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
