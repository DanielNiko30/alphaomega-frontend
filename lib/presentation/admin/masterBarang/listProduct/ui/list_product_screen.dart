import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../../controller/admin/product_controller.dart';
import '../../../../../model/product/konversi_stok.dart';
import '../../../../../model/product/product_with_stok_model.dart';
import '../bloc/list_product_bloc.dart';
import '../bloc/list_product_event.dart';
import '../bloc/list_product_state.dart';
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
  String _searchQuery = "";
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    role = box.read("role");
    // 🔥 Load produk + stok
    context.read<ListProductBloc>().add(FetchProductsWithStok());
  }

  void _onNavbarTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, "/listPesanan");
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, "/masterBarang");
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700; // threshold mobile

    final isGudang = role == "pegawai gudang";

    // Mobile / Pegawai Gudang: tampil fullscreen tanpa sidebar
    if (isMobile || isGudang) {
      return Scaffold(
        appBar: AppBar(
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
          currentIndex: _selectedIndex,
          onTap: _onNavbarTap,
        ),
      );
    }

    // Desktop: overlay sidebar
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Konten utama dengan margin kiri supaya tidak tertutup sidebar
          Padding(
            padding: const EdgeInsets.only(
                left: 100, top: 48, right: 24, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Daftar Produk",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result =
                            await Navigator.pushNamed(context, '/addProduct');
                        if (result == true) {
                          context
                              .read<ListProductBloc>()
                              .add(FetchProductsWithStok());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Produk berhasil ditambahkan"),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Tambah Produk"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Cari produk berdasarkan nama...",
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase());
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Grid produk
                Expanded(
                    child: ProductGrid(searchQuery: _searchQuery, role: role)),
              ],
            ),
          ),

          // Sidebar overlay
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Sidebar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return BlocListener<ListProductBloc, ListProductState>(
      listener: (context, state) {
        if (state is KonversiStokSuccess) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is KonversiStokFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: ProductGrid(searchQuery: _searchQuery, role: role),
    );
  }
}

// ================== PRODUCT GRID ==================
class ProductGrid extends StatelessWidget {
  final String searchQuery;
  final String? role;

  const ProductGrid({super.key, required this.searchQuery, required this.role});

  @override
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListProductBloc, ListProductState>(
      builder: (context, state) {
        // === Saat loading, tampilkan spinner ===
        if (state is ProductInitial ||
            state is ProductLoading ||
            state is KonversiStokLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // === Saat data produk dengan stok berhasil dimuat ===
        else if (state is ProductWithStokLoaded) {
          final filtered = state.products
              .where((p) =>
                  p.namaProduct.toLowerCase().contains(searchQuery) ||
                  p.productKategori.toLowerCase().contains(searchQuery))
              .toList();

          // Jika hasil pencarian kosong
          if (filtered.isEmpty) {
            return const Center(
              child: Text(
                "Produk tidak ditemukan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          // Responsif berdasarkan lebar layar
          final screenWidth = MediaQuery.of(context).size.width;
          int crossAxisCount = 6;
          if (screenWidth < 1600) crossAxisCount = 5;
          if (screenWidth < 1300) crossAxisCount = 4;
          if (screenWidth < 900) crossAxisCount = 3;
          if (screenWidth < 600) crossAxisCount = 2;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.8,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final product = filtered[index];
              return _buildProductCard(context, product);
            },
          );
        }

        // === Saat error ===
        else if (state is ProductError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          );
        }

        // === Default (misalnya belum fetch) ===
        else {
          return const Center(
            child:
                CircularProgressIndicator(), // biar ga langsung “tidak ada data”
          );
        }
      },
    );
  }

  Widget _buildProductCard(BuildContext context, ProductWithStok product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    // Minimal tinggi card desktop supaya 2 stok terlihat
    final double minHeightDesktop = 240;

    return Container(
      constraints: BoxConstraints(
        minHeight: isMobile ? 0 : minHeightDesktop,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // === Gambar Produk ===
          AspectRatio(
            aspectRatio: 1.2, // lebih tinggi → foto lebih besar
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                    child: (product.gambarProduct != null &&
                            product.gambarProduct!.isNotEmpty)
                        ? Image.memory(
                            base64Decode(
                              product.gambarProduct!.contains(',')
                                  ? product.gambarProduct!.split(',').last
                                  : product.gambarProduct!,
                            ),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('❌ Gagal decode gambar: $error');
                              return const Icon(Icons.broken_image,
                                  size: 48, color: Colors.grey);
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_outlined,
                                size: 48, color: Colors.grey),
                          ),
                  ),
                ),
                if (!isMobile)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            size: 18, color: Colors.white),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: Colors.grey.shade200, width: 0.5),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.pushNamed(context, '/editProduct',
                                arguments: product.idProduct);
                          } else if (value == 'konversi') {
                            _showKonversiDialog(context, product.idProduct);
                          }
                        },
                        itemBuilder: (context) {
                          if (role == "pegawai gudang") {
                            return [
                              PopupMenuItem(
                                value: 'konversi',
                                child: Row(
                                  children: const [
                                    Icon(Icons.swap_horiz,
                                        size: 18, color: Colors.black87),
                                    SizedBox(width: 8),
                                    Text('Konversi Stok',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ];
                          } else {
                            return [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: const [
                                    Icon(Icons.edit,
                                        size: 18, color: Colors.black87),
                                    SizedBox(width: 8),
                                    Text('Edit',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'konversi',
                                child: Row(
                                  children: const [
                                    Icon(Icons.swap_horiz,
                                        size: 18, color: Colors.black87),
                                    SizedBox(width: 8),
                                    Text('Konversi Stok',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ];
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // === Nama Produk ===
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
            child: Text(
              product.namaProduct,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black87),
            ),
          ),

          // === Desktop stok ===
          if (!isMobile) ...[
            const Divider(height: 6, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
                      flex: 3,
                      child: Text("Satuan",
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600))),
                  Expanded(
                      flex: 2,
                      child: Text("Stok",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600))),
                  Expanded(
                      flex: 4,
                      child: Text("Harga",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600))),
                ],
              ),
            ),

            // Scrollable stok list
            // Scrollable stok list
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 40, // minimal 2 stok terlihat
                  maxHeight: 120, // maksimal tinggi scrollable
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    physics: const ClampingScrollPhysics(),
                    itemCount: product.stokList.length,
                    itemBuilder: (context, i) {
                      final s = product.stokList[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 3,
                                child: Text(s.satuan,
                                    style: const TextStyle(fontSize: 11))),
                            Expanded(
                                flex: 2,
                                child: Text("${s.stok}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 11))),
                            Expanded(
                              flex: 4,
                              child: Text(
                                "Rp ${s.harga.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}",
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

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
          content: SingleChildScrollView(
            child: Column(
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
