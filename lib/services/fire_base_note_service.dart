import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveNoteToFirebase({
  required String className,
  required String summaryText,
  required String fullTranscript,
}) async {
  final notesRef = FirebaseFirestore.instance.collection('notes');

  await notesRef.add({
    'className': className,
    'summary': summaryText,
    'transcript': fullTranscript,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
