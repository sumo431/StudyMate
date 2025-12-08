import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PdfGenerator {
  static Future<File?> createPdfFromChunks(
      String title,
      List<String> chunkTexts,
      ) async {
    try {
      final pdf = pw.Document();
      for (var i = 0; i < chunkTexts.length; i++) {
        final chunk = chunkTexts[i];
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (i == 0)
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    chunk,
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                ],
              );
            },
          ),
        );
      }

      final dir = await getApplicationDocumentsDirectory();
      final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final file = File('${dir.path}/$safeTitle.pdf');

      await file.writeAsBytes(await pdf.save());

      if (file.existsSync()) {
        print('PDF success: ${file.path}');
        return file;
      } else {
        print('PDF fail');
        return null;
      }
    } catch (e) {
      print('Error in making pdf: $e');
      return null;
    }
  }

  static Future<String?> uploadToFirebase(File pdfFile, String noteId) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('notes/$noteId.pdf');
      final uploadTask = ref.putFile(pdfFile);

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      print('Upload success: $url');
      return url;
    } catch (e) {
      print('Error uploading to Firebase: $e');
      return null;
    }
  }
}
