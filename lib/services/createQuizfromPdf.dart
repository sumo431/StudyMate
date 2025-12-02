import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capstone_2/services/quiz_generator.dart';

Future<String> saveQuizToFirestore(String title, List<String> quiz) async {
  if (quiz.isEmpty) {
    print("Quiz is empty. Not saving.");
    return "";
  }

  final doc = await FirebaseFirestore.instance.collection('quizzes').add({
    'title': title,
    'questions': quiz,
    'highScore': 0,
    'createdAt': FieldValue.serverTimestamp(),
  });

  print("Quiz saved with ID: ${doc.id}");
  return doc.id;
}

Future<void> createQuizFromPdf(String pdfId) async {
  final pdfDoc = await FirebaseFirestore.instance
      .collection('pdf_recorder')
      .doc(pdfId)
      .get();

  final transcript = pdfDoc['transcript'] ?? "";
  final title = pdfDoc['title'] ?? "Untitled Quiz";

  if (transcript.isEmpty) {
    print("Transcript is empty. Cannot create quiz.");
    return;
  }
  final quiz = await AIQuizGenerator.generateQuiz(transcript);
  await saveQuizToFirestore(title, quiz);
}
