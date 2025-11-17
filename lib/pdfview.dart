import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capstone_2/button/togglebutton.dart';
import 'package:capstone_2/button/custom_bottom.dart';
import 'package:open_file/open_file.dart';

class PdfViewPage extends StatefulWidget {
  const PdfViewPage({super.key});

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My PDFs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // PDFリスト部分
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pdfs')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No PDFs yet.\nRecord something to create one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              final pdfs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: pdfs.length,
                itemBuilder: (context, index) {
                  final pdf = pdfs[index].data() as Map<String, dynamic>;
                  final title = pdf['title'] ?? 'Untitled';
                  final url = pdf['pdfUrl'];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                      title: Text(title),
                      subtitle: Text(
                        url ?? '',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      onTap: () async {
                        if (url != null) {
                          await OpenFile.open(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("PDF URL not found.")),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(child: ToggleButton()),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
