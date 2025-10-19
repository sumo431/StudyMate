import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PdfStorageService {
  /// 音声文字起こしと要約をPDFにし、Firebase StorageとFirestoreに保存する
  static Future<void> savePdfToFirebase({
    required String transcript,
    required String summary,
  }) async {
    final pdf = pw.Document();

    // PDF 内容
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 20),
            pw.Text('Recording Summary',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Transcription:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Text(transcript, style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 15),
            pw.Text('Summary:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Text(summary, style: pw.TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );

    try {
      // 一時フォルダに保存
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      print("✅ PDF temporarily saved: ${file.path}");

      // Firebase Storage にアップロード
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('pdfs/record_${DateTime.now().millisecondsSinceEpoch}.pdf');

      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print('Uploaded to Firebase Storage: $downloadUrl');

      await FirebaseFirestore.instance.collection('pdf_recorder').add({
        'summary': summary,
        'timestamp': Timestamp.now(),
        'url': downloadUrl,
      });

      print('Firestore document created successfully!');
    } catch (e) {
      print('Failed to save PDF: $e');
    }
  }
}
