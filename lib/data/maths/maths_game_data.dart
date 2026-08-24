import '../../models/maths/maths_game_model.dart';

/// Dataset containing multi-round levels for Phase 5 Mathematics Interactive Games
class MathsGameData {
  // ─── GAME 1: ABACUS CHALLENGE ROUNDS ───
  static final List<AbacusRoundModel> abacusRounds = [
    const AbacusRoundModel(
      id: 'abacus_r1',
      targetNumber: 3421,
      placeValues: ['දහස්', 'සිය', 'දහය', 'එකක'],
      parrotPrompt: '🦜 "අබකසයේ 3421 සාදමු! පබළු එකතු කරන්න."',
      hints: [
        '3421 හි දහස් ස්ථානයේ ඉලක්කම බලන්න.',
        'දහස් ස්ථානයට පබළු 3ක් එකතු කරන්න.',
        'සිය ස්ථානයට 4ක්, දහය ස්ථානයට 2ක්, එකක ස්ථානයට 1ක් යොදන්න.',
      ],
    ),
    const AbacusRoundModel(
      id: 'abacus_r2',
      targetNumber: 5421,
      placeValues: ['දහස්', 'සිය', 'දහය', 'එකක'],
      parrotPrompt: '🦜 "5421 අංකය අබකසයේ නිරූපණය කරමු!"',
      hints: [
        '5421 හි දහස් ස්ථානයට පබළු 5ක් අවශ්‍යයි.',
        'සිය ස්ථානයට පබළු 4ක් එකතු කරන්න.',
        '5 | 4 | 2 | 1 පිළිවෙලට පබළු සකසන්න.',
      ],
    ),
    const AbacusRoundModel(
      id: 'abacus_r3',
      targetNumber: 6831,
      placeValues: ['දහස්', 'සිය', 'දහය', 'එකක'],
      parrotPrompt: '🦜 "6831 සාදන්න! දහස් ස්ථානයේ පබළු 6ක් ඇත."',
      hints: [
        'දහස් ස්ථානයට පබළු 6ක් දමන්න.',
        'සිය ස්ථානයට පබළු 8ක් එකතු කරන්න.',
        'දහය ස්ථානයට 3ක් සහ එකක ස්ථානයට 1ක් දමන්න.',
      ],
    ),
    const AbacusRoundModel(
      id: 'abacus_r4',
      targetNumber: 26147,
      placeValues: ['දස දහස්', 'දහස්', 'සිය', 'දහය', 'එකක'],
      parrotPrompt: '🦜 "දැන් ඉලක්කම් 5ක සංඛ්‍යාවක්! 26 147 සාදන්න!"',
      hints: [
        'දස දහස් ස්ථානයට පබළු 2ක් යොදන්න.',
        'දහස් ස්ථානයට 6ක් සහ සිය ස්ථානයට 1ක් යොදන්න.',
        '2 | 6 | 1 | 4 | 7 ලෙස සාදන්න.',
      ],
    ),
    const AbacusRoundModel(
      id: 'abacus_r5',
      targetNumber: 68507,
      placeValues: ['දස දහස්', 'දහස්', 'සිය', 'දහය', 'එකක'],
      parrotPrompt: '🦜 "අවසාන අභියෝගය! 68 507 සාදන්න. දහය ස්ථානයේ 0යි!"',
      hints: [
        'දස දහස් ස්ථානයට 6ක්, දහස් ස්ථානයට 8ක් දමන්න.',
        'සිය ස්ථානයට 5ක් යොදන්න.',
        'දහය ස්ථානයේ පබළු 0ක් (හිස්ව) තබන්න! එකක ස්ථානයට 7ක් දමන්න.',
      ],
    ),
  ];

