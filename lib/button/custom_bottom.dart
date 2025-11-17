import 'package:flutter/material.dart';
import 'package:capstone_2/button/bnb_custom_painter.dart';
import 'package:capstone_2/savenote.dart';
import 'package:capstone_2/notesview.dart';
import 'package:capstone_2/record.dart';
import 'package:capstone_2/Home.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecordPage()),
                );
              },
              backgroundColor: Colors.orange,
              elevation: 0.1,
              shape: const CircleBorder(),
              child: const Icon(Icons.mic, color: Colors.white),
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
                      );//home
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
                        MaterialPageRoute(builder: (context) => const SaveNotePage()),
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
                        MaterialPageRoute(builder: (context) => const NotesViewPage()),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      //I am cooking about here
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
