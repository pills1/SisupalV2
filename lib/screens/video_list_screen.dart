import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'video_lesson_screen.dart';

class VideoListScreen extends StatefulWidget {
  final String category; // e.g., 'mathematics'
  final String title;

  const VideoListScreen({super.key, required this.category, required this.title});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  int? _studentGrade; // To store the logged-in student's grade
  bool _isLoadingGrade = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentGrade();
  }

  // 1. Fetch the Student's Grade from Firestore
  Future<void> _fetchStudentGrade() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          // Default to 5 if grade is missing
          _studentGrade = doc.data()?['grade'] ?? 5;
          _isLoadingGrade = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.title} (Grade $_studentGrade)")),
      body: _isLoadingGrade
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('videos')
            .where('category', isEqualTo: widget.category)
        // --- NEW: FILTER BY GRADE ---
            .where('targetGrade', isEqualTo: _studentGrade)
        // ----------------------------
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    "No Grade $_studentGrade videos for ${widget.title} yet!",
                    style: const TextStyle(color: Colors.grey),
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

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Container(
                    width: 80,
                    height: 50,
                    color: Colors.black,
                    child: const Center(child: Icon(Icons.play_circle, color: Colors.white)),
                  ),
                  title: Text(data['title'] ?? "Untitled Video"),
                  subtitle: Text(data['description'] ?? "Watch now"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoLessonScreen(
                          title: data['title'],
                          videoUrl: data['videoUrl'],
                        ),
                      ),
                    );
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