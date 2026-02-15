import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Service for managing achievements and badges
class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Reference to user's achievements collection
  CollectionReference<Map<String, dynamic>> get _achievementsRef {
    if (_userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(_userId).collection('achievements');
  }

  /// Check and unlock achievements based on current stats
  Future<List<Achievement>> checkAndUnlockAchievements({
    required int xp,
    required int streak,
    required int quizCount,
    required bool hasPerfectScore,
    required int videosWatched,
  }) async {
    if (_userId == null) return [];

    List<Achievement> newlyUnlocked = [];

    for (var achievement in Achievements.all) {
      // Check if already unlocked
      final doc = await _achievementsRef.doc(achievement.id).get();
      if (doc.exists) continue;

      // Check if criteria met
      bool unlocked = false;
      switch (achievement.type) {
        case 'xp':
          unlocked = xp >= achievement.requiredValue;
          break;
        case 'streak':
          unlocked = streak >= achievement.requiredValue;
          break;
        case 'quiz':
          unlocked = quizCount >= achievement.requiredValue;
          break;
        case 'perfect':
          unlocked = hasPerfectScore;
          break;
        case 'video':
          unlocked = videosWatched >= achievement.requiredValue;
          break;
      }

      if (unlocked) {
        await _unlockAchievement(achievement);
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  /// Unlock a specific achievement
  Future<void> _unlockAchievement(Achievement achievement) async {
    if (_userId == null) return;

    await _achievementsRef.doc(achievement.id).set({
      'id': achievement.id,
      'name': achievement.name,
      'unlockedAt': FieldValue.serverTimestamp(),
    });

    // Award bonus XP for unlocking achievements
    await _awardBonusXP(achievement);
  }

  /// Award bonus XP for unlocking achievements
  Future<void> _awardBonusXP(Achievement achievement) async {
    if (_userId == null) return;

    int bonusXP = 10; // Base XP for any achievement
    
    // Extra XP for harder achievements
    if (achievement.requiredValue >= 100) bonusXP = 25;
    if (achievement.requiredValue >= 500) bonusXP = 50;
    if (achievement.requiredValue >= 1000) bonusXP = 100;

    await _firestore.collection('users').doc(_userId).update({
      'xp': FieldValue.increment(bonusXP),
    });
  }

  /// Check if a specific achievement is unlocked
  Future<bool> isUnlocked(String achievementId) async {
    if (_userId == null) return false;

    final doc = await _achievementsRef.doc(achievementId).get();
    return doc.exists;
  }

  /// Get all unlocked achievement IDs
  Future<Set<String>> getUnlockedAchievementIds() async {
    if (_userId == null) return {};

    final snapshot = await _achievementsRef.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  /// Get count of unlocked achievements
  Future<int> getUnlockedCount() async {
    if (_userId == null) return 0;

    final snapshot = await _achievementsRef.get();
    return snapshot.docs.length;
  }

  /// Stream of unlocked achievements for real-time updates
  Stream<Set<String>> streamUnlockedAchievements() {
    if (_userId == null) return Stream.value({});

    return _achievementsRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.id).toSet());
  }

  /// Quick check for common achievement triggers
  Future<List<Achievement>> onQuizCompleted({
    required int score,
    required int total,
    required int newXP,
    required int currentStreak,
  }) async {
    // Get current stats
    final userDoc = await _firestore.collection('users').doc(_userId).get();
    final userData = userDoc.data() ?? {};
    
    // Get quiz count
    final quizResults = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('exam_results')
        .get();
    
    // Get video watch count
    final videoProgress = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('video_progress')
        .get();

    return checkAndUnlockAchievements(
      xp: userData['xp'] ?? 0,
      streak: currentStreak,
      quizCount: quizResults.docs.length,
      hasPerfectScore: score == total,
      videosWatched: videoProgress.docs.length,
    );
  }
}

/// Extended achievements list (adding video watching achievements)
extension ExtendedAchievements on Achievements {
  static List<Achievement> get allWithVideos => [
    ...Achievements.all,
    const Achievement(
      id: 'video_5',
      name: 'Video Viewer',
      description: 'Watch 5 videos',
      icon: Icons.play_circle,
      color: Colors.red,
      requiredValue: 5,
      type: 'video',
    ),
    const Achievement(
      id: 'video_20',
      name: 'Binge Learner',
      description: 'Watch 20 videos',
      icon: Icons.smart_display,
      color: Colors.red,
      requiredValue: 20,
      type: 'video',
    ),
  ];
}
