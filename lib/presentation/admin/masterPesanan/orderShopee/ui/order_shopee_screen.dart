import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../controller/admin/shopee_controller.dart';
import '../../../../../model/orderOnline/shopee_order_model.dart';
import '../../pickup_shopee/bloc/pickup_shopee_bloc.dart';
import '../../pickup_shopee/ui/pickup_shopee_screen.dart';
import '../bloc/order_shopee_bloc.dart';
import '../bloc/order_shopee_event.dart';
import '../bloc/order_shopee_state.dart';
import '../../../../../widget/sidebar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShopeeOrdersScreen extends StatefulWidget {
  const ShopeeOrdersScreen({super.key});

  @override
  State<ShopeeOrdersScreen> createState() => _ShopeeOrdersScreenState();
}

class _ShopeeOrdersScreenState extends State<ShopeeOrdersScreen> {
  late final ShopeeOrdersBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ShopeeOrdersBloc()..add(FetchShopeeOrders());
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
                          "Pesanan Shopee",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),

                        // Toggle Ready to Ship / Processed
                        BlocBuilder<ShopeeOrdersBloc, ShopeeOrdersState>(
                          builder: (context, state) {
                            final bloc = context.read<ShopeeOrdersBloc>();
                            final isProcessed =
                                bloc.currentStatus == "PROCESSED";

                            return Row(
                              children: [
                                ChoiceChip(
                                  label: const Text("Ready to Ship"),
                                  selected: !isProcessed,
                                  onSelected: (v) {
                                    if (isProcessed) {
                                      bloc.add(ChangeShopeeOrderStatus(
                                          "READY_TO_SHIP"));
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text("Processed"),
                                  selected: isProcessed,
                                  onSelected: (v) {
                                    if (!isProcessed) {
                                      bloc.add(
                                          ChangeShopeeOrderStatus("PROCESSED"));
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Orders List
                        Expanded(
                          child:
                              BlocBuilder<ShopeeOrdersBloc, ShopeeOrdersState>(
                            builder: (context, state) {
                              if (state is ShopeeOrdersLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (state is ShopeeOrdersLoaded) {
                                final orders = state.orders;
                                final isProcessed = context
                                        .read<ShopeeOrdersBloc>()
                                        .currentStatus ==
                                    "PROCESSED";

                                // Empty State dengan icon/sticker
                                if (orders.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inbox,
                                          size: 80,
                                          color: Colors.grey.shade400,
                                        ),
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
                                          isProcessed
                                              ? "Tidak ada order processed"
                                              : "Tidak ada order ready to ship",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // List order
                                return ListView.builder(
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    final firstItem = order.items.isNotEmpty
                                        ? order.items.first
                                        : ShopeeOrderItem(
                                            itemId: 0,
                                            name: 'Produk tidak tersedia',
                                            variationName: '-',
                                            quantity: 0,
                                            price: 0,
                                            fromDb: false,
                                            imageUrl: null,
                                          );

                                    final price = NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp',
                                      decimalDigits: 0,
                                    ).format(firstItem.price);

                                    final isProcessed = context
                                            .read<ShopeeOrdersBloc>()
                                            .currentStatus ==
                                        "PROCESSED";

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Header order SN
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(6),
                                                topRight: Radius.circular(6),
                                              ),
                                            ),
                                            child: Text(
                                              "No. Pesanan ${order.orderSn}",
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54),
                                            ),
                                          ),

                                          // Produk
                                          Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: firstItem.imageUrl !=
                                                          null
                                                      ? CachedNetworkImage(
                                                          imageUrl: firstItem
                                                              .imageUrl!,
                                                          width: 70,
                                                          height: 70,
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              (context, url) =>
                                                                  Container(
                                                            width: 70,
                                                            height: 70,
                                                            color: Colors
                                                                .grey.shade200,
                                                            child: const Icon(
                                                                Icons.image),
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Container(
                                                            width: 70,
                                                            height: 70,
                                                            color: Colors
                                                                .grey.shade200,
                                                            child: const Icon(Icons
                                                                .image_not_supported),
                                                          ),
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
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        firstItem.name,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        "Variasi: ${firstItem.variationName}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black54),
                                                      ),
                                                    ],
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
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .black87)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Divider(height: 1),

                                          // Info pengiriman
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    if (!isProcessed) ...[
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 2,
                                                                horizontal: 6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .red.shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: const Text(
                                                          "Besok Batal",
                                                          style: TextStyle(
                                                              fontSize: 11,
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      const Text(
                                                        "Perlu Dikirim",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ]
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      order.shippingMethod
                                                              .isNotEmpty
                                                          ? order.shippingMethod
                                                          : "-",
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    const Text(
                                                      "Drop off / Pickup",
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Divider(height: 1),

                                          // Footer tombol sesuai status
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                if (!isProcessed) ...[
                                                  OutlinedButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (ctx) =>
                                                            BlocProvider(
                                                          create: (_) =>
                                                              PickupPopupBloc(
                                                                  controller:
                                                                      ShopeeController()),
                                                          child:
                                                              PickupPopupScreen(
                                                                  orderSn: order
                                                                      .orderSn),
                                                        ),
                                                      );
                                                    },
                                                    child: const Text("Pickup"),
                                                  ),
                                                  const SizedBox(width: 8),
                                                ] else ...[
                                                  OutlinedButton(
                                                    onPressed: () {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                "Cetak resi order ${order.orderSn}")),
                                                      );
                                                    },
                                                    child: const Text(
                                                        "Print Resi"),
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                                ElevatedButton(
                                                  onPressed: () {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              "Lihat detail untuk order ${order.orderSn}")),
                                                    );
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
                              } else if (state is ShopeeOrdersError) {
                                return Center(
                                    child: Text("Error: ${state.message}"));
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
    );
  }
}
