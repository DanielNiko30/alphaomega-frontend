import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../widget/navbar_pegawai_online.dart';
import '../bloc/detail_order_shopee_bloc.dart';
import '../bloc/detail_order_shopee_event.dart';
import '../bloc/detail_order_shopee_state.dart';

class ShopeeOrderDetailPage extends StatelessWidget {
  final String orderSn;

  const ShopeeOrderDetailPage({super.key, required this.orderSn});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ShopeeOrderDetailBloc()..add(FetchShopeeOrderDetail(orderSn)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: AppBar(
              backgroundColor: Colors.blue.shade700,
              elevation: 2,
              title: const Text(
                'Shopee Order Detail',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
            ),

            // 🔹 Bottom navbar hanya tampil di mobile
            bottomNavigationBar: isMobile
                ? CustomNavbarOnline(
                    currentIndex: 0, // Shopee aktif
                    onTap: (index) {},
                  )
                : null,

            body: SafeArea(
              child: BlocBuilder<ShopeeOrderDetailBloc, ShopeeOrderDetailState>(
                builder: (context, state) {
                  if (state is ShopeeOrderDetailLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    );
                  }

                  if (state is ShopeeOrderDetailError) {
                    return _buildErrorView(state.message);
                  }

                  if (state is ShopeeOrderDetailLoaded) {
                    final order = state.order;
                    final recipient = (order['recipient_address'] ?? {})
                        as Map<String, dynamic>;
                    final items = (order['items'] ?? []) as List;
                    final packages = (order['packages'] ?? []) as List;

                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<ShopeeOrderDetailBloc>()
                            .add(FetchShopeeOrderDetail(orderSn));
                      },
                      color: Colors.blue,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAnimatedHeader(order),
                            const SizedBox(height: 20),
                            _buildSectionTitle("Recipient Information"),
                            _buildSectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(recipient['name'] ?? '-',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(recipient['phone'] ?? '-'),
                                  const SizedBox(height: 4),
                                  Text(
                                    recipient['full_address'] ?? '-',
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildSectionTitle("Order Items"),
                            ...items.map((e) =>
                                _buildItemCard(e as Map<String, dynamic>)),
                            const SizedBox(height: 20),
                            _buildSectionTitle("Package Information"),
                            ...packages.map((e) =>
                                _buildPackageCard(e as Map<String, dynamic>)),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 🧱 Reusable Widgets tetap sama ---
  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent.shade200, size: 60),
            const SizedBox(height: 12),
            Text(
              "Oops!",
              style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(Map<String, dynamic> order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.shade200.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order #${order['order_sn'] ?? '-'}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow("Buyer", order['buyer_username']),
          _buildInfoRow("Status", order['status']),
          const Divider(color: Colors.white54, height: 18),
          Text(
            "Total: Rp ${order['total_amount'] ?? '0'}",
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade800,
          ),
        ),
      );

  Widget _buildSectionCard({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              "$value",
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final imageBase64 = item['gambar_product'];
    ImageProvider? imageProvider;

    if (imageBase64 != null &&
        imageBase64.toString().startsWith("data:image")) {
      try {
        final bytes = Uri.parse(imageBase64).data?.contentAsBytes();
        if (bytes != null) imageProvider = MemoryImage(bytes);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(color: Colors.blue.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageProvider != null
                ? Image(
                    image: imageProvider,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover)
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.orange),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['item_name'] ?? '-',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  "Qty: ${item['quantity']} | ${item['satuan'] ?? ''}",
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rp ${item['price'] ?? '-'}",
                  style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> pkg) => Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.orange.shade50,
          border: Border.all(color: Colors.orange.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPackageInfo("Package No", pkg['package_number']),
            _buildPackageInfo("Carrier", pkg['shipping_carrier']),
            _buildPackageInfo("Status", pkg['logistics_status']),
          ],
        ),
      );

  Widget _buildPackageInfo(String label, dynamic value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w500)),
            Flexible(
              child: Text(
                "$value",
                textAlign: TextAlign.end,
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}
