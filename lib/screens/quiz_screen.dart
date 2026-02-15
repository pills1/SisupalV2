import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'dart:async';
import '../utils/app_theme.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/gamification_widgets.dart';
import '../services/daily_challenge_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/achievement_service.dart';
import '../services/notification_service.dart';
import 'student_dashboard.dart';

// ==========================================
// 1. QUIZ SCREEN
// ==========================================
class QuizScreen extends StatefulWidget {
  final String lessonId;
  final String subject;
  final int grade;
  final bool timerMode;
  final int secondsPerQuestion;

  const QuizScreen({
    super.key,
    required this.lessonId,
    required this.subject,
    required this.grade,
    this.timerMode = false,
    this.secondsPerQuestion = 30,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  
  // Services
  final DailyChallengeService _challengeService = DailyChallengeService();
  final ProgressService _progressService = ProgressService();
  final SoundService _soundService = SoundService();
  final AchievementService _achievementService = AchievementService();
  final NotificationService _notificationService = NotificationService();

  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedOptionIndex;
  
  // Combo system
  int _combo = 0;
  int _maxCombo = 0;
  
  // Timer mode
  Timer? _questionTimer;
  int _timeRemaining = 30;
  late AnimationController _timerController;
  
  // Animation controllers
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _correctController;

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
    
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
    
    _correctController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Timer controller for animation
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.secondsPerQuestion),
    );
    
    if (widget.timerMode) {
      _timeRemaining = widget.secondsPerQuestion;
    }
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
        await userDoc.set({'xp': currentXP + newXP}, SetOptions(merge: true));
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
        'maxCombo': _maxCombo,
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

