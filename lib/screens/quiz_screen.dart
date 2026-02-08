import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'student_dashboard.dart';

// ==========================================
// 1. QUIZ SCREEN
// ==========================================
class QuizScreen extends StatefulWidget {
  final String lessonId;
  final String subject;
  final int grade;

  const QuizScreen({
    super.key,
    required this.lessonId,
    required this.subject,
    required this.grade,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedOptionIndex;

  // Reading Passage for Sinhala Grade 5
  final String readingPassage = """
අපේ පාසලේ ගුරුවරුන්, සිසුන්, දෙමාපියන් සහ ආදී ශිෂ්‍යන්ගේ සහභාගිත්වයෙන් පසුගිය දා ශ්‍රමදානයක් පවත්වන ලදී. 
ශ්‍රමදානය පැවැත්වීමේ මූලික අරමුණ වූයේ පාසල් වත්ත පිරිසිදු කිරීමයි. මල් පාත්ති සකස් කිරීම, පාසල් වත්තේ දිරන සහ නොදිරන ද්‍රව්‍ය තෝරා වෙන් කිරීම, කුණු කසල බැහැර කිරීම වැනි කටයුතු එහිදී සිදු කරන ලදී. 
ලොකු කුඩා සෑම කෙනෙක් ම ඒ සඳහා සහභාගි වූයේ ඉමහත් ප්‍රීතියකිනි. විදුහල්පතිතුමා විසින් සහභාගි වූ සැමට ස්තූතිය පළ කරමින් වැඩසටහන නිමා කරන ලදී. 
මගේ පාසල දැන් කෙතරම් ලස්සන ද කියා මට සිතුනි.
""";

  @override
  void initState() {
    super.initState();
    _initTts();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _playSound(bool isCorrect) async {
    try {
      String fileName = isCorrect ? 'sounds/correct.mp3' : 'sounds/wrong.mp3';
      await _audioPlayer.play(AssetSource(fileName));
    } catch (e) {
      // Ignore sound errors
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _updateUserXP(int newXP) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      try {
        final snapshot = await userDoc.get();
        int currentXP = 0;
        if (snapshot.exists) {
          currentXP = snapshot.data()?['xp'] ?? 0;
        }
        await userDoc.set({
          'xp': currentXP + newXP,
        }, SetOptions(merge: true));
      } catch (e) {
        print("Error XP: $e");
      }
    }
  }

  Future<void> _saveToHistory(int totalQuestions) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('exam_results').add({
        'examTitle': "${widget.subject} Practice",
        'score': _score,
        'total': totalQuestions,
        'date': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _saveMistake(Map<String, dynamic> question) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('mistakes').add({
        'question': question['question'],
        'options': question['options'],
        'correctIndex': question['correctIndex'],
        'savedAt': FieldValue.serverTimestamp(),
        'subject': widget.subject,
      });
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _confettiController.dispose();
    super.dispose();
  }

  // --- NAVIGATION TO RESULT SCREEN ---
  void _navigateToResult(int total) async {
    int earnedXP = _score * 10;

    // Save Data
    await _updateUserXP(earnedXP);
    await _saveToHistory(total);

    if (!mounted) return;

    // Navigate to the ResultScreen (Defined below in this same file)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: _score,
          totalQuestions: total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Time!")),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('lessons')
                .doc(widget.lessonId)
                .collection('questions')
                .orderBy('qID')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final questions = snapshot.data!.docs;
              if (questions.isEmpty) return const Center(child: Text("No questions ready yet!"));

              final currentQuestion = questions[_currentQuestionIndex].data() as Map<String, dynamic>;
              final List<dynamic> options = currentQuestion['options'];
              final int correctIndex = currentQuestion['correctIndex'];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(value: (_currentQuestionIndex + 1) / questions.length, color: Colors.blue, backgroundColor: Colors.grey.shade200),
                    const SizedBox(height: 10),
                    Text("Question ${_currentQuestionIndex + 1}/${questions.length}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 10),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Sinhala Paragraph
                            if (widget.subject == 'Sinhala' && widget.grade == 5 && _currentQuestionIndex < 6)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
                                child: Text(readingPassage, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
                              ),

                            // Question Text
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Text(currentQuestion['question'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                                IconButton(onPressed: () => _speak(currentQuestion['question']), icon: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.volume_up, color: Colors.white))),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Image
                            if (currentQuestion.containsKey('imagePath') && currentQuestion['imagePath'] != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: currentQuestion['imagePath'].startsWith('http')
                                      ? Image.network(currentQuestion['imagePath'], height: 200, fit: BoxFit.contain, errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image))
                                      : Image.asset(currentQuestion['imagePath'], height: 200, fit: BoxFit.contain, errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported)),
                                ),
                              ),

                            // Options
                            ...List.generate(options.length, (index) {
                              Color getColor() {
                                if (!_isAnswered) return Colors.white;
                                if (index == correctIndex) return Colors.green.shade100;
                                if (index == _selectedOptionIndex && index != correctIndex) return Colors.red.shade100;
                                return Colors.white;
                              }
                              return Card(
                                color: getColor(),
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(options[index]),
                                  onTap: _isAnswered ? null : () {
                                    setState(() {
                                      _selectedOptionIndex = index;
                                      _isAnswered = true;
                                      if (index == correctIndex) {
                                        _score++;
                                        _playSound(true);
                                      } else {
                                        _saveMistake(currentQuestion);
                                        _playSound(false);
                                      }
                                    });
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_isAnswered)
                      ElevatedButton(
                        onPressed: () {
                          _flutterTts.stop();
                          if (_currentQuestionIndex < questions.length - 1) {
                            setState(() { _currentQuestionIndex++; _isAnswered = false; _selectedOptionIndex = null; });
                          } else {
                            _navigateToResult(questions.length);
                          }
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: Text(_currentQuestionIndex < questions.length - 1 ? "Next Question" : "Finish Quiz"),
                      ),
                  ],
                ),
              );
            },
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            numberOfParticles: 20, gravity: 0.3,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. RESULT SCREEN (IN THE SAME FILE!)
// ==========================================
class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 3));
    double percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage >= 50) {
      _controllerCenter.play();
    }
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  // Draw Star Helper
  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);
    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step), halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep), halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    double percentage = (widget.score / widget.totalQuestions) * 100;
    bool isPass = percentage >= 40;

    return Scaffold(
      backgroundColor: isPass ? Colors.blue.shade50 : Colors.red.shade50,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isPass ? Icons.emoji_events : Icons.sentiment_dissatisfied, size: 100, color: isPass ? Colors.orange : Colors.red),
                const SizedBox(height: 20),
                Text(isPass ? "Congratulations!" : "Keep Trying!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isPass ? Colors.blue.shade900 : Colors.red.shade900)),
                const SizedBox(height: 10),
                Text("You scored ${widget.score} / ${widget.totalQuestions}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                if (isPass)
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
                    child: Text("+ ${widget.score * 10} XP Earned!", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const StudentDashboard()), (route) => false);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text("Back to Home", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              createParticlePath: drawStar,
            ),
          ),
        ],
      ),
    );
  }
}