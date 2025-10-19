import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String> summarizeText(String fullText) async {
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  if (apiKey == null) throw Exception("Missing GEMINI_API_KEY");

  final url = Uri.parse(
    "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=$apiKey",
  );

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      "contents": [
        {
          "parts": [
            {
              "text":
              "Summarize the following meeting notes concisely in the Cornell note-taking format:\n\n$fullText"
            }
          ]
        }
      ]
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data["candidates"][0]["content"]["parts"][0]["text"];
  } else {
    throw Exception(
        "Summarize failed: ${response.statusCode} ${response.body}");
  }
}
