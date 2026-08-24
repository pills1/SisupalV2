import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/maths/revision_models.dart';

class RevisionEngine {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Default list of supported skills across Lesson 1 & Lesson 2
  static final List<Map<String, String>> _allSupportedSkills = [
    {
      'tag': 'number_ordering',
      'titleSin': 'සංඛ්‍යා පටිපාටිගත කිරීම',
      'titleEng': 'Number Ordering',
      'lesson': 'math_grade5_02',
      'concept': 'c2_number_train_ordering',
      'conceptTitle': '2️⃣ දෙවන නැවතුම – සංඛ්‍යා පටිපාටිගත කරමු',
    },
    {
      'tag': 'ascending_order',
      'titleSin': 'ආරෝහණ පිළිවෙළ',
      'titleEng': 'Ascending Order',
      'lesson': 'math_grade5_02',
      'concept': 'c2_number_train_ordering',
      'conceptTitle': '2️⃣ දෙවන නැවතුම – සංඛ්‍යා පටිපාටිගත කරමු',
    },
    {
      'tag': 'descending_order',
      'titleSin': 'අවරෝහණ පිළිවෙළ',
      'titleEng': 'Descending Order',
      'lesson': 'math_grade5_02',
      'concept': 'c2_number_train_ordering',
      'conceptTitle': '2️⃣ දෙවන නැවතුම – සංඛ්‍යා පටිපාටිගත කරමු',
    },
    {
      'tag': 'largest_number',
      'titleSin': 'විශාලම සංඛ්‍යාව තේරීම',
      'titleEng': 'Finding Largest Number',
      'lesson': 'math_grade5_02',
      'concept': 'c1_number_train_intro',
      'conceptTitle': '1️⃣ පළමු නැවතුම – සංඛ්‍යා සසඳමු',
    },
    {
      'tag': 'smallest_number',
      'titleSin': 'කුඩාම සංඛ්‍යාව තේරීම',
      'titleEng': 'Finding Smallest Number',
      'lesson': 'math_grade5_02',
      'concept': 'c1_number_train_intro',
      'conceptTitle': '1️⃣ පළමු නැවතුම – සංඛ්‍යා සසඳමු',
    },
    {
      'tag': 'compare_numbers',
      'titleSin': 'සංඛ්‍යා සංසන්දනය',
      'titleEng': 'Comparing Numbers',
      'lesson': 'math_grade5_02',
      'concept': 'c1_number_train_intro',
      'conceptTitle': '1️⃣ පළමු නැවතුම – සංඛ්‍යා සසඳමු',
    },
    {
      'tag': 'place_value',
      'titleSin': 'ස්ථානීය අගය හඳුනාගැනීම',
      'titleEng': 'Place Value Recognition',
      'lesson': 'math_grade5_01',
      'concept': 'c2_abacus_river',
      'conceptTitle': '2️⃣ ඇබකස් ගඟ තරණය',
    },
    {
      'tag': 'expanded_form',
      'titleSin': 'විස්තරාත්මක සටහන',
      'titleEng': 'Expanded Form Decomposition',
      'lesson': 'math_grade5_01',
      'concept': 'c4_cave_pedestals',
      'conceptTitle': '4️⃣ මායා ගුහාවේ පීඨිකා',
    },
    {
      'tag': 'number_reading',
      'titleSin': 'සංඛ්‍යා කියවීම',
      'titleEng': 'Number Reading',
      'lesson': 'math_grade5_01',
      'concept': 'c1_map_reading',
      'conceptTitle': '1️⃣ රන් අඹ වනාන්තරයේ සිතියම',
    },
  ];

  /// Analyzes telemetry logs and builds personalized revision skill models
  Future<List<RevisionSkillModel>> fetchPersonalizedRevisionSkills() async {
    final user = _auth.currentUser;
    if (user == null) {
      return _generateDefaultSkillModels();
    }

    try {
      final attemptsSnap = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('question_attempts')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      final List<Map<String, dynamic>> logs =
          attemptsSnap.docs.map((d) => d.data()).toList();

      if (logs.isEmpty) {
        return _generateDefaultSkillModels();
      }

      // Group attempts by skillTag
      final Map<String, _SkillCounter> counters = {};
      for (var log in logs) {
        final tag = (log['skillTag'] ?? 'number_ordering').toString();
        final isCorrect = log['isCorrect'] == true;
        final hintUsed = log['hintUsed'] == true;

        counters.putIfAbsent(tag, () => _SkillCounter());
        counters[tag]!.addAttempt(isCorrect, hintUsed);
      }

      List<RevisionSkillModel> skillModels = [];

      for (var meta in _allSupportedSkills) {
        final tag = meta['tag']!;
        final cnt = counters[tag] ?? _SkillCounter.defaultForTag(tag);

        double acc = cnt.totalAttempts > 0 ? (cnt.correctAttempts / cnt.totalAttempts) : 0.65;
        RevisionPriority prio;
        String msg;

        if (acc < 0.60 || cnt.hintsUsed > 3) {
          prio = RevisionPriority.high;
          msg = 'තව ටිකක් පුහුණු වෙමු! 🎯';
        } else if (acc < 0.80) {
          prio = RevisionPriority.medium;
          msg = 'හොඳ උත්සාහයක්! තව ටිකක් ප්‍රගුණ කරමු! ⭐';
        } else {
          prio = RevisionPriority.mastered;
          msg = 'විශිෂ්ටයි! ඔබ මෙම හැකියාව මැනවින් ප්‍රගුණ කර ඇත! 🏆';
        }

        skillModels.add(
          RevisionSkillModel(
            skillTag: tag,
            titleSinhala: meta['titleSin']!,
            titleEnglish: meta['titleEng']!,
            lessonId: meta['lesson']!,
            conceptId: meta['concept']!,
            conceptTitle: meta['conceptTitle']!,
            accuracyPercent: acc,
            totalAttempts: cnt.totalAttempts,
            correctAttempts: cnt.correctAttempts,
            hintsUsed: cnt.hintsUsed,
            priority: prio,
            encouragementMsg: msg,
          ),
        );
      }

      // Sort skills: High priority first, then Medium priority, then Mastered
      skillModels.sort((a, b) => a.priority.index.compareTo(b.priority.index));

      return skillModels;
    } catch (e) {
      print('Error fetching personalized revision skills: $e');
      return _generateDefaultSkillModels();
    }
  }

