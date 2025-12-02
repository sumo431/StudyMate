import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capstone_2/services/createQuizfromPdf.dart';
import 'package:capstone_2/button/togglebutton_make.dart';

class PdfQuizPage extends StatefulWidget {
  const PdfQuizPage({super.key});

  @override
  State<PdfQuizPage> createState() => _PdfQuizPageState();
}

class _PdfQuizPageState extends State<PdfQuizPage> {
  bool _isLoading = false;

  Future<void> _createQuiz(String pdfId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await createQuizFromPdf(pdfId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Success to make quiz")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("error: $e")),
      );
    } finally {
    setState(() {
    _isLoading = false;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make Quiz from PDF"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pdf_recorder')
                .where('uid', isEqualTo: uid)
                .snapshots(),
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                    }
                    final pdfs = snapshot.data?.docs ?? [];
                    if (pdfs.isEmpty) {
                          return const Center(child: Text("NO PDF here"));
                    }
                    return ListView.builder(
    itemCount: pdfs.length,
    itemBuilder: (context, index) {
    final pdf = pdfs[index];
    final title = pdf['title'] ?? "Untitle";

    return Card(
    margin: const EdgeInsets.all(8),
    child: ListTile(
    title: Text(title),
    trailing: ElevatedButton(
    onPressed: () => _createQuiz(pdf.id),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    ),
    child: const Text("Make quiz"),
    ),
    ),
    );
    },
    );
    },
    ),
    if (_isLoading)
    Container(
    color: Colors.black.withOpacity(0.3),
    child: const Center(child: CircularProgressIndicator()),
    ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(child: ToggleButton()),
          ),
    ],
    ),
    );

  }
}
