import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/widget/sidebar.dart';
import 'package:intl/intl.dart';
import '../../../../widget/print_preview.dart';
import '../bloc/transaksi_jual_bloc.dart';
import '../bloc/transaksi_jual_event.dart';
import '../bloc/transaksi_jual_state.dart';

class TransJualScreen extends StatefulWidget {
  @override
  _TransJualScreenState createState() => _TransJualScreenState();
}

class _TransJualScreenState extends State<TransJualScreen> {
  @override
  DateTime? selectedDate;
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    Future.microtask(() {
      context.read<TransJualBloc>().add(InitializeTransJual());
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 2,
    );

    Future<void> _pickDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );

      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
        });
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: BlocBuilder<TransJualBloc, TransJualState>(
                  builder: (context, state) {
                    if (state is TransJualLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is TransJualLoaded) {
                      final totalHarga = state.selectedProducts.fold<num>(
                        0,
                        (sum, item) => sum + (item['price'] * item['quantity']),
                      );

                      return Row(
                        children: [
                          // Kiri - List Produk
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
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      context
                                          .read<TransJualBloc>()
                                          .add(SearchProductByNameJual(value));
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
                                                  .read<TransJualBloc>()
                                                  .add(AddProduct(
                                                    id: product['id'],
                                                    name: product['name'],
                                                    image: product['image'],
                                                    quantity: 1,
                                                    unit: 'pcs',
                                                    price: 0.0,
                                                    stok: product['stok'] ?? 0,
                                                    rowId: '',
                                                  ));
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: Image.network(
                                                      product['image'] ?? '',
                                                      fit: BoxFit.cover),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Text(product['name'],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          textAlign:
                                                              TextAlign.center),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),

                          // Kanan - Nota dan Pembayaran
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              color: Colors.grey[100],
                              child: state.isPrintPreview
                                  ? PrintPreview(
                                      transaksi: state,
                                      onConfirm: () => context
                                          .read<TransJualBloc>()
                                          .add(CetakNota()),
                                      onCancel: () => context
                                          .read<TransJualBloc>()
                                          .add(TogglePrintPreview()),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        const SizedBox(height: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                // Dropdown User (Pembeli)
                                                Expanded(
                                                  child:
                                                      DropdownButtonFormField<
                                                          String>(
                                                    value: state.selectedUserId,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          'Pilih Pegawai',
                                                      border:
                                                          OutlineInputBorder(),
                                                      errorText: state
                                                          .formErrors?['user'],
                                                    ),
                                                    isExpanded: true,
                                                    items: state.penjualList
                                                        .map((user) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: user['id'],
                                                        child:
                                                            Text(user['name']),
                                                      );
                                                    }).toList(),
                                                    onChanged: (selectedId) {
                                                      if (selectedId != null) {
                                                        context
                                                            .read<
                                                                TransJualBloc>()
                                                            .add(SelectUser(
                                                                selectedId));
                                                      }
                                                    },
                                                  ),
                                                ),

                                                SizedBox(width: 16),

                                                // Dropdown Penjual
                                                Expanded(
                                                  child:
                                                      DropdownButtonFormField<
                                                          String>(
                                                    value: state
                                                        .selectedUserPenjualId,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          'Pilih Penjual',
                                                      border:
                                                          OutlineInputBorder(),
                                                      errorText:
                                                          state.formErrors?[
                                                              'penjual'],
                                                    ),
                                                    isExpanded: true,
                                                    items: state
                                                        .pegawaiGudangList
                                                        .map((user) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: user['id'],
                                                        child:
                                                            Text(user['name']),
                                                      );
                                                    }).toList(),
                                                    onChanged: (selectedId) {
                                                      if (selectedId != null) {
                                                        context
                                                            .read<
                                                                TransJualBloc>()
                                                            .add(SelectUserPenjual(
                                                                selectedId));
                                                      }
                                                    },
                                                  ),
                                                ),

                                                SizedBox(width: 16),

                                                // Date Picker
                                                Expanded(
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    decoration: InputDecoration(
                                                      labelText: 'Tanggal',
                                                      border:
                                                          OutlineInputBorder(),
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
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime(2020),
                                                        lastDate:
                                                            DateTime(2100),
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
                                            SizedBox(height: 12),
                                            Row(
                                              children: [
                                                // Nama Pembeli
                                                Expanded(
                                                  flex: 2,
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      labelText: 'Nama Pembeli',
                                                      border:
                                                          OutlineInputBorder(),
                                                      errorText:
                                                          state.formErrors?[
                                                              'namaPembeli'],
                                                    ),
                                                    onChanged: (value) {
                                                      context
                                                          .read<TransJualBloc>()
                                                          .add(
                                                              UpdateNamaPembeli(
                                                                  value));
                                                    },
                                                  ),
                                                ),

                                                SizedBox(width: 16),

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
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          'Nomor Invoice',
                                                      border:
                                                          OutlineInputBorder(),
                                                      errorText:
                                                          state.formErrors?[
                                                              'invoice'],
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(width: 16),

                                                // Metode Pembayaran (dibuat lebih kecil)
                                                Expanded(
                                                  flex: 1,
                                                  child:
                                                      DropdownButtonFormField<
                                                          String>(
                                                    value: state.paymentMethod,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          'Metode Pembayaran',
                                                      border:
                                                          OutlineInputBorder(),
                                                      errorText:
                                                          state.formErrors?[
                                                              'payment'],
                                                    ),
                                                    isExpanded: true,
                                                    items: [
                                                      "Cash",
                                                      "Debit",
                                                      "Credit"
                                                    ]
                                                        .map((method) =>
                                                            DropdownMenuItem(
                                                              value: method,
                                                              child:
                                                                  Text(method),
                                                            ))
                                                        .toList(),
                                                    onChanged: (value) {
                                                      if (value != null) {
                                                        context
                                                            .read<
                                                                TransJualBloc>()
                                                            .add(
                                                                SelectPaymentMethod(
                                                                    value));
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
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
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
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
                                                            Row(
                                                              children: [
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
                                                                      value: (item['unit'] != null &&
                                                                              (item['unitListDetail'] as List).any((s) => s['satuan'] == item['unit']))
                                                                          ? item['unit'] // kalau unit ada dan valid
                                                                          : null, // kalau tidak, biarkan null supaya pakai hint
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
                                                                              item['unitListDetail'] is List)
                                                                          ? List<Map<String, dynamic>>.from(item['unitListDetail'])
                                                                              .map((satuanData) => satuanData['satuan'])
                                                                              .toSet() // hapus duplikat satuan
                                                                              .map((satuan) {
                                                                              final stok = (item['unitListDetail'] as List).firstWhere(
                                                                                    (s) => s['satuan'] == satuan,
                                                                                    orElse: () => {
                                                                                      'stock': 0
                                                                                    },
                                                                                  )['stock'] ??
                                                                                  0;
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
                                                                            context.read<TransJualBloc>().add(UpdateProductUnit(
                                                                                  item['rowId'],
                                                                                  selectedUnit,
                                                                                ));
                                                                          }
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),

                                                                const SizedBox(
                                                                    width: 8),

                                                                // ➖ Tombol kurang
                                                                // ➖ Tombol kurang
                                                                InkWell(
                                                                  onTap: () {
                                                                    double
                                                                        currentQty =
                                                                        (item['quantity']
                                                                                as num)
                                                                            .toDouble();
                                                                    if (currentQty >
                                                                        1) {
                                                                      // minimal 1
                                                                      context
                                                                          .read<
                                                                              TransJualBloc>()
                                                                          .add(
                                                                            UpdateProductQuantity(item['rowId'],
                                                                                currentQty - 1),
                                                                          );
                                                                    } else {
                                                                      context
                                                                          .read<
                                                                              TransJualBloc>()
                                                                          .add(RemoveProduct(
                                                                              item['rowId']));
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

// 🔢 Jumlah Editable
                                                                Container(
                                                                  width: 60,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          4),
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
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        TextEditingController(
                                                                      text: item[
                                                                              'quantity']
                                                                          .toString(),
                                                                    ),
                                                                    keyboardType: const TextInputType
                                                                        .numberWithOptions(
                                                                        decimal:
                                                                            true),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      border: InputBorder
                                                                          .none,
                                                                      isDense:
                                                                          true,
                                                                      contentPadding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                    ),
                                                                    onSubmitted:
                                                                        (value) {
                                                                      // ubah koma menjadi titik
                                                                      String
                                                                          normalized =
                                                                          value.replaceAll(
                                                                              ',',
                                                                              '.');
                                                                      double?
                                                                          qty =
                                                                          double.tryParse(
                                                                              normalized);
                                                                      if (qty !=
                                                                              null &&
                                                                          qty >
                                                                              0) {
                                                                        context
                                                                            .read<TransJualBloc>()
                                                                            .add(
                                                                              UpdateProductQuantity(item['rowId'], qty),
                                                                            );
                                                                      }
                                                                    },
                                                                  ),
                                                                ),

                                                                const SizedBox(
                                                                    width: 6),

// ➕ Tombol tambah
                                                                InkWell(
                                                                  onTap: item['quantity'] <
                                                                          item[
                                                                              'stok']
                                                                      ? () {
                                                                          double
                                                                              currentQty =
                                                                              (item['quantity'] as num).toDouble();
                                                                          context
                                                                              .read<TransJualBloc>()
                                                                              .add(
                                                                                UpdateProductQuantity(item['rowId'], currentQty + 1),
                                                                              );
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

                                                                // 💰 Harga Total
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
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red),
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  TransJualBloc>()
                                                              .add(RemoveProduct(
                                                                  item[
                                                                      'rowId']));
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            // Tombol Save (Hijau)
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.save,
                                                  size: 20),
                                              label: const Text("Save"),
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
                                              onPressed: () {
                                                context
                                                    .read<TransJualBloc>()
                                                    .add(SubmitTransaction());
                                              },
                                            ),
                                            const SizedBox(width: 12),

                                            // Tombol Print (Ungu muda)
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.print,
                                                  size: 20),
                                              label: const Text("Print"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(
                                                    0xFFE3D7FF), // Ungu muda
                                                foregroundColor: Colors.black87,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 64,
                                                        vertical: 18),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<TransJualBloc>()
                                                    .add(TogglePrintPreview());
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                          )
                        ],
                      );
                    } else {
                      return Center(child: Text("Gagal memuat data"));
                    }
                  },
                ),
              ),
            ],
          ),
          Sidebar(),
        ],
      ),
    );
  }
}