  /// Default fallback skill models if telemetry is empty
  List<RevisionSkillModel> _generateDefaultSkillModels() {
    return _allSupportedSkills.map((meta) {
      final tag = meta['tag']!;
      double acc = 0.62;
      RevisionPriority prio = RevisionPriority.high;
      if (tag == 'place_value' || tag == 'number_reading') {
        acc = 0.85;
        prio = RevisionPriority.mastered;
      } else if (tag == 'largest_number') {
        acc = 0.72;
        prio = RevisionPriority.medium;
      }

      return RevisionSkillModel(
        skillTag: tag,
        titleSinhala: meta['titleSin']!,
        titleEnglish: meta['titleEng']!,
        lessonId: meta['lesson']!,
        conceptId: meta['concept']!,
        conceptTitle: meta['conceptTitle']!,
        accuracyPercent: acc,
        totalAttempts: 5,
        correctAttempts: (acc * 5).toInt(),
        hintsUsed: 1,
        priority: prio,
        encouragementMsg: prio == RevisionPriority.high
            ? 'තව ටිකක් පුහුණු වෙමු! 🎯'
            : (prio == RevisionPriority.medium
                ? 'හොඳ උත්සාහයක්! තව ටිකක් ප්‍රගුණ කරමු! ⭐'
                : 'විශිෂ්ටයි! ඔබ මෙම හැකියාව මැනවින් ප්‍රගුණ කර ඇත! 🏆'),
      );
    }).toList()
      ..sort((a, b) => a.priority.index.compareTo(b.priority.index));
  }

  /// Record a revision question attempt with source: "revision"
  Future<void> recordRevisionAttempt({
    required String lessonId,
    required String conceptId,
    required String questionId,
    required int attemptNumber,
    required String answerGiven,
    required String correctAnswer,
    required bool isCorrect,
    required bool hintUsed,
    required String skillTag,
    required int difficulty,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('question_attempts')
          .add({
        'studentId': user.uid,
        'lessonId': lessonId,
        'conceptId': conceptId,
        'questionId': questionId,
        'attemptNumber': attemptNumber,
        'answerGiven': answerGiven,
        'correctAnswer': correctAnswer,
        'isCorrect': isCorrect,
        'hintUsed': hintUsed,
        'skillTag': skillTag,
        'difficulty': difficulty,
        'source': 'revision',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording revision attempt: $e');
    }
  }

  /// Complete a revision session and award +50 XP, also saving an exam_results record
  Future<void> completeRevisionSession({
    String skillTitle = 'පුනරීක්ෂණ අභ්‍යාසය',
    required int totalQuestions,
    required int correctCount,
    required int xpEarned,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Increment XP and revision stats in user document
      final userRef = _firestore.collection('users').doc(user.uid);
      await userRef.set({
        'xp': FieldValue.increment(xpEarned),
        'revisionSessionsCompleted': FieldValue.increment(1),
        'revisionQuestionsCompleted': FieldValue.increment(totalQuestions),
        'revisionCorrectAnswers': FieldValue.increment(correctCount),
        'lastRevisionDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Save history record to exam_results for Exam/Revision History
      await userRef.collection('exam_results').add({
        'examTitle': '🔄 පුනරීක්ෂණය: $skillTitle',
        'score': correctCount,
        'total': totalQuestions,
        'xpEarned': xpEarned,
        'type': 'revision',
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error completing revision session: $e');
    }
  }
}

class _SkillCounter {
  int totalAttempts = 0;
  int correctAttempts = 0;
  int hintsUsed = 0;

  _SkillCounter();

  void addAttempt(bool isCorrect, bool hint) {
    totalAttempts++;
    if (isCorrect) correctAttempts++;
    if (hint) hintsUsed++;
  }

  factory _SkillCounter.defaultForTag(String tag) {
    final cnt = _SkillCounter();
    cnt.totalAttempts = 5;
    cnt.correctAttempts = (tag.contains('order') || tag.contains('smallest')) ? 3 : 4;
    cnt.hintsUsed = 1;
    return cnt;
  }
}
