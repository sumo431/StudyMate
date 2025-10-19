import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Bottom/bnb_custom_painter.dart';
import 'Quiz_UI.dart';
import 'record.dart';
import 'note.dart';
import 'Assignment.dart';
import 'Home.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> quizzes = [];
  bool isLoading = false;

  Future<String?> pickAndExtractPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      String text = await ReadPdfText.getPDFtext(filePath);
      return text;
    }
    return null;
  }



  Future<void> generateQuiz(String text) async {
    setState(() {
      isLoading = true;
    });

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) throw Exception("GEMINI_API_KEYが.envにありません");

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gemini-1.5-flash-latest",
        "messages": [
          {"role": "system", "content": "You are a quiz-making AI."},
          {
            "role": "user",
            "content": "Please create eight multiple choice questions in JSON format from the text below.:\n$text"
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String content = data['choices'][0]['message']['content'];
      List parsed = jsonDecode(content);
      setState(() {
        quizzes = List<Map<String, dynamic>>.from(parsed);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception(
          "Fail call GEMINI_AI: ${response.statusCode}, ${response.body}");
    }
  }

  Future<void> handlePdf() async {
    String? text = await pickAndExtractPdf();
    if (text != null && text.isNotEmpty) {
      await generateQuiz(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : quizzes.isEmpty
          ? Center(
        child: ElevatedButton(
          onPressed: handlePdf,
          child: Text("Select a PDF and create a quiz"),
        ),
      )
          : ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          var quiz = quizzes[index];
          return Card(
            margin:
            EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${index + 1}. ${quiz['question']}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  ...quiz['options'].map<Widget>((option) {
                    return Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          bool correct = option == quiz['answer'];
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                              Text(correct ? "Correct！" : "Incorrect"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Text(option),
                      ),
                    );
                  }).toList()
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.white10,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(size.width, 80),
              painter: BNBCustomPainter(),
            ),
            Center(
              heightFactor: 0.6,
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecordPage()),
                  );
                  if (result != null) {
                    print("New note: $result");
                  }
                },
                backgroundColor: Colors.orange,
                child: const Icon(Icons.mic, color: Colors.white),
                elevation: 0.1,
                shape: const CircleBorder(),
              ),
            ),
            SizedBox(
              width: size.width,
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 45),
                    child: IconButton(
                      icon: const Icon(Icons.note_add),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotePage()),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 45),
                    child: IconButton(
                      icon: const Icon(Icons.assignment),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AssignmentPage()),
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Icon(Icons.person),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
