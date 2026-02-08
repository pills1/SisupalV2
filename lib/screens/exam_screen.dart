import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExamScreen extends StatefulWidget {
  final String? examId;

  const ExamScreen({super.key, this.examId});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _timeLeft = 3600; // 60 minutes
  Timer? _timer;
  int _currentQuestionIndex = 0;

  // To store the questions downloaded from Firebase
  List<QueryDocumentSnapshot> _questions = [];
  bool _isLoading = true;

  // Store user answers
  List<int?> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    _fetchExamData();
    _startTimer();
  }

  // 1. Fetch the exam from Firebase
  Future<void> _fetchExamData() async {
    try {
      String selectedExamId;

      // If an ID was passed (from Past Papers screen), use it.
      if (widget.examId != null) {
        selectedExamId = widget.examId!;
      } else {
        // Otherwise (for testing), just grab the newest one
        final examQuery = await FirebaseFirestore.instance.collection('exams').limit(1).get();
        if (examQuery.docs.isEmpty) {
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        selectedExamId = examQuery.docs.first.id;
      }

      // Fetch questions for THAT specific exam
      final questionQuery = await FirebaseFirestore.instance
          .collection('exams')
          .doc(selectedExamId)
          .collection('questions')
          .orderBy('qID')
          .get();

      if (mounted) {
        setState(() {
          _questions = questionQuery.docs;
          _userAnswers = List.filled(_questions.length, null);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching exam: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        if (mounted) setState(() => _timeLeft--);
      } else {
        _submitExam();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerText {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 2. Submit Logic (With Debug Prints)
  void _submitExam() async {
    _timer?.cancel();
    int score = 0;

    print("--- SUBMITTING EXAM ---");

    for (int i = 0; i < _questions.length; i++) {
      var data = _questions[i].data() as Map<String, dynamic>;

      // Get what the database says is correct
      int correctIndex = data['correctIndex'];

      // Get what YOU clicked
      int? userAnswer = _userAnswers[i];

      // Print the comparison to the console
      print("Question ${i + 1}: Correct Answer = $correctIndex, You Selected = $userAnswer");

      if (userAnswer == correctIndex) {
        score++;
        print(" -> MATCH! Point added.");
      } else {
        print(" -> WRONG.");
      }
    }

    print("--- FINAL SCORE: $score ---");

    // Save to History
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('exam_results')
          .add({
        'examTitle': "2021 Grade 5 Scholarship",
        'score': score,
        'total': _questions.length,
        'date': FieldValue.serverTimestamp(),
      });
    }

    if (!mounted) return;

    // Show Result
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Exam Finished"),
        content: Text("Your Score: $score / ${_questions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("No exam questions found. Did you click the Cloud Upload button?")),
      );
    }

    // Get current question data
    final data = _questions[_currentQuestionIndex].data() as Map<String, dynamic>;
    final List<dynamic> options = data['options'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("2021 Past Paper"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(_timerText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Bubbles Navigation
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.grey[100],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                bool isAnswered = _userAnswers[index] != null;
                bool isCurrent = index == _currentQuestionIndex;
                return GestureDetector(
                  onTap: () => setState(() => _currentQuestionIndex = index),
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent ? Colors.blue : (isAnswered ? Colors.green : Colors.grey[300]),
                      border: isCurrent ? Border.all(color: Colors.blueAccent, width: 2) : null,
                    ),
                    child: Center(
                      child: Text("${index + 1}", style: TextStyle(color: isCurrent || isAnswered ? Colors.white : Colors.black)),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Question Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Question Number
                  Text("Question ${_currentQuestionIndex + 1}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 10),

                  // 2. The Question Text
                  Text(
                    data['question'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 3. The Image (If available)
                  if (data.containsKey('imagePath') && data['imagePath'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Image.asset(
                        data['imagePath'],
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Text(
                                "[Diagram will appear here]",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 8),

                  // 4. Options List
                  ...List.generate(options.length, (index) {
                    bool isSelected = _userAnswers[_currentQuestionIndex] == index;
                    return Card(
                      color: isSelected ? Colors.blue[50] : Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: RadioListTile<int>(
                        value: index,
                        groupValue: _userAnswers[_currentQuestionIndex],
                        title: Text(options[index]),
                        activeColor: Colors.blue,
                        onChanged: (val) {
                          setState(() {
                            _userAnswers[_currentQuestionIndex] = val;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentQuestionIndex > 0 ? () => setState(() => _currentQuestionIndex--) : null,
                  child: const Text("Previous"),
                ),
                if (_currentQuestionIndex == _questions.length - 1)
                  ElevatedButton(
                    onPressed: _submitExam,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Submit Paper"),
                  )
                else
                  ElevatedButton(
                    onPressed: () => setState(() => _currentQuestionIndex++),
                    child: const Text("Next"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}