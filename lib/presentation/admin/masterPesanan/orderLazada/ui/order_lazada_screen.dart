import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../controller/admin/lazada_controller.dart';
import '../../../../../model/product/lazada_model.dart';
import '../../../../../widget/sidebar.dart';
import '../bloc/order_lazada_bloc.dart';
import '../bloc/order_lazada_event.dart';
import '../bloc/order_lazada_state.dart';
import 'lazada_resi_popup.dart';

class LazadaOrdersScreen extends StatefulWidget {
  const LazadaOrdersScreen({super.key});

  @override
  State<LazadaOrdersScreen> createState() => _LazadaOrdersScreenState();
}

class _LazadaOrdersScreenState extends State<LazadaOrdersScreen> {
  late final LazadaOrdersBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = LazadaOrdersBloc()..add(FetchLazadaOrders());

    // 🔹 Set callback agar popup bisa muncul tanpa ganti state utama
    _bloc.eventCallback = (pdfBase64, orderId) {
      final bytes = base64Decode(pdfBase64);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => LazadaResiPopup(
          orderId: orderId,
          pdfBytes: bytes,
        ),
      );
    };
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<LazadaOrdersBloc, LazadaOrdersState>(
        listener: (context, state) {
          if (state is LazadaOrdersSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is LazadaOrdersError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 100, top: 40, right: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pesanan Lazada",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Toggle Status
                          BlocBuilder<LazadaOrdersBloc, LazadaOrdersState>(
                            builder: (context, state) {
                              final bloc = context.read<LazadaOrdersBloc>();
                              final isReady =
                                  bloc.currentStatus == "READY_TO_SHIP";

                              return Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text("Pending"),
                                    selected: !isReady,
                                    onSelected: (v) {
                                      if (isReady) {
                                        bloc.add(
                                            ChangeLazadaOrderStatus("PENDING"));
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text("Ready to Ship"),
                                    selected: isReady,
                                    onSelected: (v) {
                                      if (!isReady) {
                                        bloc.add(ChangeLazadaOrderStatus(
                                            "READY_TO_SHIP"));
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Order list
                          Expanded(
                            child: BlocBuilder<LazadaOrdersBloc,
                                LazadaOrdersState>(
                              builder: (context, state) {
                                if (state is LazadaOrdersLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (state is LazadaOrdersLoaded) {
                                  final orders = state.orders;
                                  final isReady = context
                                          .read<LazadaOrdersBloc>()
                                          .currentStatus ==
                                      "READY_TO_SHIP";

                                  if (orders.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.inbox,
                                              size: 80,
                                              color: Colors.grey.shade400),
                                          const SizedBox(height: 16),
                                          Text(
                                            "Belum ada order",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade600),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            isReady
                                                ? "Tidak ada pesanan siap dikirim"
                                                : "Tidak ada pesanan pending",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: orders.length,
                                    itemBuilder: (context, index) {
                                      final order = orders[index];
                                      final firstItem = order.items.isNotEmpty
                                          ? order.items.first
                                          : LazadaOrderItem(
                                              itemId: '',
                                              name: 'Produk tidak tersedia',
                                              quantity: 0,
                                              price: 0,
                                              fromDb: false,
                                              productId: '',
                                              skuId: '',
                                              imageUrl: null,
                                            );

                                      final price = NumberFormat.currency(
                                        locale: 'id_ID',
                                        symbol: 'Rp',
                                        decimalDigits: 0,
                                      ).format(firstItem.price);

                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Header order
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(6),
                                                  topRight: Radius.circular(6),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "No. Pesanan ${order.orderId}",
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: isReady
                                                          ? Colors
                                                              .green.shade100
                                                          : Colors
                                                              .orange.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      isReady
                                                          ? "Ready to Ship"
                                                          : "Pending",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isReady
                                                            ? Colors.green
                                                            : Colors.orange,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Isi produk
                                            Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    child: firstItem.imageUrl !=
                                                            null
                                                        ? CachedNetworkImage(
                                                            imageUrl: firstItem
                                                                .imageUrl!,
                                                            width: 70,
                                                            height: 70,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Container(
                                                            width: 70,
                                                            height: 70,
                                                            color: Colors
                                                                .grey.shade200,
                                                            child: const Icon(Icons
                                                                .image_not_supported),
                                                          ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      firstItem.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                          "x${firstItem.quantity}"),
                                                      const SizedBox(height: 6),
                                                      Text(price,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Divider(height: 1),

                                            // Tombol aksi
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 12),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  if (!isReady)
                                                    OutlinedButton.icon(
                                                      onPressed: () {
                                                        _bloc.add(
                                                          SetLazadaReadyToShip(
                                                              order.orderId),
                                                        );
                                                      },
                                                      icon: const Icon(
                                                          Icons.local_shipping),
                                                      label: const Text(
                                                          "Atur Pickup"),
                                                    )
                                                  else
                                                    OutlinedButton.icon(
                                                      onPressed: () {
                                                        _bloc.add(
                                                          PrintLazadaResi(
                                                              order.orderId),
                                                        );
                                                      },
                                                      icon: const Icon(
                                                          Icons.print),
                                                      label: const Text(
                                                          "Print Resi"),
                                                    ),
                                                  const SizedBox(width: 8),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      // TODO: Lihat detail order
                                                    },
                                                    child: const Text(
                                                        "Lihat Detail"),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Sidebar(),
            ],
          ),
        ),
      ),
    );
  }
}
