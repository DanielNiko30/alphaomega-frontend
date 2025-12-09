import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/widget/sidebar.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../../../widget/print_preview.dart';
import '../bloc/edit_transaksi_jual_bloc.dart';
import '../bloc/edit_transaksi_jual_event.dart';
import '../bloc/edit_transaksi_jual_state.dart';
import 'package:printing/printing.dart';
import '../../../../../utils/print_invoice.dart';

class TransJualEditScreen extends StatefulWidget {
  final String transactionId;

  const TransJualEditScreen({required this.transactionId, super.key});

  @override
  State<TransJualEditScreen> createState() => _TransJualEditScreenState();
}

class _TransJualEditScreenState extends State<TransJualEditScreen> {
  DateTime? selectedDate;
  int currentPageProduct = 1;
  final int productPerPage = 20;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    Future.microtask(() {
      context
          .read<TransJualEditBloc>()
          .add(LoadTransactionForEdit(widget.transactionId));
    });
  }

  bool isPrintPreview = false;
  Uint8List? previewData;
  final box = GetStorage();
  late final role = box.read("role");

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 2,
    );

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: BlocBuilder<TransJualEditBloc, TransJualEditState>(
                  builder: (context, state) {
                    if (state is TransJualEditLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TransJualEditError) {
                      return Center(child: Text(state.message));
                    } else if (state is TransJualEditLoaded) {
                      final totalHarga = state.selectedProducts.fold<num>(
                        0,
                        (sum, item) => sum + (item['price'] * item['quantity']),
                      );

                      return Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 100, top: 25, bottom: 25),
                              child: Column(
                                children: [
                                  TextField(
                                    decoration: const InputDecoration(
                                      hintText: "Cari...",
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        currentPageProduct =
                                            1; // reset page ketika search
                                      });
                                      context
                                          .read<TransJualEditBloc>()
                                          .add(SearchProductByNameEdit(value));
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // =========================================================
                                  // 🔥 FILTER + PAGINATION
                                  // =========================================================
                                  Expanded(
                                    child: Builder(
                                      builder: (context) {
                                        // Produk hasil BLoC (sudah terfilter via SearchProductByNameEdit)
                                        final filteredProducts = state.products;

                                        // Hitung total halaman
                                        final totalPages =
                                            (filteredProducts.length /
                                                    productPerPage)
                                                .ceil();

                                        final safePage = totalPages == 0
                                            ? 1
                                            : (currentPageProduct > totalPages
                                                ? totalPages
                                                : currentPageProduct);

                                        // Hitung range item berdasarkan page
                                        final start =
                                            (safePage - 1) * productPerPage;
                                        final end = (start + productPerPage >
                                                filteredProducts.length)
                                            ? filteredProducts.length
                                            : start + productPerPage;

                                        final paginatedProducts =
                                            filteredProducts.sublist(
                                                start, end);

                                        return GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            childAspectRatio: 3 / 4,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                          ),
                                          itemCount: paginatedProducts.length,
                                          itemBuilder: (context, index) {
                                            final product =
                                                paginatedProducts[index];

                                            return Card(
                                              child: InkWell(
                                                onTap: () {
                                                  context
                                                      .read<TransJualEditBloc>()
                                                      .add(
                                                        AddProductEdit(
                                                          id: product['id'],
                                                          name: product['name'],
                                                          image:
                                                              product['image'],
                                                          quantity: 1,
                                                          unit: 'pcs',
                                                          price: 0.0,
                                                          stok:
                                                              product['stok'] ??
                                                                  0,
                                                        ),
                                                      );
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      child: buildProductImage(
                                                          product['image']),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        product['name'],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),

                                  // =========================================================
                                  // 🔥 PAGINATION BUTTONS
                                  // =========================================================
                                  Builder(builder: (context) {
                                    final totalPages =
                                        (state.products.length / productPerPage)
                                            .ceil();

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.chevron_left),
                                          onPressed: currentPageProduct > 1
                                              ? () {
                                                  setState(() {
                                                    currentPageProduct--;
                                                  });
                                                }
                                              : null,
                                        ),
                                        Text(
                                          "$currentPageProduct / ${totalPages == 0 ? 1 : totalPages}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.chevron_right),
                                          onPressed:
                                              currentPageProduct < totalPages
                                                  ? () {
                                                      setState(() {
                                                        currentPageProduct++;
                                                      });
                                                    }
                                                  : null,
                                        ),
                                      ],
                                    );
                                  }),

                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),

                          // ==== BAGIAN KANAN - Form & Selected Product ====
                          Expanded(
                            flex: 2,
                            child: isPrintPreview
                                ? Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        // 🧾 Tampilan struk dengan rasio kecil
                                        Expanded(
                                          child: Center(
                                            child: Container(
                                              width:
                                                  350, // biar proporsional kayak kertas roll 80mm
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Colors.black12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: previewData == null
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    )
                                                  : PdfPreview(
                                                      build: (format) async =>
                                                          previewData!,
                                                      allowPrinting: false,
                                                      allowSharing: false,
                                                      canChangePageFormat:
                                                          false,
                                                      canChangeOrientation:
                                                          false,
                                                      pdfFileName:
                                                          "invoice.pdf",
                                                      // 🔹 Hilangkan toolbar ungu:
                                                      scrollViewDecoration:
                                                          const BoxDecoration(
                                                              color:
                                                                  Colors.white),
                                                    ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        // 🔘 Tombol bawah
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () async {
                                                // 1. Update status dulu
                                                context
                                                    .read<TransJualEditBloc>()
                                                    .add(
                                                      UpdateStatusTransaksiEdit(
                                                          widget.transactionId),
                                                    );

                                                // 2. Print PDF
                                                await Printing.layoutPdf(
                                                  onLayout: (format) async =>
                                                      previewData!,
                                                );

                                                // 3. Setelah selesai print, kembali ke halaman pending
                                                if (context.mounted) {
                                                  Navigator
                                                      .pushNamedAndRemoveUntil(
                                                    context,
                                                    '/transaksiPenjualanPending',
                                                    (route) =>
                                                        false, // hapus semua halaman sebelumnya
                                                  );
                                                }
                                              },
                                              icon: const Icon(Icons.print,
                                                  size: 18),
                                              label:
                                                  const Text("Print Sekarang"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 32,
                                                        vertical: 14),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  isPrintPreview = false;
                                                });
                                              },
                                              icon: const Icon(Icons.arrow_back,
                                                  size: 18),
                                              label: const Text("Kembali"),
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 32,
                                                        vertical: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(16),
                                    color: Colors.grey[100],
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // === Row 1: Pegawai, Penjual, Tanggal ===
                                        Row(
                                          children: [
                                            // Pegawai
                                            Expanded(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                value: state.selectedUserId,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Pilih Pegawai',
                                                  border: OutlineInputBorder(),
                                                ),
                                                items:
                                                    state.userList.map((user) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: user['id'],
                                                    child: Text(user['name']),
                                                  );
                                                }).toList(),
                                                onChanged: (selectedId) {
                                                  if (selectedId != null) {
                                                    context
                                                        .read<
                                                            TransJualEditBloc>()
                                                        .add(SelectUserEdit(
                                                            selectedId));
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 16),

                                            // Penjual
                                            Expanded(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                value:
                                                    state.selectedUserPenjualId,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Pilih Penjual',
                                                  border: OutlineInputBorder(),
                                                ),
                                                items:
                                                    state.userList.map((user) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: user['id'],
                                                    child: Text(user['name']),
                                                  );
                                                }).toList(),
                                                onChanged: (selectedId) {
                                                  if (selectedId != null) {
                                                    context
                                                        .read<
                                                            TransJualEditBloc>()
                                                        .add(
                                                            SelectUserPenjualEdit(
                                                                selectedId));
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 16),

                                            // Tanggal
                                            Expanded(
                                              child: TextFormField(
                                                readOnly: true,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Tanggal',
                                                  border: OutlineInputBorder(),
                                                ),
                                                controller:
                                                    TextEditingController(
                                                  text: selectedDate != null
                                                      ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
                                                      : "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                                                ),
                                                onTap: () async {
                                                  final picked =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2020),
                                                    lastDate: DateTime(2100),
                                                  );
                                                  if (picked != null) {
                                                    setState(() {
                                                      selectedDate = picked;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        // === Row 2: Nama Pembeli, Invoice, Metode Pembayaran ===
                                        Row(
                                          children: [
                                            // Nama Pembeli
                                            Expanded(
                                              flex: 2,
                                              child: TextFormField(
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Nama Pembeli',
                                                  border: OutlineInputBorder(),
                                                ),
                                                controller:
                                                    TextEditingController(
                                                        text:
                                                            state.namaPembeli),
                                                onChanged: (value) {
                                                  context
                                                      .read<TransJualEditBloc>()
                                                      .add(
                                                          UpdateNamaPembeliEdit(
                                                              value));
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 16),

                                            // Nomor Invoice
                                            Expanded(
                                              flex: 2,
                                              child: TextFormField(
                                                readOnly: true,
                                                controller:
                                                    TextEditingController(
                                                        text: state
                                                                .invoiceNumber ??
                                                            ''),
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Nomor Invoice',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),

                                            // Metode Pembayaran
                                            Expanded(
                                              flex: 1,
                                              child: DropdownButtonFormField<
                                                  String>(
                                                value: state.paymentMethod,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText:
                                                      'Metode Pembayaran',
                                                  border: OutlineInputBorder(),
                                                ),
                                                items: [
                                                  "Cash",
                                                  "Debit",
                                                  "Credit"
                                                ]
                                                    .map((method) =>
                                                        DropdownMenuItem(
                                                          value: method,
                                                          child: Text(method),
                                                        ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    context
                                                        .read<
                                                            TransJualEditBloc>()
                                                        .add(
                                                            SelectPaymentMethodEdit(
                                                                value));
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        // ==== Selected Products ====
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount:
                                                state.selectedProducts.length,
                                            itemBuilder: (context, index) {
                                              final item =
                                                  state.selectedProducts[index];
                                              return Card(
                                                key: ValueKey(
                                                    '${item['id']}_${item['unit']}'),
                                                color: const Color(0xFFF9F8FF),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6,
                                                        horizontal: 4),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Gambar
                                                      ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          child:
                                                              buildProductImage(
                                                                  item[
                                                                      'image'])),
                                                      const SizedBox(width: 12),

                                                      // Detail Produk
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              item['name'] ??
                                                                  '',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14),
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  currencyFormatter
                                                                      .format(item[
                                                                          'price']),
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          13),
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Text(
                                                                  "Stok: ${item['stok'] ?? '-'}",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          600],
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 8),

                                                            // Dropdown satuan + qty control
                                                            Row(
                                                              children: [
                                                                // Dropdown satuan
                                                                Container(
                                                                  width: 90,
                                                                  height: 38,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child:
                                                                      DropdownButtonHideUnderline(
                                                                    child: DropdownButton<
                                                                        String>(
                                                                      value: item[
                                                                          'unit'],
                                                                      hint:
                                                                          const Text(
                                                                        "Satuan",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                13),
                                                                      ),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.black),
                                                                      isExpanded:
                                                                          true,
                                                                      dropdownColor:
                                                                          Colors
                                                                              .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .arrow_drop_down),
                                                                      items: (item['unitListDetail'] != null &&
                                                                              item['unitListDetail']
                                                                                  is List)
                                                                          ? List<Map<String, dynamic>>.from(item['unitListDetail'])
                                                                              .map((satuanData) {
                                                                              final satuan = satuanData['satuan'];
                                                                              final stok = satuanData['stock'] ?? 0;
                                                                              final isHabis = stok == 0;

                                                                              return DropdownMenuItem<String>(
                                                                                value: satuan,
                                                                                enabled: !isHabis,
                                                                                child: Text(
                                                                                  isHabis ? '$satuan (habis)' : satuan.toString(),
                                                                                  style: TextStyle(
                                                                                    fontSize: 13,
                                                                                    color: isHabis ? Colors.grey : Colors.black,
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            }).toList()
                                                                          : [],
                                                                      onChanged:
                                                                          (selectedUnit) {
                                                                        if (selectedUnit !=
                                                                            null) {
                                                                          final selectedDetail =
                                                                              (item['unitListDetail'] as List).firstWhere(
                                                                            (s) =>
                                                                                s['satuan'] ==
                                                                                selectedUnit,
                                                                            orElse: () =>
                                                                                {
                                                                              'stock': 0
                                                                            },
                                                                          );

                                                                          final stok =
                                                                              selectedDetail['stock'] ?? 0;

                                                                          if (stok >
                                                                              0) {
                                                                            context.read<TransJualEditBloc>().add(UpdateProductUnitEdit(item['id'],
                                                                                selectedUnit));
                                                                          }
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),

                                                                // Tombol Kurang
                                                                InkWell(
                                                                  onTap: () {
                                                                    if (item[
                                                                            'quantity'] >
                                                                        1) {
                                                                      context.read<TransJualEditBloc>().add(UpdateProductQuantityEdit(
                                                                          item[
                                                                              'id'],
                                                                          item['quantity'] -
                                                                              1));
                                                                    } else {
                                                                      context
                                                                          .read<
                                                                              TransJualEditBloc>()
                                                                          .add(RemoveProductEdit(
                                                                              item['id']));
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            6),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: const Color(
                                                                          0xFFD7C2F5),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6),
                                                                    ),
                                                                    child: const Icon(
                                                                        Icons
                                                                            .remove,
                                                                        size:
                                                                            16,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 6),

                                                                // Jumlah
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          6),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(6),
                                                                  ),
                                                                  child: Text(
                                                                    item['quantity']
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 6),

                                                                // Tombol Tambah
                                                                InkWell(
                                                                  onTap: item['quantity'] <
                                                                          item[
                                                                              'stok']
                                                                      ? () {
                                                                          context.read<TransJualEditBloc>().add(UpdateProductQuantityEdit(
                                                                              item['id'],
                                                                              item['quantity'] + 1));
                                                                        }
                                                                      : null,
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            6),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: item['quantity'] <
                                                                              item[
                                                                                  'stok']
                                                                          ? const Color(
                                                                              0xFFD7C2F5)
                                                                          : Colors
                                                                              .grey
                                                                              .shade300,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6),
                                                                    ),
                                                                    child: const Icon(
                                                                        Icons
                                                                            .add,
                                                                        size:
                                                                            16,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 12),

                                                                // Total Harga Per Item
                                                                Expanded(
                                                                  child: Text(
                                                                    currencyFormatter.format(item[
                                                                            'price'] *
                                                                        item[
                                                                            'quantity']),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      // Tombol Delete
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red),
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  TransJualEditBloc>()
                                                              .add(RemoveProductEdit(
                                                                  item['id']));
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        // === Total Harga & Tombol ===
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  "Total: ${currencyFormatter.format(totalHarga)}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.purple,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        BlocListener<TransJualEditBloc,
                                            TransJualEditState>(
                                          listener: (context, state) {
                                            if (state is TransJualEditSuccess) {
                                              Navigator.pushReplacementNamed(
                                                  context,
                                                  '/transaksiPenjualanPending');
                                            } else if (state
                                                is TransJualEditError) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text(state.message)),
                                              );
                                            }
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  // 🔹 Tombol Save
                                                  BlocBuilder<TransJualEditBloc,
                                                      TransJualEditState>(
                                                    builder: (context, state) {
                                                      final isSubmitting = state
                                                              is TransJualEditLoaded &&
                                                          state.isSubmitting;

                                                      return ElevatedButton
                                                          .icon(
                                                        icon: isSubmitting
                                                            ? const SizedBox(
                                                                width: 16,
                                                                height: 16,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )
                                                            : const Icon(
                                                                Icons.save,
                                                                size: 20),
                                                        label: Text(isSubmitting
                                                            ? "Saving..."
                                                            : "Save"),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.green,
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      64,
                                                                  vertical: 18),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        onPressed: isSubmitting
                                                            ? null
                                                            : () {
                                                                context
                                                                    .read<
                                                                        TransJualEditBloc>()
                                                                    .add(
                                                                        SubmitEditTransaction());
                                                              },
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 12),

                                                  // 🔹 Tombol Print
                                                  if (role == "admin")
                                                    ElevatedButton.icon(
                                                      icon: const Icon(
                                                          Icons.print,
                                                          size: 20),
                                                      label:
                                                          const Text("Print"),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Color(0xFFE3D7FF),
                                                        foregroundColor:
                                                            Colors.black87,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 64,
                                                                vertical: 18),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        final stateBloc = context
                                                            .read<
                                                                TransJualEditBloc>()
                                                            .state;
                                                        if (stateBloc
                                                            is! TransJualEditLoaded)
                                                          return;

                                                        String getUserName(
                                                            String? id) {
                                                          try {
                                                            final user =
                                                                stateBloc
                                                                    .userList
                                                                    .firstWhere(
                                                              (u) =>
                                                                  u['id'] == id,
                                                              orElse: () =>
                                                                  <String,
                                                                      dynamic>{
                                                                'name': '-'
                                                              },
                                                            );
                                                            return (user[
                                                                    'name'] ??
                                                                '-') as String;
                                                          } catch (_) {
                                                            return '-';
                                                          }
                                                        }

                                                        final data =
                                                            await buildInvoicePdf(
                                                          invoiceNumber: stateBloc
                                                                  .invoiceNumber ??
                                                              '-',
                                                          tanggal: selectedDate !=
                                                                  null
                                                              ? "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"
                                                              : DateTime.now()
                                                                  .toString(),
                                                          namaPegawai: getUserName(
                                                              stateBloc
                                                                  .selectedUserId),
                                                          namaPenjual: getUserName(
                                                              stateBloc
                                                                  .selectedUserPenjualId),
                                                          namaPembeli: stateBloc
                                                                  .namaPembeli ??
                                                              '-',
                                                          metodePembayaran:
                                                              stateBloc
                                                                      .paymentMethod ??
                                                                  '-',
                                                          items: stateBloc
                                                              .selectedProducts
                                                              .map((p) => {
                                                                    'name': p[
                                                                        'name'],
                                                                    'qty': p[
                                                                        'quantity'],
                                                                    'price': p[
                                                                        'price'],
                                                                    'subtotal':
                                                                        (p['price'] *
                                                                            p['quantity']),
                                                                  })
                                                              .toList(),
                                                          subtotal: stateBloc
                                                              .selectedProducts
                                                              .fold<num>(
                                                                0,
                                                                (sum, item) =>
                                                                    sum +
                                                                    (item['price'] *
                                                                        item[
                                                                            'quantity']),
                                                              )
                                                              .toString(),
                                                        );

                                                        setState(() {
                                                          previewData = data;
                                                          isPrintPreview = true;
                                                        });
                                                      },
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
          const Sidebar()
        ],
      ),
    );
  }
}

final Map<String, Uint8List> _imageCache = {};

Widget buildProductImage(String? imageData) {
  if (imageData == null || imageData.isEmpty) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[300],
      child:
          const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
    );
  }

  Widget imageWidget;

  if (imageData.startsWith('http')) {
    imageWidget = Image.network(
      imageData,
      fit: BoxFit.cover,
      width: 100,
      height: 100,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  } else {
    try {
      Uint8List? bytes = _imageCache[imageData];
      if (bytes == null) {
        final base64String =
            imageData.contains(',') ? imageData.split(',').last : imageData;
        bytes = base64Decode(base64String);
        _imageCache[imageData] = bytes;
      }

      imageWidget = Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } catch (e) {
      debugPrint('⚠️ Error parsing image: $e');
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
      );
    }
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 100,
      height: 100,
      color: Colors.grey[200],
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: imageWidget,
      ),
    ),
  );
}
