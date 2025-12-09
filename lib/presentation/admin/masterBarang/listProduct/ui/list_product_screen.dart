import 'dart:convert';
import 'dart:typed_data';
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
import '../../../../../widget/navbar_pegawai_gudang.dart';

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});

  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  int currentPage = 1;
  final box = GetStorage();
  late String? role;
  String _searchQuery = "";
  String? _selectedKategori; // 🔥 kategori terpilih
  List<String> _kategoriList = [
    "Semua Kategori"
  ]; // 🔥 daftar kategori dropdown
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    role = box.read("role");

    // 🔥 Ambil data produk dan kategori
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    context.read<ListProductBloc>().add(FetchProductsWithStok());

    // ambil daftar kategori dari produk
    final products = await ProductController.getAllProductsWithStok();
    final kategoriSet = <String>{"Semua Kategori"};
    for (var p in products) {
      kategoriSet.add(p.productKategori);
    }

    setState(() {
      _kategoriList = kategoriSet.toList();
    });
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    final isGudang = role == "pegawai gudang";

    // === Mobile layout ===
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

    // === Desktop layout ===
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 100, top: 48, right: 24, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header + Tambah Produk
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Daftar Produk",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
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
                          _loadInitialData(); // refresh kategori
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

                // 🔍 Search + Filter Row
                Row(
                  children: [
                    // 🔹 Search Bar
                    Expanded(
                      flex: 2,
                      child: Container(
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
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                                currentPage = 1; // RESET PAGE
                              });
                            }),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // 🔹 Dropdown Filter Kategori
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                              value: _selectedKategori ?? _kategoriList.first,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: _kategoriList.map((kategori) {
                                return DropdownMenuItem<String>(
                                  value: kategori,
                                  child: Text(
                                    kategori,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedKategori = val!;
                                  currentPage = 1;
                                });
                              }),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 Product Grid
                Expanded(
                    child: Expanded(
                  child: ProductGrid(
                    searchQuery: _searchQuery,
                    role: role,
                    selectedKategori: _selectedKategori,
                    currentPage: currentPage,
                    onPageChange: (page) {
                      setState(() {
                        currentPage = page;
                      });
                    },
                  ),
                )),
              ],
            ),
          ),

          // Sidebar
          const Positioned(left: 0, top: 0, bottom: 0, child: Sidebar()),
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
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // 🔍 Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
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
                  // update state pencarian
                  setState(() => _searchQuery = value.toLowerCase());
                },
              ),
            ),

            const SizedBox(height: 12),

            // 🔽 Dropdown Kategori
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedKategori ?? _kategoriList.first,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _kategoriList.map((kategori) {
                    return DropdownMenuItem<String>(
                      value: kategori,
                      child: Text(
                        kategori,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedKategori = val!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 Daftar Produk
            Expanded(
              child: Expanded(
                child: ProductGrid(
                  searchQuery: _searchQuery,
                  role: role,
                  selectedKategori: _selectedKategori,
                  currentPage: currentPage,
                  onPageChange: (page) {
                    setState(() {
                      currentPage = page;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== PRODUCT GRID ==================
class ProductGrid extends StatelessWidget {
  final String searchQuery;
  final String? role;
  final String? selectedKategori;
  final int currentPage;
  final Function(int) onPageChange;

  const ProductGrid({
    super.key,
    required this.searchQuery,
    required this.role,
    required this.selectedKategori,
    required this.currentPage,
    required this.onPageChange,
  });

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
          // pastikan list tidak null
          final products = state.products ?? [];

          // 🔥 Filter by search + kategori (null-safe)
          final filtered = products.where((p) {
            final nama = (p.namaProduct ?? '').toString().toLowerCase();
            final kategori = (p.productKategori ?? '').toString();

            final matchSearch = nama.contains(searchQuery.toLowerCase());
            final matchKategori = (selectedKategori == null ||
                selectedKategori == "Semua Kategori" ||
                kategori == selectedKategori);

            return matchSearch && matchKategori;
          }).toList();

          final totalItems = filtered.length;
          final totalPages = (totalItems / 20).ceil();

          final start = (currentPage - 1) * 20;
          final end = start + 20;

          final paginated = filtered.sublist(
            start,
            end > totalItems ? totalItems : end,
          );

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

          return Column(
            children: [
              // === GRID VIEW ===
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: paginated.length,
                  itemBuilder: (context, index) {
                    final product = paginated[index];
                    return _buildProductCard(context, product);
                  },
                ),
              ),

              // === PAGINATION BAR ===
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // PREV BUTTON
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: currentPage > 1
                            ? () => onPageChange(currentPage - 1)
                            : null,
                      ),

                      // Numbered pages
                      for (int i = 1; i <= totalPages; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ElevatedButton(
                            onPressed: () => onPageChange(i),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (i == currentPage)
                                  ? Colors.blue
                                  : Colors.grey[300],
                              minimumSize: const Size(40, 40),
                            ),
                            child: Text(
                              "$i",
                              style: TextStyle(
                                color: (i == currentPage)
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),

                      // NEXT BUTTON
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: currentPage < totalPages
                            ? () => onPageChange(currentPage + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          );
        }

        // === Saat error ===
        else if (state is ProductError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        // === Default (misalnya belum fetch) ===
        else {
          return const Center(
            child: CircularProgressIndicator(),
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
                    child: buildProductImage(
                      product.gambarProduct,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
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
                        side:
                            BorderSide(color: Colors.grey.shade200, width: 0.5),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.pushNamed(context, '/editProduct',
                              arguments: product.idProduct);
                        } else if (value == 'konversi') {
                          _showKonversiDialog(context, product.idProduct);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, product.idProduct);
                        }
                      },
                      itemBuilder: (context) {
                        // Jika pegawai gudang → hanya Konversi
                        if (role == "pegawai gudang") {
                          return [
                            const PopupMenuItem(
                              value: 'konversi',
                              child: Row(
                                children: [
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
                          // Jika admin / pemilik → Edit + Konversi
                          return [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit,
                                      size: 18, color: Colors.black87),
                                  SizedBox(width: 8),
                                  Text('Edit',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'konversi',
                              child: Row(
                                children: [
                                  Icon(Icons.swap_horiz,
                                      size: 18, color: Colors.black87),
                                  SizedBox(width: 8),
                                  Text('Konversi Stok',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      color: Colors.red, size: 18),
                                  SizedBox(width: 8),
                                  Text("Nonaktifkan Produk",
                                      style: TextStyle(color: Colors.red)),
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
        final isMobile = MediaQuery.of(context).size.width < 600;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 120, vertical: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TITLE
                  const Text(
                    "Konversi Stok",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CARD FORM
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.grey.shade100,
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration("Dari Satuan"),
                          items: satuanList
                              .where((s) => s.jumlah > 0)
                              .map((s) => DropdownMenuItem(
                                    value: s.satuan,
                                    child:
                                        Text("${s.satuan} (stok: ${s.jumlah})"),
                                  ))
                              .toList(),
                          onChanged: (val) => dariSatuan = val,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: jumlahDariController,
                          decoration: _inputDecoration("Jumlah Dari"),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration("Ke Satuan"),
                          items: satuanList
                              .map((s) => DropdownMenuItem(
                                    value: s.satuan,
                                    child:
                                        Text("${s.satuan} (stok: ${s.jumlah})"),
                                  ))
                              .toList(),
                          onChanged: (val) => keSatuan = val,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: jumlahKeController,
                          decoration: _inputDecoration("Jumlah Ke"),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Batal",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          if (dariSatuan == null ||
                              keSatuan == null ||
                              jumlahDariController.text.isEmpty ||
                              jumlahKeController.text.isEmpty) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                  content: Text("Lengkapi semua field")),
                            );
                            return;
                          }

                          if (dariSatuan == keSatuan) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                  content: Text("Satuan tidak boleh sama")),
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
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// 🔧 Reusable input decoration mewah & rapi
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }
}

final Map<String, Uint8List> _imageCache = {};

Widget buildProductImage(String? imageData,
    {BoxFit fit = BoxFit.cover, double? width, double? height}) {
  if (imageData == null || imageData.isEmpty) {
    return Container(
      color: Colors.grey[300],
      width: width,
      height: height,
      child:
          const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
    );
  }

  Uint8List? bytes;

  if (imageData.startsWith('http')) {
    // Network image (opsional pakai CachedNetworkImage)
    return Image.network(
      imageData,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, size: 48, color: Colors.grey),
    );
  } else {
    try {
      // Base64 decode + cache
      bytes = _imageCache[imageData];
      if (bytes == null) {
        final base64String =
            imageData.contains(',') ? imageData.split(',').last : imageData;
        bytes = base64Decode(base64String);
        _imageCache[imageData] = bytes;
      }

      return Image.memory(
        bytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 48, color: Colors.grey),
      );
    } catch (e) {
      debugPrint('⚠️ Error parsing image: $e');
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
      );
    }
  }
}

void _showDeleteConfirmation(BuildContext context, String productId) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Nonaktifkan Produk"),
      content: const Text("Apakah Anda yakin ingin menonaktifkan produk ini?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.of(ctx).pop();

            final success = await ProductController.deleteProduct(productId);

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Produk berhasil dinonaktifkan")),
              );

              // Refresh List Product
              context.read<ListProductBloc>().add(FetchProductsWithStok());
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Gagal menonaktifkan produk")),
              );
            }
          },
          child: const Text("Ya, Nonaktifkan"),
        ),
      ],
    ),
  );
}
