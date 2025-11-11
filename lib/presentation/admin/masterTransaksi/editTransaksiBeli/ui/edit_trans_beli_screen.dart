import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/presentation/admin/masterTransaksi/editTransaksiBeli/bloc/edit_trans_beli_event.dart';
import 'package:frontend/widget/sidebar.dart';
import 'package:intl/intl.dart';
import '../bloc/edit_trans_beli_bloc.dart';
import '../bloc/edit_trans_beli_state.dart';

class EditTransBeliScreen extends StatefulWidget {
  final String idTransaksi; // ✅ tambahkan properti ini

  const EditTransBeliScreen({
    Key? key,
    required this.idTransaksi, // ✅ wajib diisi
  }) : super(key: key);

  @override
  _EditTransBeliScreenState createState() => _EditTransBeliScreenState();
}

class _EditTransBeliScreenState extends State<EditTransBeliScreen> {
  DateTime? selectedDate;
  Map<String, TextEditingController> qtyControllers = {};
  String? metodePembayaran;
  final TextEditingController invoiceController = TextEditingController();
  final TextEditingController pajakController = TextEditingController();
  Map<String, TextEditingController> priceControllers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final bloc = context.read<EditTransBeliBloc>();
      context
          .read<EditTransBeliBloc>()
          .add(FetchTransactionById(widget.idTransaksi));
      bloc.add(FetchSuppliers());
      bloc.add(FetchProducts());
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _pickDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null && picked != selectedDate) {
        setState(() => selectedDate = picked);
      }
    }

    String formatRupiah(double value) {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 2,
      );
      return formatter.format(value);
    }

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: BlocBuilder<EditTransBeliBloc, EditTransBeliState>(
                  builder: (context, state) {
                    if (state is TransBeliLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is EditTransBeliLoaded) {
                      if (metodePembayaran == null &&
                          state.paymentMethod != null) {
                        metodePembayaran = state.paymentMethod;
                      }

                      if (invoiceController.text.isEmpty &&
                          state.nomorInvoice != null) {
                        invoiceController.text = state.nomorInvoice!;
                      }

                      if (invoiceController.text != state.nomorInvoice) {
                        invoiceController.text = state.nomorInvoice ?? '';
                        invoiceController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: invoiceController.text.length),
                        );
                      }
                      pajakController.text = state.pajak.toString();

                      return Row(
                        children: [
                          // 🟢 Kiri (60%) - List Produk
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
                                    onChanged: (value) => context
                                        .read<EditTransBeliBloc>()
                                        .add(SearchProductByName(value)),
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
                                                  .read<EditTransBeliBloc>()
                                                  .add(AddProduct(
                                                    id: product['id'],
                                                    name: product['name'],
                                                    image: product['image'],
                                                    quantity: 1,
                                                    unit: '',
                                                    price: 0.0,
                                                  ));
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: SizedBox(
                                                    width: 120,
                                                    height: 120,
                                                    child: buildProductImage(
                                                        product['image']),
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

                          // 🟣 Kanan (40%) - Nota dan Pembayaran
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              color: Colors.grey[100],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🔹 Supplier dan Tanggal
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: state.selectedSupplier,
                                          decoration: InputDecoration(
                                            labelText: "Pilih Supplier",
                                            border: const OutlineInputBorder(),
                                            errorText:
                                                state.formErrors['supplier'],
                                          ),
                                          items: state.suppliers
                                              .map((s) =>
                                                  DropdownMenuItem<String>(
                                                    value: s['id'] as String,
                                                    child: Text(s['name']),
                                                  ))
                                              .toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              context
                                                  .read<EditTransBeliBloc>()
                                                  .add(SelectSupplier(value));
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _pickDate(context),
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: 'Pilih Tanggal',
                                              border: OutlineInputBorder(),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(selectedDate != null
                                                    ? "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}"
                                                    : "Belum dipilih"),
                                                const Icon(Icons.calendar_today,
                                                    size: 20),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // 🔹 Invoice & Metode Pembayaran
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 400,
                                        child: TextFormField(
                                          controller: invoiceController,
                                          decoration: InputDecoration(
                                            labelText: "Nomor Invoice",
                                            border: const OutlineInputBorder(),
                                            errorText:
                                                state.formErrors['invoice'],
                                          ),
                                          onChanged: (val) => context
                                              .read<EditTransBeliBloc>()
                                              .add(UpdateInvoiceNumber(val)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: metodePembayaran ??
                                              state.paymentMethod,
                                          decoration: InputDecoration(
                                            labelText: 'Metode Pembayaran',
                                            border: const OutlineInputBorder(),
                                            errorText: state
                                                .formErrors['paymentMethod'],
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                                value: 'Cash',
                                                child: Text('Cash')),
                                            DropdownMenuItem(
                                                value: 'Transfer',
                                                child: Text('Transfer')),
                                            DropdownMenuItem(
                                                value: 'Kredit',
                                                child: Text('Kredit')),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) {
                                              context
                                                  .read<EditTransBeliBloc>()
                                                  .add(SelectPaymentMethod(
                                                      value));
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // 🔹 Daftar Produk yang Dipilih
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: state.selectedProducts.length,
                                      itemBuilder: (context, index) {
                                        final item =
                                            state.selectedProducts[index];
                                        final id = item['id']?.toString() ?? '';

                                        final priceController =
                                            priceControllers.putIfAbsent(
                                          id,
                                          () => TextEditingController(
                                              text: (item['price'] ?? 0)
                                                  .toString()),
                                        );

                                        final qtyController =
                                            qtyControllers.putIfAbsent(
                                          id,
                                          () => TextEditingController(
                                              text: (item['quantity'] ?? 1)
                                                  .toString()),
                                        );

                                        qtyController.text =
                                            (item['quantity'] ?? 1).toString();

                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // 🖼️ Gambar
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: SizedBox(
                                                    width: 60,
                                                    height: 60,
                                                    child: buildProductImage(
                                                        item['image']),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),

                                                // 🔸 Info Produk
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item['name'],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        "${formatRupiah(double.tryParse(item['price'].toString()) ?? 0)}  Stok: ${item['stock'] ?? '-'}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                      ),
                                                      const SizedBox(height: 8),

                                                      // 🔸 Input Harga
                                                      SizedBox(
                                                        width: 90,
                                                        height: 34,
                                                        child: TextFormField(
                                                          controller:
                                                              priceController,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText: "Harga",
                                                            prefixText: "Rp ",
                                                            border:
                                                                OutlineInputBorder(),
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            6,
                                                                        vertical:
                                                                            6),
                                                          ),
                                                          onChanged: (value) {
                                                            final parsed =
                                                                double.tryParse(
                                                                      value.replaceAll(
                                                                          RegExp(
                                                                              r'[^0-9.]'),
                                                                          ''),
                                                                    ) ??
                                                                    0.0;
                                                            context
                                                                .read<
                                                                    EditTransBeliBloc>()
                                                                .add(UpdateProductPrice(
                                                                    id,
                                                                    parsed));
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),

                                                      // 🔸 Dropdown Satuan + Qty Editable
                                                      Row(
                                                        children: [
                                                          // 🔹 Dropdown satuan
                                                          Container(
                                                            height: 34,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                            ),
                                                            child:
                                                                DropdownButtonHideUnderline(
                                                              child:
                                                                  DropdownButton<
                                                                      String>(
                                                                value: item['unit'] !=
                                                                        ''
                                                                    ? item[
                                                                        'unit']
                                                                    : null,
                                                                hint: const Text(
                                                                    "RTG",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                                items: (item['unitList'] !=
                                                                            null &&
                                                                        item['unitList']
                                                                            is List)
                                                                    ? List<String>.from(
                                                                            item['unitList'])
                                                                        .map(
                                                                          (s) =>
                                                                              DropdownMenuItem<String>(
                                                                            value:
                                                                                s,
                                                                            child:
                                                                                Text(s, style: const TextStyle(fontSize: 13)),
                                                                          ),
                                                                        )
                                                                        .toList()
                                                                    : [],
                                                                onChanged:
                                                                    (selectedUnit) {
                                                                  if (selectedUnit !=
                                                                      null) {
                                                                    context
                                                                        .read<
                                                                            EditTransBeliBloc>()
                                                                        .add(UpdateProductUnit(
                                                                            id,
                                                                            selectedUnit));
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),

                                                          // 🔹 Tombol "-" ungu muda
                                                          Container(
                                                            width: 30,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .purple
                                                                  .shade100,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                            ),
                                                            child: IconButton(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              icon: const Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .purple,
                                                                  size: 18),
                                                              onPressed: () {
                                                                if (item[
                                                                        'quantity'] >
                                                                    1) {
                                                                  context
                                                                      .read<
                                                                          EditTransBeliBloc>()
                                                                      .add(UpdateProductQuantity(
                                                                          id,
                                                                          item['quantity'] -
                                                                              1));

                                                                  // update UI qty langsung
                                                                  qtyController
                                                                          .text =
                                                                      (item['quantity'] -
                                                                              1)
                                                                          .toString();
                                                                } else {
                                                                  context
                                                                      .read<
                                                                          EditTransBeliBloc>()
                                                                      .add(RemoveProduct(
                                                                          id));
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 6),

                                                          // 🔹 Input jumlah (qty)
                                                          Container(
                                                            width: 50,
                                                            height: 30,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  qtyController,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          13),
                                                              decoration:
                                                                  const InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                isDense: true,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                              onChanged:
                                                                  (value) {
                                                                final qty =
                                                                    int.tryParse(
                                                                            value) ??
                                                                        1;
                                                                if (qty > 0) {
                                                                  context
                                                                      .read<
                                                                          EditTransBeliBloc>()
                                                                      .add(UpdateProductQuantity(
                                                                          id,
                                                                          qty));
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 6),

                                                          // 🔹 Tombol "+" ungu muda
                                                          Container(
                                                            width: 30,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .purple
                                                                  .shade100,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                            ),
                                                            child: IconButton(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              icon: const Icon(
                                                                  Icons.add,
                                                                  color: Colors
                                                                      .purple,
                                                                  size: 18),
                                                              onPressed: () {
                                                                context
                                                                    .read<
                                                                        EditTransBeliBloc>()
                                                                    .add(UpdateProductQuantity(
                                                                        id,
                                                                        item['quantity'] +
                                                                            1));

                                                                // update UI qty langsung
                                                                qtyController
                                                                        .text =
                                                                    (item['quantity'] +
                                                                            1)
                                                                        .toString();
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),

                                                // Diskon + Total
                                                SizedBox(
                                                  width: 60,
                                                  child: TextFormField(
                                                    initialValue:
                                                        (item['discount'] ?? 0)
                                                            .toString(),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: "%",
                                                      isDense: true,
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                    onChanged: (value) {
                                                      final diskon =
                                                          double.tryParse(
                                                                  value) ??
                                                              0.0;
                                                      context
                                                          .read<
                                                              EditTransBeliBloc>()
                                                          .add(
                                                              UpdateProductDiscount(
                                                                  id, diskon));
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  formatRupiah(
                                                    ((item['price'] ?? 0.0) *
                                                            (item['quantity'] ??
                                                                1) *
                                                            (1 -
                                                                ((item['discount'] ??
                                                                        0.0) /
                                                                    100)))
                                                        .toDouble(),
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // 🔹 Total, Pajak, Submit
                                  const SizedBox(height: 8),
                                  Builder(
                                    builder: (context) {
                                      final subTotal =
                                          state.selectedProducts.fold<double>(
                                        0.0,
                                        (sum, item) {
                                          final price = item['price'] ?? 0.0;
                                          final qty = item['quantity'] ?? 1;
                                          final disc = item['discount'] ?? 0.0;
                                          return sum +
                                              (price * qty * (1 - disc / 100));
                                        },
                                      );
                                      final pajakPersen = double.tryParse(
                                              pajakController.text) ??
                                          0.0;
                                      final pajak =
                                          pajakPersen / 100 * subTotal;
                                      final total = subTotal + pajak;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "Sub Total: ${formatRupiah(subTotal.toDouble())}"),
                                          Row(
                                            children: [
                                              const Text("Pajak: "),
                                              SizedBox(
                                                width: 60,
                                                height: 30,
                                                child: TextFormField(
                                                  controller: pajakController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 6),
                                                    border:
                                                        OutlineInputBorder(),
                                                    suffixText: '%',
                                                  ),
                                                  onChanged: (_) =>
                                                      (context as Element)
                                                          .markNeedsBuild(),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Total: ${formatRupiah(total.toDouble())}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      height: 36, // 🔹 lebih kecil
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 2,
                                        ),
                                        onPressed: () {
                                          final bloc =
                                              context.read<EditTransBeliBloc>();
                                          final state = bloc.state;

                                          if (state is EditTransBeliLoaded) {
                                            bloc.add(UpdateTransaction(
                                                widget.idTransaksi, context));
                                          } else {
                                            bloc.add(ValidateTransactionForm());
                                          }
                                        },
                                        icon: const Icon(Icons.check,
                                            size: 16, color: Colors.white),
                                        label: const Text(
                                          "Submit",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (state is TransBeliInitial) {
                      Future.microtask(() {
                        final bloc = context.read<EditTransBeliBloc>();
                        bloc.add(FetchSuppliers());
                        bloc.add(FetchProducts());
                      });
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TransBeliError) {
                      return Center(child: Text("Error: ${state.message}"));
                    } else {
                      return const Center(child: Text("Gagal memuat data"));
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

final Map<String, Uint8List> _imageCache = {};
Widget buildProductImage(String? imageData) {
  if (imageData == null || imageData.isEmpty) {
    return Container(
      color: Colors.grey[300],
      child:
          const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
    );
  }

  Widget imageWidget;

  if (imageData.startsWith('http')) {
    // 🔹 Gunakan CachedNetworkImage jika ingin lebih efisien (opsional)
    imageWidget = Image.network(
      imageData,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  } else {
    try {
      // 🔹 Gunakan cache untuk hasil decode base64
      Uint8List? bytes = _imageCache[imageData];
      if (bytes == null) {
        final base64String =
            imageData.contains(',') ? imageData.split(',').last : imageData;
        bytes = base64Decode(base64String);
        _imageCache[imageData] = bytes; // simpan di cache
      }

      imageWidget = Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } catch (e) {
      debugPrint('⚠️ Error parsing image: $e');
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
      );
    }
  }

  // 🔹 Bungkus agar ukuran dan rasio tetap konsisten
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: 100,
          height: 100,
          child: imageWidget,
        ),
      ),
    ),
  );
}
