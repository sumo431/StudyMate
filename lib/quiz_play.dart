import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capstone_2/services/recordactivity.dart';

class QuizPlayPage extends StatefulWidget {
  final String? quizId;

  const QuizPlayPage({super.key, required this.quizId});

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  int current = 0;
  int score = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.quizId == null || widget.quizId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: const Center(child: Text("Quiz ID is missing.")),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Quiz not found.")),
          );
        }

        final data = snapshot.data!;
        final List<String> questions =
        List<String>.from(data['questions'] ?? []);

        if (questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(data['title'] ?? "Quiz")),
            body: const Center(child: Text("No questions available.")),
          );
        }

        final String q = questions[current];

        return Scaffold(
          appBar: AppBar(title: Text(data['title'] ?? "Quiz")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Q${current + 1}: $q",
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                ...List.generate(4, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (i == 0) score++;
                        if (current < questions.length - 1) {
                          setState(() => current++);
                        } else {
                          finishQuiz(score, questions.length, data);
                        }
                      },
                      child: Text(String.fromCharCode(65 + i)),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void finishQuiz(int score, int total, DocumentSnapshot quiz) async {
    if (quiz.data() != null &&
        (quiz['highScore'] == null || score > quiz['highScore'])) {
      await quiz.reference.update({'highScore': score});
    }

    recordUserActivity();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Result"),
        content: Text("$score / $total"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}