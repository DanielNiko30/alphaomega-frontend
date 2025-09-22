import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../presentation/admin/masterTransaksi/transaksiJual/bloc/transaksi_jual_bloc.dart';
import '../presentation/admin/masterTransaksi/transaksiJual/bloc/transaksi_jual_state.dart';

class PrintPreview extends StatelessWidget {
  final TransJualLoaded transaksi;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PrintPreview({
    Key? key,
    required this.transaksi,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2);

    final subtotal = transaksi.selectedProducts.fold<int>(0, (total, item) {
      final qty = item['quantity'] as int? ?? 0;
      final price = item['price'] as int? ?? 0;
      return total + (qty * price);
    });

    return Center(
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preview Nota',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text('Invoice: ${transaksi.invoiceNumber}'),
                Text('Tanggal: ${DateTime.now()}'),
                Text('Pegawai: ${transaksi.selectedUserPenjualId}'),
                Text('Pembeli: ${transaksi.namaPembeli ?? '-'}'),
                Text('Pembayaran: ${transaksi.paymentMethod ?? '-'}'),
                const Divider(),
                ...transaksi.selectedProducts.map((item) {
                  final name = item['name'] ?? '-';
                  final qty = item['quantity'] ?? 0;
                  final price = item['price'] ?? 0;
                  final total = qty * price;
                  return Text(
                    '$name x$qty @${currencyFormatter.format(price)} = ${currencyFormatter.format(total)}',
                    style: const TextStyle(fontSize: 14),
                  );
                }),
                const Divider(),
                Text(
                  'Subtotal: ${currencyFormatter.format(subtotal)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onConfirm,
                      child: const Text('Cetak'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
