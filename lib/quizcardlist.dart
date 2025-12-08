import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_play.dart';

class QuizCardList extends StatelessWidget {
  const QuizCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quizzes')
          .where('isFavorite', isEqualTo: true)
          .orderBy('createdAt', descending: true)

          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final quizzes = snapshot.data!.docs;
        if (quizzes.isEmpty) return const Center(child: Text("No quizzes available"));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index].data() as Map<String, dynamic>;
            final title = quiz['title'] ?? "Untitled Quiz";
            final description = quiz['description'] ?? "";

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizPlayPage(quizId: quizzes[index].id),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent[100],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 5,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(description, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
