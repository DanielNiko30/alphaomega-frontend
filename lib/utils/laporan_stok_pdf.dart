import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'conditional_html_stub.dart'
    if (dart.library.html) 'conditional_html_real.dart' as html;

/// Generate PDF laporan stok
Future<void> generateLaporanStokPdf({
  required BuildContext context,
  required String reportTitle,
  required List<Map<String, dynamic>> data,
  String? periode,
}) async {
  try {
    await initializeDateFormatting('id_ID', null);
    final fontData =
        await rootBundle.load('assets/fonts/Roboto/static/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
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
            if (periode != null)
              pw.Text("Periode: $periode", textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 16),
            ...data.map<pw.Widget>((item) {
              final nama = item['nama_product'] ?? '-';
              final stokAwal = item['stok_awal'] ?? 0;
              final totalMasuk = item['total_masuk'] ?? 0;
              final detailMasuk = (item['detail_masuk'] as List?)
                      ?.cast<Map<String, dynamic>>() ??
                  [];
              final totalKeluar = item['total_keluar'] ?? 0;
              final detailKeluar = (item['detail_keluar'] as List?)
                      ?.cast<Map<String, dynamic>>() ??
                  [];
              final stokAkhir = item['stok_akhir'] ?? 0;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: double.infinity,
                    color: PdfColors.grey300,
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      nama,
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  // Stok Summary
                  pw.Table(
                    border: pw.TableBorder.all(
                        color: PdfColors.grey400, width: 0.3),
                    columnWidths: const {
                      0: pw.FlexColumnWidth(2),
                      1: pw.FlexColumnWidth(2),
                      2: pw.FlexColumnWidth(2),
                      3: pw.FlexColumnWidth(2),
                    },
                    children: [
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          _cellHeader("Stok Awal", ttf),
                          _cellHeader("Masuk", ttf),
                          _cellHeader("Keluar", ttf),
                          _cellHeader("Stok Akhir", ttf),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _cellText(stokAwal.toString(), ttf),
                          _cellText(totalMasuk.toString(), ttf),
                          _cellText(totalKeluar.toString(), ttf),
                          _cellText(stokAkhir.toString(), ttf),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  // Detail Masuk
                  if (detailMasuk.isNotEmpty)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Detail Masuk:",
                            style: pw.TextStyle(
                                font: ttf,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                                color: PdfColors.green)),
                        pw.Table(
                          border: pw.TableBorder.all(
                              color: PdfColors.grey400, width: 0.3),
                          columnWidths: const {
                            0: pw.FlexColumnWidth(2),
                            1: pw.FlexColumnWidth(1),
                            2: pw.FlexColumnWidth(2),
                          },
                          children: [
                            pw.TableRow(
                              decoration: const pw.BoxDecoration(
                                  color: PdfColors.grey200),
                              children: [
                                _cellHeader("Tanggal", ttf),
                                _cellHeader("Jumlah", ttf),
                                _cellHeader("Invoice", ttf),
                              ],
                            ),
                            ...detailMasuk.map((d) {
                              final tanggal = d['tanggal'] is DateTime
                                  ? d['tanggal']
                                  : DateTime.tryParse(
                                          d['tanggal'].toString()) ??
                                      DateTime.now();
                              return pw.TableRow(children: [
                                _cellText(dateFormatter.format(tanggal), ttf),
                                _cellText(d['jumlah']?.toString() ?? '0', ttf),
                                _cellText(d['invoice'] ?? '-', ttf),
                              ]);
                            }),
                          ],
                        ),
                      ],
                    ),
                  // Detail Keluar
                  if (detailKeluar.isNotEmpty)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 4),
                        pw.Text("Detail Keluar:",
                            style: pw.TextStyle(
                                font: ttf,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                                color: PdfColors.red)),
                        pw.Table(
                          border: pw.TableBorder.all(
                              color: PdfColors.grey400, width: 0.3),
                          columnWidths: const {
                            0: pw.FlexColumnWidth(2),
                            1: pw.FlexColumnWidth(1),
                          },
                          children: [
                            pw.TableRow(
                              decoration: const pw.BoxDecoration(
                                  color: PdfColors.grey200),
                              children: [
                                _cellHeader("Tanggal", ttf),
                                _cellHeader("Jumlah", ttf),
                              ],
                            ),
                            ...detailKeluar.map((d) {
                              final tanggal = d['tanggal'] is DateTime
                                  ? d['tanggal']
                                  : DateTime.tryParse(
                                          d['tanggal'].toString()) ??
                                      DateTime.now();
                              return pw.TableRow(children: [
                                _cellText(dateFormatter.format(tanggal), ttf),
                                _cellText(d['jumlah']?.toString() ?? '0', ttf),
                              ]);
                            }),
                          ],
                        ),
                      ],
                    ),
                  pw.SizedBox(height: 8),
                ],
              );
            }).toList(),
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

pw.Widget _cellHeader(String text, pw.Font ttf) => pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: ttf,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
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

Future<void> _savePdfToFile(List<int> pdfBytes, String fileName) async {
  try {
    Directory? dir;
    if (Platform.isAndroid || Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
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
