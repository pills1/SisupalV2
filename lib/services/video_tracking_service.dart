import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for tracking video watch progress
class VideoTrackingService {
  static final VideoTrackingService _instance = VideoTrackingService._internal();
  factory VideoTrackingService() => _instance;
  VideoTrackingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Reference to user's video progress collection
  CollectionReference<Map<String, dynamic>> get _progressRef {
    if (_userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(_userId).collection('video_progress');
  }

  /// Mark a video as started watching
  Future<void> startWatching(String videoId, {String? videoTitle, String? category}) async {
    if (_userId == null) return;

    try {
      final docRef = _progressRef.doc(videoId);
      final doc = await docRef.get();

      if (!doc.exists) {
        // First time watching this video
        await docRef.set({
          'videoId': videoId,
          'videoTitle': videoTitle,
          'category': category,
          'startedAt': FieldValue.serverTimestamp(),
          'lastWatchedAt': FieldValue.serverTimestamp(),
          'watchCount': 1,
          'completed': false,
          'watchDurationSeconds': 0,
        });
      } else {
        // Increment watch count
        await docRef.update({
          'lastWatchedAt': FieldValue.serverTimestamp(),
          'watchCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Error starting video tracking: $e');
    }
  }

  /// Update watch duration (call periodically while watching)
  Future<void> updateWatchDuration(String videoId, int durationSeconds) async {
    if (_userId == null) return;

    try {
      await _progressRef.doc(videoId).update({
        'watchDurationSeconds': durationSeconds,
        'lastWatchedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating watch duration: $e');
    }
  }

  /// Mark a video as completed
  Future<void> markCompleted(String videoId) async {
    if (_userId == null) return;

    try {
      await _progressRef.doc(videoId).update({
        'completed': true,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking video complete: $e');
    }
  }

  /// Check if a video has been watched
  Future<bool> hasWatched(String videoId) async {
    if (_userId == null) return false;

    try {
      final doc = await _progressRef.doc(videoId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Check if a video has been completed
  Future<bool> isCompleted(String videoId) async {
    if (_userId == null) return false;

    try {
      final doc = await _progressRef.doc(videoId).get();
      if (!doc.exists) return false;
      return doc.data()?['completed'] ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get all watched videos
  Future<List<VideoProgress>> getWatchedVideos() async {
    if (_userId == null) return [];

    try {
      final snapshot = await _progressRef
          .orderBy('lastWatchedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => VideoProgress.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting watched videos: $e');
      return [];
    }
  }

  /// Get count of completed videos
  Future<int> getCompletedCount() async {
    if (_userId == null) return 0;

    try {
      final snapshot = await _progressRef
          .where('completed', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Stream of video progress for real-time updates
  Stream<List<VideoProgress>> streamWatchedVideos() {
    if (_userId == null) return Stream.value([]);

    return _progressRef
        .orderBy('lastWatchedAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => VideoProgress.fromMap(doc.data())).toList());
  }
}

/// Model for video progress data
class VideoProgress {
  final String videoId;
  final String? videoTitle;
  final String? category;
  final DateTime? startedAt;
  final DateTime? lastWatchedAt;
  final DateTime? completedAt;
  final int watchCount;
  final int watchDurationSeconds;
  final bool completed;

  VideoProgress({
    required this.videoId,
    this.videoTitle,
    this.category,
    this.startedAt,
    this.lastWatchedAt,
    this.completedAt,
    this.watchCount = 0,
    this.watchDurationSeconds = 0,
    this.completed = false,
  });

  factory VideoProgress.fromMap(Map<String, dynamic> map) {
    return VideoProgress(
      videoId: map['videoId'] ?? '',
      videoTitle: map['videoTitle'],
      category: map['category'],
      startedAt: (map['startedAt'] as Timestamp?)?.toDate(),
      lastWatchedAt: (map['lastWatchedAt'] as Timestamp?)?.toDate(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      watchCount: map['watchCount'] ?? 0,
      watchDurationSeconds: map['watchDurationSeconds'] ?? 0,
      completed: map['completed'] ?? false,
    );
  }

  String get formattedDuration {
    final minutes = watchDurationSeconds ~/ 60;
    final seconds = watchDurationSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
