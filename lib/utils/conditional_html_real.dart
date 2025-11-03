// File ini hanya dipakai kalau build di web
import 'dart:typed_data';
import 'dart:html' as html;

void downloadPdfWeb(List<int> bytes, String filename) {
  final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
