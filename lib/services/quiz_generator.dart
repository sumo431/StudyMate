import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIQuizGenerator {
  static Future<List<Map<String, dynamic>>> generateQuiz(String text) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) throw Exception("GEMINI_API_KEY not found in .env");

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );

    final prompt = """
       Create 5 multiple-choice quiz questions from the following text.

        TEXT:$text

        Return ONLY JSON in this format:
        [
          {
            "question": "...",
            "choices": ["A", "B", "C", "D"],
            "answerIndex": 1
          }
        ]
    """;

    final response = await model.generateContent([Content.text(prompt)]);
    final jsonText = response.text ?? "[]";
    print("AI Response: $jsonText");

    final startIndex = jsonText.indexOf('[');
    final endIndex = jsonText.lastIndexOf(']') + 1;
    final cleanedJson = startIndex != -1 && endIndex != -1
        ? jsonText.substring(startIndex, endIndex)
        : "[]";

    return List<Map<String, dynamic>>.from(jsonDecode(cleanedJson));
  }
}
