import 'package:flutter/material.dart';
import 'package:capstone_2/notesview.dart';
import 'package:capstone_2/pdfview.dart';
import 'package:capstone_2/quizlist.dart';

class ToggleButton extends StatefulWidget {
  const ToggleButton({super.key});

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

const double width = 300.0;
const double height = 60.0;
const Color selectedColor = Colors.white;
const Color normalColor = Colors.black54;

class _ToggleButtonState extends State<ToggleButton> {
  double xAlign = -1;
  Color notesColor = selectedColor;
  Color pdfColor = normalColor;
  Color settingsColor = normalColor;

  void _switchTab(double align, int tabIndex) {
    setState(() {
      xAlign = align;
      notesColor = tabIndex == 0 ? selectedColor : normalColor;
      pdfColor = tabIndex == 1 ? selectedColor : normalColor;
      settingsColor = tabIndex == 2 ? selectedColor : normalColor;
    });

    Widget page = const NotesViewPage();
    switch (tabIndex) {
    case 0:
      page = NotesViewPage();
      break;
    case 1:
      page = PdfViewPage();
      break;
    case 2:
      page = QuizListPage();
      break;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: Alignment(xAlign, 0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                width: width / 3,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _switchTab(-1, 0),
              child: Align(
                alignment: const Alignment(-1, 0),
                child: Container(
                  width: width / 3,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Text(
                    'Notes',
                    style: TextStyle(
                      color: notesColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _switchTab(0, 1),
              child: Align(
                alignment: const Alignment(0, 0),
                child: Container(
                  width: width / 3,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Text(
                    'PDFs',
                    style: TextStyle(
                      color: pdfColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _switchTab(1, 2),
              child: Align(
                alignment: const Alignment(1, 0),
                child: Container(
                  width: width / 3,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Text(
                    'Quiz',
                    style: TextStyle(
                      color: settingsColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
