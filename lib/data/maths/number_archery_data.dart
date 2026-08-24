import '../../models/maths/number_archery_model.dart';

class NumberArcheryData {
  static final List<NumberArcheryChallenge> challenges = [
    // Challenge 1: Rounding to nearest 10
    const NumberArcheryChallenge(
      id: 'archery_01_tens',
      originalNumber: 47,
      formattedOriginal: '47',
      roundingInstruction: 'ළඟම 10 ට වැටයන්න',
      roundingBase: 10,
      correctRoundedNumber: 50,
      targetOptions: [40, 50, 60],
      difficultyLevel: 1,
      hint1Sinhala: '💡 ඒකස්ථානයේ අංකය 7 වේ. එය 5ට වඩා විශාලදැයි බලන්න.',
      hint2Sinhala: '💡 ඒකස්ථානය 5 හෝ ඊට වැඩි නම් ඉහළ දහයට (50ට) වැටයේ.',
      explanationSinhala: '47 හි ඒකස්ථානය 7 වේ (5ට වැඩියි). එබැවින් ළඟම 10 වන්නේ 50 යි.',
    ),

    // Challenge 2: Rounding to nearest 10 (rounding down)
    const NumberArcheryChallenge(
      id: 'archery_02_tens_down',
      originalNumber: 82,
      formattedOriginal: '82',
      roundingInstruction: 'ළඟම 10 ට වැටයන්න',
      roundingBase: 10,
      correctRoundedNumber: 80,
      targetOptions: [70, 80, 90],
      difficultyLevel: 2,
      hint1Sinhala: '💡 ඒකස්ථානයේ අංකය 2 වේ. එය 5ට වඩා අඩුය.',
      hint2Sinhala: '💡 ඒකස්ථානය 5ට අඩු නම් පහළ දහයට (80ට) වැටයේ.',
      explanationSinhala: '82 හි ඒකස්ථානය 2 වේ (5ට අඩුයි). එබැවින් ළඟම 10 වන්නේ 80 යි.',
    ),

    // Challenge 3: Rounding to nearest 100
    const NumberArcheryChallenge(
      id: 'archery_03_hundreds',
      originalNumber: 364,
      formattedOriginal: '364',
      roundingInstruction: 'ළඟම 100 ට වැටයන්න',
      roundingBase: 100,
      correctRoundedNumber: 400,
      targetOptions: [300, 350, 400],
      difficultyLevel: 3,
      hint1Sinhala: '💡 ළඟම 100ට වැටයීමේදී දසස්ථානයේ අගය (6) බලන්න.',
      hint2Sinhala: '💡 දසස්ථානය 6 (5ට වැඩි) නිසා ඉහළ සියයට (400ට) වැටයේ.',
      explanationSinhala: '364 හි දසස්ථානය 6 වේ (5ට වැඩියි). එබැවින් ළඟම 100 වන්නේ 400 යි.',
    ),

    // Challenge 4: Rounding to nearest 100 (boundary case)
    const NumberArcheryChallenge(
      id: 'archery_04_hundreds_down',
      originalNumber: 748,
      formattedOriginal: '748',
      roundingInstruction: 'ළඟම 100 ට වැටයන්න',
      roundingBase: 100,
      correctRoundedNumber: 700,
      targetOptions: [700, 750, 800],
      difficultyLevel: 4,
      hint1Sinhala: '💡 748 හි දසස්ථානය 4 වේ. එය 5ට වඩා කුඩාය.',
      hint2Sinhala: '💡 දසස්ථානය 4 නිසා පහළ සියයට (700ට) වැටයේ.',
      explanationSinhala: '748 හි දසස්ථානය 4 වේ (5ට අඩුයි). එබැවින් ළඟම 100 වන්නේ 700 යි.',
    ),

    // Challenge 5: Rounding to nearest 1000
    const NumberArcheryChallenge(
      id: 'archery_05_thousands',
      originalNumber: 3745,
      formattedOriginal: '3,745',
      roundingInstruction: 'ළඟම 1,000 ට වැටයන්න',
      roundingBase: 1000,
      correctRoundedNumber: 4000,
      targetOptions: [3000, 3500, 4000],
      difficultyLevel: 5,
      hint1Sinhala: '💡 ළඟම 1000ට වැටයීමේදී සියස්ථානයේ අගය (7) බලන්න.',
      hint2Sinhala: '💡 සියස්ථානය 7 (5ට වැඩි) නිසා ඉහළ දහසට (4,000ට) වැටයේ.',
      explanationSinhala: '3,745 හි සියස්ථානය 7 වේ (5ට වැඩියි). එබැවින් ළඟම 1,000 වන්නේ 4,000 යි.',
    ),

    // Challenge 6: Rounding 5-digit number to nearest 1000
    const NumberArcheryChallenge(
      id: 'archery_06_thousands_5digit',
      originalNumber: 24280,
      formattedOriginal: '24,280',
      roundingInstruction: 'ළඟම 1,000 ට වැටයන්න',
      roundingBase: 1000,
      correctRoundedNumber: 24000,
      targetOptions: [23000, 24000, 25000],
      difficultyLevel: 6,
      hint1Sinhala: '💡 24,280 හි සියස්ථානයේ අගය 2 වේ (5ට අඩුයි).',
      hint2Sinhala: '💡 සියස්ථානය 2 නිසා 24,000 ට වැටයේ.',
      explanationSinhala: '24,280 හි සියස්ථානය 2 වේ (5ට අඩුයි). එබැවින් ළඟම 1,000 වන්නේ 24,000 යි.',
    ),
  ];

  static List<NumberArcheryChallenge> generateGameSession() {
    return List<NumberArcheryChallenge>.from(challenges);
  }
}
