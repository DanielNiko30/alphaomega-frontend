import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

Widget buildPdfViewer(Uint8List pdfBytes, String? orderSn) {
  // Untuk Windows / Mobile / fallback
  return SfPdfViewer.memory(pdfBytes);
}
