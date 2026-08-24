/// Story speakers for Lesson 2: The Great Number Train
enum TrainStorySpeaker {
  leo,
  ella,
  felix,
}

/// Interaction types for the 6 Train Challenges
enum NumberTrainInteractionType {
  tapSelection,      // Challenge 1: Tap largest number card
  ticketDrag,        // Challenge 2: Drag train ticket onto station counter
  carriageOrdering,  // Challenge 3: Arrange 3 carriages from smallest -> largest
  guidedPlaceValue,  // Challenge 4: Interactive place-value digit comparison
  carriageSorting,   // Challenge 5: Drag and drop 3 numbers into correct track slots
  masteryOrdering,   // Challenge 6: 4-digit train carriage sorting with moving train animation
  digitBuilder,      // Digit Card Builder: Arrange digit cards 0-9 into slots
}

/// Model for a Story Dialogue Beat in Lesson 2
class NumberTrainStoryBeatModel {
  final TrainStorySpeaker speaker;
  final String speakerNameSi;
  final String dialogueSi;
  final bool isInteractiveChoice;
  final String? choicePromptSi;
  final String? wrongOptionText;
  final String? correctOptionText;
  final String? wrongFeedbackSi;

  const NumberTrainStoryBeatModel({
    required this.speaker,
    required this.speakerNameSi,
    required this.dialogueSi,
    this.isInteractiveChoice = false,
    this.choicePromptSi,
    this.wrongOptionText,
    this.correctOptionText,
    this.wrongFeedbackSi,
  });
}

/// Model for a Train Interactive Challenge (1 to 6)
class NumberTrainChallengeModel {
  final String id;
  final String conceptId;
  final int challengeNumber;
  final NumberTrainInteractionType interactionType;
  final String title;
  final String questionText;
  final List<String> numbers;
  final String correctAnswer;
  final String hintLevel1;
  final String hintLevel2;
  final String explanation;
  final String skillTag;
  final int difficulty;
  final Map<String, dynamic>? extraData;

  const NumberTrainChallengeModel({
    required this.id,
    required this.conceptId,
    required this.challengeNumber,
    required this.interactionType,
    required this.title,
    required this.questionText,
    required this.numbers,
    required this.correctAnswer,
    required this.hintLevel1,
    required this.hintLevel2,
    required this.explanation,
    required this.skillTag,
    this.difficulty = 1,
    this.extraData,
  });
}

/// Model for Lesson 2 Concept
class NumberTrainConceptModel {
  final String id;
  final String title;
  final String subtitle;
  final String learningObjective;
  final String stationBgAsset;
  final String interiorBgAsset;
  final List<NumberTrainStoryBeatModel> storyBeats;
  final List<NumberTrainChallengeModel> challenges;

  const NumberTrainConceptModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.learningObjective,
    required this.stationBgAsset,
    required this.interiorBgAsset,
    required this.storyBeats,
    required this.challenges,
  });
}
