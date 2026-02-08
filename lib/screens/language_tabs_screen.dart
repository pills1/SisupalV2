import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_screen.dart';

class LanguageTabsScreen extends StatelessWidget {
  final int grade;

  const LanguageTabsScreen({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Language Practice (Grade $grade)"),
          backgroundColor: Colors.teal,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.language), text: "English"),
              Tab(icon: Icon(Icons.translate), text: "Tamil"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: English List
            _LessonList(subject: 'English', grade: grade),

            // Tab 2: Tamil List
            _LessonList(subject: 'Tamil', grade: grade),
          ],
        ),
      ),
    );
  }
}

// Internal Widget to show the list for a specific subject
class _LessonList extends StatelessWidget {
  final String subject;
  final int grade;

  const _LessonList({
    required this.subject,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    // --- FIX: ADDED GRADE FILTERING LOGIC HERE ---
    Query query = FirebaseFirestore.instance
        .collection('lessons')
        .where('subject', isEqualTo: subject);

    // If the student is NOT Grade 5, only show their specific grade.
    if (grade != 5) {
      query = query.where('grade', isEqualTo: grade);
    }
    // ---------------------------------------------

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final lessons = snapshot.data!.docs;

        // --- NEW: Extra Filter for Grade 5 ---
        // (Optional) Hide lower grade lessons from Grade 5 students logic
        var filteredLessons = lessons.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          int? lessonGrade = data['grade'];
          // If I am Grade 5, hide Grade 3 & 4 stuff so it's not cluttered
          if (grade == 5 && (lessonGrade == 3 || lessonGrade == 4)) {
            return false;
          }
          return true;
        }).toList();

        if (filteredLessons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Text("No Grade $grade lessons yet!", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredLessons.length,
          itemBuilder: (context, index) {
            var data = filteredLessons[index].data() as Map<String, dynamic>;

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade100,
                  child: Text("${index + 1}", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                ),
                title: Text(data['title'] ?? data['topic'] ?? "No Topic", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['description'] ?? "Practice questions"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        lessonId: filteredLessons[index].id,
                        subject: subject,
                        grade: grade,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}