import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capstone_2/button/custom_bottom.dart';

class SaveNotePage extends StatefulWidget {
  const SaveNotePage({super.key});

  @override
  State<SaveNotePage> createState() => _SaveNotePageState();
}

class _SaveNotePageState extends State<SaveNotePage> {
  final TextEditingController _titleController = TextEditingController();
  String? selectedImage;

  final List<String> availableImages = [
    'assets/image/math.jpg',
    'assets/image/music.jpg',
    'assets/image/dog.jpg',
    'assets/image/flowerandgirl.jpg',
  ];

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty || selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a title and select an image.")),
      );
      return;
    }

    try {
      final docRef = await FirebaseFirestore.instance.collection('notes').add({
        'Title': _titleController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'image': selectedImage,
        'pdfUrl': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note saved successfully!")),
      );

      Navigator.pop(context, {
        'id': docRef.id,
        'Title': _titleController.text,
        'image': selectedImage,
      });

    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save note: ${e.code}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Note Title',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter note title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select an Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
                              ? Colors.orange
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
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Note'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