  // Timer methods for timer mode
  void _startQuestionTimer() {
    if (!widget.timerMode) return;
    
    _timerController.forward(from: 0);
    _timeRemaining = widget.secondsPerQuestion;
    
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _timeRemaining--;
        if (_timeRemaining <= 0) {
          _onTimeUp();
        }
      });
    });
  }

  void _stopQuestionTimer() {
    _questionTimer?.cancel();
    _timerController.stop();
  }

  void _onTimeUp() {
    _stopQuestionTimer();
    // Auto-skip when time runs out - treat as wrong answer
    setState(() {
      _isAnswered = true;
      _combo = 0; // Reset combo
    });
    _playSound(false);
    _shakeController.forward().then((_) => _shakeController.reset());
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _flutterTts.stop();
    _confettiController.dispose();
    _shakeController.dispose();
    _correctController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  void _navigateToResult(int total) async {
    int comboBonus = (_maxCombo >= 3) ? (_maxCombo * 5) : 0;
    int earnedXP = (_score * 10) + comboBonus;

    await _updateUserXP(earnedXP);
    await _saveToHistory(total);
    
    // Report lesson and quiz completion to services
    await _progressService.completeLesson(widget.subject, widget.lessonId);
    await _progressService.completeQuiz(widget.subject, widget.lessonId, _score, total);
    await _challengeService.updateProgress(ChallengeType.quizComplete);
    
    // Report combo achievement
    if (_maxCombo >= 3) {
      await _challengeService.updateProgress(ChallengeType.combo, amount: _maxCombo);
      await _soundService.playCombo(_maxCombo);
    }
    
    // Report perfect score if achieved
    if (_score == total) {
      await _challengeService.updateProgress(ChallengeType.perfectQuiz);
    }
    
    // Report XP earned
    await _challengeService.updateProgress(ChallengeType.earnXP, amount: earnedXP);
    
    // Check for new achievements
    final newAchievements = await _achievementService.onQuizCompleted(
      score: _score,
      total: total,
      newXP: earnedXP,
      currentStreak: 0, // Will be fetched from user data
    );
    
    // Send quiz completion notification
    final percentage = (((_score / total) * 100).round());
    String message = _score == total
        ? "🎉 Perfect Score! You got $percentage% and earned $earnedXP XP!"
        : "You got $_score out of $total ($percentage%) and earned $earnedXP XP!";
    await _notificationService.createNotification(
      title: "📝 Quiz Completed!",
      body: message,
      type: NotificationType.quizReminder,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: _score,
          totalQuestions: total,
          maxCombo: _maxCombo,
          earnedXP: earnedXP,
        ),
      ),

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => _showExitDialog(),
        ),
        title: Text(widget.timerMode ? "⏱️ Speed Quiz!" : "Quiz Time!", style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Timer display
          if (widget.timerMode)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _timeRemaining <= 5 
                        ? Colors.red.withOpacity(0.2) 
                        : Colors.blue.withOpacity(0.1),
                    border: Border.all(
                      color: _timeRemaining <= 5 ? Colors.red : Colors.blue,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$_timeRemaining',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _timeRemaining <= 5 ? Colors.red : Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_combo > 1)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ComboCounter(combo: _combo),
            ),
        ],
      ),
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
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final questions = snapshot.data!.docs;
              if (questions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text("No questions ready yet!", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    ],
                  ),
                );
              }

              final currentQuestion = questions[_currentQuestionIndex].data() as Map<String, dynamic>;
              final List<dynamic> options = currentQuestion['options'];
              final int correctIndex = currentQuestion['correctIndex'];
              final double progress = (_currentQuestionIndex + 1) / questions.length;

              // Start timer on first question
              if (_currentQuestionIndex == 0 && !_isAnswered && _timeRemaining == widget.secondsPerQuestion && widget.timerMode) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _startQuestionTimer());
              }

              return Column(
                children: [
                  // Progress Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Question ${_currentQuestionIndex + 1} of ${questions.length}",
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text("$_score pts", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AnimatedProgressBar(
                          progress: progress,
                          height: 8,
                          gradient: AppColors.successGradient,
                        ),
                      ],
                    ),
                  ),

                  // Question Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Reading passage for Sinhala
                          if (widget.subject == 'Sinhala' && widget.grade == 5 && _currentQuestionIndex < 6)
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.orange.shade50, Colors.orange.shade100],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.menu_book, color: Colors.orange.shade700),
                                      const SizedBox(width: 8),
                                      Text("Reading Passage", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                                    ],
                                  ),
                                  const Divider(),
                                  Text(readingPassage, style: const TextStyle(fontSize: 15, height: 1.6)),
                                ],
                              ),
                            ),

                          // Question Card
                          AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(_shakeAnimation.value * sin(_shakeController.value * 4 * pi), 0),
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: AppShadows.cardShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          currentQuestion['question'],
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          onPressed: () => _speak(currentQuestion['question']),
                                          icon: const Icon(Icons.volume_up, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Image if exists
                                  if (currentQuestion.containsKey('imagePath') && currentQuestion['imagePath'] != null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: currentQuestion['imagePath'].toString().startsWith('http')
                                            ? Image.network(
                                                currentQuestion['imagePath'],
                                                height: 180,
                                                fit: BoxFit.contain,
                                                errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 60),
                                              )
                                            : Image.asset(
                                                currentQuestion['imagePath'],
                                                height: 180,
                                                fit: BoxFit.contain,
                                                errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported, size: 60),
                                              ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Options
                          ...List.generate(options.length, (index) {
                            bool isCorrect = index == correctIndex;
                            bool isSelected = index == _selectedOptionIndex;
                            
                            Color cardColor = Colors.white;
                            Color borderColor = Colors.grey.shade200;
                            Color textColor = Colors.black87;
                            IconData? trailingIcon;
                            Color? iconColor;

                            if (_isAnswered) {
                              if (isCorrect) {
                                cardColor = Colors.green.shade50;
                                borderColor = Colors.green;
                                trailingIcon = Icons.check_circle;
                                iconColor = Colors.green;
                              } else if (isSelected && !isCorrect) {
                                cardColor = Colors.red.shade50;
                                borderColor = Colors.red;
                                trailingIcon = Icons.cancel;
                                iconColor = Colors.red;
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: BouncingButton(
                                onPressed: _isAnswered ? null : () => _handleAnswer(index, correctIndex, currentQuestion),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: borderColor, width: 2),
                                    boxShadow: isSelected && _isAnswered
                                        ? [BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 10)]
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: _isAnswered && isCorrect
                                              ? Colors.green
                                              : (_isAnswered && isSelected ? Colors.red : Colors.grey.shade200),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + index),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _isAnswered && (isCorrect || isSelected) ? Colors.white : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          options[index],
                                          style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      if (trailingIcon != null)
                                        Icon(trailingIcon, color: iconColor, size: 28),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Next Button
                  if (_isAnswered)
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: BouncingButton(
                        onPressed: () {
                          _flutterTts.stop();
                          if (_currentQuestionIndex < questions.length - 1) {
                            setState(() {
                              _currentQuestionIndex++;
                              _isAnswered = false;
                              _selectedOptionIndex = null;
                            });
                            _startQuestionTimer(); // Start timer for next question
                          } else {
                            _stopQuestionTimer();
                            _navigateToResult(questions.length);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentQuestionIndex < questions.length - 1 ? "Next Question" : "See Results",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentQuestionIndex < questions.length - 1 ? Icons.arrow_forward : Icons.emoji_events,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          
          // Confetti
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            numberOfParticles: 20,
            gravity: 0.3,
          ),
        ],
      ),
    );
  }

  void _handleAnswer(int selectedIndex, int correctIndex, Map<String, dynamic> question) {
    _stopQuestionTimer(); // Stop timer when answer submitted
    
    setState(() {
      _selectedOptionIndex = selectedIndex;
      _isAnswered = true;
      
      if (selectedIndex == correctIndex) {
        _score++;
        _combo++;
        _maxCombo = max(_maxCombo, _combo);
        _playSound(true);
        if (_combo >= 3) {
          _confettiController.play();
        }
      } else {
        _combo = 0;
        _saveMistake(question);
        _playSound(false);
        _shakeController.forward().then((_) => _shakeController.reset());
      }
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Leave Quiz?"),
        content: const Text("Your progress will be lost if you leave now."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Stay"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Leave", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. RESULT SCREEN
// ==========================================
class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int maxCombo;
  final int earnedXP;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    this.maxCombo = 0,
    this.earnedXP = 0,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late ConfettiController _controllerCenter;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 5));
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_scaleController);
    
    double percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage >= 50) {
      _controllerCenter.play();
    }
    _scaleController.forward();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    _scaleController.dispose();
    super.dispose();
  }

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
    bool isPerfect = percentage == 100;

    String title;
    String subtitle;
    IconData icon;
    Gradient gradient;

    if (isPerfect) {
      title = "PERFECT!";
      subtitle = "You're a genius! 🌟";
      icon = Icons.workspace_premium;
      gradient = const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]);
    } else if (percentage >= 80) {
      title = "Excellent!";
      subtitle = "Amazing work! 🎉";
      icon = Icons.emoji_events;
      gradient = AppColors.successGradient;
    } else if (isPass) {
      title = "Good Job!";
      subtitle = "Keep practicing! 💪";
      icon = Icons.thumb_up;
      gradient = AppColors.primaryGradient;
    } else {
      title = "Keep Trying!";
      subtitle = "Practice makes perfect! 📚";
      icon = Icons.refresh;
      gradient = const LinearGradient(colors: [Color(0xFFff6b6b), Color(0xFFee5a5a)]);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Trophy Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 70, color: Colors.white),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Score Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "${widget.score} / ${widget.totalQuestions}",
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              Text(
                                "${percentage.toInt()}% Correct",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 12),
                              
                              // Stats Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatItem(Icons.star, "${widget.earnedXP} XP", Colors.amber),
                                  if (widget.maxCombo > 1)
                                    _buildStatItem(Icons.flash_on, "${widget.maxCombo}x Combo", Colors.orange),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Home Button
                        BouncingButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const StudentDashboard()),
                              (route) => false,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.home, color: Colors.grey.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  "Back to Home",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _controllerCenter,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.yellow],
                createParticlePath: drawStar,
                numberOfParticles: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}