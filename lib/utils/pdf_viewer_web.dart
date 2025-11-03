// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

Widget buildPdfViewer(Uint8List pdfBytes, String orderSn) {
  // ✅ buat blob dengan MIME type PDF
  final pdfBlob = html.Blob([pdfBytes], 'application/pdf');
  final pdfUrl = html.Url.createObjectUrlFromBlob(pdfBlob);
  final viewType = 'pdf-viewer-$orderSn';

  // ✅ register iframe viewer
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final iframe = html.IFrameElement()
      ..src = pdfUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
    return iframe;
  });

  return HtmlElementView(viewType: viewType);
}
