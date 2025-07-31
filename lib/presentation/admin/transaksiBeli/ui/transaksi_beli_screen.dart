import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/widget/sidebar.dart';
import '../bloc/transaksi_beli_bloc.dart';
import '../bloc/transaksi_beli_event.dart';
import '../bloc/transaksi_beli_state.dart';

class TransBeliScreen extends StatefulWidget {
  @override
  _TransBeliScreenState createState() => _TransBeliScreenState();
}

class _TransBeliScreenState extends State<TransBeliScreen> {
  DateTime? selectedDate;
  String? metodePembayaran;
  final TextEditingController invoiceController = TextEditingController();
  final TextEditingController pajakController = TextEditingController();
  Map<String, TextEditingController> priceControllers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final bloc = context.read<TransBeliBloc>();
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
                child: BlocBuilder<TransBeliBloc, TransBeliState>(
                  builder: (context, state) {
                    if (state is TransBeliLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is TransBeliLoaded) {
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
                          // Kiri - List Produk
                          Expanded(
                            flex: 2,
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
                                          .read<TransBeliBloc>()
                                          .add(SearchProductByName(value));
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
                                                  .read<TransBeliBloc>()
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: state.selectedSupplier,
                                          decoration: InputDecoration(
                                            labelText: "Pilih Supplier",
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8),
                                            errorText: state.formErrors[
                                                'supplier'], // ✅ Tambah errorText
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
                                                  .read<TransBeliBloc>()
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
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  selectedDate != null
                                                      ? "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}"
                                                      : "Belum dipilih",
                                                ),
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
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 400,
                                        child: TextFormField(
                                          controller: invoiceController,
                                          decoration: InputDecoration(
                                            labelText: "Nomor Invoice",
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8),
                                            errorText:
                                                state.formErrors['invoice'],
                                          ),
                                          onChanged: (val) {
                                            context
                                                .read<TransBeliBloc>()
                                                .add(UpdateInvoiceNumber(val));
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: state.paymentMethod,
                                          decoration: InputDecoration(
                                            labelText: 'Metode Pembayaran',
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8),
                                            errorText: state.formErrors[
                                                'paymentMethod'], // ✅ Tambah errorText
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
                                              context.read<TransBeliBloc>().add(
                                                  SelectPaymentMethod(value));
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: state.selectedProducts.length,
                                      itemBuilder: (context, index) {
                                        final item =
                                            state.selectedProducts[index];

                                        final id = item['id'];
                                        if (!priceControllers.containsKey(id)) {
                                          priceControllers[id] =
                                              TextEditingController(
                                            text: item['price'] == 0
                                                ? ''
                                                : item['price'].toString(),
                                          );
                                        }

                                        final priceController =
                                            priceControllers[id]!;
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Gambar Produk
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    item['image'] ?? '',
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            Container(
                                                      width: 60,
                                                      height: 60,
                                                      color: Colors.grey[300],
                                                      child: const Icon(Icons
                                                          .image_not_supported),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),

                                                // Info Produk dan Kontrol
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Nama Produk
                                                      Text(
                                                        item['name'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),

                                                      // Harga satuan & stok
                                                      Text(
                                                        "Rp ${item['price'].toString()}  Stok: ${item['stock'] ?? '-'}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                      ),
                                                      const SizedBox(height: 8),

                                                      // Input Harga Satuan
                                                      SizedBox(
                                                        width: 90,
                                                        height: 34,
                                                        child: TextFormField(
                                                          controller:
                                                              priceControllers[
                                                                  item['id']],
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText: "Harga",
                                                            labelStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        11),
                                                            prefixText: "Rp ",
                                                            prefixStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        12),
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
                                                                    TransBeliBloc>()
                                                                .add(UpdateProductPrice(
                                                                    item['id'],
                                                                    parsed));
                                                          },
                                                        ),
                                                      ),

                                                      const SizedBox(height: 8),

                                                      // Row Dropdown + Quantity
                                                      Row(
                                                        children: [
                                                          // Dropdown Satuan
                                                          DropdownButton<
                                                              String>(
                                                            value:
                                                                item['unit'] !=
                                                                        ''
                                                                    ? item[
                                                                        'unit']
                                                                    : null,
                                                            hint: const Text(
                                                                "Satuan"),
                                                            items: (item['unitList'] !=
                                                                        null &&
                                                                    item['unitList']
                                                                        is List)
                                                                ? List<String>.from(
                                                                        item[
                                                                            'unitList'])
                                                                    .map((s) =>
                                                                        DropdownMenuItem<
                                                                            String>(
                                                                          value:
                                                                              s,
                                                                          child:
                                                                              Text("Satuan ($s)"),
                                                                        ))
                                                                    .toList()
                                                                : [],
                                                            onChanged:
                                                                (selectedUnit) {
                                                              if (selectedUnit !=
                                                                  null) {
                                                                context
                                                                    .read<
                                                                        TransBeliBloc>()
                                                                    .add(UpdateProductUnit(
                                                                        item[
                                                                            'id'],
                                                                        selectedUnit));
                                                              }
                                                            },
                                                          ),
                                                          const SizedBox(
                                                              width: 12),

                                                          // Tombol Kurang
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.remove,
                                                                color: Colors
                                                                    .purple),
                                                            onPressed: () {
                                                              if (item[
                                                                      'quantity'] >
                                                                  1) {
                                                                context
                                                                    .read<
                                                                        TransBeliBloc>()
                                                                    .add(UpdateProductQuantity(
                                                                        item[
                                                                            'id'],
                                                                        item['quantity'] -
                                                                            1));
                                                              } else {
                                                                context
                                                                    .read<
                                                                        TransBeliBloc>()
                                                                    .add(RemoveProduct(
                                                                        item[
                                                                            'id']));
                                                              }
                                                            },
                                                          ),
                                                          Text(item['quantity']
                                                              .toString()),
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.add,
                                                                color: Colors
                                                                    .purple),
                                                            onPressed: () {
                                                              context
                                                                  .read<
                                                                      TransBeliBloc>()
                                                                  .add(UpdateProductQuantity(
                                                                      item[
                                                                          'id'],
                                                                      item['quantity'] +
                                                                          1));
                                                            },
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(width: 12),
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
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 8),
                                                    ),
                                                    onChanged: (value) {
                                                      final diskon =
                                                          double.tryParse(
                                                                  value) ??
                                                              0.0;
                                                      context
                                                          .read<TransBeliBloc>()
                                                          .add(
                                                              UpdateProductDiscount(
                                                                  item['id'],
                                                                  diskon));
                                                    },
                                                  ),
                                                ),

                                                const SizedBox(width: 12),
                                                // Total Harga
                                                Text(
                                                  "Rp ${((item['price'] ?? 0.0) * (item['quantity'] ?? 1) * (1 - ((item['discount'] ?? 0.0) / 100))).toStringAsFixed(0)}",
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
                                  const SizedBox(height: 8),
                                  Builder(
                                    builder: (context) {
                                      final subTotal =
                                          state.selectedProducts.fold<double>(
                                        0.0,
                                        (sum, item) {
                                          final price = item['price'] ?? 0.0;
                                          final quantity =
                                              item['quantity'] ?? 1;
                                          final discount =
                                              item['discount'] ?? 0.0;
                                          final itemTotal = price *
                                              quantity *
                                              (1 - discount / 100);
                                          return sum + itemTotal;
                                        },
                                      );

                                      final pajakPersen = double.tryParse(
                                              pajakController.text) ??
                                          0.0;
                                      final pajak =
                                          (pajakPersen / 100) * subTotal;
                                      final total = subTotal + pajak;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "Sub Total: Rp ${subTotal.toStringAsFixed(0)}"),
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
                                                  onChanged: (_) {
                                                    // Trigger UI rebuild
                                                    (context as Element)
                                                        .markNeedsBuild();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Total: Rp ${total.toStringAsFixed(0)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green),
                                      onPressed: () {
                                        final state =
                                            context.read<TransBeliBloc>().state;
                                        if (state is TransBeliLoaded) {
                                          context
                                              .read<TransBeliBloc>()
                                              .add(SubmitTransaction());
                                        } else {
                                          context
                                              .read<TransBeliBloc>()
                                              .add(ValidateTransactionForm());
                                        }
                                      },
                                      child: const Text("Submit"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    } else if (state is TransBeliInitial) {
                      // Tampilkan loading sebentar, lalu fetch ulang data
                      Future.microtask(() {
                        final bloc = context.read<TransBeliBloc>();
                        bloc.add(FetchSuppliers());
                        bloc.add(FetchProducts());
                      });
                      return Center(child: CircularProgressIndicator());
                    } else if (state is TransBeliError) {
                      return Center(child: Text("Error: ${state.message}"));
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