  // ─── GAME 2: DIGIT BUILDER ROUNDS ───
  static final List<DigitBuilderRoundModel> digitBuilderRounds = [
    const DigitBuilderRoundModel(
      id: 'db_r1',
      digits: [1, 3, 6, 4],
      instructionSi: 'මෙම ඉලක්කම් භාවිතයෙන් විශාලතම සංඛ්‍යාව සාදන්න.',
      targetAnswer: '6431',
      hints: [
        'විශාලතම සංඛ්‍යාව සෑදීමට විශාලතම ඉලක්කම (6) මුලට ගන්න.',
        'ඉලක්කම් විශාල අගයේ සිට කුඩා අගයට සකසන්න.',
        '6 → 4 → 3 → 1 ලෙස සකසන්න.',
      ],
    ),
    const DigitBuilderRoundModel(
      id: 'db_r2',
      digits: [5, 2, 8, 1],
      instructionSi: 'මෙම ඉලක්කම් භාවිතයෙන් කුඩාම සංඛ්‍යාව සාදන්න.',
      targetAnswer: '1258',
      hints: [
        'කුඩාම සංඛ්‍යාව සෑදීමට කුඩාම ඉලක්කම (1) මුලට ගන්න.',
        'ඉලක්කම් කුඩා අගයේ සිට විශාල අගයට සකසන්න.',
        '1 → 2 → 5 → 8 ලෙස සකසන්න.',
      ],
    ),
    const DigitBuilderRoundModel(
      id: 'db_r3',
      digits: [7, 4, 1, 6, 2],
      instructionSi: 'මෙම ඉලක්කම් භාවිතයෙන් විශාලතම සංඛ්‍යාව සාදන්න.',
      targetAnswer: '76421',
      hints: [
        'විශාලතම ඉලක්කම 7යි. එය දස දහස් ස්ථානයට දමන්න.',
        'ඊළඟට 6, 4, 2, 1 සකසන්න.',
        '76 421 ලෙස සාදන්න.',
      ],
    ),
    const DigitBuilderRoundModel(
      id: 'db_r4',
      digits: [6, 8, 5, 0, 7],
      instructionSi: '68 507 සංඛ්‍යාව සාදන්න.',
      targetAnswer: '68507',
      hints: [
        'දස දහස් ස්ථානයට 6 සහ දහස් ස්ථානයට 8 යොදන්න.',
        'සිය ස්ථානයට 5 යොදන්න.',
        '6 → 8 → 5 → 0 → 7 පිළිවෙලට සකසන්න.',
      ],
    ),
  ];

  // ─── GAME 3: PLACE VALUE EXPLORER ROUNDS ───
  static final List<PlaceValueRoundModel> placeValueRounds = [
    const PlaceValueRoundModel(
      id: 'pv_r1',
      fullNumber: '35421',
      targetDigit: '4',
      questionText: '35 421 හි \'4\' හි නිරූපිත අගය කුමක්ද?',
      correctPlaceValue: 'සිය ස්ථානය',
      correctRepresentedValue: '400',
      options: ['400', '40', '4000', '4'],
      explanationSi: '4 පිහිටා ඇත්තේ සිය ස්ථානයේය. එමනිසා නිරූපිත අගය 4 × 100 = 400 වේ.',
      hints: [
        '4 පිහිටා ඇති ස්ථානය හඳුනාගන්න (එකක, දහය, සිය...).',
        '4 තියෙන්නේ සිය ස්ථානයේ.',
        '4 × 100 = 400.',
      ],
    ),
    const PlaceValueRoundModel(
      id: 'pv_r2',
      fullNumber: '68507',
      targetDigit: '6',
      questionText: '68 507 හි \'6\' පිහිටා ඇති ස්ථානය කුමක්ද?',
      correctPlaceValue: 'දස දහස් ස්ථානය',
      correctRepresentedValue: '60000',
      options: ['දස දහස් ස්ථානය', 'දහස් ස්ථානය', 'සිය ස්ථානය', 'දහය ස්ථානය'],
      explanationSi: '6 පිහිටා ඇත්තේ දස දහස් ස්ථානයේය. නිරූපිත අගය 60 000 වේ.',
      hints: [
        'වම්පසම ඇති ඉලක්කම (6) පරීක්ෂා කරන්න.',
        'ස්ථානීය අගයන්: එකක, දහය, සිය, දහස්, දස දහස්.',
        '6 තියෙන්නේ දස දහස් ස්ථානයේ.',
      ],
    ),
    const PlaceValueRoundModel(
      id: 'pv_r3',
      fullNumber: '26147',
      targetDigit: '6',
      questionText: '26 147 හි \'6\' හි නිරූපිත අගය කොපමණද?',
      correctPlaceValue: 'දහස් ස්ථානය',
      correctRepresentedValue: '6000',
      options: ['6000', '600', '60000', '60'],
      explanationSi: '6 පිහිටා ඇත්තේ දහස් ස්ථානයේය. එමනිසා නිරූපිත අගය 6 × 1000 = 6000 වේ.',
      hints: [
        '6 පිහිටා ඇත්තේ වම්පස සිට දෙවන ස්ථානයේය.',
        'එය දහස් ස්ථානයයි.',
        '6 × 1000 = 6000.',
      ],
    ),
  ];

