import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_auth/firebase_auth.dart';

import 'transcribe_service.dart';
import 'summarize.dart';

class RecordService {
  final AudioRecorder _recorder = AudioRecorder();
  final List<String> _audioChunks = [];
  bool isRecording = false;

  List<String> get audioChunks => _audioChunks;

  Future<String> _getNewFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    await Directory(dir.path).create(recursive: true);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = p.join(dir.path, "chunk_$timestamp.wav");
    _audioChunks.add(path);
    return path;
  }

  Future<void> startRecordingLoop() async {
    if (!await _recorder.hasPermission()) {
      throw Exception("No record permission");
    }

    isRecording = true;
    const chunkDuration = Duration(minutes: 1);

    while (isRecording) {
      final filePath = await _getNewFilePath();

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: filePath,
      );

      if (kDebugMode) print("Recording: $filePath");

      await Future.delayed(chunkDuration);

      if (!isRecording) break;

      await _recorder.stop();
      if (kDebugMode) print("Chunk saved: $filePath");
    }
  }

  Future<void> stopRecording() async {
    isRecording = false;
    await _recorder.stop();
  }

  Future<void> processRecording() async {
    final chunksCopy = List<String>.from(_audioChunks);

    final transcript = await transcribeAllChunks(chunksCopy);
    final summary = await summarizeText(transcript);
    await _saveAsPdf(transcript, summary);
  }

  Future<void> _saveAsPdf(String transcript, String summary) async {
    final pdf = pw.Document();

    // Summary page
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Summary',
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(summary, style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );

    // Transcript page
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Transcript',
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(transcript, style: const pw.TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );

    // Save
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final fileName = "record_${now.toIso8601String().replaceAll(':','-')}.pdf";
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Upload
    final ref = FirebaseStorage.instance.ref().child('pdf_recorder/$fileName');
    final snapshot = await ref.putFile(file);
    final url = await snapshot.ref.getDownloadURL();

    // Firestore save
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('pdf_recorder').add({
      'title': fileName,
      'summary': summary,
      'transcript': transcript,
      'timestamp': FieldValue.serverTimestamp(),
      'url': url,
      'uid': user?.uid,
    });
  }
}
