import 'dart:io';
import 'dart:async';
import 'package:capstone_2/services/summerize.dart';
import 'Assignment.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'note.dart';
import 'services/transcribe_service.dart';
import 'Bottom/bnb_custom_painter.dart';
import 'Home.dart';
import 'package:pdf/widgets.dart' as pw;


class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool isRecording = false;
  List<String> _audioChunks = [];
  String? _currentFilePath;

  Future<void> _saveAsPdf(String transcript, String summary) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 20),
            pw.Text('Summary', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(summary, style: pw.TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('pdfs/${file.uri.pathSegments.last}');
    await storageRef.putFile(file);

    final downloadUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance.collection('pdf_recorder').add({
      'summary': summary,
      'timestamp': FieldValue.serverTimestamp(),
      'url': downloadUrl,
    });

    print('PDF uploaded to Firebase and Firestore: $downloadUrl');
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> _getNewFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = p.join(dir.path, "chunk_$timestamp.m4a");
    _audioChunks.add(path);
    return path;
  }

  Future<void> _startChunkRecording() async {
    if (!await _audioRecorder.hasPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No record permission")),
      );
      return;
    }

    isRecording = true;
    setState(() {});

    const chunkDuration = Duration(minutes: 1);

    while (isRecording) {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentFilePath = p.join(dir.path, "chunk_$timestamp.wav");//order
      _audioChunks.add(_currentFilePath!);


      // start recording
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _currentFilePath!,
      );
      print("Recording started: $_currentFilePath");

      // 1 min record
      await Future.delayed(chunkDuration);

      if (!isRecording) break;

      // stop recording
      await _audioRecorder.stop();
      await Future.delayed(const Duration(milliseconds: 200));
      print("Recording stopped: $_currentFilePath");

      // check file
      final file = File(_currentFilePath!);
      if (await file.exists() && await file.length() > 0) {
        print("File exists and has data: ${file.path} (${await file.length()} bytes)");
      } else {
        print("Recording failed or empty: ${file.path}");
      }
    }
  }

  Future<void> _stopRecording() async {
    isRecording = false;
    await _audioRecorder.stop();
    setState(() {});

    for (var path in _audioChunks) {
      final file = File(path);
      if (await file.exists()) {
        print("Found file: ${file.path}, size = ${await file.length()} bytes");
      } else {
        print("Missing file: $path");
      }
    }

    try {
      print("Step 1: Transcribing...");
      final transcript = await transcribeAllChunks(_audioChunks);
      print("Transcript length: ${transcript.length}");
      print("Transcription successful!\n$transcript");

      print("Step 2: Summarizing...");
      final summary = await summarizeText(transcript);
      print("Summary successful!\n$summary");

      print("Step 2: Make PDF...");
      await _saveAsPdf(transcript, summary);
      print("Make PDF successful!");

    } catch (e, stack) {
      print("Error occurred: $e");
      print(stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error during transcription: $e")),
        );
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (isRecording) {
      await _stopRecording();
    } else {
      await _startChunkRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: _toggleRecording,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
              isRecording ? Colors.grey.shade200 : Colors.grey.shade300,
            ),
            child: Icon(
              Icons.mic,
              size: 100,
              color: isRecording ? Colors.red : Colors.white,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white10,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(size.width, 80),
              painter: BNBCustomPainter(),
            ),
            Center(
              heightFactor: 0.6,
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecordPage()),
                  );
                  if (result != null) {
                    print("New note: $result");
                  }
                },
                backgroundColor: Colors.orange,
                child: const Icon(Icons.mic, color: Colors.white),
                elevation: 0.1,
                shape: const CircleBorder(),
              ),
            ),
            SizedBox(
              width: size.width,
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 45),
                    child: IconButton(
                      icon: const Icon(Icons.note_add),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotePage()),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 45),
                    child: IconButton(
                      icon: const Icon(Icons.assignment),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AssignmentPage()),
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Icon(Icons.person),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
