// download_pdf_stub.dart
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

Future<void> downloadPdf(Uint8List bytes, String filename) async {
  // Desktop / Mobile
  final dir = await getDownloadsDirectory();
  if (dir == null) throw Exception("Tidak bisa menemukan folder Downloads");

  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes);
  if (kDebugMode) print("📁 File disimpan di: ${file.path}");
}
