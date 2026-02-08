import 'package:flutter/material.dart';
import 'video_list_screen.dart'; // We create this next

class VideoHubScreen extends StatelessWidget {
  const VideoHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Classroom 🎬"),
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. SPECIAL: Past Paper Discussions
          _buildVideoCategory(
              context,
              "Past Paper Discussions 🎓",
              "Watch teachers solve exam papers",
              Colors.orange,
              Icons.history_edu,
              "past_papers" // Category ID
          ),

          const SizedBox(height: 20),
          const Text("Subject Lessons", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // 2. Subjects
          _buildVideoCategory(context, "Mathematics", "Fractions, Algebra, Shapes", Colors.blue, Icons.calculate, "mathematics"),
          _buildVideoCategory(context, "Sinhala", "Grammar, Reading", Colors.purple, Icons.menu_book, "sinhala"),
          _buildVideoCategory(context, "English", "Spoken English, Grammar", Colors.redAccent, Icons.language, "english"),
          _buildVideoCategory(context, "Environment", "Nature, History", Colors.green, Icons.public, "environment"),
        ],
      ),
    );
  }

  Widget _buildVideoCategory(BuildContext context, String title, String subtitle, Color color, IconData icon, String categoryId) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoListScreen(category: categoryId, title: title),
            ),
          );
        },
      ),
    );
  }
}