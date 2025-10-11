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

class ShopeeOrdersScreen extends StatelessWidget {
  const ShopeeOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShopeeOrdersBloc()..add(FetchShopeeOrders()),
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
                        Expanded(
                          child:
                              BlocBuilder<ShopeeOrdersBloc, ShopeeOrdersState>(
                            builder: (context, state) {
                              if (state is ShopeeOrdersLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (state is ShopeeOrdersLoaded) {
                                final orders = state.orders;
                                if (orders.isEmpty) {
                                  return const Center(
                                      child: Text("Belum ada order"));
                                }

                                return ListView.builder(
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];

                                    // Aman: fallback jika items kosong
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
                                          // Header dengan order SN
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
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "No. Pesanan ${order.orderSn}",
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54),
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
                                                // Gambar produk dari URL atau placeholder
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

                                                // Detail produk
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
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        "Variasi: ${firstItem.variationName}",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Qty dan harga
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

                                          // Footer
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 12),
                                            child: Column(
                                              children: [
                                                // Informasi status
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 2,
                                                                  horizontal:
                                                                      6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .red.shade100,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                          child: const Text(
                                                            "Besok Batal",
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        const Text(
                                                          "Perlu Dikirim",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          order.shippingMethod
                                                                  .isNotEmpty
                                                              ? order
                                                                  .shippingMethod
                                                              : "Hemat Kargo",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                        ),
                                                        const Text(
                                                          "Drop off / Pickup",
                                                          style: TextStyle(
                                                              fontSize: 11,
                                                              color: Colors
                                                                  .black54),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),

                                                // Tombol aksi
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
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
                                                            child: PickupPopupScreen(
                                                                orderSn: order
                                                                    .orderSn),
                                                          ),
                                                        );
                                                      },
                                                      child:
                                                          const Text("Pickup"),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                "Lihat detail untuk order ${order.orderSn}"),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                          "Lihat Detail"),
                                                    ),
                                                  ],
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
