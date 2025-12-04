import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capstone_2/Pdf_viewer.dart';

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
          final String title = data['title'] ?? "Untitled";
          final List<dynamic> pdfs = data['pdfs'] ?? [];

          //pdfs = pdfs.reversed.toList();

          if (pdfs.isEmpty) {
            return const Center(
              child: Text("No PDFs uploaded yet."),
            );
          }

          return ListView.builder(
            itemCount: pdfs.length,
            itemBuilder: (context, index) {
              final url = pdfs[index] as String;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text(title),
                  subtitle: Text(
                    url ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfViewerPage(
                            url: url,
                            title: title,
                          ),
                        ),
                      );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}