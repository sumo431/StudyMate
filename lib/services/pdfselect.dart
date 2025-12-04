import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:capstone_2/notesview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PdfSelectPage extends StatefulWidget {
  final String noteId;
  const PdfSelectPage({super.key, required this.noteId});

  @override
  State<PdfSelectPage> createState() => _PdfSelectPageState();
}

class _PdfSelectPageState extends State<PdfSelectPage> {
  List<Reference> pdfFiles = [];
  Set<Reference> selectedPdfRefs = {};

  @override
  void initState() {
    super.initState();
    _loadPdfFiles();
  }

  Future<void> _loadPdfFiles() async {
    try {
      final result = await FirebaseStorage.instance.ref('pdf_recorder').listAll();
      setState(() {
        pdfFiles = result.items;
      });
    } catch (e) {
      print("Failed to load PDF files: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load PDFs.")),
      );
    }
  }

  Future<String?> _getDownloadUrl(Reference ref) async {
    try {
      return await ref.getDownloadURL();
    } catch (e) {
      print("Failed to get URL for ${ref.fullPath}: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select PDFs'),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      body: pdfFiles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          final file = pdfFiles[index];
          final isSelected = selectedPdfRefs.contains(file);

          return ListTile(
            key: ValueKey(file.fullPath),
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(file.name),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.orange)
                : const Icon(Icons.circle_outlined),
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedPdfRefs.remove(file);
                } else {
                  selectedPdfRefs.add(file);
                }
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.check),
        onPressed: () async {
          List<String> urls = [];
          for (var ref in selectedPdfRefs) {
            final url = await _getDownloadUrl(ref);
            if (url != null) urls.add(url);
          }
          if (urls.isNotEmpty) {
            final noteDoc = FirebaseFirestore.instance.collection('notes').doc(widget.noteId);
            await noteDoc.update({
              'pdfs': FieldValue.arrayUnion(urls),
            });
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotesViewPage()),
          );
        },
      ),
    );
  }
}