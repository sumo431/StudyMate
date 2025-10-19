import 'dart:io';
import 'package:capstone_2/services/wisper.dart';

Future<String> transcribeAllChunks(List<String> audioChunks) async {
  String fullText = '';
  for (final path in audioChunks) {
    final file = File(path);
    print("Checking file: $path exists=${await file.exists()} size=${await file.length()}");
    if (await file.exists()) {
      final text = await transcribeAudio(file);
      print("Chunk text: $text");
      fullText += text + "\n";
    }
  }
  return fullText;
}

