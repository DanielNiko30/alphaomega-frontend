import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index); // tetap panggil callback

        // 🔹 Navigasi otomatis sesuai index
        if (index == 0) {
          Navigator.pushReplacementNamed(context, "/listPesanan");
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, "/masterBarang");
        }
      },
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: "Pesanan",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: "Produk",
        ),
      ],
    );
  }
}
