import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_screen.dart';
import 'video_lesson_screen.dart';
import 'maths/maths_lesson_player_screen.dart';
import 'maths/golden_mango_lesson_screen.dart';

class LessonListScreen extends StatelessWidget {
  final String subject;
  final Color color;
  final int studentGrade;

  const LessonListScreen({
    super.key,
    required this.subject,
    required this.color,
    required this.studentGrade,
  });

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('lessons')
        .where('subject', isEqualTo: subject)
        .where('grade', isEqualTo: 5);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text("$subject (Grade 5)"),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No Grade 5 lessons yet.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String title = data['title'] ?? subject;
              String lessonId = docs[index].id;
              String? videoUrl = data['videoUrl'];
              String description = data['description'] ?? "Click to start lesson";

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    radius: 30,
                    child: Icon(Icons.star, color: color, size: 30),
                  ),
                  title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    if (subject == "Mathematics") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GoldenMangoLessonScreen(studentGrade: studentGrade),
                        ),
                      );
                      return;
                    }

                    if (videoUrl != null && videoUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoLessonScreen(
                            title: title,
                            videoUrl: videoUrl,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            lessonId: lessonId,
                            subject: subject,
                            grade: studentGrade,
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
