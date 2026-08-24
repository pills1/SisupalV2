import 'dart:math';
import '../../models/maths/lily_pad_leap_model.dart';

class LilyPadLeapData {
  static final List<LilyPadLeapChallenge> challenges = [
    // Challenge 1: Simple addition pattern (+25)
    const LilyPadLeapChallenge(
      id: 'lily_01_plus25',
      title: '25 බැගින් වැඩිවන රටාව',
      sequence: [100, 125, null, 175, 200],
      missingIndex: 2,
      correctAnswer: 150,
      options: [150, 140, 160], // Shuffled dynamically at runtime
      patternRuleSinhala: 'සෑම පියවරකදීම 25ක් එකතු වේ (+25).',
      difficultyLevel: 1,
      hint1Sinhala: '💡 100 සිට 125 දක්වා වෙනස කීයද බලන්න (125 - 100 = 25).',
      hint2Sinhala: '💡 125 ට 25ක් එකතු කරන්න: 125 + 25 = ?',
      explanationSinhala: 'රටාව 25 බැගින් වැඩි වේ. එබැවින් 125 + 25 = 150 වේ.',
    ),

    // Challenge 2: Decreasing pattern (-50)
    const LilyPadLeapChallenge(
      id: 'lily_02_minus50',
      title: '50 බැගින් අඩුවන රටාව',
      sequence: [500, 450, 400, null, 300],
      missingIndex: 3,
      correctAnswer: 350,
      options: [320, 380, 350],
      patternRuleSinhala: 'සෑම පියවරකදීම 50ක් අඩු වේ (-50).',
      difficultyLevel: 2,
      hint1Sinhala: '💡 සංඛ්‍යා අඩුවෙමින් යයි. 500, 450, 400... වෙනස 50කි.',
      hint2Sinhala: '💡 400 න් 50ක් අඩු කරන්න: 400 - 50 = ?',
      explanationSinhala: 'රටාව 50 බැගින් අඩු වේ. එබැවින් 400 - 50 = 350 වේ.',
    ),

    // Challenge 3: Multiplication doubling pattern (x2)
    const LilyPadLeapChallenge(
      id: 'lily_03_double',
      title: 'ගුණනය වන රටාව (×2)',
      sequence: [15, 30, null, 120, 240],
      missingIndex: 2,
      correctAnswer: 60,
      options: [60, 45, 90],
      patternRuleSinhala: 'සෑම පියවරකදීම 2න් ගුණ වේ (×2).',
      difficultyLevel: 3,
      hint1Sinhala: '💡 15 දෙගුණ කළ විට 30යි. 30 දෙගුණ කළ විට කීයද?',
      hint2Sinhala: '💡 30 × 2 = ? සහ 60 × 2 = 120 නිවැරදිදැයි බලන්න.',
      explanationSinhala: 'සංඛ්‍යාව දෙගුණ වෙමින් යයි (×2). එබැවින් 30 × 2 = 60 වේ.',
    ),

    // Challenge 4: Large hundreds pattern (+125)
    const LilyPadLeapChallenge(
      id: 'lily_04_plus125',
      title: '125 බැගින් වැඩිවන රටාව',
      sequence: [1250, null, 1500, 1625, 1750],
      missingIndex: 1,
      correctAnswer: 1375,
      options: [1350, 1400, 1375],
      patternRuleSinhala: 'සෑම පියවරකදීම 125ක් එකතු වේ (+125).',
      difficultyLevel: 4,
      hint1Sinhala: '💡 1500 සහ 1625 අතර වෙනස බලන්න (1625 - 1500 = 125).',
      hint2Sinhala: '💡 1250 ට 125ක් එකතු කරන්න: 1250 + 125 = ?',
      explanationSinhala: 'රටාව 125 බැගින් වැඩි වේ. එබැවින් 1250 + 125 = 1375 වේ.',
    ),

    // Challenge 5: Thousands skip pattern (+2500)
    const LilyPadLeapChallenge(
      id: 'lily_05_thousands',
      title: 'දහස් සංඛ්‍යා රටාව (+2,500)',
      sequence: [10000, 12500, 15000, null, 20000],
      missingIndex: 3,
      correctAnswer: 17500,
      options: [17500, 16500, 18500],
      patternRuleSinhala: 'සෑම පියවරකදීම 2,500ක් එකතු වේ (+2,500).',
      difficultyLevel: 5,
      hint1Sinhala: '💡 10,000 සිට 12,500 දක්වා වෙනස 2,500කි.',
      hint2Sinhala: '💡 15,000 ට 2,500ක් එකතු කරන්න: 15,000 + 2,500 = ?',
      explanationSinhala: 'රටාව 2,500 බැගින් වැඩි වේ. එබැවින් 15,000 + 2,500 = 17,500 වේ.',
    ),

    // Challenge 6: Multi-step mastery pattern (+75)
    const LilyPadLeapChallenge(
      id: 'lily_06_mastery',
      title: 'ශිෂ්‍යත්ව විශේෂ රටාව (+75)',
      sequence: [225, 300, 375, 450, null],
      missingIndex: 4,
      correctAnswer: 525,
      options: [500, 525, 550],
      patternRuleSinhala: 'සෑම පියවරකදීම 75ක් එකතු වේ (+75).',
      difficultyLevel: 6,
      hint1Sinhala: '💡 225 + 75 = 300, 300 + 75 = 375. වෙනස 75කි.',
      hint2Sinhala: '💡 අවසන් අංකය සොයා ගැනීමට 450 ට 75ක් එකතු කරන්න.',
      explanationSinhala: 'රටාව 75 බැගින් වැඩි වේ. එබැවින් 450 + 75 = 525 වේ.',
    ),
  ];

  static List<LilyPadLeapChallenge> generateGameSession() {
    final rand = Random();
    return challenges.map((c) {
      final shuffledOpts = List<int>.from(c.options)..shuffle(rand);
      return LilyPadLeapChallenge(
        id: c.id,
        title: c.title,
        sequence: c.sequence,
        missingIndex: c.missingIndex,
        correctAnswer: c.correctAnswer,
        options: shuffledOpts,
        patternRuleSinhala: c.patternRuleSinhala,
        difficultyLevel: c.difficultyLevel,
        hint1Sinhala: c.hint1Sinhala,
        hint2Sinhala: c.hint2Sinhala,
        explanationSinhala: c.explanationSinhala,
      );
    }).toList();
  }
}
