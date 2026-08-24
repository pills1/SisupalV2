import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/maths/golden_mango_exercise_models.dart';

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

  /// Normalize subject names (e.g. 'maths' -> 'mathematics')
  static String normalizeSubject(String subject) {
    final s = subject.trim().toLowerCase();
    if (s == 'maths' || s == 'math' || s == 'mathematics') {
      return 'mathematics';
    }
    return s;
  }

  /// Concept ID aliases mapping to prevent naming mismatches
  static final Map<String, List<String>> _conceptAliases = {
    'c1_jungle_map': ['c1_map_reading', 'c1'],
    'c1_map_reading': ['c1_jungle_map', 'c1'],
    'c2_river_of_beads': ['c2_abacus_river', 'c2'],
    'c2_abacus_river': ['c2_river_of_beads', 'c2'],
    'c3_giants_gate': ['c3_place_value_gate', 'c3'],
    'c3_place_value_gate': ['c3_giants_gate', 'c3'],
    'c4_crystal_cavern': ['c4_cave_pedestals', 'c4'],
    'c4_cave_pedestals': ['c4_crystal_cavern', 'c4'],
    'c5_golden_chest': ['c5_golden_mango_chest', 'c5'],
    'c5_golden_mango_chest': ['c5_golden_chest', 'c5'],
  };

  /// Get progress for a specific subject
  Future<SubjectProgress> getSubjectProgress(String subject) async {
    try {
      final normalized = normalizeSubject(subject);
      final doc = await _progressRef.doc(normalized).get();
      if (doc.exists) {
        return SubjectProgress.fromMap(doc.data()!, subject);
      }
      // Check legacy doc fallback
      if (normalized == 'mathematics') {
        final legacyDoc = await _progressRef.doc('maths').get();
        if (legacyDoc.exists) {
          return SubjectProgress.fromMap(legacyDoc.data()!, subject);
        }
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

  /// Mark a concept as completed
  Future<void> completeConcept(String subject, String lessonId, String conceptId) async {
    if (_userId == null) return;

    try {
      final normalized = normalizeSubject(subject);
      final docRef = _progressRef.doc(normalized);
      final doc = await docRef.get();

      List<String> completedConcepts = [];
      if (doc.exists) {
        completedConcepts =
            List<String>.from(doc.data()?['completedConcepts'] ?? []);
      }

      // Check legacy 'maths' doc if empty
      if (completedConcepts.isEmpty && normalized == 'mathematics') {
        final legacyDoc = await _progressRef.doc('maths').get();
        if (legacyDoc.exists) {
          completedConcepts.addAll(
            List<String>.from(legacyDoc.data()?['completedConcepts'] ?? []),
          );
        }
      }

      // Collect all aliases for this concept
      final allIdsToAdd = <String>{conceptId};
      if (_conceptAliases.containsKey(conceptId)) {
        allIdsToAdd.addAll(_conceptAliases[conceptId]!);
      }

      bool isNewCompletion = false;
      for (final cid in allIdsToAdd) {
        if (!completedConcepts.contains(cid)) {
          completedConcepts.add(cid);
          isNewCompletion = true;
        }
      }

      if (isNewCompletion) {
        final payload = {
          'subject': 'Mathematics',
          'completedConcepts': completedConcepts,
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        // Write to primary 'mathematics' doc
        await docRef.set(payload, SetOptions(merge: true));

        // Mirror to legacy 'maths' doc
        if (normalized == 'mathematics') {
          await _progressRef.doc('maths').set(payload, SetOptions(merge: true));
        }

        // 🌟 Award +100 XP to the student's profile!
        await _firestore.collection('users').doc(_userId).set({
          'xp': FieldValue.increment(100),
          'lastActiveDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error completing concept: $e');
    }
  }

  /// Mark a lesson as completed
  Future<void> completeLesson(String subject, String lessonId) async {
    if (_userId == null) return;

    try {
      final normalized = normalizeSubject(subject);
      final docRef = _progressRef.doc(normalized);
      final doc = await docRef.get();

      List<String> completedLessons = [];
      if (doc.exists) {
        completedLessons = List<String>.from(doc.data()?['completedLessons'] ?? []);
      }

      if (!completedLessons.contains(lessonId)) {
        completedLessons.add(lessonId);
        final payload = {
          'subject': 'Mathematics',
          'completedLessons': completedLessons,
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        await docRef.set(payload, SetOptions(merge: true));
        if (normalized == 'mathematics') {
          await _progressRef.doc('maths').set(payload, SetOptions(merge: true));
        }

        // 👑 Award bonus +200 XP for completing a full lesson!
        await _firestore.collection('users').doc(_userId).set({
          'xp': FieldValue.increment(200),
          'lastActiveDate': FieldValue.serverTimestamp(),
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
  /// Record a detailed itemized question attempt for analytics & adaptive tracking
  Future<void> recordQuestionAttempt({
    required String lessonId,
    required String conceptId,
    required String questionId,
    required int attemptNumber,
    required String answerGiven,
    required String correctAnswer,
    required bool isCorrect,
    required int timeTakenSeconds,
    required bool hintUsed,
    required int hintLevel,
    required String skillTag,
    required int difficulty,
  }) async {
    if (_userId == null) return;

    try {
      final attemptLog = QuestionAttemptLog(
        studentId: _userId!,
        lessonId: lessonId,
        conceptId: conceptId,
        questionId: questionId,
        attemptNumber: attemptNumber,
        answerGiven: answerGiven,
        correctAnswer: correctAnswer,
        isCorrect: isCorrect,
        timeTakenSeconds: timeTakenSeconds,
        hintUsed: hintUsed,
        hintLevel: hintLevel,
        skillTag: skillTag,
        difficulty: difficulty,
      );

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('question_attempts')
          .add(attemptLog.toMap());
    } catch (e) {
      print('Error recording question attempt: $e');
    }
  }

  Stream<SubjectProgress> streamProgress(String subject) {
    if (_userId == null) return Stream.value(SubjectProgress(subject: subject));

    final normalized = normalizeSubject(subject);
    final primaryDocRef = _progressRef.doc(normalized);

    return primaryDocRef.snapshots().asyncMap((doc) async {
      Map<String, dynamic> data = doc.exists ? Map<String, dynamic>.from(doc.data()!) : {};

      // If mathematics, merge with legacy 'maths' document if it exists
      if (normalized == 'mathematics') {
        try {
          final legacyDoc = await _progressRef.doc('maths').get();
          if (legacyDoc.exists && legacyDoc.data() != null) {
            final legacyConcepts = List<String>.from(legacyDoc.data()?['completedConcepts'] ?? []);
            final currentConcepts = List<String>.from(data['completedConcepts'] ?? []);
            final mergedConcepts = <String>{...currentConcepts, ...legacyConcepts}.toList();

            // Expand all concept aliases
            final expandedConcepts = <String>{...mergedConcepts};
            for (final cid in mergedConcepts) {
              if (_conceptAliases.containsKey(cid)) {
                expandedConcepts.addAll(_conceptAliases[cid]!);
              }
            }

            data['completedConcepts'] = expandedConcepts.toList();

            final legacyLessons = List<String>.from(legacyDoc.data()?['completedLessons'] ?? []);
            final currentLessons = List<String>.from(data['completedLessons'] ?? []);
            data['completedLessons'] = <String>{...currentLessons, ...legacyLessons}.toList();
          }
        } catch (_) {}
      }

      if (data.isNotEmpty) {
        // Expand aliases in data['completedConcepts'] as well
        final rawConcepts = List<String>.from(data['completedConcepts'] ?? []);
        final expanded = <String>{...rawConcepts};
        for (final cid in rawConcepts) {
          if (_conceptAliases.containsKey(cid)) {
            expanded.addAll(_conceptAliases[cid]!);
          }
        }
        data['completedConcepts'] = expanded.toList();
        return SubjectProgress.fromMap(data, subject);
      }
      return SubjectProgress(subject: subject);
    });
  }
}

/// Model for subject progress data
class SubjectProgress {
  final String subject;
  final List<String> completedLessons;
  final List<String> completedConcepts;
  final Map<String, QuizScore> quizScores;
  final DateTime? lastUpdated;

  SubjectProgress({
    required this.subject,
    this.completedLessons = const [],
    this.completedConcepts = const [],
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
      completedConcepts: List<String>.from(map['completedConcepts'] ?? []),
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
