import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

/// Service for managing daily challenges
class DailyChallengeService {
  static final DailyChallengeService _instance = DailyChallengeService._internal();
  factory DailyChallengeService() => _instance;
  DailyChallengeService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Random _random = Random();

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> get _userChallengesRef {
    if (_userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(_userId).collection('daily_challenges').doc(_todayKey);
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Available challenge templates
  static final List<ChallengeTemplate> _templates = [
    ChallengeTemplate(
      id: 'complete_quiz',
      title: 'Quiz Master',
      description: 'Complete {target} quiz in any subject',
      xpReward: 50,
      target: 1,
      type: ChallengeType.quizComplete,
    ),
    ChallengeTemplate(
      id: 'complete_2_quizzes',
      title: 'Quiz Champion',
      description: 'Complete {target} quizzes today',
      xpReward: 100,
      target: 2,
      type: ChallengeType.quizComplete,
    ),
    ChallengeTemplate(
      id: 'perfect_quiz',
      title: 'Perfect Score',
      description: 'Get 100% on any quiz',
      xpReward: 75,
      target: 1,
      type: ChallengeType.perfectQuiz,
    ),
    ChallengeTemplate(
      id: 'combo_3',
      title: 'Combo Starter',
      description: 'Get a {target}x combo in a quiz',
      xpReward: 50,
      target: 3,
      type: ChallengeType.combo,
    ),
    ChallengeTemplate(
      id: 'combo_5',
      title: 'Combo Master',
      description: 'Get a {target}x combo in a quiz',
      xpReward: 100,
      target: 5,
      type: ChallengeType.combo,
    ),
    ChallengeTemplate(
      id: 'complete_lesson',
      title: 'Knowledge Seeker',
      description: 'Complete {target} lesson today',
      xpReward: 40,
      target: 1,
      type: ChallengeType.lessonComplete,
    ),
    ChallengeTemplate(
      id: 'watch_video',
      title: 'Video Learner',
      description: 'Watch {target} video lesson',
      xpReward: 30,
      target: 1,
      type: ChallengeType.videoWatch,
    ),
    ChallengeTemplate(
      id: 'earn_xp',
      title: 'XP Hunter',
      description: 'Earn {target} XP today',
      xpReward: 50,
      target: 100,
      type: ChallengeType.earnXP,
    ),
  ];

  /// Get today's challenges for the user
  Future<List<DailyChallenge>> getTodaysChallenges() async {
    if (_userId == null) return [];

    try {
      final doc = await _userChallengesRef.get();
      
      if (doc.exists) {
        // Return existing challenges for today
        final data = doc.data()!;
        final challengesList = data['challenges'] as List<dynamic>;
        return challengesList.map((c) => DailyChallenge.fromMap(c as Map<String, dynamic>)).toList();
      } else {
        // Generate new challenges for today
        final challenges = _generateDailyChallenges();
        await _saveChallenges(challenges);
        return challenges;
      }
    } catch (e) {
      print('Error getting challenges: $e');
      return [];
    }
  }

  /// Generate random daily challenges
  List<DailyChallenge> _generateDailyChallenges() {
    // Pick 3 random templates
    final shuffled = List<ChallengeTemplate>.from(_templates)..shuffle(_random);
    final selectedTemplates = shuffled.take(3).toList();

    return selectedTemplates.map((template) {
      return DailyChallenge(
        id: template.id,
        title: template.title,
        description: template.description.replaceAll('{target}', template.target.toString()),
        xpReward: template.xpReward,
        target: template.target,
        progress: 0,
        completed: false,
        type: template.type,
        date: _todayKey,
      );
    }).toList();
  }

  /// Save challenges to Firestore
  Future<void> _saveChallenges(List<DailyChallenge> challenges) async {
    if (_userId == null) return;

    await _userChallengesRef.set({
      'date': _todayKey,
      'challenges': challenges.map((c) => c.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update challenge progress
  Future<void> updateProgress(ChallengeType type, {int amount = 1}) async {
    if (_userId == null) return;

    try {
      final challenges = await getTodaysChallenges();
      bool anyUpdated = false;

      for (var i = 0; i < challenges.length; i++) {
        if (challenges[i].type == type && !challenges[i].completed) {
          challenges[i] = challenges[i].copyWith(
            progress: (challenges[i].progress + amount).clamp(0, challenges[i].target),
          );
          
          // Check if completed
          if (challenges[i].progress >= challenges[i].target && !challenges[i].completed) {
            challenges[i] = challenges[i].copyWith(completed: true);
            await _awardXP(challenges[i].xpReward);
          }
          anyUpdated = true;
        }
      }

      if (anyUpdated) {
        await _userChallengesRef.update({
          'challenges': challenges.map((c) => c.toMap()).toList(),
        });
      }
    } catch (e) {
      print('Error updating challenge progress: $e');
    }
  }

  /// Award XP to user for completing challenge
  Future<void> _awardXP(int xp) async {
    if (_userId == null) return;

    try {
      final userRef = _firestore.collection('users').doc(_userId);
      await userRef.update({
        'xp': FieldValue.increment(xp),
      });
    } catch (e) {
      print('Error awarding XP: $e');
    }
  }

  /// Stream today's challenges for real-time updates
  Stream<List<DailyChallenge>> streamTodaysChallenges() {
    if (_userId == null) return Stream.value([]);

    return _userChallengesRef.snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data()!;
      final challengesList = data['challenges'] as List<dynamic>;
      return challengesList.map((c) => DailyChallenge.fromMap(c as Map<String, dynamic>)).toList();
    });
  }

  /// Check and reset challenges at midnight (call on app start)
  Future<void> checkAndResetChallenges() async {
    // Getting today's challenges will automatically generate new ones if needed
    await getTodaysChallenges();
  }
}

/// Challenge types
enum ChallengeType {
  quizComplete,
  perfectQuiz,
  combo,
  lessonComplete,
  videoWatch,
  earnXP,
}

/// Template for generating challenges
class ChallengeTemplate {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int target;
  final ChallengeType type;

  const ChallengeTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.target,
    required this.type,
  });
}

/// Daily challenge model
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int target;
  final int progress;
  final bool completed;
  final ChallengeType type;
  final String date;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.target,
    required this.progress,
    required this.completed,
    required this.type,
    required this.date,
  });

  double get progressPercentage => target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  DailyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    int? xpReward,
    int? target,
    int? progress,
    bool? completed,
    ChallengeType? type,
    String? date,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'xpReward': xpReward,
      'target': target,
      'progress': progress,
      'completed': completed,
      'type': type.name,
      'date': date,
    };
  }

  factory DailyChallenge.fromMap(Map<String, dynamic> map) {
    return DailyChallenge(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      xpReward: map['xpReward'] ?? 0,
      target: map['target'] ?? 1,
      progress: map['progress'] ?? 0,
      completed: map['completed'] ?? false,
      type: ChallengeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ChallengeType.quizComplete,
      ),
      date: map['date'] ?? '',
    );
  }
}
