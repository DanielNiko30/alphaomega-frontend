import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../widget/navbar_pegawai_online.dart';
import '../bloc/detail_order_lazada_bloc.dart';
import '../bloc/detail_order_lazada_event.dart';
import '../bloc/detail_order_lazada_state.dart';
import 'package:intl/intl.dart';

class LazadaOrderDetailPage extends StatelessWidget {
  final String orderId;

  const LazadaOrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LazadaOrderDetailBloc()..add(FetchLazadaOrderDetail(orderId)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: AppBar(
              backgroundColor: Colors.deepPurple,
              title: const Text(
                'Lazada Order Detail',
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
            ),

            // 🔹 Bottom navbar hanya tampil di mobile
            bottomNavigationBar: isMobile
                ? CustomNavbarOnline(
                    currentIndex: 1, // Lazada aktif
                    onTap: (index) {},
                  )
                : null,

            body: BlocBuilder<LazadaOrderDetailBloc, LazadaOrderDetailState>(
              builder: (context, state) {
                if (state is LazadaOrderDetailLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is LazadaOrderDetailError) {
                  return Center(
                    child: Text(state.message,
                        style: const TextStyle(color: Colors.redAccent)),
                  );
                }

                if (state is LazadaOrderDetailLoaded) {
                  final order = state.order;
                  final items = state.items;

                  final shipping =
                      (order['address_shipping'] ?? {}) as Map<String, dynamic>;
                  final billing =
                      (order['address_billing'] ?? {}) as Map<String, dynamic>;

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<LazadaOrderDetailBloc>()
                          .add(FetchLazadaOrderDetail(orderId));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(order),
                          const SizedBox(height: 20),
                          _buildSectionTitle("Customer Information"),
                          _buildSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "${order['customer_first_name'] ?? '-'} ${order['customer_last_name'] ?? ''}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                    "Payment: ${order['payment_method'] ?? '-'} | Status: ${(order['statuses'] as List?)?.join(', ') ?? '-'}"),
                                const SizedBox(height: 4),
                                Text(
                                  "Created at: ${order['created_at'] ?? '-'}",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildSectionTitle("Shipping Address"),
                          _buildSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(shipping['first_name'] ?? '-',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(shipping['phone'] ?? '-'),
                                const SizedBox(height: 4),
                                Text(
                                  "${shipping['address1'] ?? ''}, ${shipping['city'] ?? ''}",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildSectionTitle("Order Items"),
                          ...items.map((item) =>
                              _buildItemCard(item as Map<String, dynamic>)),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  // 🎨 UI Components tetap sama
  Widget _buildHeader(Map<String, dynamic> order) {
    // 🔹 Format total price
    final totalPrice = order['price'] != null
        ? NumberFormat.currency(
                locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2)
            .format(order['price'])
        : 'Rp 0,00';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.deepPurple.shade200.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order #${order['order_number'] ?? '-'}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          _infoRow("Payment", order['payment_method']),
          _infoRow("Status", (order['statuses'] as List?)?.join(', ') ?? '-'),
          const Divider(color: Colors.white54, height: 18),
          Text(
            "Total: $totalPrice", // 🔹 pakai format Rupiah
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
            color: Colors.deepPurple.shade800,
          ),
        ),
      );

  Widget _buildSectionCard({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple.shade100),
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

  Widget _infoRow(String label, dynamic value) => Padding(
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

  Widget _buildItemCard(Map<String, dynamic> item) {
    // 🔹 Format harga per item
    final itemPrice = item['paid_price'] != null
        ? NumberFormat.currency(
                locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2)
            .format(item['paid_price'])
        : 'Rp 0,00';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(color: Colors.deepPurple.shade50),
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
            child: Image.network(
              item['product_main_image'] ?? '',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? '-',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  "Qty: ${item['quantity'] ?? 1} | SKU: ${item['sku'] ?? '-'}",
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  itemPrice, // 🔹 pakai format Rupiah
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
}
