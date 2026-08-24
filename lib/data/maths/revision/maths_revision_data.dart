import 'dart:math';
import '../../../models/maths/revision_models.dart';
import 'maths_official_revision_bank.dart';

class MathsRevisionData {
  static final Random _random = Random();

  /// Returns all 40 official Grade 5 revision questions
  static List<RevisionChallengeModel> getAllOfficialQuestions() {
    return MathsOfficialRevisionBank.allRevisionQuestions;
  }

  /// Returns questions for a specific Lesson (Lesson 1 has 20 questions, Lesson 2 has 20 questions)
  static List<RevisionChallengeModel> getQuestionsByLesson(String lessonId) {
    return MathsOfficialRevisionBank.allRevisionQuestions
        .where((q) => q.lessonId == lessonId)
        .toList();
  }

  /// Returns questions for a specific Concept
  static List<RevisionChallengeModel> getQuestionsByConcept(String conceptId) {
    return MathsOfficialRevisionBank.allRevisionQuestions
        .where((q) => q.conceptId == conceptId)
        .toList();
  }

  /// Generates a personalized 5-question revision session tailored to the requested skill
  static List<RevisionChallengeModel> generateRevisionSession({
    required String skillTag,
    required String lessonId,
    required String conceptId,
    int averageDifficulty = 2,
  }) {
    // 1. Find direct skill matches from the 40-question official bank
    List<RevisionChallengeModel> pool = MathsOfficialRevisionBank.allRevisionQuestions
        .where((q) => q.skillTag == skillTag || q.conceptId == conceptId)
        .toList();

    // 2. If pool is small, add other questions from the same lesson
    if (pool.length < 5) {
      final lessonPool = MathsOfficialRevisionBank.allRevisionQuestions
          .where((q) => q.lessonId == lessonId && !pool.contains(q))
          .toList()
        ..shuffle(_random);
      pool.addAll(lessonPool);
    }

    // 3. If still less than 5, add from entire bank
    if (pool.length < 5) {
      final fullPool = MathsOfficialRevisionBank.allRevisionQuestions
          .where((q) => !pool.contains(q))
          .toList()
        ..shuffle(_random);
      pool.addAll(fullPool);
    }

    // Return the first 5 questions sorted by progressive difficulty (Level 1 -> 2 -> 3)
    final selected = pool.take(5).toList();
    selected.sort((a, b) => a.difficultyLevel.compareTo(b.difficultyLevel));
    return selected;
  }
}
