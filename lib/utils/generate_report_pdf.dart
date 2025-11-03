import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../model/laporan/laporan_model.dart';

// Gunakan import dart:html hanya di web (hindari error di Android/Windows)
import 'conditional_html_stub.dart'
    if (dart.library.html) 'conditional_html_real.dart' as html;

Future<void> generateReportPdf({
  required BuildContext context,
  required String reportTitle,
  required String reportType, // "per_produk", "per_periode", "detail"
  required List<dynamic> data,
}) async {
  try {
    await initializeDateFormatting('id_ID', null);

    final fontData =
        await rootBundle.load('assets/fonts/Roboto/static/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();
    final dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                reportTitle,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 16),
            _buildReportTable(
              reportType,
              data,
              dateFormatter,
              currencyFormatter,
              ttf,
            ),
          ];
        },
      ),
    );

    final pdfBytes = await pdf.save();

    if (kIsWeb) {
      // Web: download lewat browser
      html.downloadPdfWeb(pdfBytes, "$reportTitle.pdf");
    } else {
      // Mobile / Desktop
      await _savePdfToFile(pdfBytes, reportTitle);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF berhasil dibuat')),
    );
  } catch (e, stack) {
    debugPrint('PDF Generate Error: $e');
    debugPrint(stack.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal membuat PDF: $e')),
    );
  }
}

// =====================================================
// Simpan PDF di folder Download/Documents (non-Web)
// =====================================================
Future<void> _savePdfToFile(List<int> pdfBytes, String fileName) async {
  try {
    Directory? dir;
    if (Platform.isAndroid || Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dir = await getDownloadsDirectory();
    }

    final file = File(
      '${dir!.path}/$fileName-${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(pdfBytes);
    debugPrint('✅ PDF saved at: ${file.path}');
  } catch (e) {
    debugPrint('❌ Error saving PDF: $e');
  }
}

// =====================================================
// Build tabel PDF
// =====================================================
pw.Widget _buildReportTable(
  String reportType,
  List<dynamic> data,
  DateFormat dateFormatter,
  NumberFormat currencyFormatter,
  pw.Font ttf,
) {
  if (data.isEmpty) {
    return pw.Center(
      child: pw.Text("Tidak ada data tersedia", style: pw.TextStyle(font: ttf)),
    );
  }

  switch (reportType) {
    case "per_produk":
      return pw.Table.fromTextArray(
        headers: ['No', 'Nama Produk', 'Total Jumlah', 'Total Nominal'],
        data: List.generate(data.length, (index) {
          final item = data[index];
          return [
            (index + 1).toString(),
            item.namaProduk,
            item.totalJumlah.toStringAsFixed(0),
            currencyFormatter.format(item.totalNominal),
          ];
        }),
        headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
        border: pw.TableBorder.all(width: 0.5),
        cellAlignment: pw.Alignment.centerLeft,
        headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      );

    case "per_periode":
      return pw.Table.fromTextArray(
        headers: ['No', 'Periode', 'Jumlah Transaksi', 'Total'],
        data: List.generate(data.length, (index) {
          final item = data[index];
          return [
            (index + 1).toString(),
            item.periode,
            item.jumlahTransaksi.toString(),
            currencyFormatter.format(item.total),
          ];
        }),
        headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
        border: pw.TableBorder.all(width: 0.5),
        cellAlignment: pw.Alignment.centerLeft,
        headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      );

    case "detail":
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: List.generate(data.length, (index) {
          final item = data[index];
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "No: ${item.noTransaksi} | Tanggal: ${item.tanggal}",
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Table.fromTextArray(
                headers: ['No', 'Nama Produk', 'Jumlah', 'Subtotal'],
                data: List.generate(item.detail.length, (i) {
                  final d = item.detail[i];
                  return [
                    (i + 1).toString(),
                    d.namaProduk,
                    d.jumlah.toStringAsFixed(0),
                    currencyFormatter.format(d.subtotal),
                  ];
                }),
                headerStyle:
                    pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
                border: pw.TableBorder.all(width: 0.5),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
              ),
              pw.SizedBox(height: 4),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Total: ${currencyFormatter.format(item.totalHarga)}",
                  style: pw.TextStyle(
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 10),
            ],
          );
        }),
      );

    default:
      return pw.Center(
        child: pw.Text(
          "Tipe laporan tidak dikenali.",
          style: pw.TextStyle(font: ttf),
        ),
      );
  }
}