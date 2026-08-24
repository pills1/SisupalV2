import 'package:flutter/material.dart';

/// Type of step in the Akurata Mathematics Lesson player
enum StepStage {
  intro,
  learnChapter,
  guidedPractice,
  assessment,
  adaptivePath,
  rapidFire,
  abacusRevision,
  completion,
}

/// Type of interactive UI component to render
enum QuestionInteractionType {
  multipleChoice,
  numericInput,
  digitPlacement,
  matchingTable,
  expandedFormBuilder,
  wordArrangement,
  placeValuePicker,
  abacusInteractive,
}

/// Model representing a single option item in MCQs or matching pairs
class QuestionOption {
  final String text;
  final bool isCorrect;
  final String? hint;

  const QuestionOption({
    required this.text,
    this.isCorrect = false,
    this.hint,
  });
}

/// Model representing a matching pair (e.g. 2 -> දස දහස්)
class MatchingPair {
  final String digit;
  final String placeValue;

  const MatchingPair({
    required this.digit,
    required this.placeValue,
  });
}

/// Model representing a step or activity inside Lesson 1
class LessonStepModel {
  final String id;
  final StepStage stage;
  final String title;
  final String? subtitle;
  final String? description;
  final String? parrotDialogue;
  final QuestionInteractionType interactionType;
  final String questionText;
  final List<QuestionOption> options; // Raw options list (will be shuffled)
  final String? correctAnswer; // String representation of correct answer for input/builders
  final List<MatchingPair>? matchingPairs;
  final Map<String, dynamic>? extraData;

  const LessonStepModel({
    required this.id,
    required this.stage,
    required this.title,
    this.subtitle,
    this.description,
    this.parrotDialogue,
    this.interactionType = QuestionInteractionType.multipleChoice,
    required this.questionText,
    this.options = const [],
    this.correctAnswer,
    this.matchingPairs,
    this.extraData,
  });

  /// Shuffles options while keeping track of correct item
  List<QuestionOption> getShuffledOptions() {
    final list = List<QuestionOption>.from(options);
    list.shuffle();
    return list;
  }
}
