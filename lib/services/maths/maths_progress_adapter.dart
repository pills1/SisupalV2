import 'package:flutter/material.dart';
import '../../models/maths/adventure_node_model.dart';
import '../progress_service.dart';

/// Adapter service that reads existing ProgressService data and converts
/// user progress records into Adventure Map node states without mutating Firestore.
class MathsProgressAdapter {
  final ProgressService _progressService = ProgressService();

  /// Default list of Mathematics Adventure Map nodes for Grade 5
  /// Each node carries themed location metadata for the game-world map
  static final List<AdventureNodeModel> _defaultNodes = [
    const AdventureNodeModel(
      id: 'node_1',
      lessonId: 'math_grade5_01',
      lessonNumber: 1,
      title: 'Quest for the Golden Mango 🥭',
      subtitle: 'රන් අඹ ගෙඩිය සොයා ගමන',
      description: 'Interactive story with Leo, Ella & Felix',
      xpReward: 50,
      isPlaceholder: false,
      locationName: 'Golden Mango Jungle',
      locationEmoji: '🥭',
      themeColor: Color(0xFFFF6B35),
    ),
    const AdventureNodeModel(
      id: 'node_2',
      lessonId: 'math_grade5_02',
      lessonNumber: 2,
      title: 'සංඛ්‍යා - 2 🚂',
      subtitle: 'The Great Number Train',
      description: 'සංඛ්‍යා සසඳමු & පටිපාටිගත කරමු',
      xpReward: 100,
      isPlaceholder: false,
      locationName: 'මහා සංඛ්‍යා දුම්රිය',
      locationEmoji: '🚂',
      themeColor: Color(0xFF8E44AD),
    ),
    const AdventureNodeModel(
      id: 'node_3',
      lessonId: 'math_grade5_03_placeholder',
      lessonNumber: 3,
      title: 'එකතු කිරීම & අඩුකිරීම',
      subtitle: 'Addition & Subtraction',
      description: 'ස්ථානීය අගයන් අනුව එකතු කිරීම සහ අඩුකිරීම',
      xpReward: 60,
      isPlaceholder: true,
      locationName: 'ගණිත වනාන්තරය',
      locationEmoji: '🌳',
      themeColor: Color(0xFF27AE60),
    ),
    const AdventureNodeModel(
      id: 'node_4',
      lessonId: 'math_grade5_04_placeholder',
      lessonNumber: 4,
      title: 'ගුණකිරීම & බෙදීම',
      subtitle: 'Multiplication & Division',
      description: 'ගුණකිරීම සහ බෙදීමේ ගැටලු විසඳීම',
      xpReward: 75,
      isPlaceholder: true,
      locationName: 'සංඛ්‍යා පාලම',
      locationEmoji: '🌉',
      themeColor: Color(0xFF2980B9),
    ),
    const AdventureNodeModel(
      id: 'node_5',
      lessonId: 'math_grade5_05_placeholder',
      lessonNumber: 5,
      title: 'ගණිත අභියෝගය 🏰',
      subtitle: 'Grand Maths Challenge',
      description: 'ශිෂ්‍යත්ව ගණිත ප්‍රශ්න මාලාව',
      xpReward: 100,
      isPlaceholder: true,
      locationName: 'මහා ගණිත අභියෝග මාලිගාව',
      locationEmoji: '👑',
      themeColor: Color(0xFFF39C12),
    ),
  ];

  /// Get evaluated Adventure Map nodes with dynamic node states computed from ProgressService
  Future<List<AdventureNodeModel>> getEvaluatedNodes() async {
    try {
      final subjectProgress = await _progressService.getSubjectProgress('Mathematics');
      final completedList = subjectProgress.completedLessons;
      final quizScoresMap = subjectProgress.quizScores;

      List<AdventureNodeModel> evaluatedNodes = [];
      bool previousCompleted = true; // First node has no prerequisite

      for (int i = 0; i < _defaultNodes.length; i++) {
        final node = _defaultNodes[i];

        // Placeholder nodes beyond initial lessons remain locked for future expansion
        if (node.isPlaceholder && i > 1) {
          evaluatedNodes.add(node.copyWith(
            state: LessonNodeState.locked,
            stars: 0,
          ));
          continue;
        }

        final isExplicitlyCompleted = completedList.contains(node.lessonId);
        final quizScore = quizScoresMap[node.lessonId];
        final hasScore = quizScore != null;
        final percentage = hasScore ? quizScore.percentage : 0.0;

        LessonNodeState state;
        int stars = 0;

        if (isExplicitlyCompleted || (hasScore && percentage >= 0.8)) {
          state = LessonNodeState.completed;
          if (percentage >= 0.95) {
            stars = 3;
          } else if (percentage >= 0.8) {
            stars = 2;
          } else {
            stars = 1;
          }
        } else if (hasScore && percentage < 0.8) {
          state = LessonNodeState.inProgress;
          stars = 0;
        } else if (previousCompleted) {
          state = LessonNodeState.available;
          stars = 0;
        } else {
          state = LessonNodeState.locked;
          stars = 0;
        }

        evaluatedNodes.add(node.copyWith(
          state: state,
          stars: stars,
        ));

        // Track whether this node allows the next node to unlock
        previousCompleted = (state == LessonNodeState.completed);
      }

      return evaluatedNodes;
    } catch (e) {
      // Fallback: Return default node states if progress cannot be read
      return _defaultNodes.map((n) {
        if (n.lessonNumber == 1) {
          return n.copyWith(state: LessonNodeState.available);
        }
        return n.copyWith(state: LessonNodeState.locked);
      }).toList();
    }
  }

  /// Stream of evaluated nodes for real-time map updates
  Stream<List<AdventureNodeModel>> streamEvaluatedNodes() {
    return _progressService.streamProgress('Mathematics').map((subjectProgress) {
      final completedList = subjectProgress.completedLessons;
      final quizScoresMap = subjectProgress.quizScores;

      List<AdventureNodeModel> evaluatedNodes = [];
      bool previousCompleted = true;

      for (int i = 0; i < _defaultNodes.length; i++) {
        final node = _defaultNodes[i];

        if (node.isPlaceholder && i > 1) {
          evaluatedNodes.add(node.copyWith(
            state: LessonNodeState.locked,
            stars: 0,
          ));
          continue;
        }

        final isExplicitlyCompleted = completedList.contains(node.lessonId);
        final quizScore = quizScoresMap[node.lessonId];
        final hasScore = quizScore != null;
        final percentage = hasScore ? quizScore.percentage : 0.0;

        LessonNodeState state;
        int stars = 0;

        if (isExplicitlyCompleted || (hasScore && percentage >= 0.8)) {
          state = LessonNodeState.completed;
          if (percentage >= 0.95) {
            stars = 3;
          } else if (percentage >= 0.8) {
            stars = 2;
          } else {
            stars = 1;
          }
        } else if (hasScore && percentage < 0.8) {
          state = LessonNodeState.inProgress;
          stars = 0;
        } else if (previousCompleted) {
          state = LessonNodeState.available;
          stars = 0;
        } else {
          state = LessonNodeState.locked;
          stars = 0;
        }

        evaluatedNodes.add(node.copyWith(
          state: state,
          stars: stars,
        ));

        previousCompleted = (state == LessonNodeState.completed);
      }

      return evaluatedNodes;
    });
  }
}
