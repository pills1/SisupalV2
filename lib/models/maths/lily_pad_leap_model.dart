/// Model representing a challenge for Lily Pad Leap (දිය ගෙම්බාගේ පිම්ම)
class LilyPadLeapChallenge {
  final String id;
  final String title;
  final List<int?> sequence; // e.g. [125, 250, null, 500, 625]
  final int missingIndex; // 0-based index of the null/missing slot
  final int correctAnswer;
  final List<int> options; // Shuffled list including correct answer & distractors
  final String patternRuleSinhala; // e.g. "25 බැගින් වැඩි වේ (+25)"
  final int difficultyLevel; // 1 to 6
  final String hint1Sinhala;
  final String hint2Sinhala;
  final String explanationSinhala;

  const LilyPadLeapChallenge({
    required this.id,
    required this.title,
    required this.sequence,
    required this.missingIndex,
    required this.correctAnswer,
    required this.options,
    required this.patternRuleSinhala,
    required this.difficultyLevel,
    required this.hint1Sinhala,
    required this.hint2Sinhala,
    required this.explanationSinhala,
  });
}
