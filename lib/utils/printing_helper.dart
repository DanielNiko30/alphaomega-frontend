import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Flag [directPrint] kalau true akan langsung kirim ke printer,
/// kalau false tampilkan preview PDF.
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
    // langsung print tanpa preview
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
    // tampilkan preview PDF
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

  // Gunakan tinggi realistis untuk thermal printer
  final pageFormat = PdfPageFormat(
    80 * PdfPageFormat.mm, // lebar 80mm
    200 * PdfPageFormat.mm, // tinggi awal, bisa scroll
    marginAll: 2 * PdfPageFormat.mm,
  );

  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
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
              child: pw.Text('Jl. Ploso Timur 3B No.2',
                  style: pw.TextStyle(fontSize: 10)),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Invoice   : $invoiceNumber',
                style: pw.TextStyle(fontSize: 10)),
            pw.Text('Tanggal   : $tanggal', style: pw.TextStyle(fontSize: 10)),
            pw.Text('Pegawai   : $namaPegawai',
                style: pw.TextStyle(fontSize: 10)),
            pw.Text('Penjual   : $namaPenjual',
                style: pw.TextStyle(fontSize: 10)),
            pw.Text('Pembeli   : $namaPembeli',
                style: pw.TextStyle(fontSize: 10)),
            pw.Text('Pembayaran: $metodePembayaran',
                style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 10),
            pw.Text('Detail Barang:', style: pw.TextStyle(fontSize: 10)),
            ...items.map(
              (item) => pw.Text(
                '${item['name']} x${item['qty']} @${item['price']} = ${item['subtotal']}',
                style: pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.Divider(),
            pw.Text('Subtotal: $subtotal',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Center(
                child:
                    pw.Text('Terima kasih', style: pw.TextStyle(fontSize: 10))),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
