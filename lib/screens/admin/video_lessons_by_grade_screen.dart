import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/animated_widgets.dart';
import 'manage_videos_screen.dart';
import 'add_video_screen.dart';

class VideoLessonsByGradeScreen extends StatelessWidget {
  final int grade;

  const VideoLessonsByGradeScreen({super.key, required this.grade});

  String get _gradeTitle {
    switch (grade) {
      case 3:
        return "Grade 3 - Fun Basics";
      case 4:
        return "Grade 4 - Foundation";
      case 5:
        return "Grade 5 - Scholarship";
      default:
        return "Grade $grade";
    }
  }

  String get _gradeEmoji {
    switch (grade) {
      case 3:
        return "🌟";
      case 4:
        return "📚";
      case 5:
        return "🏆";
      default:
        return "📖";
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = [
      {'id': 'mathematics', 'name': 'Mathematics', 'icon': Icons.calculate, 'color': const Color(0xFFff9f43), 'emoji': '🔢'},
      {'id': 'sinhala', 'name': 'Sinhala', 'icon': Icons.menu_book, 'color': const Color(0xFFa55eea), 'emoji': '📝'},
      {'id': 'english', 'name': 'English', 'icon': Icons.language, 'color': const Color(0xFF45aaf2), 'emoji': '🔤'},
      {'id': 'environment', 'name': 'Environment', 'icon': Icons.public, 'color': const Color(0xFF26de81), 'emoji': '🌍'},
      {'id': 'tamil', 'name': 'Tamil', 'icon': Icons.translate, 'color': const Color(0xFFfc5c65), 'emoji': '📜'},
      {'id': 'past_papers', 'name': 'Past Papers', 'icon': Icons.description, 'color': const Color(0xFF778ca3), 'emoji': '📋'},
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      BouncingButton(
                        onPressed: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),

              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SlideInWidget(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: grade == 3
                              ? [const Color(0xFF11998e), const Color(0xFF38ef7d)]
                              : grade == 4
                                  ? [const Color(0xFFfc4a1a), const Color(0xFFf7b733)]
                                  : [const Color(0xFF667eea), const Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(_gradeEmoji, style: const TextStyle(fontSize: 32)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _gradeTitle,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('videos')
                                      .where('targetGrade', isEqualTo: grade)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                                    return Text(
                                      "$count total videos",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Select Subject Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Select Subject",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Subject List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final subject = subjects[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SubjectTile(
                          grade: grade,
                          subjectId: subject['id'] as String,
                          subjectName: subject['name'] as String,
                          icon: subject['icon'] as IconData,
                          color: subject['color'] as Color,
                          emoji: subject['emoji'] as String,
                          delay: 100 + (index * 100),
                        ),
                      );
                    },
                    childCount: subjects.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
      floatingActionButton: SlideInWidget(
        delay: const Duration(milliseconds: 600),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddVideoScreen(prefilledGrade: grade),
              ),
            );
          },
          backgroundColor: const Color(0xFF667eea),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Video", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final int grade;
  final String subjectId;
  final String subjectName;
  final IconData icon;
  final Color color;
  final String emoji;
  final int delay;

  const _SubjectTile({
    required this.grade,
    required this.subjectId,
    required this.subjectName,
    required this.icon,
    required this.color,
    required this.emoji,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return SlideInWidget(
      delay: Duration(milliseconds: delay),
      child: BouncingButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManageVideosScreen(
                grade: grade,
                subject: subjectId,
                subjectName: subjectName,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1a2a3a),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              // Emoji Container
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              // Subject Name
              Expanded(
                child: Text(
                  subjectName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // Video Count Badge
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('videos')
                    .where('targetGrade', isEqualTo: grade)
                    .where('category', isEqualTo: subjectId)
                    .snapshots(),
                builder: (context, snapshot) {
                  int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_filled, color: color, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "$count",
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.5), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
