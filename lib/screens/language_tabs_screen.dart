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
    Query query = FirebaseFirestore.instance
        .collection('lessons')
        .where('subject', isEqualTo: subject)
        .where('grade', isEqualTo: 5);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final filteredLessons = snapshot.data!.docs;

        if (filteredLessons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                const Text("No Grade 5 lessons found yet!", style: TextStyle(color: Colors.grey)),
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