import 'package:flutter/material.dart';

/// Single skill analytics item (calculated from skillTag attempts)
class SkillMetric {
  final String skillTag;
  final String titleSinhala;
  final String titleEnglish;
  final double accuracyPercent;
  final int totalAttempts;
  final int correctAttempts;
  final int hintsUsedCount;
  final String suggestedPracticeConceptTitle;
  final String suggestedLessonId;
  final String suggestedConceptId;

  SkillMetric({
    required this.skillTag,
    required this.titleSinhala,
    required this.titleEnglish,
    required this.accuracyPercent,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.hintsUsedCount,
    required this.suggestedPracticeConceptTitle,
    required this.suggestedLessonId,
    required this.suggestedConceptId,
  });
}

/// Trend data point for accuracy progress timeline
class TrendPoint {
  final DateTime date;
  final double accuracyPercent;
  final int attemptCount;

  TrendPoint({
    required this.date,
    required this.accuracyPercent,
    required this.attemptCount,
  });
}

/// Concept progress item for expandable pathways in parent dashboard
class ConceptAnalyticsModel {
  final String conceptId;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;

  ConceptAnalyticsModel({
    required this.conceptId,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
  });
}

/// Lesson analytics summary for Parent Dashboard
class LessonAnalyticsModel {
  final String lessonId;
  final int lessonNumber;
  final String title;
  final String subtitle;
  final String icon;
  final Color themeColor;
  final double completionPercent;
  final int completedConceptsCount;
  final int totalConceptsCount;
  final bool isCompleted;
  final List<ConceptAnalyticsModel> concepts;

  LessonAnalyticsModel({
    required this.lessonId,
    required this.lessonNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    required this.completionPercent,
    required this.completedConceptsCount,
    required this.totalConceptsCount,
    required this.isCompleted,
    required this.concepts,
  });
}

/// Recommendation model for actionable parent guidance
class RecommendationModel {
  final String skillTag;
  final String skillTitle;
  final String lessonId;
  final String conceptId;
  final String conceptTitle;
  final double currentAccuracy;
  final String reason;

  RecommendationModel({
    required this.skillTag,
    required this.skillTitle,
    required this.lessonId,
    required this.conceptId,
    required this.conceptTitle,
    required this.currentAccuracy,
    required this.reason,
  });
}

/// Activity Feed item model
class ActivityFeedItem {
  final String title;
  final String lessonName;
  final DateTime timestamp;
  final int score;
  final int total;
  final double percentage;

  ActivityFeedItem({
    required this.title,
    required this.lessonName,
    required this.timestamp,
    required this.score,
    required this.total,
    required this.percentage,
  });
}

/// Comprehensive aggregated analytics model for Parent Dashboard 2.0
class ParentAnalyticsModel {
  final String studentUid;
  final String studentName;
  final int grade;
  final int xp;
  final int streak;
  final String levelTitle;
  final double overallProgressPercent;
  final double overallAccuracyPercent;
  final int totalBadgesCount;
  final int completedLessonsCount;
  final List<SkillMetric> strengths;
  final List<SkillMetric> focusAreas;
  final RecommendationModel? recommendedNextStep;
  final List<TrendPoint> trendData;
  final List<LessonAnalyticsModel> lessonProgressList;
  final List<ActivityFeedItem> recentActivities;
  final List<String> earnedBadgesList;
  final String weeklyInsight;

  ParentAnalyticsModel({
    required this.studentUid,
    required this.studentName,
    required this.grade,
    required this.xp,
    required this.streak,
    required this.levelTitle,
    required this.overallProgressPercent,
    required this.overallAccuracyPercent,
    required this.totalBadgesCount,
    required this.completedLessonsCount,
    required this.strengths,
    required this.focusAreas,
    this.recommendedNextStep,
    required this.trendData,
    required this.lessonProgressList,
    required this.recentActivities,
    required this.earnedBadgesList,
    required this.weeklyInsight,
  });
}
