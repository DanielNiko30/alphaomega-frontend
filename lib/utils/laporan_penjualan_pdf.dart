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

Future<void> generateLaporanJualPdf({
  required BuildContext context,
  required String reportTitle,
  required Map<String, dynamic> data,
}) async {
  try {
    await initializeDateFormatting('id_ID', null);

    final fontData =
        await rootBundle.load('assets/fonts/Roboto/static/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          final List<Map<String, dynamic>> channels = [];

          // Konversi map ke list
          data.forEach((key, value) {
            channels.add({
              'namaChannel': key.toUpperCase(),
              'laporan': value['laporan'] ?? [],
              'total': value['total'] ?? {},
            });
          });

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
            ...channels.map<pw.Widget>((channel) {
              final laporanList = channel['laporan'] as List<dynamic>;
              final totalChannel = channel['total'] ?? {};
              final totalPenjualan = _toNum(totalChannel['penjualan']);
              final totalHpp = _toNum(totalChannel['hpp']);
              final totalUntung = _toNum(totalChannel['untung']);

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: double.infinity,
                    color: PdfColors.grey300,
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Channel: ${channel['namaChannel']}',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // === Loop per transaksi ===
                  ...laporanList.map((transaksi) {
                    final tanggal = transaksi['tanggal'] ?? '-';
                    final nota = transaksi['id_htrans_jual']?.toString() ?? '-';
                    final detailList = (transaksi['detail'] as List?)
                            ?.cast<Map<String, dynamic>>() ??
                        [];

                    // deteksi total per nota (fallback ke total_nota, total, subtotal)
                    final totalNotaMap = transaksi['total_nota'] ??
                        transaksi['total'] ??
                        transaksi['subtotal'] ??
                        {};
                    final totalHppNota = _toNum(
                        totalNotaMap['total_hpp'] ?? totalNotaMap['hpp']);
                    final totalUntungNota = _toNum(
                        totalNotaMap['total_untung'] ?? totalNotaMap['untung']);

                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4),
                          child: pw.Text(
                            "Tanggal: $tanggal | Nota: $nota",
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),

                        // === Detail tabel per nota ===
                        pw.Table(
                          border: pw.TableBorder.all(
                            color: PdfColors.grey400,
                            width: 0.3,
                          ),
                          columnWidths: {
                            0: const pw.FlexColumnWidth(3),
                            1: const pw.FlexColumnWidth(1),
                            2: const pw.FlexColumnWidth(1),
                            3: const pw.FlexColumnWidth(1),
                            4: const pw.FlexColumnWidth(1),
                          },
                          children: [
                            pw.TableRow(
                              decoration: const pw.BoxDecoration(
                                  color: PdfColors.grey200),
                              children: [
                                _cellHeader("Barang", ttf),
                                _cellHeader("Qty", ttf),
                                _cellHeader("Harga Jual", ttf),
                                _cellHeader("HPP", ttf),
                                _cellHeader("Untung", ttf),
                              ],
                            ),
                            ...detailList.map((item) {
                              final nama = item['nama_product'] ?? '-';
                              final jumlah = item['jumlah']?.toString() ?? '0';
                              final hargaJual = _toNum(item['harga_jual']);
                              final hpp = _toNum(item['hpp']);
                              final untung = _toNum(item['untung']);

                              return pw.TableRow(children: [
                                _cellText(nama, ttf),
                                _cellText(jumlah, ttf),
                                _cellText(
                                    currencyFormatter.format(hargaJual), ttf),
                                _cellText(currencyFormatter.format(hpp), ttf),
                                _cellText(currencyFormatter.format(untung), ttf,
                                    align: pw.TextAlign.right),
                              ]);
                            }),
                          ],
                        ),

                        // === Subtotal per nota ===
                        pw.Container(
                          alignment: pw.Alignment.centerRight,
                          padding: const pw.EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: pw.Text(
                            "Subtotal : HPP: ${currencyFormatter.format(totalHppNota)} | Untung: ${currencyFormatter.format(totalUntungNota)}",
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 8),
                      ],
                    );
                  }),

                  // === Total per channel ===
                  pw.Container(
                    alignment: pw.Alignment.centerRight,
                    padding: const pw.EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                    color: PdfColors.grey200,
                    child: pw.Text(
                      "TOTAL ${channel['namaChannel']} : "
                      "Penjualan: ${currencyFormatter.format(totalPenjualan)} | "
                      "HPP: ${currencyFormatter.format(totalHpp)} | "
                      "Untung: ${currencyFormatter.format(totalUntung)}",
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 12),
                ],
              );
            }),
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

/// Konversi aman ke num (support null, string, int, double)
num _toNum(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value;
  return num.tryParse(value.toString()) ?? 0;
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
