import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';

class PdfListPage extends StatelessWidget {
  final String noteId;

  const PdfListPage({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF List"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('notes')
            .doc(noteId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> pdfs = data['pdfs'] ?? [];

          // 🔥 新しい順にする
          pdfs = pdfs.reversed.toList();

          if (pdfs.isEmpty) {
            return const Center(
              child: Text("No PDFs uploaded yet."),
            );
          }

          return ListView.builder(
            itemCount: pdfs.length,
            itemBuilder: (context, index) {
              final pdfUrl = pdfs[index];

              return ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text("PDF ${index + 1}"),
                onTap: () async {
                  await OpenFile.open(pdfUrl);
                },
              );
            },
          );
        },
      ),
    );
  }
}