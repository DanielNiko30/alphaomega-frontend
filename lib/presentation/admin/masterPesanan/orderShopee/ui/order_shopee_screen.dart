import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/presentation/admin/masterPesanan/orderShopee/ui/shopee_resi_popup.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../controller/admin/shopee_controller.dart';
import '../../../../../model/orderOnline/shopee_order_model.dart';
import '../../../../../widget/navbar_pegawai_online.dart';
import '../../pickup_shopee/bloc/pickup_shopee_bloc.dart';
import '../../pickup_shopee/ui/pickup_shopee_screen.dart';
import '../bloc/order_shopee_bloc.dart';
import '../bloc/order_shopee_event.dart';
import '../bloc/order_shopee_state.dart';
import '../../../../../widget/sidebar.dart';

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

  bool get isMobile {
    final size = MediaQuery.of(context).size.width;
    return size < 700; // batas mobile
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,

        // ✅ Tambahkan navbar online jika mobile
        bottomNavigationBar: isMobile
            ? CustomNavbarOnline(
                currentIndex: 0, // index 0 karena ini halaman Shopee
                onTap: (index) {},
              )
            : null,

        body: SafeArea(
          child: Stack(
            children: [
              Row(
                children: [
                  // Sidebar hanya muncul di desktop
                  if (!isMobile) const Sidebar(),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: isMobile ? 16 : 100,
                        top: isMobile ? 20 : 40,
                        right: isMobile ? 16 : 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pesanan Shopee",
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 🔹 Toggle Ready to Ship / Processed
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
                                        bloc.add(ChangeShopeeOrderStatus(
                                            "PROCESSED"));
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // 🔹 Orders List
                          Expanded(
                            child: BlocBuilder<ShopeeOrdersBloc,
                                ShopeeOrdersState>(
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

                                  if (orders.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.inbox_outlined,
                                            size: 80,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            "Belum ada order",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            isProcessed
                                                ? "Tidak ada order processed"
                                                : "Tidak ada order ready to ship",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: orders.length,
                                    padding: EdgeInsets.only(
                                        bottom: isMobile
                                            ? 80
                                            : 30), // extra padding bawah
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
                                        margin:
                                            const EdgeInsets.only(bottom: 14),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Header
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                ),
                                              ),
                                              child: Text(
                                                "No. Pesanan ${order.orderSn}",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),

                                            // Produk
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: firstItem.imageUrl !=
                                                            null
                                                        ? CachedNetworkImage(
                                                            imageUrl: firstItem
                                                                .imageUrl!,
                                                            width: isMobile
                                                                ? 60
                                                                : 70,
                                                            height: isMobile
                                                                ? 60
                                                                : 70,
                                                            fit: BoxFit.cover,
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    Container(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              child: const Icon(
                                                                  Icons.image),
                                                            ),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Container(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              child: const Icon(
                                                                  Icons
                                                                      .image_not_supported),
                                                            ),
                                                          )
                                                        : Container(
                                                            width: isMobile
                                                                ? 60
                                                                : 70,
                                                            height: isMobile
                                                                ? 60
                                                                : 70,
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
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        "x${firstItem.quantity}",
                                                        style: const TextStyle(
                                                            fontSize: 13),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        price,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const Divider(height: 1),

                                            // Footer Tombol
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 12),
                                              child: Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                alignment: WrapAlignment.end,
                                                children: [
                                                  if (!isProcessed)
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
                                                              orderSn:
                                                                  order.orderSn,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child:
                                                          const Text("Pickup"),
                                                    )
                                                  else
                                                    OutlinedButton(
                                                      onPressed: () async {
                                                        try {
                                                          final pdfBytes =
                                                              await ShopeeController
                                                                  .printShopeeResi(
                                                                      order
                                                                          .orderSn);

                                                          if (pdfBytes
                                                              .isNotEmpty) {
                                                            if (context
                                                                .mounted) {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (ctx) =>
                                                                    ShopeeResiPopup(
                                                                  orderSn: order
                                                                      .orderSn,
                                                                  pdfBytes:
                                                                      pdfBytes,
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        } catch (e) {
                                                          debugPrint(
                                                              "❌ Error printShopeeResi: $e");
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'Gagal ambil resi: $e'),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: const Text(
                                                          "Print Resi"),
                                                    ),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.blue.shade600,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 10),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      elevation: 1.5,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/shopeeOrderDetail',
                                                        arguments: {
                                                          'orderSn':
                                                              order.orderSn
                                                        },
                                                      );
                                                    },
                                                    child: const Text(
                                                      "Lihat Detail",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
