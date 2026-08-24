/// Model for Number Archery (ඉලක්කයට විදින්න - Rounding Game)
class NumberArcheryChallenge {
  final String id;
  final int originalNumber;
  final String formattedOriginal; // e.g. "3,742"
  final String roundingInstruction; // e.g. "ළඟම 1,000 ට වැටයන්න"
  final int roundingBase; // 10, 100, 1000
  final int correctRoundedNumber;
  final List<int> targetOptions; // 3-4 target board values (shuffled)
  final int difficultyLevel; // 1 to 6
  final String hint1Sinhala;
  final String hint2Sinhala;
  final String explanationSinhala;

  const NumberArcheryChallenge({
    required this.id,
    required this.originalNumber,
    required this.formattedOriginal,
    required this.roundingInstruction,
    required this.roundingBase,
    required this.correctRoundedNumber,
    required this.targetOptions,
    required this.difficultyLevel,
    required this.hint1Sinhala,
    required this.hint2Sinhala,
    required this.explanationSinhala,
  });
}
