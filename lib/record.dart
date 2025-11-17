import 'package:flutter/material.dart';
import 'package:capstone_2/services/record_service.dart';
import 'package:capstone_2/button/custom_bottom.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final RecordService _recordService = RecordService();

  Future<void> _toggleRecording() async {
    if (_recordService.isRecording) {
      await _recordService.stopRecording();
      await _recordService.processRecording();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recording complete!")),
      );
      setState(() {});
    } else {
      await _recordService.startRecordingLoop();

      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: _toggleRecording,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _recordService.isRecording
                  ? Colors.grey.shade200
                  : Colors.grey.shade300,
            ),
            child: Icon(
              Icons.mic,
              size: 100,
              color: _recordService.isRecording
                  ? Colors.red
                  : Colors.white,
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
