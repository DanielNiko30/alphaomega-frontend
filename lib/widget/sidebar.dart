import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isCollapsed = true;

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
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildListTile(Icons.dashboard, 'Dashboard', () {
                    Navigator.pushNamed(context, '/dashboard');
                  }),

                  // Master Data Section
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

                  // Expandable Master Produk
                  ExpansionTile(
                    leading: Icon(Icons.inventory),
                    title: isCollapsed
                        ? const SizedBox.shrink()
                        : const Text('Master Produk'),
                    children: [
                      ListTile(
                        leading: const Icon(
                            Icons.list_alt), // tetap tampil walau isCollapsed
                        title: isCollapsed ? null : const Text('Daftar Produk'),
                        onTap: () {
                          Navigator.pushNamed(context, '/masterBarang');
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                            Icons.category), // tetap tampil walau isCollapsed
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

                  // Transaksi Section
                  // Transaksi Section
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

                  // Laporan Section
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
