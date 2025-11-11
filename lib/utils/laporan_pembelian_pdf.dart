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

// Gunakan import dart:html hanya di web
import 'conditional_html_stub.dart'
    if (dart.library.html) 'conditional_html_real.dart' as html;

Future<void> generateReportPdf({
  required BuildContext context,
  required String reportTitle,
  required String reportType, // 'harian' atau 'per_nota'
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
      html.downloadPdfWeb(pdfBytes, "$reportTitle.pdf");
    } else {
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

  // 1️⃣ Kelompokkan data per pemasok
  final Map<String, List<Map<String, dynamic>>> groupedData = {};
  for (final item in data) {
    final pemasok = item['pemasok'] ?? 'Tanpa Pemasok';
    groupedData.putIfAbsent(pemasok, () => []);
    groupedData[pemasok]!.add(item);
  }

  double grandTotal = 0;

  // 2️⃣ Bangun tampilan mirip contoh laporan
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      for (final entry in groupedData.entries)
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              color: PdfColors.grey300,
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: pw.Text(
                entry.key,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 4),

            // 3️⃣ Baris detail per transaksi
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.3),
              columnWidths: {
                0: const pw.FixedColumnWidth(60),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
                5: const pw.FlexColumnWidth(1.2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _cellHeader("Tanggal", ttf),
                    _cellHeader("Invoice", ttf),
                    _cellHeader("Barang", ttf),
                    _cellHeader("Jumlah", ttf),
                    _cellHeader("Harga", ttf),
                    _cellHeader("Subtotal", ttf),
                  ],
                ),
                ...entry.value.map((item) {
                  final subtotal = (item['subtotal'] ?? 0).toDouble();
                  return pw.TableRow(children: [
                    _cellText(item['waktu'] ?? "-", ttf),
                    _cellText(item['invoice'] ?? "-", ttf),
                    _cellText(item['barang'] ?? "-", ttf),
                    _cellText("${item['jumlah']} ${item['satuan'] ?? ''}", ttf),
                    _cellText(
                        currencyFormatter.format(item['harga_beli']), ttf),
                    _cellText(currencyFormatter.format(subtotal), ttf,
                        align: pw.TextAlign.right),
                  ]);
                }),
              ],
            ),

            // 4️⃣ Subtotal per pemasok
            pw.Container(
              alignment: pw.Alignment.centerRight,
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: pw.Text(
                "Sub Total: ${currencyFormatter.format(entry.value.fold<double>(0, (sum, e) => sum + (e['subtotal'] ?? 0).toDouble()))}",
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
          ],
        ),

      // 5️⃣ Grand total
      pw.Divider(),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          "Total Pembelian: ${currencyFormatter.format(
            data.fold<double>(
                0, (sum, e) => sum + (e['subtotal'] ?? 0).toDouble()),
          )}",
          style: pw.TextStyle(
            font: ttf,
            fontWeight: pw.FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    ],
  );
}

pw.Widget _cellHeader(String text, pw.Font ttf) => pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            font: ttf, fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
    );

pw.Widget _cellText(String text, pw.Font ttf,
        {pw.TextAlign align = pw.TextAlign.left}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(font: ttf, fontSize: 10),
      ),
    );
