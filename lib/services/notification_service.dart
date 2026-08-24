import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Types of notifications
enum NotificationType {
  streakReminder,
  quizReminder,
  achievementUnlock,
  dailyChallenge,
  levelUp,
  mathsQuest,
  pastPaper,
}

/// Notification model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type.name,
    'createdAt': createdAt,
    'isRead': isRead,
    'data': data,
  };

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => NotificationType.quizReminder,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      data: map['data'],
    );
  }
}

/// Notification service for managing in-app notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Get notifications collection reference
  CollectionReference<Map<String, dynamic>> get _notificationsRef {
    if (_userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(_userId).collection('notifications');
  }

  /// Create a new notification
  Future<void> createNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    if (_userId == null) return;

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
      data: data,
    );

    await _notificationsRef.doc(notification.id).set(notification.toMap());
  }

  /// Get stream of unread notifications count
  Stream<int> getUnreadCountStream() {
    if (_userId == null) return Stream.value(0);

    return _notificationsRef
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get stream of all notifications
  Stream<List<AppNotification>> getNotificationsStream() {
    if (_userId == null) return Stream.value([]);

    return _notificationsRef
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromMap(doc.data()))
            .toList());
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_userId == null) return;
    await _notificationsRef.doc(notificationId).update({'isRead': true});
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_userId == null) return;

    final batch = _firestore.batch();
    final unreadDocs = await _notificationsRef.where('isRead', isEqualTo: false).get();

    for (var doc in unreadDocs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (_userId == null) return;
    await _notificationsRef.doc(notificationId).delete();
  }

  /// Check and send streak reminder if needed
  Future<void> checkStreakReminder() async {
    if (_userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final lastReminderKey = 'last_streak_reminder_$_userId';
    final lastReminder = prefs.getString(lastReminderKey);
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastReminder == today) return;

    final userDoc = await _firestore.collection('users').doc(_userId).get();
    final userData = userDoc.data();
    if (userData == null) return;

    final streak = userData['streak'] ?? 0;
    final lastActive = userData['lastActive'] as Timestamp?;

    if (lastActive != null) {
      final hoursSinceActive = DateTime.now().difference(lastActive.toDate()).inHours;
      if (hoursSinceActive >= 12 && streak > 0) {
        await createNotification(
          title: "🔥 Don't lose your streak!",
          body: "You have a $streak day streak! Complete a quiz today to keep it going.",
          type: NotificationType.streakReminder,
        );
        await prefs.setString(lastReminderKey, today);
      }
    }
  }

  /// Send achievement unlock notification
  Future<void> notifyAchievementUnlock(String achievementName, String emoji) async {
    await createNotification(
      title: "$emoji Achievement Unlocked!",
      body: "Congratulations! You earned the '$achievementName' badge!",
      type: NotificationType.achievementUnlock,
    );
  }

  /// Send level up notification
  Future<void> notifyLevelUp(int newLevel, String title) async {
    await createNotification(
      title: "🎉 Level Up!",
      body: "You reached Level $newLevel - $title! Keep up the great work!",
      type: NotificationType.levelUp,
    );
  }

  /// Send quiz reminder
  Future<void> sendQuizReminder() async {
    await createNotification(
      title: "📚 Time to Learn!",
      body: "Complete a quiz today and earn XP to level up!",
      type: NotificationType.quizReminder,
    );
  }

  /// Send daily challenge notification
  Future<void> notifyDailyChallenge() async {
    await createNotification(
      title: "🎯 New Daily Challenge!",
      body: "A new daily challenge is waiting for you. Complete it for bonus XP!",
      type: NotificationType.dailyChallenge,
    );
  }

  /// Send Maths Kingdom Adventure Quest notification
  Future<void> sendMathsQuestNotification() async {
    await createNotification(
      title: "🦜 New Maths Quest Available!",
      body: "Lesson 1: සංඛ්‍යා - 1 (Numbers - Part 1) is ready on the Adventure Map!",
      type: NotificationType.mathsQuest,
    );
  }

  /// Send Scholarship Past Papers notification
  Future<void> sendPastPapersNotification() async {
    await createNotification(
      title: "📄 Scholarship Past Papers Ready!",
      body: "Grade 5 Scholarship Past Papers (2021, 2022, 2023) are ready for practice!",
      type: NotificationType.pastPaper,
    );
  }

  /// Send welcome & initial educational notifications
  Future<void> sendWelcomeNotification() async {
    if (_userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final initKey = 'initial_notifications_sent_$_userId';
    final alreadySent = prefs.getBool(initKey) ?? false;

    if (!alreadySent) {
      await createNotification(
        title: "👋 Welcome to SisuPal 2.0!",
        body: "Start your Grade 5 learning adventure today and earn XP!",
        type: NotificationType.quizReminder,
      );
      await sendMathsQuestNotification();
      await sendPastPapersNotification();
      await notifyDailyChallenge();

      await prefs.setBool(initKey, true);
    }
  }
}

/// Widget to show notification icon with badge
class NotificationBadge extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;

  const NotificationBadge({
    super.key,
    required this.onTap,
    this.iconColor = Colors.blue,
    this.backgroundColor = const Color(0xFFE3F2FD),
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: NotificationService().getUnreadCountStream(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications, color: iconColor, size: 20),
              ),
              if (count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      count > 9 ? '9+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
