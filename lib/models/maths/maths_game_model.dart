
/// Types of interactive games in Phase 5 Mathematics Kingdom
enum MathsGameType {
  abacusChallenge,
  lilyPadLeap,
  numberArchery,
  digitBuilder,
  placeValueExplorer,
  expandedFormBuilder,
  rapidNumberChallenge,
}

/// Result summary of a played mini-game session
class MathsGameResult {
  final MathsGameType gameType;
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final int starsEarned;
  final int hintsUsed;
  final Duration timeTaken;
  final bool isPerfect;

  const MathsGameResult({
    required this.gameType,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    required this.starsEarned,
    required this.hintsUsed,
    required this.timeTaken,
    required this.isPerfect,
  });
}

/// Model for Abacus Challenge rounds
class AbacusRoundModel {
  final String id;
  final int targetNumber;
  final List<String> placeValues; // e.g. ['දහස්', 'සිය', 'දහය', 'එකක'] or 5-digit
  final String parrotPrompt;
  final List<String> hints;

  const AbacusRoundModel({
    required this.id,
    required this.targetNumber,
    required this.placeValues,
    required this.parrotPrompt,
    required this.hints,
  });

  int get digitCount => targetNumber.toString().length;
}

/// Model for Digit Builder rounds
class DigitBuilderRoundModel {
  final String id;
  final List<int> digits; // e.g. [1, 3, 6, 4]
  final String instructionSi; // e.g. 'මෙම ඉලක්කම් භාවිතයෙන් විශාලතම සංඛ්‍යාව සාදන්න.'
  final String targetAnswer; // e.g. '6431'
  final List<String> hints;

  const DigitBuilderRoundModel({
    required this.id,
    required this.digits,
    required this.instructionSi,
    required this.targetAnswer,
    required this.hints,
  });
}

/// Model for Place Value Explorer rounds
class PlaceValueRoundModel {
  final String id;
  final String fullNumber; // e.g. '35421'
  final String targetDigit; // e.g. '4'
  final String questionText;
  final String correctPlaceValue; // e.g. 'සිය ස්ථානය'
  final String correctRepresentedValue; // e.g. '400'
  final List<String> options; // e.g. ['400', '40', '4000', '4'] (will be randomized)
  final String explanationSi;
  final List<String> hints;

  const PlaceValueRoundModel({
    required this.id,
    required this.fullNumber,
    required this.targetDigit,
    required this.questionText,
    required this.correctPlaceValue,
    required this.correctRepresentedValue,
    required this.options,
    required this.explanationSi,
    required this.hints,
  });
}

/// Model for Expanded Form Builder rounds
class ExpandedFormRoundModel {
  final String id;
  final String targetNumber; // e.g. '5421' or '68507'
  final List<String> correctComponents; // e.g. ['5000', '400', '20', '1'] or ['60000', '8000', '500', '0', '7']
  final List<String> availableCards; // Component cards (shuffled)
  final List<String> hints;

  const ExpandedFormRoundModel({
    required this.id,
    required this.targetNumber,
    required this.correctComponents,
    required this.availableCards,
    required this.hints,
  });
}

/// Model for Rapid Challenge rounds
class RapidChallengeRoundModel {
  final String id;
  final String questionText;
  final String parrotDialogue;
  final List<String> options; // Will be randomized
  final String correctAnswer;
  final String explanationSi;
  final int timeLimitSeconds;

  const RapidChallengeRoundModel({
    required this.id,
    required this.questionText,
    required this.parrotDialogue,
    required this.options,
    required this.correctAnswer,
    required this.explanationSi,
    this.timeLimitSeconds = 15,
  });
}
