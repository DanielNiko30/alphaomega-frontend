import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/widget/sidebar.dart';
import 'package:intl/intl.dart';

import '../bloc/edit_transaksi_jual_bloc.dart';
import '../bloc/edit_transaksi_jual_event.dart';
import '../bloc/edit_transaksi_jual_state.dart';

class TransJualEditScreen extends StatefulWidget {
  final String transactionId;

  const TransJualEditScreen({required this.transactionId, super.key});

  @override
  State<TransJualEditScreen> createState() => _TransJualEditScreenState();
}

class _TransJualEditScreenState extends State<TransJualEditScreen> {
  DateTime? selectedDate;

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
                                    decoration: InputDecoration(
                                      hintText: "Cari...",
                                      prefixIcon: const Icon(Icons.search),
                                      border: const OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      context
                                          .read<TransJualEditBloc>()
                                          .add(SearchProductByNameEdit(value));
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: 3 / 4,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                      ),
                                      itemCount: state.products.length,
                                      itemBuilder: (context, index) {
                                        final product = state.products[index];
                                        return Card(
                                          child: InkWell(
                                            onTap: () {
                                              context
                                                  .read<TransJualEditBloc>()
                                                  .add(
                                                    AddProductEdit(
                                                      id: product['id'],
                                                      name: product['name'],
                                                      image: product['image'],
                                                      quantity: 1,
                                                      unit: 'pcs',
                                                      price: 0.0,
                                                      stok:
                                                          product['stok'] ?? 0,
                                                    ),
                                                  );
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: Image.network(
                                                    product['image'] ?? '',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    product['name'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ==== BAGIAN KANAN - Form & Selected Product ====
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              color: Colors.grey[100],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // === Row 1: Pegawai, Penjual, Tanggal ===
                                  Row(
                                    children: [
                                      // Pegawai
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: state.selectedUserId,
                                          decoration: const InputDecoration(
                                            labelText: 'Pilih Pegawai',
                                            border: OutlineInputBorder(),
                                          ),
                                          items: state.userList.map((user) {
                                            return DropdownMenuItem<String>(
                                              value: user['id'],
                                              child: Text(user['name']),
                                            );
                                          }).toList(),
                                          onChanged: (selectedId) {
                                            if (selectedId != null) {
                                              context
                                                  .read<TransJualEditBloc>()
                                                  .add(SelectUserEdit(
                                                      selectedId));
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Penjual
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: state.selectedUserPenjualId,
                                          decoration: const InputDecoration(
                                            labelText: 'Pilih Penjual',
                                            border: OutlineInputBorder(),
                                          ),
                                          items: state.userList.map((user) {
                                            return DropdownMenuItem<String>(
                                              value: user['id'],
                                              child: Text(user['name']),
                                            );
                                          }).toList(),
                                          onChanged: (selectedId) {
                                            if (selectedId != null) {
                                              context
                                                  .read<TransJualEditBloc>()
                                                  .add(SelectUserPenjualEdit(
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
                                          decoration: const InputDecoration(
                                            labelText: 'Tanggal',
                                            border: OutlineInputBorder(),
                                          ),
                                          controller: TextEditingController(
                                            text: selectedDate != null
                                                ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
                                                : "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                                          ),
                                          onTap: () async {
                                            final picked = await showDatePicker(
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
                                          decoration: const InputDecoration(
                                            labelText: 'Nama Pembeli',
                                            border: OutlineInputBorder(),
                                          ),
                                          controller: TextEditingController(
                                              text: state.namaPembeli),
                                          onChanged: (value) {
                                            context
                                                .read<TransJualEditBloc>()
                                                .add(UpdateNamaPembeliEdit(
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
                                          controller: TextEditingController(
                                              text: state.invoiceNumber ?? ''),
                                          decoration: const InputDecoration(
                                            labelText: 'Nomor Invoice',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Metode Pembayaran
                                      Expanded(
                                        flex: 1,
                                        child: DropdownButtonFormField<String>(
                                          value: state.paymentMethod,
                                          decoration: const InputDecoration(
                                            labelText: 'Metode Pembayaran',
                                            border: OutlineInputBorder(),
                                          ),
                                          items: ["Cash", "Debit", "Credit"]
                                              .map((method) => DropdownMenuItem(
                                                    value: method,
                                                    child: Text(method),
                                                  ))
                                              .toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              context
                                                  .read<TransJualEditBloc>()
                                                  .add(SelectPaymentMethodEdit(
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
                                      itemCount: state.selectedProducts.length,
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
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 4),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Gambar
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    item['image'] ?? '',
                                                    width: 56,
                                                    height: 56,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            size: 40),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),

                                                // Detail Produk
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item['name'] ?? '',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14),
                                                      ),
                                                      const SizedBox(height: 4),
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
                                                                fontSize: 13),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            "Stok: ${item['stok'] ?? '-'}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                                fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),

                                                      // Dropdown satuan + qty control
                                                      Row(
                                                        children: [
                                                          // Dropdown satuan
                                                          Container(
                                                            width: 90,
                                                            height: 38,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child:
                                                                DropdownButtonHideUnderline(
                                                              child:
                                                                  DropdownButton<
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
                                                                    color: Colors
                                                                        .black),
                                                                isExpanded:
                                                                    true,
                                                                dropdownColor:
                                                                    Colors
                                                                        .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .arrow_drop_down),
                                                                items: (item['unitListDetail'] !=
                                                                            null &&
                                                                        item['unitListDetail']
                                                                            is List)
                                                                    ? List<Map<String, dynamic>>.from(item[
                                                                            'unitListDetail'])
                                                                        .map(
                                                                            (satuanData) {
                                                                        final satuan =
                                                                            satuanData['satuan'];
                                                                        final stok =
                                                                            satuanData['stock'] ??
                                                                                0;
                                                                        final isHabis =
                                                                            stok ==
                                                                                0;

                                                                        return DropdownMenuItem<
                                                                            String>(
                                                                          value:
                                                                              satuan,
                                                                          enabled:
                                                                              !isHabis,
                                                                          child:
                                                                              Text(
                                                                            isHabis
                                                                                ? '$satuan (habis)'
                                                                                : satuan.toString(),
                                                                            style:
                                                                                TextStyle(
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
                                                                        (item['unitListDetail']
                                                                                as List)
                                                                            .firstWhere(
                                                                      (s) =>
                                                                          s['satuan'] ==
                                                                          selectedUnit,
                                                                      orElse:
                                                                          () =>
                                                                              {
                                                                        'stock':
                                                                            0
                                                                      },
                                                                    );

                                                                    final stok =
                                                                        selectedDetail['stock'] ??
                                                                            0;

                                                                    if (stok >
                                                                        0) {
                                                                      context
                                                                          .read<
                                                                              TransJualEditBloc>()
                                                                          .add(UpdateProductUnitEdit(
                                                                              item['id'],
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
                                                                context
                                                                    .read<
                                                                        TransJualEditBloc>()
                                                                    .add(UpdateProductQuantityEdit(
                                                                        item[
                                                                            'id'],
                                                                        item['quantity'] -
                                                                            1));
                                                              } else {
                                                                context
                                                                    .read<
                                                                        TransJualEditBloc>()
                                                                    .add(RemoveProductEdit(
                                                                        item[
                                                                            'id']));
                                                              }
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(6),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: const Color(
                                                                    0xFFD7C2F5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6),
                                                              ),
                                                              child: const Icon(
                                                                  Icons.remove,
                                                                  size: 16,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 6),

                                                          // Jumlah
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        6),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                            ),
                                                            child: Text(
                                                              item['quantity']
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 6),

                                                          // Tombol Tambah
                                                          InkWell(
                                                            onTap: item['quantity'] <
                                                                    item['stok']
                                                                ? () {
                                                                    context.read<TransJualEditBloc>().add(UpdateProductQuantityEdit(
                                                                        item[
                                                                            'id'],
                                                                        item['quantity'] +
                                                                            1));
                                                                  }
                                                                : null,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(6),
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
                                                                    BorderRadius
                                                                        .circular(
                                                                            6),
                                                              ),
                                                              child: const Icon(
                                                                  Icons.add,
                                                                  size: 16,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 12),

                                                          // Total Harga Per Item
                                                          Expanded(
                                                            child: Text(
                                                              currencyFormatter
                                                                  .format(item[
                                                                          'price'] *
                                                                      item[
                                                                          'quantity']),
                                                              textAlign:
                                                                  TextAlign.end,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Tombol Delete
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
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
                                          alignment: Alignment.centerRight,
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
                                        Navigator.pushReplacementNamed(context,
                                            '/transaksiPenjualanPending');
                                      } else if (state is TransJualEditError) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(state.message)),
                                        );
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        BlocBuilder<TransJualEditBloc,
                                            TransJualEditState>(
                                          builder: (context, state) {
                                            final isSubmitting =
                                                state is TransJualEditLoaded &&
                                                    state.isSubmitting;

                                            return ElevatedButton.icon(
                                              icon: isSubmitting
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const Icon(Icons.save,
                                                      size: 20),
                                              label: Text(isSubmitting
                                                  ? "Saving..."
                                                  : "Save"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 64,
                                                        vertical: 18),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                                        ElevatedButton.icon(
                                          icon:
                                              const Icon(Icons.print, size: 20),
                                          label: const Text("Print"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFE3D7FF),
                                            foregroundColor: Colors.black87,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 64, vertical: 18),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {
                                            // Aksi print akan ditambahkan nanti
                                          },
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
