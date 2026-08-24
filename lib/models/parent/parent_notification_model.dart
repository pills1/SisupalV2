import 'package:cloud_firestore/cloud_firestore.dart';

enum ParentNotificationType {
  info,      // Informational updates
  positive,  // Achievements, streaks, milestone completions
  attention, // Focus areas needing practice
}

class ParentNotificationModel {
  final String id;
  final String parentUid;
  final String studentUid;
  final String title;
  final String message;
  final ParentNotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedLessonId;
  final String? relatedConceptId;

  ParentNotificationModel({
    required this.id,
    required this.parentUid,
    required this.studentUid,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.relatedLessonId,
    this.relatedConceptId,
  });

  factory ParentNotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    ParentNotificationType parseType(String? val) {
      switch (val) {
        case 'positive':
          return ParentNotificationType.positive;
        case 'attention':
          return ParentNotificationType.attention;
        default:
          return ParentNotificationType.info;
      }
    }

    DateTime parseTime(dynamic raw) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      return DateTime.now();
    }

    return ParentNotificationModel(
      id: docId,
      parentUid: map['parentUid'] ?? '',
      studentUid: map['studentUid'] ?? '',
      title: map['title'] ?? 'Notification',
      message: map['message'] ?? '',
      type: parseType(map['type']),
      timestamp: parseTime(map['timestamp']),
      isRead: map['isRead'] ?? false,
      relatedLessonId: map['relatedLessonId'],
      relatedConceptId: map['relatedConceptId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentUid': parentUid,
      'studentUid': studentUid,
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
      'relatedLessonId': relatedLessonId,
      'relatedConceptId': relatedConceptId,
    };
  }
}
