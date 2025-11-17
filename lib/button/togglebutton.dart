import 'package:flutter/material.dart';
import 'package:capstone_2/notesview.dart';
import 'package:capstone_2/pdfview.dart';

class ToggleButton extends StatefulWidget {
  const ToggleButton({super.key});

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

const double width = 300.0;
const double height = 60.0;
const double loginAlign = -1;
const double signInAlign = 1;
const Color selectedColor = Colors.white;
const Color normalColor = Colors.black54;

class _ToggleButtonState extends State<ToggleButton> {
  double xAlign = loginAlign;
  Color notesColor = selectedColor;
  Color pdfColor = normalColor;

  void _switchTab(double align, bool isNotes) {
    setState(() {
      xAlign = align;
      notesColor = isNotes ? selectedColor : normalColor;
      pdfColor = isNotes ? normalColor : selectedColor;
    });

    // アニメーション後に画面遷移
    Future.delayed(const Duration(milliseconds: 300), () {
      if (isNotes) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotesViewPage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PdfViewPage()),
        );
      }
    });
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
                width: width * 0.5,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ),
            // Notes ボタン
            GestureDetector(
              onTap: () => _switchTab(loginAlign, true),
              child: Align(
                alignment: const Alignment(-1, 0),
                child: Container(
                  width: width * 0.5,
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
              onTap: () => _switchTab(signInAlign, false),
              child: Align(
                alignment: const Alignment(1, 0),
                child: Container(
                  width: width * 0.5,
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
          ],
        ),
      ),
    );
  }
}
