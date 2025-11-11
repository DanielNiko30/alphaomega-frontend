import 'package:flutter/material.dart';

class CustomNavbarOnline extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavbarOnline({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index);

        // 🔹 Navigasi otomatis sesuai index
        if (index == 0) {
          Navigator.pushReplacementNamed(context, "/shopeeOrders");
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, "/lazadaOrders");
        }
      },
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.store), // ikon Shopee
          label: "Shopee",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag), // ikon Lazada
          label: "Lazada",
        ),
      ],
    );
  }
}
