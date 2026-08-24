import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/parent/parent_analytics_model.dart';
import '../models/parent/parent_notification_model.dart';

class ParentAnalyticsConfig {
  static const double strengthThreshold = 0.80; // >= 80% accuracy = Strength
  static const double focusThreshold = 0.70;    // < 70% accuracy = Focus Area
  static const int minSampleSize = 2;           // Min attempt logs required
}

class ParentAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch and aggregate full Parent Dashboard analytics for the linked student
  Future<ParentAnalyticsModel> fetchParentAnalytics() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not authenticated");
    }

    String parentUid = currentUser.uid;
    String targetStudentUid = parentUid;

    // 1. Resolve linked student UID
    try {
      final parentDoc = await _firestore.collection('users').doc(parentUid).get();
      if (parentDoc.exists && parentDoc.data() != null) {
        final data = parentDoc.data()!;
        if (data.containsKey('linkedStudentUid') && data['linkedStudentUid'] != null) {
          targetStudentUid = data['linkedStudentUid'].toString();
        }
      }
    } catch (e) {
      print('Error resolving linked student UID: $e');
    }

    // 2. Load Student User Profile Document
    DocumentSnapshot studentDoc =
        await _firestore.collection('users').doc(targetStudentUid).get();
    Map<String, dynamic> studentData = {};
    if (studentDoc.exists && studentDoc.data() != null) {
      studentData = studentDoc.data() as Map<String, dynamic>;
    }

    final studentName = studentData['name'] ?? studentData['studentName'] ?? 'Student';
    final grade = studentData['grade'] is int ? studentData['grade'] : 5;
    final xp = studentData['xp'] is int ? studentData['xp'] : (studentData['xp'] as num?)?.toInt() ?? 0;
    final streak = studentData['streak'] is int ? studentData['streak'] : (studentData['streak'] as num?)?.toInt() ?? 0;

    // Calculate level title based on XP
    String levelTitle = 'Level 1 Explorer';
    if (xp >= 2000) {
      levelTitle = 'Level 5 Master Explorer 👑';
    } else if (xp >= 1200) {
      levelTitle = 'Level 4 Explorer 🌟';
    } else if (xp >= 600) {
      levelTitle = 'Level 3 Adventurer 🚀';
    } else if (xp >= 200) {
      levelTitle = 'Level 2 Voyager 🧭';
    }

    // 3. Load Progress Doc (Completed Lessons & Concepts)
    final progressDoc =
        await _firestore.collection('users').doc(targetStudentUid).collection('progress').doc('maths').get();
    List<String> completedLessons = [];
    List<String> completedConcepts = [];

    if (progressDoc.exists && progressDoc.data() != null) {
      final pData = progressDoc.data()!;
      completedLessons = List<String>.from(pData['completedLessons'] ?? []);
      completedConcepts = List<String>.from(pData['completedConcepts'] ?? []);
    }

    // 4. Load Achievements & Badges
    final achievementsSnap =
        await _firestore.collection('users').doc(targetStudentUid).collection('achievements').get();
    final List<String> earnedBadges = achievementsSnap.docs.map((d) {
      final data = d.data();
      return (data['title'] ?? data['id'] ?? 'Achievement').toString();
    }).toList();

    // 5. Load Question Attempts Telemetry
    final attemptsSnap = await _firestore
        .collection('users')
        .doc(targetStudentUid)
        .collection('question_attempts')
        .orderBy('timestamp', descending: true)
        .limit(150)
        .get();

    final List<Map<String, dynamic>> attemptLogs =
        attemptsSnap.docs.map((d) => d.data()).toList();

    // 6. Aggregate Skill Performance Metrics
    final Map<String, _SkillAggregator> skillAggregates = {};

    for (var log in attemptLogs) {
      final skillTag = (log['skillTag'] ?? 'general_maths').toString();
      final isCorrect = log['isCorrect'] == true;
      final hintUsed = log['hintUsed'] == true;

      skillAggregates.putIfAbsent(skillTag, () => _SkillAggregator(skillTag: skillTag));
      skillAggregates[skillTag]!.addAttempt(isCorrect: isCorrect, hintUsed: hintUsed);
    }

    // Classify into Strengths and Focus Areas
    final List<SkillMetric> strengths = [];
    final List<SkillMetric> focusAreas = [];

    skillAggregates.forEach((tag, agg) {
      if (agg.totalAttempts >= ParentAnalyticsConfig.minSampleSize) {
        final metric = agg.toMetric();
        if (metric.accuracyPercent >= ParentAnalyticsConfig.strengthThreshold) {
          strengths.add(metric);
        } else if (metric.accuracyPercent < ParentAnalyticsConfig.focusThreshold) {
          focusAreas.add(metric);
        }
      }
    });

    // 7. Determine Recommended Next Step
    RecommendationModel? recommendation;
    if (focusAreas.isNotEmpty) {
      final primaryFocus = focusAreas.first;
      recommendation = RecommendationModel(
        skillTag: primaryFocus.skillTag,
        skillTitle: primaryFocus.titleSinhala,
        lessonId: primaryFocus.suggestedLessonId,
        conceptId: primaryFocus.suggestedConceptId,
        conceptTitle: primaryFocus.suggestedPracticeConceptTitle,
        currentAccuracy: primaryFocus.accuracyPercent,
        reason: 'ඔබේ දරුවාට ${primaryFocus.titleSinhala} නැවත පුහුණු වීමට උපකාර අවශ්‍යයි.',
      );
    } else if (completedLessons.contains('math_grade5_01') && !completedLessons.contains('math_grade5_02')) {
      recommendation = RecommendationModel(
        skillTag: 'number_ordering',
        skillTitle: 'සංඛ්‍යා පටිපාටිගත කරමු',
        lessonId: 'math_grade5_02',
        conceptId: 'c3_digit_card_train',
        conceptTitle: 'තෙවන නැවතුම – ඉලක්කම් පත්‍ර දුම්රිය',
        currentAccuracy: 0.75,
        reason: 'Lesson 2 නැවතුම් සාර්ථකව ඉදිරියට කරගෙන යන්න!',
      );
    }

    // 8. Aggregate Performance Trend Timeline (7/30 days)
    final List<TrendPoint> trendData = _aggregateTrendPoints(attemptLogs);

    // 9. Build Mathematics Lesson & Concept Analytics
    final List<LessonAnalyticsModel> lessonProgressList = _buildLessonAnalytics(
      completedLessons: completedLessons,
      completedConcepts: completedConcepts,
    );

    int totalConcepts = 11; // 5 concepts in Lesson 1 + 6 concepts in Lesson 2
    int completedConceptsCount = 0;
    for (var lesson in lessonProgressList) {
      completedConceptsCount += lesson.completedConceptsCount;
    }

    final double overallProgressPercent =
        (completedConceptsCount / totalConcepts).clamp(0.0, 1.0);

    // 10. Compute Overall Accuracy Percent
    int totalAllAttempts = 0;
    int totalCorrectAttempts = 0;
    for (var log in attemptLogs) {
      totalAllAttempts++;
      if (log['isCorrect'] == true) totalCorrectAttempts++;
    }

    final double overallAccuracyPercent = totalAllAttempts > 0
        ? (totalCorrectAttempts / totalAllAttempts)
        : 0.85;

    // 11. Load Recent Exam/Quiz Activity Feed
    final examSnap = await _firestore
        .collection('users')
        .doc(targetStudentUid)
        .collection('exam_results')
        .orderBy('date', descending: true)
        .limit(10)
        .get();

    final List<ActivityFeedItem> recentActivities = examSnap.docs.map((d) {
      final data = d.data();
      final title = (data['examTitle'] ?? 'Mathematics Quiz').toString();
      final score = (data['score'] ?? 0) as int;
      final total = (data['total'] ?? 10) as int;
      final perc = total > 0 ? (score / total) : 0.0;
      DateTime time = DateTime.now();
      if (data['date'] is Timestamp) {
        time = (data['date'] as Timestamp).toDate();
      }

      return ActivityFeedItem(
        title: title,
        lessonName: 'Mathematics',
        timestamp: time,
        score: score,
        total: total,
        percentage: perc,
      );
    }).toList();

    // 12. Dynamic Weekly Insight
    String weeklyInsight =
        'ඔබේ දරුවා ගණිත විෂයෙහි සාර්ථක ප්‍රගතියක් පෙන්වයි. කෙටි, දිනපතා පුහුණුවීම් දිරිමත් කරන්න! 🌟';
    if (focusAreas.isNotEmpty) {
      weeklyInsight =
          '${focusAreas.first.titleSinhala} සඳහා තවත් සුළු පුහුණුවක් ලබාදීමෙන් දරුවාගේ ලකුණු තවත් ඉහළ නැංවිය හැක. 🎯';
    } else if (overallProgressPercent >= 0.8) {
      weeklyInsight =
          'නියමයි! ඔබේ දරුවා ගණිත 1 සහ 2 පාඩම් සියල්ල පාහේ විශිෂ්ට ලෙස අවසන් කර ඇත! 🏆';
    }

    final model = ParentAnalyticsModel(
      studentUid: targetStudentUid,
      studentName: studentName,
      grade: grade,
      xp: xp,
      streak: streak,
      levelTitle: levelTitle,
      overallProgressPercent: overallProgressPercent,
      overallAccuracyPercent: overallAccuracyPercent,
      totalBadgesCount: earnedBadges.length,
      completedLessonsCount: completedLessons.length,
      strengths: strengths,
      focusAreas: focusAreas,
      recommendedNextStep: recommendation,
      trendData: trendData,
      lessonProgressList: lessonProgressList,
      recentActivities: recentActivities,
      earnedBadgesList: earnedBadges,
      weeklyInsight: weeklyInsight,
    );

    // Save automatic notifications if needed
    _generateNotificationsIfNecessary(parentUid, targetStudentUid, model);

    return model;
  }

  /// Build Lesson Analytics models for Lesson 1 & Lesson 2
  List<LessonAnalyticsModel> _buildLessonAnalytics({
    required List<String> completedLessons,
    required List<String> completedConcepts,
  }) {
    // LESSON 1: Quest for the Golden Mango
    final isLesson1Done = completedLessons.contains('math_grade5_01');
    final l1ConceptsRaw = [
      {'id': 'c1_map_reading', 't': '1️⃣ රන් අඹ වනාන්තරයේ සිතියම', 's': 'ස්ථානීය අගය හැඳින්වීම'},
      {'id': 'c2_abacus_river', 't': '2️⃣ ඇබකස් ගඟ තරණය', 's': 'ඇබකස් සංකල්පය භාවිතය'},
      {'id': 'c3_place_value_gate', 't': '3️⃣ සංඛ්‍යා රාජධානියේ විශාල දොරටුව', 's': 'ස්ථානීය අගයන් සංසන්දනය'},
      {'id': 'c4_cave_pedestals', 't': '4️⃣ මායා ගුහාවේ පීඨිකා', 's': 'විස්තරාත්මක සටහන'},
      {'id': 'c5_golden_mango_chest', 't': '5️⃣ රන් අඹ අභිමුව', 's': 'රන් අඹ පූර්ණ පරීක්ෂණය'},
    ];

    int l1CompletedCount = 0;
    List<ConceptAnalyticsModel> l1Concepts = [];

    for (int i = 0; i < l1ConceptsRaw.length; i++) {
      final raw = l1ConceptsRaw[i];
      final cid = raw['id']!;
      bool isDone = isLesson1Done ||
          completedConcepts.contains(cid) ||
          (i == 0 && (completedConcepts.contains('c1_jungle_map') || completedConcepts.contains('c1_map_reading') || completedConcepts.contains('c1'))) ||
          (i == 1 && (completedConcepts.contains('c2_river_of_beads') || completedConcepts.contains('c2_abacus_river') || completedConcepts.contains('c2'))) ||
          (i == 2 && (completedConcepts.contains('c3_giants_gate') || completedConcepts.contains('c3_place_value_gate') || completedConcepts.contains('c3'))) ||
          (i == 3 && (completedConcepts.contains('c4_crystal_cavern') || completedConcepts.contains('c4_cave_pedestals') || completedConcepts.contains('c4'))) ||
          (i == 4 && (completedConcepts.contains('c5_golden_chest') || completedConcepts.contains('c5_golden_mango_chest') || completedConcepts.contains('c5')));

      bool isCurr = !isDone && (i == 0 || (i > 0 && l1Concepts[i - 1].isCompleted));
      bool isLock = !isDone && !isCurr;

      if (isDone) l1CompletedCount++;

      l1Concepts.add(
        ConceptAnalyticsModel(
          conceptId: cid,
          title: raw['t']!,
          subtitle: raw['s']!,
          isCompleted: isDone,
          isCurrent: isCurr,
          isLocked: isLock,
        ),
      );
    }

    final double l1Percent = (l1CompletedCount / 5).clamp(0.0, 1.0);

    final lesson1 = LessonAnalyticsModel(
      lessonId: 'math_grade5_01',
      lessonNumber: 1,
      title: 'Quest for the Golden Mango 🥭',
      subtitle: 'රන් අඹ ගෙඩිය සොයා ගමන (Concepts 1–5)',
      icon: '🥭',
      themeColor: const Color(0xFFFF6B35),
      completionPercent: l1Percent,
      completedConceptsCount: l1CompletedCount,
      totalConceptsCount: 5,
      isCompleted: isLesson1Done || l1CompletedCount == 5,
      concepts: l1Concepts,
    );

    // LESSON 2: The Great Number Train
    final isLesson2Done = completedLessons.contains('math_grade5_02');
    final l2ConceptsRaw = [
      {'id': 'c1_number_train_intro', 't': '1️⃣ පළමු නැවතුම – සංඛ්‍යා සසඳමු', 's': '2, 3, 4 සහ 5 ඉලක්කම් සංඛ්‍යා සසඳමු'},
      {'id': 'c2_number_train_ordering', 't': '2️⃣ දෙවන නැවතුම – සංඛ්‍යා පටිපාටිගත කරමු', 's': 'ආරෝහණ සහ අවරෝහණ පිළිවෙළ'},
      {'id': 'c3_digit_card_train', 't': '3️⃣ තෙවන නැවතුම – ඉලක්කම් පත්‍ර දුම්රිය', 's': 'ඉලක්කම් පත්වලින් සංඛ්‍යා හදමු'},
      {'id': 'c4_thousands_mountain', 't': '4️⃣ හතරවන නැවතුම – දහස් කඳුකරය', 's': '4 සහ 5 ඉලක්කම් සංඛ්‍යා සසඳමු'},
      {'id': 'c5_challenge_train', 't': '5️⃣ පස්වන නැවතුම – අභියෝග දුම්රිය', 's': 'සංඛ්‍යා අභියෝග ජයගමු'},
      {'id': 'c6_great_number_train_mastery', 't': '6️⃣ හයවන නැවතුම – මහා සංඛ්‍යා දුම්රිය', 's': 'මහා ගණිත ශූරතාවය'},
    ];

    int l2CompletedCount = 0;
    List<ConceptAnalyticsModel> l2Concepts = [];

    for (int i = 0; i < l2ConceptsRaw.length; i++) {
      final raw = l2ConceptsRaw[i];
      final cid = raw['id']!;
      bool isDone = isLesson2Done || completedConcepts.contains(cid);
      bool isCurr = isLesson1Done && !isDone && (i == 0 || (i > 0 && l2Concepts[i - 1].isCompleted));
      bool isLock = !isDone && !isCurr;

      if (isDone) l2CompletedCount++;

      l2Concepts.add(
        ConceptAnalyticsModel(
          conceptId: cid,
          title: raw['t']!,
          subtitle: raw['s']!,
          isCompleted: isDone,
          isCurrent: isCurr,
          isLocked: isLock,
        ),
      );
    }

    final double l2Percent = (l2CompletedCount / 6).clamp(0.0, 1.0);

    final lesson2 = LessonAnalyticsModel(
      lessonId: 'math_grade5_02',
      lessonNumber: 2,
      title: 'The Great Number Train 🚂',
      subtitle: 'සංඛ්‍යා - 2 | The Great Number Train (Concepts 1–6)',
      icon: '🚂',
      themeColor: const Color(0xFF8E44AD),
      completionPercent: l2Percent,
      completedConceptsCount: l2CompletedCount,
      totalConceptsCount: 6,
      isCompleted: isLesson2Done || l2CompletedCount == 6,
      concepts: l2Concepts,
    );

    return [lesson1, lesson2];
  }

  /// Trend timeline data points calculation
  List<TrendPoint> _aggregateTrendPoints(List<Map<String, dynamic>> logs) {
    if (logs.isEmpty) return [];

    final Map<String, List<bool>> groupedByDay = {};

    for (var log in logs) {
      DateTime time = DateTime.now();
      if (log['timestamp'] is Timestamp) {
        time = (log['timestamp'] as Timestamp).toDate();
      }
      final key = DateFormat('yyyy-MM-dd').format(time);

      groupedByDay.putIfAbsent(key, () => []);
      groupedByDay[key]!.add(log['isCorrect'] == true);
    }

    final List<TrendPoint> points = [];
    groupedByDay.forEach((dateStr, bools) {
      final dt = DateTime.tryParse(dateStr) ?? DateTime.now();
      int correct = bools.where((b) => b).length;
      double acc = correct / bools.length;
      points.add(TrendPoint(date: dt, accuracyPercent: acc, attemptCount: bools.length));
    });

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  /// Generate notifications automatically based on analytics milestones
  Future<void> _generateNotificationsIfNecessary(
    String parentUid,
    String studentUid,
    ParentAnalyticsModel model,
  ) async {
    try {
      final notifRef = _firestore.collection('users').doc(parentUid).collection('notifications');
      final existingNotifs = await notifRef.limit(10).get();

      if (existingNotifs.docs.isEmpty) {
        // Add initial welcome & progress notifications
        await notifRef.add(
          ParentNotificationModel(
            id: '',
            parentUid: parentUid,
            studentUid: studentUid,
            title: '🎉 Lesson 1 Completed!',
            message: '${model.studentName} successfully completed Quest for the Golden Mango 🥭!',
            type: ParentNotificationType.positive,
            timestamp: DateTime.now(),
            isRead: false,
          ).toMap(),
        );

        if (model.focusAreas.isNotEmpty) {
          final focus = model.focusAreas.first;
          await notifRef.add(
            ParentNotificationModel(
              id: '',
              parentUid: parentUid,
              studentUid: studentUid,
              title: '🎯 Focus Area Recommendation',
              message: '${model.studentName} could use a little practice with ${focus.titleSinhala}.',
              type: ParentNotificationType.attention,
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              isRead: false,
            ).toMap(),
          );
        }
      }
    } catch (e) {
      print('Error generating notifications: $e');
    }
  }

  /// Real-time stream of parent notifications
  Stream<List<ParentNotificationModel>> streamNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ParentNotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Mark notification as read
  Future<void> markNotificationRead(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification read: $e');
    }
  }
}

