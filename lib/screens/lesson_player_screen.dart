import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'quiz_screen.dart';

class LessonPlayerScreen extends StatefulWidget {
  final String lessonId;
  final String title;
  final String content;
  final String subject;
  final int grade;

  const LessonPlayerScreen({
    super.key,
    required this.lessonId,
    required this.title,
    required this.content,
    required this.subject,
    required this.grade,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  // 1. Initialize the Audio Player
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  @override
  void dispose() {
    flutterTts.stop(); // Stop audio if user leaves screen
    super.dispose();
  }

  // Function to handle speaking
  Future<void> _speak() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() => isSpeaking = false);
    } else {
      setState(() => isSpeaking = true);
      await flutterTts.setLanguage("en-US"); // Use 'si-LK' for Sinhala later if supported
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(widget.content);

      flutterTts.setCompletionHandler(() {
        setState(() => isSpeaking = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Column(
        children: [
          // 1. Image Area (Placeholder)
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.orange.shade100,
            child: const Icon(Icons.menu_book_rounded, size: 80, color: Colors.orange),
          ),

          // 2. Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Audio Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Read Lesson",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(
                          isSpeaking ? Icons.stop_circle : Icons.volume_up,
                          color: Colors.blue,
                          size: 32,
                        ),
                        onPressed: _speak,
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  // The Actual Text from Firebase
                  Text(
                    widget.content,
                    style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),

          // 3. Start Quiz Button
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      lessonId: widget.lessonId,
                      subject: widget.subject,
                      grade: widget.grade,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Start Quiz",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}