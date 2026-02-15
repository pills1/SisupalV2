import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for tracking user progress per subject
class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's UID
  String? get _userId => _auth.currentUser?.uid;

  /// Reference to user's progress collection
  CollectionReference<Map<String, dynamic>> get _progressRef {
    if (_userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(_userId).collection('progress');
  }

  /// Get progress for a specific subject
  Future<SubjectProgress> getSubjectProgress(String subject) async {
    try {
      final doc = await _progressRef.doc(subject.toLowerCase()).get();
      if (doc.exists) {
        return SubjectProgress.fromMap(doc.data()!, subject);
      }
      return SubjectProgress(subject: subject);
    } catch (e) {
      print('Error getting progress: $e');
      return SubjectProgress(subject: subject);
    }
  }

  /// Get progress for all subjects
  Future<Map<String, SubjectProgress>> getAllProgress() async {
    try {
      final snapshot = await _progressRef.get();
      final Map<String, SubjectProgress> progress = {};
      for (var doc in snapshot.docs) {
        progress[doc.id] = SubjectProgress.fromMap(doc.data(), doc.id);
      }
      return progress;
    } catch (e) {
      print('Error getting all progress: $e');
      return {};
    }
  }

  /// Mark a lesson as completed
  Future<void> completeLesson(String subject, String lessonId) async {
    if (_userId == null) return;

    try {
      final docRef = _progressRef.doc(subject.toLowerCase());
      final doc = await docRef.get();

      List<String> completedLessons = [];
      if (doc.exists) {
        completedLessons = List<String>.from(doc.data()?['completedLessons'] ?? []);
      }

      if (!completedLessons.contains(lessonId)) {
        completedLessons.add(lessonId);
        await docRef.set({
          'subject': subject,
          'completedLessons': completedLessons,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error completing lesson: $e');
    }
  }

  /// Mark a quiz as completed with score
  Future<void> completeQuiz(String subject, String lessonId, int score, int total) async {
    if (_userId == null) return;

    try {
      final docRef = _progressRef.doc(subject.toLowerCase());
      final doc = await docRef.get();

      Map<String, dynamic> quizScores = {};
      if (doc.exists) {
        quizScores = Map<String, dynamic>.from(doc.data()?['quizScores'] ?? {});
      }

      // Store the best score for each quiz
      int existingScore = quizScores[lessonId]?['score'] ?? 0;
      if (score > existingScore) {
        quizScores[lessonId] = {
          'score': score,
          'total': total,
          'completedAt': DateTime.now().toIso8601String(),
        };
      }

      await docRef.set({
        'subject': subject,
        'quizScores': quizScores,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving quiz score: $e');
    }
  }

  /// Get total lessons count for a subject (from Firestore lessons collection)
  Future<int> getTotalLessonsCount(String subject, int grade) async {
    try {
      final snapshot = await _firestore
          .collection('lessons')
          .where('subject', isEqualTo: subject)
          .where('grade', isEqualTo: grade)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting lesson count: $e');
      return 10; // Default fallback
    }
  }

  /// Calculate overall progress percentage for a subject
  Future<double> getProgressPercentage(String subject, int grade) async {
    final progress = await getSubjectProgress(subject);
    final totalLessons = await getTotalLessonsCount(subject, grade);
    
    if (totalLessons == 0) return 0.0;
    return (progress.completedLessonsCount / totalLessons).clamp(0.0, 1.0);
  }

  /// Stream for real-time progress updates
  Stream<SubjectProgress> streamProgress(String subject) {
    if (_userId == null) return Stream.value(SubjectProgress(subject: subject));
    
    return _progressRef.doc(subject.toLowerCase()).snapshots().map((doc) {
      if (doc.exists) {
        return SubjectProgress.fromMap(doc.data()!, subject);
      }
      return SubjectProgress(subject: subject);
    });
  }
}

/// Model for subject progress data
class SubjectProgress {
  final String subject;
  final List<String> completedLessons;
  final Map<String, QuizScore> quizScores;
  final DateTime? lastUpdated;

  SubjectProgress({
    required this.subject,
    this.completedLessons = const [],
    this.quizScores = const {},
    this.lastUpdated,
  });

  int get completedLessonsCount => completedLessons.length;
  int get completedQuizzesCount => quizScores.length;
  
  int get totalScore => quizScores.values.fold(0, (sum, q) => sum + q.score);
  int get totalPossible => quizScores.values.fold(0, (sum, q) => sum + q.total);
  
  double get averageScore {
    if (totalPossible == 0) return 0.0;
    return totalScore / totalPossible;
  }

  factory SubjectProgress.fromMap(Map<String, dynamic> map, String subject) {
    final quizScoresMap = map['quizScores'] as Map<String, dynamic>? ?? {};
    final quizScores = quizScoresMap.map((key, value) => 
      MapEntry(key, QuizScore.fromMap(value as Map<String, dynamic>)));

    return SubjectProgress(
      subject: subject,
      completedLessons: List<String>.from(map['completedLessons'] ?? []),
      quizScores: quizScores,
      lastUpdated: map['lastUpdated'] != null 
          ? (map['lastUpdated'] as Timestamp).toDate() 
          : null,
    );
  }
}

/// Model for quiz score data
class QuizScore {
  final int score;
  final int total;
  final DateTime? completedAt;

  QuizScore({
    required this.score,
    required this.total,
    this.completedAt,
  });

  double get percentage => total > 0 ? score / total : 0.0;

  factory QuizScore.fromMap(Map<String, dynamic> map) {
    return QuizScore(
      score: map['score'] ?? 0,
      total: map['total'] ?? 0,
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt']) 
          : null,
    );
  }
}
