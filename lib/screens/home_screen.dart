import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("SisuPal Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          String studentName = "Student";
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            studentName = (data?['studentName'] as String?)?.trim().isNotEmpty == true
                ? data!['studentName']
                : (data?['name'] as String?)?.trim().isNotEmpty == true
                    ? data!['name']
                    : (data?['displayName'] as String?)?.trim().isNotEmpty == true
                        ? data!['displayName']
                        : user?.displayName ?? "Student";
          } else {
            studentName = user?.displayName ?? "Student";
          }
          return Center(
            child: Text(
              "Welcome, $studentName! 🎓",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}