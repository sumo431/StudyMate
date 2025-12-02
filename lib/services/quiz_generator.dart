import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIQuizGenerator {
  static Future<List<String>> generateQuiz(String text) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) throw Exception("GEMINI_API_KEY not found in .env");

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );

    final prompt = """
You are a quiz generator. Create 5 multiple-choice questions from the following text.

TEXT:
$text

Return your output as plain text. Format each question like this:

Question 1: ...
A. choice1
B. choice2
C. choice3
D. choice4
Answer: A

Separate each question with a blank line. Do NOT include JSON or code blocks.
""";

    final response = await model.generateContent([Content.text(prompt)]);
    final rawText = response.text ?? "";

    print("AI raw response: $rawText");
    final quizList = rawText
        .split(RegExp(r'\n\s*\n'))
        .map((q) => q.trim())
        .where((q) => q.isNotEmpty)
        .toList();

    return quizList;
  }
}