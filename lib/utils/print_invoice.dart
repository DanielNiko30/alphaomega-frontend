import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

Future<Uint8List> buildInvoicePdf({
  required String invoiceNumber,
  required String tanggal,
  required String namaPegawai,
  required String namaPenjual,
  required String namaPembeli,
  required String metodePembayaran,
  required List<Map<String, dynamic>> items,
  required String subtotal,
}) async {
  final pdf = pw.Document();

  // Formatter untuk Rupiah
  final formatRupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.all(8),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header toko
            pw.Center(
              child: pw.Text(
                'Toko AlphaOmega',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Jl. Ploso Timur 3B No.2',
                style: pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.SizedBox(height: 10),

            // Info invoice
            pw.Text('Invoice   : $invoiceNumber'),
            pw.Text('Tanggal   : $tanggal'),
            pw.Text('Pegawai   : $namaPegawai'),
            pw.Text('Penjual   : $namaPenjual'),
            pw.Text('Pembeli   : $namaPembeli'),
            pw.Text('Pembayaran: $metodePembayaran'),

            pw.SizedBox(height: 10),

            // Header tabel barang
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 0.5),
                ),
              ),
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text(
                      'Nama Barang',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Qty',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Harga',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Total',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 4),

            // List barang
            ...items.map((item) {
              final harga = formatRupiah.format(item['price'] ?? 0);
              final total = formatRupiah.format(item['subtotal'] ?? 0);

              return pw.Row(
                children: [
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text(
                      item['name'] ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      '${item['qty']}',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      harga,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      total,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              );
            }).toList(),

            pw.Divider(),

            // Total
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Subtotal:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  formatRupiah.format(int.tryParse(subtotal) ?? 0),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),

            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Terima kasih telah berbelanja!',
                style: pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
