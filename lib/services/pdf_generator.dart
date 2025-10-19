import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PdfGenerator {
  static Future<File> createPdf(String title, String content) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text(content, style: const pw.TextStyle(fontSize: 16)),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${title.replaceAll(" ", "_")}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<String> uploadToFirebase(File pdfFile, String noteId) async {
    final ref = FirebaseStorage.instance.ref().child('notes/$noteId.pdf');
    final uploadTask = ref.putFile(pdfFile);
    await uploadTask;
    return await ref.getDownloadURL();
  }
}