/// Helper aggregator for skill tag calculation
class _SkillAggregator {
  final String skillTag;
  int totalAttempts = 0;
  int correctAttempts = 0;
  int hintsUsedCount = 0;

  _SkillAggregator({required this.skillTag});

  void addAttempt({required bool isCorrect, required bool hintUsed}) {
    totalAttempts++;
    if (isCorrect) correctAttempts++;
    if (hintUsed) hintsUsedCount++;
  }

  SkillMetric toMetric() {
    double acc = totalAttempts > 0 ? (correctAttempts / totalAttempts) : 0.0;

    String titleSinhala = 'සංඛ්‍යා සංසන්දනය';
    String titleEnglish = 'Number Comparison';
    String practiceTitle = '1️⃣ පළමු නැවතුම – සංඛ්‍යා සසඳමු';
    String lessonId = 'math_grade5_02';
    String conceptId = 'c1_number_train_intro';

    if (skillTag == 'number_ordering' || skillTag.contains('order')) {
      titleSinhala = 'සංඛ්‍යා පටිපාටිගත කිරීම';
      titleEnglish = 'Number Ordering';
      practiceTitle = '2️⃣ දෙවන නැවතුම – සංඛ්‍යා පටිපාටිගත කරමු';
      conceptId = 'c2_number_train_ordering';
    } else if (skillTag == 'place_value' || skillTag.contains('place')) {
      titleSinhala = 'ස්ථානීය අගය හඳුනාගැනීම';
      titleEnglish = 'Place Value Recognition';
      practiceTitle = '3️⃣ තෙවන නැවතුම – ඉලක්කම් පත්‍ර දුම්රිය';
      conceptId = 'c3_digit_card_train';
    } else if (skillTag == 'number_reading' || skillTag.contains('read')) {
      titleSinhala = 'සංඛ්‍යා කියවීම';
      titleEnglish = 'Number Reading';
      practiceTitle = '1️⃣ රන් අඹ වනාන්තරයේ සිතියම';
      lessonId = 'math_grade5_01';
      conceptId = 'c1_map_reading';
    } else if (skillTag == 'thousands_comparison') {
      titleSinhala = 'දහස් ස්ථාන සංසන්දනය';
      titleEnglish = 'Thousands Comparison';
      practiceTitle = '4️⃣ හතරවන නැවතුම – දහස් කඳුකරය';
      conceptId = 'c4_thousands_mountain';
    }

    return SkillMetric(
      skillTag: skillTag,
      titleSinhala: titleSinhala,
      titleEnglish: titleEnglish,
      accuracyPercent: acc,
      totalAttempts: totalAttempts,
      correctAttempts: correctAttempts,
      hintsUsedCount: hintsUsedCount,
      suggestedPracticeConceptTitle: practiceTitle,
      suggestedLessonId: lessonId,
      suggestedConceptId: conceptId,
    );
  }
}
