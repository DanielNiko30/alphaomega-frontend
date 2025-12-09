import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';

/// Tampilkan preview invoice atau langsung print.
Future<void> showInvoicePreview(
  BuildContext context, {
  required String invoiceNumber,
  required String tanggal,
  required String namaPegawai,
  required String namaPenjual,
  required String namaPembeli,
  required String metodePembayaran,
  required List<Map<String, dynamic>> items,
  required String subtotal,
  bool directPrint = false,
}) async {
  if (directPrint) {
    await Printing.layoutPdf(
      onLayout: (format) => buildInvoicePdf(
        invoiceNumber: invoiceNumber,
        tanggal: tanggal,
        namaPegawai: namaPegawai,
        namaPenjual: namaPenjual,
        namaPembeli: namaPembeli,
        metodePembayaran: metodePembayaran,
        items: items,
        subtotal: subtotal,
      ),
      usePrinterSettings: true,
    );
  } else {
    final Uint8List pdfData = await buildInvoicePdf(
      invoiceNumber: invoiceNumber,
      tanggal: tanggal,
      namaPegawai: namaPegawai,
      namaPenjual: namaPenjual,
      namaPembeli: namaPembeli,
      metodePembayaran: metodePembayaran,
      items: items,
      subtotal: subtotal,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdfData,
      name: 'Invoice_$invoiceNumber',
    );
  }
}

/// Build invoice untuk printer thermal
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

  final pageFormat = PdfPageFormat(
    80 * PdfPageFormat.mm, // Lebar printer thermal 80mm
    double.infinity, // Panjang fleksibel
    marginAll: 3 * PdfPageFormat.mm,
  );

  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (pw.Context context) {
        // Fungsi bantu untuk memastikan teks tidak null
        String safeText(String? text) {
          if (text == null || text.trim().isEmpty || text == '-') {
            return '(Tidak ada)';
          }
          return text;
        }

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

            // Info transaksi
            pw.Text('Invoice   : $invoiceNumber',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Tanggal   : $tanggal',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Pegawai   : ${safeText(namaPegawai)}',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Penjual   : ${safeText(namaPenjual)}',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Pembeli   : ${safeText(namaPembeli)}',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Pembayaran: ${safeText(metodePembayaran)}',
                style: const pw.TextStyle(fontSize: 10)),

            pw.SizedBox(height: 10),
            pw.Text('Detail Barang:',
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),

            // Header tabel
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 0.5),
                ),
              ),
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

            // List item barang
            ...items.map(
              (item) => pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 0.2, color: PdfColors.grey300),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(
                        item['name'] ?? '',
                        style: const pw.TextStyle(fontSize: 9),
                        overflow: pw.TextOverflow.clip,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        '${item['qty']}',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        '${item['price']}',
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        '${item['subtotal']}',
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            pw.Divider(thickness: 0.8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal:',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text(subtotal,
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ],
            ),

            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text('Terima kasih atas pembelian Anda',
                  style: const pw.TextStyle(fontSize: 9)),
            ),
            pw.Center(
              child: pw.Text(
                  'Barang yang sudah dibeli tidak dapat dikembalikan.',
                  style:
                      const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
