import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Assignment.dart';
import 'Home.dart';
import 'record.dart';
import 'package:capstone_2/Bottom/bnb_custom_painter.dart';


class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  String noteTitle = '';
  String? selectedImage;

  final List<String> availableImages = [
    'assets/image/math.jpg',
    'assets/image/music.jpg',
  ];

  Future<void> _saveNote() async {
    if (noteTitle.isEmpty || selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a title and select an image.")),
      );
      return;
    }

    // Store Firestore
    await FirebaseFirestore.instance.collection('notes').add({
      'Title': noteTitle,
      'createdAt': FieldValue.serverTimestamp(),
      'image': selectedImage,
      'pdfUrl': null
    });

    Navigator.pop(context, {
      'Title': noteTitle,
      'image': selectedImage,
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Note Title", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: "Enter note title",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orangeAccent),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              onChanged: (value) => noteTitle = value,
            ),
            const SizedBox(height: 24),
            const Text("Select an Image", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: availableImages.length,
                itemBuilder: (context, index) {
                  final image = availableImages[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImage = image;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedImage == image
                              ? Colors.orangeAccent
                              : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(image, width: 120, height: 100),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveNote,
                icon: const Icon(Icons.save),
                label: const Text("Save Note"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
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
                onPressed: ()async{
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecordPage()),
                  );
                  if (result != null) {
                    print("New note: $result");
                  }
                },
                backgroundColor: Colors.orange,
                child: Icon(
                    Icons.mic,
                    color:Colors.white),
                elevation: 0.1,
                shape: CircleBorder(),
              ),
            ),
            SizedBox(
              width: size.width,
              height: 80,
              child: Row(
                mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: IconButton(icon: Icon(Icons.home), onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 45),
                    child: IconButton(icon: Icon(Icons.note_add), onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotePage()),
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 45),
                    child: IconButton(icon: Icon(Icons.assignment), onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AssignmentPage()),
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: IconButton(icon: Icon(Icons.person), onPressed: () {}),
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
