import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PdfGenerator {
  static Future<File?> createPdf(String title, String content) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(content, style: const pw.TextStyle(fontSize: 16)),
              ],
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final file = File('${dir.path}/$safeTitle.pdf');

      await file.writeAsBytes(await pdf.save());

      if (file.existsSync()) {
        print('success: ${file.path}');
        return file;
      } else {
        print('fail');
        return null;
      }
    } catch (e) {
      print('error in making pdf $e');
      return null;
    }
  }

  /// PDF を Firebase Storage にアップロードする
  static Future<String?> uploadToFirebase(File pdfFile, String noteId) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('notes/$noteId.pdf');
      final uploadTask = ref.putFile(pdfFile);

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      print('アップロード成功: $url');
      return url;
    } catch (e) {
      print('Firebase アップロード中にエラー: $e');
      return null;
    }
  }
}
