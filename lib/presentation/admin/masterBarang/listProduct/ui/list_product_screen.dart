import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../bloc/list_product_bloc.dart';
import '../bloc/list_product_event.dart';
import '../bloc/list_product_state.dart';
import '../../../../../model/product/konversi_stok.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../widget/sidebar.dart';
import '../../../../../widget/navbar.dart';

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});

  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  final box = GetStorage();
  late String? role;

  int _selectedIndex = 1; // ✅ Halaman ini selalu index 1 (Master Barang)

  @override
  void initState() {
    super.initState();
    role = box.read("role"); // ambil role dari local storage
  }

  void _onNavbarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacementNamed(context, "/listPesanan");
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, "/masterBarang");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (role == "pegawai gudang") {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // hilangkan tombol back
          title: const Text("Daftar Produk"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                box.erase();
                Navigator.pushReplacementNamed(context, "/login");
              },
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: CustomNavbar(
          currentIndex: _selectedIndex, // ✅ Navbar aktif di index 1
          onTap: _onNavbarTap,
        ),
      );
    }

    // ✅ Jika role BUKAN pegawai gudang → tampil dengan sidebar
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  automaticallyImplyLeading: false, // hilangkan hamburger
                  title: const Text("Daftar Produk"),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        box.erase();
                        Navigator.pushReplacementNamed(context, "/login");
                      },
                    ),
                  ],
                ),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return BlocListener<ListProductBloc, ListProductState>(
      listener: (context, state) {
        if (state is KonversiStokSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is KonversiStokFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Column(
        children: [
          // ✅ Header + Tombol Tambah (hanya untuk non-gudang)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (role != "pegawai gudang")
                  const Text(
                    "Daftar Produk",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                if (role != "pegawai gudang")
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result =
                          await Navigator.pushNamed(context, '/addProduct');
                      if (result == true) {
                        context.read<ListProductBloc>().add(FetchProducts());

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Produk berhasil ditambahkan"),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),

          // ✅ List Produk
          Expanded(child: ProductList(role: role)),
        ],
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  final String? role;
  const ProductList({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListProductBloc, ListProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductLoaded) {
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: state.products.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = state.products[index];
              final parentContext = context;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: product.gambarProduct != null
                      ? Image.memory(
                          base64Decode(product.gambarProduct!.split(",")[1]),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported, size: 40),
                  title: Text(
                    product.namaProduct,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.pushNamed(
                          context,
                          '/editProduct',
                          arguments: product.idProduct,
                        );
                      } else if (value == 'konversi') {
                        _showKonversiDialog(parentContext, product.idProduct);
                      }
                    },
                    itemBuilder: (context) {
                      if (role == "pegawai gudang") {
                        return const [
                          PopupMenuItem(
                            value: 'konversi',
                            child: Text('Konversi Stok'),
                          ),
                        ];
                      } else {
                        return const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'konversi',
                            child: Text('Konversi Stok'),
                          ),
                        ];
                      }
                    },
                  ),
                ),
              );
            },
          );
        } else if (state is ProductError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text("Tidak ada data"));
      },
    );
  }

  /// Dialog Konversi Stok
  Future<void> _showKonversiDialog(
      BuildContext parentContext, String productId) async {
    final satuanList = await ProductController.getSatuanByProductId(productId);

    String? dariSatuan;
    String? keSatuan;
    final jumlahDariController = TextEditingController();
    final jumlahKeController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konversi Stok"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Dari Satuan"),
                items: satuanList
                    .where((s) => s.jumlah > 0)
                    .map((s) => DropdownMenuItem(
                          value: s.satuan,
                          child: Text("${s.satuan} (stok: ${s.jumlah})"),
                        ))
                    .toList(),
                onChanged: (val) => dariSatuan = val,
              ),
              TextField(
                controller: jumlahDariController,
                decoration: const InputDecoration(labelText: "Jumlah Dari"),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Ke Satuan"),
                items: satuanList
                    .map((s) => DropdownMenuItem(
                          value: s.satuan,
                          child: Text("${s.satuan} (stok: ${s.jumlah})"),
                        ))
                    .toList(),
                onChanged: (val) => keSatuan = val,
              ),
              TextField(
                controller: jumlahKeController,
                decoration: const InputDecoration(labelText: "Jumlah Ke"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (dariSatuan == null ||
                    keSatuan == null ||
                    jumlahDariController.text.isEmpty ||
                    jumlahKeController.text.isEmpty) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text("Lengkapi semua field")),
                  );
                  return;
                }

                if (dariSatuan == keSatuan) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text("Satuan tidak boleh sama")),
                  );
                  return;
                }

                final konversi = KonversiStok(
                  idProduct: productId,
                  dariSatuan: dariSatuan!,
                  jumlahDari: int.parse(jumlahDariController.text),
                  keSatuan: keSatuan!,
                  jumlahKe: int.parse(jumlahKeController.text),
                );

                parentContext
                    .read<ListProductBloc>()
                    .add(KonversiStokEvent(konversi));

                Navigator.pop(context);
              },
              child: const Text("Konversi"),
            ),
          ],
        );
      },
    );
  }
}
