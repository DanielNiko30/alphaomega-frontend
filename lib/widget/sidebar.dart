import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isCollapsed = true;
  final box = GetStorage();

  Future<void> logout() async {
    await box.remove('token');
    await box.remove('user');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 70 : 250,
      child: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(isCollapsed ? Icons.menu : Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      isCollapsed = !isCollapsed;
                    });
                  },
                ),
              ),
            ),

            // 🔹 Bagian Menu
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildListTile(Icons.dashboard, 'Dashboard', () {
                    Navigator.pushNamed(context, '/dashboard');
                  }),
                  if (!isCollapsed)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Master Data',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  _buildListTile(Icons.person, 'Master User', () {
                    Navigator.pushNamed(context, '/masterUser');
                  }),
                  ExpansionTile(
                    leading: const Icon(Icons.inventory),
                    title: isCollapsed
                        ? const SizedBox.shrink()
                        : const Text('Master Produk'),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.list_alt),
                        title: isCollapsed ? null : const Text('Daftar Produk'),
                        onTap: () {
                          Navigator.pushNamed(context, '/masterBarang');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.category),
                        title:
                            isCollapsed ? null : const Text('Kategori Produk'),
                        onTap: () {
                          Navigator.pushNamed(context, '/kategoriProduk');
                        },
                      ),
                    ],
                  ),
                  _buildListTile(Icons.local_shipping, 'Master Supplier', () {
                    Navigator.pushNamed(context, '/masterSupplier');
                  }),
                  if (!isCollapsed)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Transaksi',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  _buildListTile(Icons.shopping_cart, 'Transaksi Pembelian',
                      () {
                    Navigator.pushNamed(context, '/transaksiPembelian');
                  }),
                  _buildListTile(Icons.sell, 'Transaksi Penjualan', () {
                    Navigator.pushNamed(context, '/transaksiPenjualan');
                  }),
                  _buildListTile(Icons.pending_actions, 'Pesanan Diproses', () {
                    Navigator.pushNamed(context, '/transaksiPenjualanPending');
                  }),
                  _buildListTile(Icons.shopping_bag, 'Pesanan Online', () {
                    Navigator.pushNamed(context, '/pesananOnline');
                  }),
                  if (!isCollapsed)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Laporan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  _buildListTile(Icons.receipt_long, 'Laporan Pembelian', () {
                    Navigator.pushNamed(context, '/laporanPembelian');
                  }),
                  _buildListTile(Icons.receipt, 'Laporan Penjualan', () {
                    Navigator.pushNamed(context, '/laporanPenjualan');
                  }),
                  _buildListTile(Icons.storage, 'Laporan Stok', () {
                    Navigator.pushNamed(context, '/laporanStok');
                  }),
                ],
              ),
            ),

            // 🔹 Tombol Logout di bawah
            SafeArea(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: isCollapsed ? null : const Text("Logout"),
                onTap: () async {
                  await logout();
                  Navigator.pushReplacementNamed(context, "/login");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, GestureTapCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: isCollapsed ? null : Text(title),
      onTap: onTap,
    );
  }
}
