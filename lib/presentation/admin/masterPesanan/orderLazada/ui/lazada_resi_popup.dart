import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../../controller/admin/lazada_controller.dart';
import '../../../../../utils/pdf_viewer_stub.dart'
    if (dart.library.html) '../../../../../utils/pdf_viewer_web.dart';

class LazadaResiPopup extends StatelessWidget {
  final String orderId;
  final Uint8List pdfBytes;

  const LazadaResiPopup({
    super.key,
    required this.orderId,
    required this.pdfBytes,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Resi Lazada - $orderId",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // PDF Viewer
            Expanded(
              child: buildPdfViewer(pdfBytes, orderId),
            ),

            // Tombol Download
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final filename = "resi_lazada_$orderId.pdf";
                  await LazadaController.downloadResi(pdfBytes, filename);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Resi disimpan sebagai $filename ✅")),
                    );
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text("Download Resi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