  // ─── GAME 4: EXPANDED FORM BUILDER ROUNDS ───
  static final List<ExpandedFormRoundModel> expandedFormRounds = [
    const ExpandedFormRoundModel(
      id: 'ef_r1',
      targetNumber: '5421',
      correctComponents: ['5000', '400', '20', '1'],
      availableCards: ['5000', '400', '20', '1'],
      hints: [
        '5421 හි 5 හි අගය 5000 වේ.',
        '4 හි අගය 400 වේ.',
        '5000 + 400 + 20 + 1 පිළිවෙලට යොදන්න.',
      ],
    ),
    const ExpandedFormRoundModel(
      id: 'ef_r2',
      targetNumber: '6831',
      correctComponents: ['6000', '800', '30', '1'],
      availableCards: ['6000', '800', '30', '1'],
      hints: [
        '6 හි අගය 6000 වේ.',
        '8 හි අගය 800 වේ.',
        '6000 + 800 + 30 + 1 පිළිවෙලට යොදන්න.',
      ],
    ),
    const ExpandedFormRoundModel(
      id: 'ef_r3',
      targetNumber: '26147',
      correctComponents: ['20000', '6000', '100', '40', '7'],
      availableCards: ['20000', '6000', '100', '40', '7'],
      hints: [
        '2 හි අගය 20 000 වේ.',
        '6 හි අගය 6000 වේ.',
        '20000 + 6000 + 100 + 40 + 7 ලෙස සකසන්න.',
      ],
    ),
    const ExpandedFormRoundModel(
      id: 'ef_r4',
      targetNumber: '68507',
      correctComponents: ['60000', '8000', '500', '0', '7'],
      availableCards: ['60000', '8000', '500', '0', '7'],
      hints: [
        '68 507 හි දහය ස්ථානයේ 0 ඇත.',
        '60000 + 8000 + 500 + 0 + 7 පිළිවෙල පරීක්ෂා කරන්න.',
        '0 ස්ථානය අමතක නොකරන්න!',
      ],
    ),
  ];

  // ─── GAME 5: RAPID NUMBER CHALLENGE ROUNDS ───
  static final List<RapidChallengeRoundModel> rapidRounds = [
    const RapidChallengeRoundModel(
      id: 'rf_r1',
      questionText: '7304 හි \'7\' හි නිරූපිත අගය කුමක්ද?',
      parrotDialogue: '🦜 "ඉක්මන් කරන්න! 7304 හි 7 හි නිරූපිත අගය සොයන්න!"',
      options: ['7000', '700', '70', '7'],
      correctAnswer: '7000',
      explanationSi: '7 පිහිටා ඇත්තේ දහස් ස්ථානයේ නිසා නිරූපිත අගය 7000 වේ.',
      timeLimitSeconds: 15,
    ),
    const RapidChallengeRoundModel(
      id: 'rf_r2',
      questionText: '45 600 විහිදුවා ලිවීමේදී සිය ස්ථානයේ අගය කුමක්ද?',
      parrotDialogue: '🦜 "45 600 හි සිය ස්ථානයේ අගය කුමක්ද?"',
      options: ['600', '6000', '60', '6'],
      correctAnswer: '600',
      explanationSi: '6 පිහිටා ඇත්තේ සිය ස්ථානයේය. 6 × 100 = 600 වේ.',
      timeLimitSeconds: 15,
    ),
    const RapidChallengeRoundModel(
      id: 'rf_r3',
      questionText: '2, 3, 1, 4, 2 ඉලක්කම් භාවිතයෙන් 23 142 සාදන්න.',
      parrotDialogue: '🦜 "විසිතුන් දහස් සිය හතළිස් දෙකක් = ?"',
      options: ['23142', '23412', '32142', '21342'],
      correctAnswer: '23142',
      explanationSi: '23 142 = 20000 + 3000 + 100 + 40 + 2.',
      timeLimitSeconds: 15,
    ),
    const RapidChallengeRoundModel(
      id: 'rf_r4',
      questionText: '68 507 හි දහය ස්ථානයේ ඇති ඉලක්කම කුමක්ද?',
      parrotDialogue: '🦜 "68 507 හි දහය ස්ථානයේ ඉලක්කම?"',
      options: ['0', '5', '7', '8'],
      correctAnswer: '0',
      explanationSi: '68 507 හි දහය ස්ථානයේ ඉලක්කම 0 වේ.',
      timeLimitSeconds: 15,
    ),
    const RapidChallengeRoundModel(
      id: 'rf_r5',
      questionText: '99 999 ඊළඟට එන සංඛ්‍යාව කුමක්ද?',
      parrotDialogue: '🦜 "99 999 ට පසු ලැබෙන සංඛ්‍යාව කුමක්ද?"',
      options: ['100 000', '10 000', '99 990', '999 999'],
      correctAnswer: '100 000',
      explanationSi: '99 999 + 1 = 100 000 (ලක්ෂය) වේ!',
      timeLimitSeconds: 15,
    ),
  ];
}
