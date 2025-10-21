import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

Future<void> savePdf(List<int> pdfBytes, String fileName) async {
  try {
    Directory? dir;
    if (Platform.isAndroid || Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dir = await getDownloadsDirectory(); // path_provider >=2.0.0
    }

    final file = File('${dir!.path}/$fileName.pdf');
    await file.writeAsBytes(pdfBytes);
    debugPrint('PDF saved at ${file.path}');
  } catch (e) {
    debugPrint('Error saving PDF: $e');
  }
}
