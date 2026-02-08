import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MistakesScreen extends StatefulWidget {
  const MistakesScreen({super.key});

  @override
  State<MistakesScreen> createState() => _MistakesScreenState();
}

class _MistakesScreenState extends State<MistakesScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _answered = false;
  String _feedback = "";

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: Text("Please login")));

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Mistakes Jail 🛑"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('mistakes') // Fetching from 'mistakes' subcollection
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  const SizedBox(height: 20),
                  const Text("Great Job!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text("You have cleared all your mistakes.", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back to Dashboard"),
                  )
                ],
              ),
            );
          }

          // If we have mistakes, show them as a Quiz
          var currentQuestion = docs[_currentIndex].data() as Map<String, dynamic>;
          List<dynamic> options = currentQuestion['options'] ?? [];
          int correctIndex = currentQuestion['correctIndex'] ?? 0;
          String questionText = currentQuestion['question'] ?? "No Question";

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / docs.length,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 20),

                // Question Count
                Text(
                  "Mistake ${_currentIndex + 1} of ${docs.length}",
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Question Text
                Text(
                  questionText,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Options
                ...List.generate(options.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      onPressed: () {
                        _handleAnswer(index, correctIndex, docs[_currentIndex].reference);
                      },
                      child: Text(options[index], style: const TextStyle(fontSize: 16)),
                    ),
                  );
                }),

                if (_answered)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 20),
                    color: _feedback == "Correct!" ? Colors.green.shade100 : Colors.red.shade100,
                    child: Text(
                      _feedback,
                      style: TextStyle(
                        color: _feedback == "Correct!" ? Colors.green.shade800 : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleAnswer(int selectedIndex, int correctIndex, DocumentReference docRef) {
    if (_answered) return; // Prevent double clicking

    setState(() {
      _answered = true;
    });

    if (selectedIndex == correctIndex) {
      // CORRECT!
      setState(() {
        _feedback = "Correct! Fixing mistake...";
      });

      // Delay, then DELETE the mistake and move on
      Future.delayed(const Duration(seconds: 1), () async {
        await docRef.delete(); // <--- MAGIC: Remove from Jail

        if (mounted) {
          setState(() {
            _answered = false;
            _feedback = "";
            // If we deleted the last item, the StreamBuilder will handle the "Empty" state automatically
            // If there are more items, but we were at the last index, reset index
            if (_currentIndex >= 1) {
              _currentIndex = 0;
            }
          });
        }
      });

    } else {
      // WRONG AGAIN
      setState(() {
        _feedback = "Not quite. Try again!";
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _answered = false;
          _feedback = "";
        });
      });
    }
  }
}