import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capstone_2/services/recordactivity.dart';

class QuizPlayPage extends StatefulWidget {
  final String quizId;

  const QuizPlayPage({super.key, required this.quizId});

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  int current = 0;
  int score = 0;
  int highScore = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Quiz not found")),
          );
        }

        final data = snapshot.data!;
        final List<Map<String, dynamic>> questions =
        List<Map<String, dynamic>>.from(data['questions'] ?? []);
        highScore = data['highScore'] ?? 0;

        if (questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(data['title'] ?? "Quiz")),
            body: const Center(child: Text("No questions available")),
          );
        }

        final question = questions[current];

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.orangeAccent,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['title'] ?? "Quiz"),
                Text("High: $highScore",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Q${current + 1}: ${question['question']}",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                ...List.generate(question['choices'].length, (i) {
                  final choiceText = question['choices'][i];
                  final answerIndex = question['answerIndex'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          if (i == answerIndex) score++;
                          if (current < questions.length - 1) {
                            setState(() => current++);
                          } else {
                            finishQuiz(score, questions.length, data);
                          }
                        },
                        child: Text(
                          choiceText,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
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
    final quizData = quiz.data() as Map<String, dynamic>?;
    if (quizData != null &&
        (quizData['highScore'] == null || score > quizData['highScore'])) {
      await quiz.reference.update({'highScore': score});
    }

    await recordUserActivity();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          AlertDialog(
            title: const Text("Result"),
            content: Text("$score / $total"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }
}