import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_screen.dart';
import 'add_question_screen.dart';
import 'manage_questions_screen.dart';
import 'manage_videos_screen.dart';
import 'manage_papers_screen.dart';
import 'student_list_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Admin Panel 👨‍🏫"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Manage Video Lessons
              Card(
                color: Colors.deepPurple.shade50,
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 24),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.video_library, color: Colors.white),
                  ),
                  title: const Text(
                    "Manage Video Lessons",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  subtitle: const Text("Add YouTube links for lessons"),
                  trailing: const Icon(
                      Icons.arrow_forward, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageVideosScreen()),
                    );
                  },
                ),
              ),

              // 2. Manage Past Papers
              Card(
                color: Colors.indigo.shade50,
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 24),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.picture_as_pdf, color: Colors.white),
                  ),
                  title: const Text(
                    "Manage Past Papers",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  subtitle: const Text("Upload Exam PDFs"),
                  trailing: const Icon(
                      Icons.arrow_forward, color: Colors.indigo),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManagePapersScreen()),
                    );
                  },
                ),
              ),

              // 3. Classroom Monitor
              Card(
                color: Colors.teal.shade50,
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 24),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.people, color: Colors.white),
                  ),
                  title: const Text(
                    "Classroom Monitor",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  subtitle: const Text("View all students & reports"),
                  trailing: const Icon(Icons.arrow_forward, color: Colors.teal),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StudentListScreen()),
                    );
                  },
                ),
              ),

              const Text(
                "Select a Subject to Add Questions:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Subject Buttons
              _buildSubjectCard(
                  context, "Mathematics", Icons.calculate, Colors.orange),
              _buildSubjectCard(
                  context, "Sinhala", Icons.menu_book, Colors.purple),
              _buildSubjectCard(
                  context, "Environment", Icons.public, Colors.green),
              _buildSubjectCard(
                  context, "English", Icons.language, Colors.blue),
              _buildSubjectCard(
                  context, "Tamil", Icons.translate, Colors.redAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, String subject, IconData icon,
      Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color)),
        title: Text(
            subject, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.add_circle, color: Colors.teal),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManageQuestionsScreen(subject: subject),
            ),
          );
        },
      ),
    );
  }
}
