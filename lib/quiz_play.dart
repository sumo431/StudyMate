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
        final questions = (data['questions'] as List<dynamic>?)
            ?.map((q) => q as Map<String, dynamic>)
            .toList() ??
            [];
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
                          setState(() {
                            if (i == question['answerIndex']) score++;

                            if (current < questions.length - 1) {
                              current++;
                            } else {
                              finishQuiz(score, questions.length);
                            }
                          });
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

  void finishQuiz(int score, int total) async {
    final quizRef =
    FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId);
    final quizSnapshot = await quizRef.get();
    final quizData = quizSnapshot.data() as Map<String, dynamic>?;

    if (quizData != null &&
        (quizData['highScore'] == null || score > quizData['highScore'])) {
      await quizRef.update({'highScore': score});
    }


    try {
      await recordUserActivity();
    } catch (e) {
      debugPrint('recordUserActivity failed: $e');
    }



    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Result"),
        content: Text("You scored $score / $total"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
