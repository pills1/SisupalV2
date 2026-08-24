/// Type of exercise question interface
enum GoldenMangoQuestionType {
  multipleChoice,
  numericInput,
  placeValuePicker,
  abacusInteractive,
  expandedFormBuilder,
  digitBuilder,
}

/// Question option for MCQs and pickers
class ExerciseOption {
  final String text;
  final bool isCorrect;
  final String? hint;

  const ExerciseOption({
    required this.text,
    this.isCorrect = false,
    this.hint,
  });
}

/// Model representing a single curriculum-aligned Golden Mango exercise question
class GoldenMangoQuestion {
  final String id;
  final String conceptId;
  final GoldenMangoQuestionType questionType;
  final String questionText;
  final List<ExerciseOption> options;
  final String? correctAnswer; // String representation of answer
  final String skillTag;
  final int difficulty; // 1 = Easy, 2 = Medium, 3 = Mastery
  final String hintLevel1; // Light conceptual hint
  final String hintLevel2; // Strong guided reasoning
  final String explanation; // Worked solution for 3rd attempt fallback
  final Map<String, dynamic>? extraData; // Extra metadata (e.g., place values, target numbers)

  const GoldenMangoQuestion({
    required this.id,
    required this.conceptId,
    required this.questionType,
    required this.questionText,
    this.options = const [],
    this.correctAnswer,
    required this.skillTag,
    this.difficulty = 1,
    required this.hintLevel1,
    required this.hintLevel2,
    required this.explanation,
    this.extraData,
  });

  /// Get shuffled options
  List<ExerciseOption> getShuffledOptions() {
    final list = List<ExerciseOption>.from(options);
    list.shuffle();
    return list;
  }
}

/// Data structure for recording question attempt telemetry
class QuestionAttemptLog {
  final String studentId;
  final String lessonId;
  final String conceptId;
  final String questionId;
  final int attemptNumber;
  final String answerGiven;
  final String correctAnswer;
  final bool isCorrect;
  final int timeTakenSeconds;
  final bool hintUsed;
  final int hintLevel; // 0 = none, 1 = light, 2 = guided
  final String skillTag;
  final int difficulty;
  final DateTime timestamp;

  QuestionAttemptLog({
    required this.studentId,
    required this.lessonId,
    required this.conceptId,
    required this.questionId,
    required this.attemptNumber,
    required this.answerGiven,
    required this.correctAnswer,
    required this.isCorrect,
    required this.timeTakenSeconds,
    required this.hintUsed,
    required this.hintLevel,
    required this.skillTag,
    required this.difficulty,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'lessonId': lessonId,
      'conceptId': conceptId,
      'questionId': questionId,
      'attemptNumber': attemptNumber,
      'answerGiven': answerGiven,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'timeTaken': timeTakenSeconds,
      'hintUsed': hintUsed,
      'hintLevel': hintLevel,
      'skillTag': skillTag,
      'difficulty': difficulty,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
