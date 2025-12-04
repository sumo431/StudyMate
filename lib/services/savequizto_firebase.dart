import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> saveQuizToFirestore(String title, List<Map<String, dynamic>> quiz) async {
  final doc = await FirebaseFirestore.instance.collection('quizzes').add({
    'title': title,
    'questions': quiz,
    'highScore': 0,
    'createdAt': FieldValue.serverTimestamp(),
  });
  return doc.id;
}
