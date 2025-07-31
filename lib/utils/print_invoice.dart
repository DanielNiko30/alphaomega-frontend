import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Text('Toko AlphaOmega', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))),
            pw.Center(child: pw.Text('Jl. Ploso Timur 3B No.2', style: pw.TextStyle(fontSize: 10))),
            pw.SizedBox(height: 10),
            pw.Text('Invoice   : $invoiceNumber'),
            pw.Text('Tanggal   : $tanggal'),
            pw.Text('Pegawai   : $namaPegawai'),
            pw.Text('Penjual   : $namaPenjual'),
            pw.Text('Pembeli   : $namaPembeli'),
            pw.Text('Pembayaran: $metodePembayaran'),
            pw.SizedBox(height: 10),
            pw.Text('Detail Barang:'),
            ...items.map((item) => pw.Text(
              '${item['name']} x${item['qty']} @${item['price']} = ${item['subtotal']}'
            )),
            pw.Divider(),
            pw.Text('Subtotal: $subtotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Center(child: pw.Text('Terima kasih')),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
