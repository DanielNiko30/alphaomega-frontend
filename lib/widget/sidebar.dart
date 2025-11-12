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

  String? role;

  @override
  void initState() {
    super.initState();
    final user = box.read('user');
    if (user != null && user['role'] != null) {
      role = user['role']; // Pastikan field-nya sesuai dari backend
    } else {
      role = 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 70 : 250,
      child: Drawer(
        child: Column(
          children: <Widget>[
            // 🔹 Header
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
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

            // 🔹 Daftar Menu (Filtered by Role)
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _buildMenuByRole(context),
              ),
            ),

            // 🔹 Tombol Logout
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

  /// 🔹 Fungsi buat daftar menu sesuai role
  List<Widget> _buildMenuByRole(BuildContext context) {
    switch (role) {
      case 'admin':
        return _buildAdminMenu(context);
      case 'penjual':
        return _buildPenjualMenu(context);
      case 'pegawai gudang':
        return _buildGudangMenu(context);
      case 'pegawai online':
        return _buildOnlineMenu(context);
      default:
        return [
          const ListTile(
            title: Text('Role tidak dikenali'),
          ),
        ];
    }
  }

  /// 🔹 Menu untuk Admin (semua akses)
  List<Widget> _buildAdminMenu(BuildContext context) {
    return [
      _buildListTile(Icons.dashboard, 'Dashboard', () {
        Navigator.pushNamed(context, '/dashboard');
      }),
      if (!isCollapsed)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Master Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      _buildListTile(Icons.person, 'Master User', () {
        Navigator.pushNamed(context, '/masterUser');
      }),
      ExpansionTile(
        leading: const Icon(Icons.inventory),
        title:
            isCollapsed ? const SizedBox.shrink() : const Text('Master Produk'),
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
            title: isCollapsed ? null : const Text('Kategori Produk'),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ExpansionTile(
        leading: const Icon(Icons.shopping_cart),
        title: isCollapsed
            ? const SizedBox.shrink()
            : const Text('Transaksi Beli'),
        children: [
          ListTile(
            leading: const Icon(Icons.note_add),
            title: isCollapsed ? null : const Text('Buat Nota Pembelian'),
            onTap: () {
              Navigator.pushNamed(context, '/transaksiPembelian');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: isCollapsed ? null : const Text('Histori Pembelian'),
            onTap: () {
              Navigator.pushNamed(context, '/historiPembelian');
            },
          ),
        ],
      ),
      ExpansionTile(
        leading: const Icon(Icons.sell),
        title: isCollapsed
            ? const SizedBox.shrink()
            : const Text('Transaksi Jual'),
        children: [
          ListTile(
            leading: const Icon(Icons.note_add_outlined),
            title: isCollapsed ? null : const Text('Buat Nota Penjualan'),
            onTap: () {
              Navigator.pushNamed(context, '/transaksiPenjualan');
            },
          ),
          ListTile(
            leading: const Icon(Icons.pending_actions),
            title: isCollapsed ? null : const Text('Penjualan Pending'),
            onTap: () {
              Navigator.pushNamed(context, '/transaksiPenjualanPending');
            },
          ),
        ],
      ),
      ExpansionTile(
        leading: const Icon(Icons.shopping_bag),
        title: isCollapsed
            ? const SizedBox.shrink()
            : const Text('Pesanan Online'),
        children: [
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: isCollapsed ? null : const Text('Shopee'),
            onTap: () {
              Navigator.pushNamed(context, '/shopeeOrders');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: isCollapsed ? null : const Text('Lazada'),
            onTap: () {
              Navigator.pushNamed(context, '/lazadaOrders');
            },
          ),
        ],
      ),
      if (!isCollapsed)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Laporan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
    ];
  }

  /// 🔹 Menu Penjual (hanya Transaksi Penjualan)
  List<Widget> _buildPenjualMenu(BuildContext context) {
    return [
      ExpansionTile(
        leading: const Icon(Icons.sell),
        title: isCollapsed
            ? const SizedBox.shrink()
            : const Text('Transaksi Jual'),
        children: [
          ListTile(
            leading: const Icon(Icons.note_add_outlined),
            title: isCollapsed ? null : const Text('Buat Nota Penjualan'),
            onTap: () {
              Navigator.pushNamed(context, '/transaksiPenjualan');
            },
          ),
          ListTile(
            leading: const Icon(Icons.pending_actions),
            title: isCollapsed ? null : const Text('Penjualan Pending'),
            onTap: () {
              Navigator.pushNamed(context, '/transaksiPenjualanPending');
            },
          ),
        ],
      ),
    ];
  }

  /// 🔹 Menu Pegawai Gudang (hanya Master Barang)
  List<Widget> _buildGudangMenu(BuildContext context) {
    return [
      ExpansionTile(
        leading: const Icon(Icons.inventory),
        title:
            isCollapsed ? const SizedBox.shrink() : const Text('Master Produk'),
        children: [
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: isCollapsed ? null : const Text('Daftar Produk'),
            onTap: () {
              Navigator.pushNamed(context, '/masterBarang');
            },
          ),
        ],
      ),
    ];
  }

  /// 🔹 Menu Pegawai Online (Shopee & Lazada Orders)
  List<Widget> _buildOnlineMenu(BuildContext context) {
    return [
      ExpansionTile(
        leading: const Icon(Icons.shopping_bag),
        title: isCollapsed
            ? const SizedBox.shrink()
            : const Text('Pesanan Online'),
        children: [
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: isCollapsed ? null : const Text('Shopee'),
            onTap: () {
              Navigator.pushNamed(context, '/shopeeOrders');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: isCollapsed ? null : const Text('Lazada'),
            onTap: () {
              Navigator.pushNamed(context, '/lazadaOrders');
            },
          ),
        ],
      ),
    ];
  }

  Widget _buildListTile(IconData icon, String title, GestureTapCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: isCollapsed ? null : Text(title),
      onTap: onTap,
    );
  }
}
