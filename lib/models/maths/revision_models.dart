import 'package:flutter/material.dart';

/// Revision priority level for personalized skill recommendations
enum RevisionPriority {
  high,     // 🔴 High priority (Accuracy < 60% or repeated failures)
  medium,   // 🟠 Medium priority (Accuracy 60-79%)
  mastered, // 🟢 Mastered (Accuracy >= 80%)
}

/// Question type for interactive revision challenges
enum RevisionQuestionType {
  numberOrdering,      // Drag and drop carriage ordering
  largestSmallest,     // Finding largest or smallest number
  placeValueAbacus,    // Interactive abacus / place value blocks
  digitCardConstruction,// Building numbers using digit cards
  expandedForm,        // Expanded form decomposition / construction
  compareNumbers,      // Comparing two numbers (<, >, =)
}

/// Model encapsulating skill analytics and revision recommendations
class RevisionSkillModel {
  final String skillTag;
  final String titleSinhala;
  final String titleEnglish;
  final String lessonId;
  final String conceptId;
  final String conceptTitle;
  final double accuracyPercent;
  final int totalAttempts;
  final int correctAttempts;
  final int hintsUsed;
  final RevisionPriority priority;
  final String encouragementMsg;

  RevisionSkillModel({
    required this.skillTag,
    required this.titleSinhala,
    required this.titleEnglish,
    required this.lessonId,
    required this.conceptId,
    required this.conceptTitle,
    required this.accuracyPercent,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.hintsUsed,
    required this.priority,
    required this.encouragementMsg,
  });
}

/// Model for a single dynamic interactive revision challenge
class RevisionChallengeModel {
  final String id;
  final String skillTag;
  final String lessonId;
  final String conceptId;
  final int difficultyLevel; // 1 = Easy, 2 = Medium, 3 = Challenge
  final RevisionQuestionType questionType;
  final String promptSinhala;
  final List<dynamic> optionsOrCards;
  final dynamic correctAnswer;
  final String hint1Sinhala;
  final String hint2Sinhala;
  final String explanationSinhala;

  RevisionChallengeModel({
    required this.id,
    required this.skillTag,
    required this.lessonId,
    required this.conceptId,
    required this.difficultyLevel,
    required this.questionType,
    required this.promptSinhala,
    required this.optionsOrCards,
    required this.correctAnswer,
    required this.hint1Sinhala,
    required this.hint2Sinhala,
    required this.explanationSinhala,
  });
}

/// Result model for a completed 5-challenge Revision Session
class RevisionSessionResultModel {
  final int totalQuestions;
  final int correctFirstAttempt;
  final int correctWithHints;
  final int xpEarned;
  final double accuracyPercent;
  final String skillTitle;

  RevisionSessionResultModel({
    required this.totalQuestions,
    required this.correctFirstAttempt,
    required this.correctWithHints,
    required this.xpEarned,
    required this.accuracyPercent,
    required this.skillTitle,
  });
}
