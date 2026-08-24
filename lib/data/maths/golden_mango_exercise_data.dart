import '../../models/maths/golden_mango_exercise_models.dart';

/// ============================================
/// GOLDEN MANGO INTERACTIVE EXERCISE DATA
/// 30 NIE Grade 5 Curriculum-aligned questions (6 per concept)
/// Diverse mixture of Abacus, Digit Builder, Expanded Form,
/// Place Value Picker, Numeric Input, and MCQ.
/// ============================================
class GoldenMangoExerciseData {
  /// Question data mapped by conceptId
  static final Map<String, List<GoldenMangoQuestion>> conceptQuestions = {
    // ─── CONCEPT 1: JUNGLE MAP (c1_jungle_map) — Numbers up to 9,999 ───
    'c1_jungle_map': [
      const GoldenMangoQuestion(
        id: 'c1_q1',
        conceptId: 'c1_jungle_map',
        questionType: GoldenMangoQuestionType.multipleChoice,
        questionText: '84 කියවන ආකාරය තෝරන්න.',
        options: [
          ExerciseOption(text: 'අටසිය හතර', isCorrect: false),
          ExerciseOption(text: 'අසූ හතර', isCorrect: true), // Option B
          ExerciseOption(text: 'අසූ හත', isCorrect: false),
          ExerciseOption(text: 'අටසිය හතළිහ', isCorrect: false),
        ],
        skillTag: 'number_reading',
        difficulty: 1,
        hintLevel1: '84 සංඛ්‍යාවේ දහයස්ථානයේ 8 ද (අසූ), ඒකස්ථානයේ 4 ද (හතර) ඇත.',
        hintLevel2: '80 (අසූ) + 4 (හතර) = 84 (අසූ හතර).',
        explanation: '84 හි 80 = අසූ, 4 = හතර. එම නිසා 84 කියවන්නේ "අසූ හතර" ලෙසයි.',
      ),
      const GoldenMangoQuestion(
        id: 'c1_q2',
        conceptId: 'c1_jungle_map',
        questionType: GoldenMangoQuestionType.numericInput,
        questionText: '"තුන් දහස් හාරසිය විසි එක" ඉලක්කම් වලින් ලියන්න.',
        correctAnswer: '3421',
        options: [
          ExerciseOption(text: '3241', isCorrect: false),
          ExerciseOption(text: '3421', isCorrect: true), // Option B
          ExerciseOption(text: '3412', isCorrect: false),
          ExerciseOption(text: '30421', isCorrect: false),
        ],
        skillTag: 'number_writing',
        difficulty: 1,
        hintLevel1: 'තුන් දහස් = 3000, හාරසිය = 400, විසි එක = 21.',
        hintLevel2: '3000 + 400 + 20 + 1 = 3421.',
        explanation: 'තුන් දහස් (3000) + හාරසිය (400) + විසි එක (21) = 3421.',
      ),
      const GoldenMangoQuestion(
        id: 'c1_q3',
        conceptId: 'c1_jungle_map',
        questionType: GoldenMangoQuestionType.digitBuilder,
        questionText: '1, 3, 6, 4 ඉලක්කම් 4 භාවිතයෙන් සාදාගත හැකි විශාලතම සංඛ්‍යාව සාදන්න.',
        correctAnswer: '6431',
        skillTag: 'four_digit_number',
        difficulty: 2,
        hintLevel1: 'විශාලතම සංඛ්‍යාව සෑදීමට විශාලතම ඉලක්කම (6) දහස්ස්ථානයට තබන්න.',
        hintLevel2: 'ඉලක්කම් විශාලත්වයේ සිට කුඩාත්වයට අනුපිළිවෙලින් තබන්න: 6, 4, 3, 1.',
        explanation: '6 > 4 > 3 > 1 අනුපිළිවෙලින් තැබූ විට විශාලතම සංඛ්‍යාව 6431 වේ.',
        extraData: {
          'digits': [3, 1, 6, 4], // Scrambled order
          'targetAnswer': '6431',
          'instructionSi': 'ඉලක්කම් කාඩ්පත් තට්ටුවෙන් 6431 සංඛ්‍යාව සාදන්න.',
        },
      ),
      const GoldenMangoQuestion(
        id: 'c1_q4',
        conceptId: 'c1_jungle_map',
        questionType: GoldenMangoQuestionType.multipleChoice,
        questionText: '997 නිවැරදිව කියවන ආකාරය කුමක්ද?',
        options: [
          ExerciseOption(text: 'නවසිය හතළිස් හත', isCorrect: false),
          ExerciseOption(text: 'නවදහස් හත', isCorrect: false),
          ExerciseOption(text: 'නවසිය අනූ හත', isCorrect: true), // Option C
          ExerciseOption(text: 'අනූ නවසිය හත', isCorrect: false),
        ],
        skillTag: 'number_name',
        difficulty: 2,
        hintLevel1: '900 = නවසිය, 90 = අනූ, 7 = හත.',
        hintLevel2: '900 + 90 + 7 = 997.',
        explanation: '900 (නවසිය) + 90 (අනූ) + 7 (හත) = නවසිය අනූ හත.',
      ),
      const GoldenMangoQuestion(
        id: 'c1_q5',
        conceptId: 'c1_jungle_map',
        questionType: GoldenMangoQuestionType.digitBuilder,
        questionText: '4, 9, 0, 5 ඉලක්කම් භාවිතයෙන් 4905 සංඛ්‍යාව සාදන්න.',
        correctAnswer: '4905',
        skillTag: 'four_digit_number',
        difficulty: 2,
        hintLevel1: 'දහස්ස්ථානයට 4, සියයස්ථානයට 9, දහයස්ථානයට 0, ඒකස්ථානයට 5 තබන්න.',
        hintLevel2: '4 -> 9 -> 0 -> 5 අනුපිළිවෙලින් ඉලක්කම් අදින්න.',
        explanation: '4 (දහස්) + 9 (සිය) + 0 (දහය) + 5 (ඒක) = 4905.',
        extraData: {
          'digits': [4, 9, 5, 0],
          'targetAnswer': '4905',
          'instructionSi': 'ඉලක්කම් තට්ටුවෙන් 4905 සංඛ්‍යාව සාදන්න.',
        },
      ),
      const GoldenMangoQuestion(
        id: 'c1_q6',
        conceptId: 'c1_jungle_map',
        questionType: GoldenMangoQuestionType.numericInput,
        questionText: '"හත්දහස් හාරසිය තිස් එක" ඉලක්කම් වලින් ලියන්න.',
        correctAnswer: '7431',
        options: [
          ExerciseOption(text: '7341', isCorrect: false),
          ExerciseOption(text: '7413', isCorrect: false),
          ExerciseOption(text: '7431', isCorrect: true), // Option C
        ],
        skillTag: 'four_digit_number',
        difficulty: 3,
        hintLevel1: 'හත්දහස් = 7000, හාරසිය = 400, තිස් එක = 31.',
        hintLevel2: '7000 + 400 + 30 + 1 = 7431.',
        explanation: '7000 (හත්දහස්) + 400 (හාරසිය) + 31 (තිස් එක) = 7431.',
      ),
    ],

    // ─── CONCEPT 2: RIVER OF BEADS (c2_river_of_beads) — 4-digit Place Value ───
    'c2_river_of_beads': [
      const GoldenMangoQuestion(
        id: 'c2_q1',
        conceptId: 'c2_river_of_beads',
        questionType: GoldenMangoQuestionType.placeValuePicker,
        questionText: '5,421 සංඛ්‍යාවේ \'1\' ඉලක්කම පිහිටා ඇති ස්ථානීය අගය තෝරන්න.',
        correctAnswer: 'ඒකස්ථානය',
        options: [
          ExerciseOption(text: 'දහයස්ථානය', isCorrect: false),
          ExerciseOption(text: 'සියයස්ථානය', isCorrect: false),
          ExerciseOption(text: 'ඒකස්ථානය', isCorrect: true), // Option C
          ExerciseOption(text: 'දහසස්ථානය', isCorrect: false),
        ],
        skillTag: 'place_value_units',
        difficulty: 1,
        hintLevel1: 'දකුණුපසම ඇති පළමු ඉලක්කම නිරූපණය කරන්නේ ඒකස්ථානයයි.',
        hintLevel2: '5,421 හි දකුණුපසම 1 ඇත. එම නිසා එය ඒකස්ථානය වේ.',
        explanation: 'සංඛ්‍යාවක දකුණුපසම ඇති ඉලක්කම ඒකස්ථානයයි (1).',
        extraData: {
          'fullNumber': '5421',
          'targetDigit': '1',
          'correctPlaceValue': 'ඒකස්ථානය',
          'correctRepresentedValue': '1',
        },
      ),
      const GoldenMangoQuestion(
        id: 'c2_q2',
        conceptId: 'c2_river_of_beads',
        questionType: GoldenMangoQuestionType.abacusInteractive,
        questionText: '3,618 සංඛ්‍යාව පබළු භාවිතයෙන් ගණක රාමුවේ නිරූපණය කරන්න.',
        correctAnswer: '3618',
        skillTag: 'place_value_thousands',
        difficulty: 2,
        hintLevel1: 'දහස්ස්ථානයට 3ක්, සියයස්ථානයට 6ක්, දහයස්ථානයට 1ක්, ඒකස්ථානයට 8ක් එකතු කරන්න.',
        hintLevel2: '3000 + 600 + 10 + 8 = 3618.',
        explanation: 'දහස් (3), සිය (6), දහය (1), ඒක (8) ගණක රාමුවේ තැබූ විට 3618 වේ.',
        extraData: {
          'targetNumber': 3618,
          'placeValues': ['දහස්', 'සිය', 'දහය', 'ඒක'],
        },
      ),
      const GoldenMangoQuestion(
        id: 'c2_q3',
        conceptId: 'c2_river_of_beads',
        questionType: GoldenMangoQuestionType.abacusInteractive,
        questionText: '5,421 සංඛ්‍යාව පබළු භාවිතයෙන් ගණක රාමුවේ නිරූපණය කරන්න.',
        correctAnswer: '5421',
        skillTag: 'place_value_thousands',
        difficulty: 2,
        hintLevel1: 'දහස් (5), සිය (4), දහය (2), ඒක (1) කණුවල පබළු තබන්න.',
        hintLevel2: '5000 + 400 + 20 + 1 = 5421.',
        explanation: '5000 + 400 + 20 + 1 = 5421.',
        extraData: {
          'targetNumber': 5421,
          'placeValues': ['දහස්', 'සිය', 'දහය', 'ඒක'],
        },
      ),
      const GoldenMangoQuestion(
        id: 'c2_q4',
        conceptId: 'c2_river_of_beads',
        questionType: GoldenMangoQuestionType.placeValuePicker,
        questionText: '5,421 හි \'4\' ඉලක්කම තිබෙන ස්ථානය කුමක්ද?',
        correctAnswer: 'සියයස්ථානය',
        options: [
          ExerciseOption(text: 'දහසස්ථානය', isCorrect: false),
          ExerciseOption(text: 'සියයස්ථානය', isCorrect: true), // Option B
          ExerciseOption(text: 'දහයස්ථානය', isCorrect: false),
          ExerciseOption(text: 'ඒකස්ථානය', isCorrect: false),
        ],
        skillTag: 'place_value_hundreds',
        difficulty: 1,
        hintLevel1: 'දකුණේ සිට බලන විට: 1 (ඒක), 2 (දහය), 4 (සියය).',
        hintLevel2: '4 පිහිටා ඇත්තේ තෙවන ස්ථානයේ එනම් සියයස්ථානයේය.',
        explanation: '5,421 හි 4 තිබෙන්නේ තෙවන ස්ථානයේය (සියයස්ථානය).',
        extraData: {
          'fullNumber': '5421',
          'targetDigit': '4',
          'correctPlaceValue': 'සියයස්ථානය',
          'correctRepresentedValue': '400',
        },
      ),
      const GoldenMangoQuestion(
        id: 'c2_q5',
        conceptId: 'c2_river_of_beads',
        questionType: GoldenMangoQuestionType.numericInput,
        questionText: '5,421 හි \'4\' ඉලක්කමෙන් නිරූපිත අගය ලියන්න.',
        correctAnswer: '400',
        options: [
          ExerciseOption(text: '4', isCorrect: false),
          ExerciseOption(text: '40', isCorrect: false),
          ExerciseOption(text: '400', isCorrect: true), // Option C
        ],
        skillTag: 'digit_value',
        difficulty: 2,
        hintLevel1: '4 තිබෙන්නේ සියයස්ථානයේය. 4 × 100 ගණනය කරන්න.',
        hintLevel2: 'සියයස්ථානයේ ඇති 4 හි අගය 400 කි.',
        explanation: '4 සියයස්ථානයේ ඇති බැවින් 4 × 100 = 400 වේ.',
      ),
      const GoldenMangoQuestion(
        id: 'c2_q6',
        conceptId: 'c2_river_of_beads',
        questionType: GoldenMangoQuestionType.multipleChoice,
        questionText: '4,905 හි දහයස්ථානයේ ඇති \'0\' ඉලක්කමේ නිරූපිත අගය කොපමණද?',
        options: [
          ExerciseOption(text: '10', isCorrect: false),
          ExerciseOption(text: '100', isCorrect: false),
          ExerciseOption(text: '40', isCorrect: false),
          ExerciseOption(text: '0', isCorrect: true), // Option D
        ],
        skillTag: 'digit_value',
        difficulty: 3,
        hintLevel1: '0 ඕනෑම ස්ථානයක තිබුණද එහි නිරූපිත අගය 0ම වේ.',
        hintLevel2: '0 × 10 = 0 වේ.',
        explanation: '0 ඉලක්කම දහයස්ථානයේ තිබුණද 0 × 10 = 0 අගයක් නිරූපණය කරයි.',
      ),
    ],

    // ─── CONCEPT 3: GIANT'S GATE (c3_giants_gate) — Numbers up to 100,000 ───
    'c3_giants_gate': [
      const GoldenMangoQuestion(
        id: 'c3_q1',
        conceptId: 'c3_giants_gate',
        questionType: GoldenMangoQuestionType.multipleChoice,
        questionText: '"දහදහස් එකසිය" ඉලක්කම් වලින් ලියූ විට කුමක්ද?',
        options: [
          ExerciseOption(text: '10,010', isCorrect: false),
          ExerciseOption(text: '1,010', isCorrect: false),
          ExerciseOption(text: '10,100', isCorrect: true), // Option C
          ExerciseOption(text: '100,100', isCorrect: false),
        ],
        skillTag: 'five_digit_number',
        difficulty: 1,
        hintLevel1: 'දහදහස් = 10,000, එකසිය = 100.',
        hintLevel2: '10,000 + 100 = 10,100.',
        explanation: '10,000 + 100 = 10,100.',
      ),
      const GoldenMangoQuestion(
        id: 'c3_q2',
        conceptId: 'c3_giants_gate',
        questionType: GoldenMangoQuestionType.numericInput,
        questionText: '"තිස්අටදහස් දහහත" ඉලක්කම් වලින් ලියන්න.',
        correctAnswer: '38017',
        options: [
          ExerciseOption(text: '3817', isCorrect: false),
          ExerciseOption(text: '38017', isCorrect: true), // Option B
          ExerciseOption(text: '38170', isCorrect: false),
        ],
        skillTag: 'five_digit_number',
        difficulty: 2,
        hintLevel1: 'තිස්අටදහස් = 38,000. සියයස්ථානයේ කිසිවක් නැත (0). දහහත = 17.',
        hintLevel2: '38,000 + 0 + 17 = 38017.',
        explanation: '38,000 (තිස්අටදහස්) + 0 (සියය) + 17 (දහහත) = 38017.',
      ),
      const GoldenMangoQuestion(
        id: 'c3_q3',
        conceptId: 'c3_giants_gate',
        questionType: GoldenMangoQuestionType.digitBuilder,
        questionText: '7, 5, 5, 0, 1 ඉලක්කම් භාවිතයෙන් 75501 සංඛ්‍යාව සාදන්න.',
        correctAnswer: '75501',
        skillTag: 'five_digit_number',
        difficulty: 2,
        hintLevel1: '75,000 (දසදහස් 7, දහස් 5) + 500 (සිය 5) + 0 + 1.',
        hintLevel2: '7 -> 5 -> 5 -> 0 -> 1 අනුපිළිවෙලින් තබන්න.',
        explanation: '75,501 හි ඉලක්කම් අනුපිළිවෙල 75501 වේ.',
        extraData: {
          'digits': [5, 1, 7, 0, 5], // Scrambled order
          'targetAnswer': '75501',
          'instructionSi': 'ඉලක්කම් භාවිතයෙන් 75501 සංඛ්‍යාව සාදන්න.',
        },
      ),
      const GoldenMangoQuestion(
        id: 'c3_q4',
        conceptId: 'c3_giants_gate',
        questionType: GoldenMangoQuestionType.multipleChoice,
        questionText: '25,602 සංඛ්‍යාවේ සංඛ්‍යා නාමය කුමක්ද?',
        options: [
          ExerciseOption(text: 'විසිපන්දහස් හයසිය විස්ස', isCorrect: false),
          ExerciseOption(text: 'දෙදහස් පන්සිය හටදෙක', isCorrect: false),
          ExerciseOption(text: 'විසිපන්දහස් හයසිය දෙක', isCorrect: true), // Option C
          ExerciseOption(text: 'විසිපන්දහස් විස්ස', isCorrect: false),
        ],
        skillTag: 'number_name',
        difficulty: 1,
        hintLevel1: '25,000 = විසිපන්දහස්, 600 = හයසිය, 2 = දෙක.',
        hintLevel2: '25,000 + 600 + 2 = විසිපන්දහස් හයසිය දෙක.',
        explanation: '25,000 (විසිපන්දහස්) + 600 (හයසිය) + 2 (දෙක) = විසිපන්දහස් හයසිය දෙක.',
      ),
      const GoldenMangoQuestion(
        id: 'c3_q5',
        conceptId: 'c3_giants_gate',
        questionType: GoldenMangoQuestionType.digitBuilder,
        questionText: '5, 3, 9, 0, 0 ඉලක්කම් භාවිතයෙන් 53900 සංඛ්‍යාව සාදන්න.',
        correctAnswer: '53900',
        skillTag: 'five_digit_number',
        difficulty: 2,
        hintLevel1: '5 (දසදහස්) + 3 (දහස්) + 9 (සිය) + 0 + 0.',
        hintLevel2: '5 -> 3 -> 9 -> 0 -> 0 අනුපිළිවෙලින් තබන්න.',
        explanation: '53,900 හි ඉලක්කම් 53900 වේ.',
        extraData: {
          'digits': [0, 9, 5, 0, 3], // Scrambled order
          'targetAnswer': '53900',
          'instructionSi': 'ඉලක්කම් භාවිතයෙන් 53900 සංඛ්‍යාව සාදන්න.',
        },
      ),
      const GoldenMangoQuestion(
        id: 'c3_q6',
        conceptId: 'c3_giants_gate',
        questionType: GoldenMangoQuestionType.multipleChoice,
        questionText: '"සියක් දහස" ලියනු ලබන්නේ කුමන ඉලක්කම් වලින්ද?',
        options: [
          ExerciseOption(text: '10,000', isCorrect: false),
          ExerciseOption(text: '1,000,000', isCorrect: false),
          ExerciseOption(text: '99,999', isCorrect: false),
          ExerciseOption(text: '100,000', isCorrect: true), // Option D
        ],
        skillTag: 'five_digit_number',
        difficulty: 3,
        hintLevel1: 'සියයක් (100) × දහසක් (1000).',
        hintLevel2: '100 ළඟට බිංදු 3ක් එක් කළ විට 100,000 වේ.',
        explanation: 'සියක් දහස (100 × 1,000) යනු 100,000 වේ.',
      ),
    ],

    // ─── CONCEPT 4: GLOWING PEDESTALS (c4_glowing_pedestals) — Ten-thousands place ───
    'c4_glowing_pedestals': [
      const GoldenMangoQuestion(
        id: 'c4_q1',
        conceptId: 'c4_glowing_pedestals',
        questionType: GoldenMangoQuestionType.placeValuePicker,
        questionText: '68,507 හි \'6\' ඉලක්කම පිහිටා ඇති ස්ථානීය අගය කුමක්ද?',
        correctAnswer: 'දස දහසස්ථානය',
        options: [
          ExerciseOption(text: 'දහසස්ථානය', isCorrect: false),
          ExerciseOption(text: 'දස දහසස්ථානය', isCorrect: true), // Option B
          ExerciseOption(text: 'සියයස්ථානය', isCorrect: false),
          ExerciseOption(text: 'දහයස්ථානය', isCorrect: false),
        ],
        skillTag: 'ten_thousands_place',
        difficulty: 1,
        hintLevel1: 'පස්වන ස්ථානය (වම්පසම ඉලක්කම) දස දහසස්ථානයයි.',
        hintLevel2: '68,507 හි 6 ඇත්තේ 5 වන ස්ථානය හෙවත් දස දහසස්ථානයේය.',
        explanation: 'ඉලක්කම් 5ක සංඛ්‍යාවක 5 වන ස්ථානය දස දහසස්ථානය වේ.',
        extraData: {
          'fullNumber': '68507',
          'targetDigit': '6',
          'correctPlaceValue': 'දස දහසස්ථානය',
          'correctRepresentedValue': '60000',
        },
      ),
      const GoldenMangoQuestion(
        id: 'c4_q2',
        conceptId: 'c4_glowing_pedestals',
        questionType: GoldenMangoQuestionType.placeValuePicker,
        questionText: '68,507 හි \'6\' ඉලක්කමෙන් නිරූපණය වන අගය කුමක්ද?',
        correctAnswer: '60,000',
        options: [
          ExerciseOption(text: '6,000', isCorrect: false),
          ExerciseOption(text: '600', isCorrect: false),
          ExerciseOption(text: '60,000', isCorrect: true), // Option C
          ExerciseOption(text: '60', isCorrect: false),
        ],
        skillTag: 'digit_value',
        difficulty: 1,
        hintLevel1: '6 තිබෙන්නේ දස දහසස්ථානයේය. 6 × 10,000 ගණනය කරන්න.',
        hintLevel2: '6 × 10,000 = 60,000.',
        explanation: '6 දස දහසස්ථානයේ පිහිටි බැවින් එහි නිරූපිත අගය 60,000 වේ.',
        extraData: {
          'fullNumber': '68507',
          'targetDigit': '6',
          'correctPlaceValue': 'දස දහසස්ථානය',
          'correctRepresentedValue': '60,000',
        },
      ),
      const GoldenMangoQuestion(
        id: 'c4_q3',
        conceptId: 'c4_glowing_pedestals',
        questionType: GoldenMangoQuestionType.numericInput,
        questionText: '35,421 හි \'3\' ඉලක්කමේ නිරූපිත අගය ලියන්න.',
        correctAnswer: '30000',
        options: [
          ExerciseOption(text: '3000', isCorrect: false),
          ExerciseOption(text: '30000', isCorrect: true), // Option B
          ExerciseOption(text: '300', isCorrect: false),
        ],
        skillTag: 'ten_thousands_place',
        difficulty: 2,
        hintLevel1: '3 ඇත්තේ දස දහසස්ථානයේය. 3 × 10,000 කරන්න.',
        hintLevel2: '3 × 10,000 = 30,000.',
        explanation: '3 × 10,000 = 30,000 වේ.',
      ),
      const GoldenMangoQuestion(
        id: 'c4_q4',
        conceptId: 'c4_glowing_pedestals',
        questionType: GoldenMangoQuestionType.placeValuePicker,
        questionText: '26,147 හි \'2\' පිහිටා ඇත්තේ දස දහසස්ථානයේය. එහි අගය කුමක්ද?',
        correctAnswer: '20,000',
        options: [
          ExerciseOption(text: '2,000', isCorrect: false),
          ExerciseOption(text: '200', isCorrect: false),
          ExerciseOption(text: '20,000', isCorrect: true), // Option C
          ExerciseOption(text: '20', isCorrect: false),
        ],
        skillTag: 'digit_value',
        difficulty: 2,
        hintLevel1: 'දස දහස් 2ක් යනු කොපමණද?',
        hintLevel2: '2 × 10,000 = 20,000.',
        explanation: '2 × 10,000 = 20,000 වේ.',
        extraData: {
          'fullNumber': '26147',
          'targetDigit': '2',
          'correctPlaceValue': 'දස දහසස්ථානය',
          'correctRepresentedValue': '20,000',
        },
      ),
      const GoldenMangoQuestion(
        id: 'c4_q5',
        conceptId: 'c4_glowing_pedestals',
        questionType: GoldenMangoQuestionType.multipleChoice,
        questionText: '68,507 හි සියයස්ථානයේ ඇති \'5\' ඉලක්කමේ නිරූපිත අගය කොපමණද?',
        options: [
          ExerciseOption(text: '5,000', isCorrect: false),
          ExerciseOption(text: '500', isCorrect: true), // Option B
          ExerciseOption(text: '50', isCorrect: false),
          ExerciseOption(text: '5', isCorrect: false),
        ],
        skillTag: 'digit_value',
        difficulty: 2,
        hintLevel1: '5 තිබෙන්නේ සියයස්ථානයේය. 5 × 100 බලන්න.',
        hintLevel2: '5 × 100 = 500.',
        explanation: '5 සියයස්ථානයේ පිහිටි බැවින් එහි නිරූපිත අගය 500 වේ.',
      ),
      const GoldenMangoQuestion(
        id: 'c4_q6',
        conceptId: 'c4_glowing_pedestals',
        questionType: GoldenMangoQuestionType.multipleChoice,
        questionText: '68,507 හි දහයස්ථානයේ ඇති \'0\' ඉලක්කමේ නිරූපිත අගය කොපමණද?',
        options: [
          ExerciseOption(text: '10', isCorrect: false),
          ExerciseOption(text: '500', isCorrect: false),
          ExerciseOption(text: '0', isCorrect: true), // Option C
          ExerciseOption(text: '60000', isCorrect: false),
        ],
        skillTag: 'ten_thousands_place',
        difficulty: 3,
        hintLevel1: '0 ඉලක්කම දහයස්ථානයේ තිබුණද එහි අගය 0 වේ.',
        hintLevel2: '0 × 10 = 0.',
        explanation: '0 × 10 = 0 වේ.',
      ),
    ],

    // ─── CONCEPT 5: UNLOCKING THE CHEST (c5_unlocking_chest) — Expanded form ───
    'c5_unlocking_chest': [
      const GoldenMangoQuestion(
        id: 'c5_q1',
        conceptId: 'c5_unlocking_chest',
        questionType: GoldenMangoQuestionType.multipleChoice,
        questionText: '6,831 විහිදුවා ලියන නිවැරදි ආකාරය තෝරන්න.',
        options: [
          ExerciseOption(text: '600 + 800 + 30 + 1', isCorrect: false),
          ExerciseOption(text: '6000 + 80 + 300 + 1', isCorrect: false),
          ExerciseOption(text: '60000 + 800 + 30 + 1', isCorrect: false),
          ExerciseOption(text: '6000 + 800 + 30 + 1', isCorrect: true), // Option D
        ],
        skillTag: 'expanded_form',
        difficulty: 1,
        hintLevel1: '6000 (දහස්) + 800 (සිය) + 30 (දහය) + 1 (ඒක).',
        hintLevel2: 'ස්ථානීය අගයන් එකතු කරන්න: 6000 + 800 + 30 + 1.',
        explanation: '6,831 = 6000 + 800 + 30 + 1 වේ.',
      ),
      const GoldenMangoQuestion(
        id: 'c5_q2',
        conceptId: 'c5_unlocking_chest',
        questionType: GoldenMangoQuestionType.expandedFormBuilder,
        questionText: '68,507 විහිදුවා ලියූ කොටස් නිවැරදිව පේළියට තබන්න.',
        correctAnswer: '60000 + 8000 + 500 + 0 + 7',
        skillTag: 'expanded_form',
        difficulty: 1,
        hintLevel1: '60,000 + 8,000 + 500 + 0 + 7.',
        hintLevel2: 'දසදහස් 6 = 60,000, දහස් 8 = 8,000, සිය 5 = 500, දහය = 0, ඒක = 7.',
        explanation: '68,507 = 60,000 + 8,000 + 500 + 0 + 7 වේ.',
        extraData: {
          'targetNumber': '68507',
          'correctComponents': ['60000', '8000', '500', '0', '7'],
          'availableCards': ['8000', '60000', '0', '500', '7', '6000', '80'], // Scrambled cards
        },
      ),
      const GoldenMangoQuestion(
        id: 'c5_q3',
        conceptId: 'c5_unlocking_chest',
        questionType: GoldenMangoQuestionType.expandedFormBuilder,
        questionText: '45,600 විහිදුවා ලියූ කොටස් නිවැරදිව පේළියට තබන්න.',
        correctAnswer: '40000 + 5000 + 600 + 0 + 0',
        skillTag: 'expanded_form',
        difficulty: 2,
        hintLevel1: '40,000 (දසදහස් 4) + 5,000 (දහස් 5) + 600 (සිය 6) + 0 + 0.',
        hintLevel2: '40000 + 5000 + 600 + 0 + 0.',
        explanation: '45,600 = 40000 + 5000 + 600 + 0 + 0 වේ.',
        extraData: {
          'targetNumber': '45600',
          'correctComponents': ['40000', '5000', '600', '0', '0'],
          'availableCards': ['600', '40000', '0', '5000', '0', '4000', '50'], // Scrambled cards
        },
      ),
      const GoldenMangoQuestion(
        id: 'c5_q4',
        conceptId: 'c5_unlocking_chest',
        questionType: GoldenMangoQuestionType.numericInput,
        questionText: '68,507 = 60,000 + ? + 500 + 0 + 7 හි හිස්තැනට සුදුසු අගය ලියන්න.',
        correctAnswer: '8000',
        options: [
          ExerciseOption(text: '800', isCorrect: false),
          ExerciseOption(text: '8000', isCorrect: true), // Option B
          ExerciseOption(text: '80', isCorrect: false),
        ],
        skillTag: 'expanded_form',
        difficulty: 2,
        hintLevel1: '8 තිබෙන්නේ දහසස්ථානයේය. 8 × 1000 සිතන්න.',
        hintLevel2: 'දහසස්ථානයේ ඇති 8 හි අගය 8,000 කි.',
        explanation: '68,507 හි 8 ඇත්තේ දහසස්ථානයේ බැවින් එහි අගය 8,000 වේ.',
      ),
      const GoldenMangoQuestion(
        id: 'c5_q5',
        conceptId: 'c5_unlocking_chest',
        questionType: GoldenMangoQuestionType.multipleChoice,
        questionText: '68,507 හි දහයස්ථානයේ විහිදුවූ අගය 0 වේ. මන්ද?',
        options: [
          ExerciseOption(text: 'දහයස්ථානයේ ඇති ඉලක්කම 0 නිසා', isCorrect: true), // Option A
          ExerciseOption(text: 'දහයස්ථානයක් නැති නිසා', isCorrect: false),
          ExerciseOption(text: 'දහයස්ථානයේ අගය 100 නිසා', isCorrect: false),
        ],
        skillTag: 'expanded_form_zero',
        difficulty: 2,
        hintLevel1: '0 ඉලක්කම ඕනෑම ස්ථානයක තිබුණද එහි අගය 0 වේ.',
        hintLevel2: '0 × 10 = 0 වේ.',
        explanation: 'දහයස්ථානයේ 0 ඇති බැවින් එහි විහිදුවූ අගය 0 × 10 = 0 වේ.',
      ),
      const GoldenMangoQuestion(
        id: 'c5_q6',
        conceptId: 'c5_unlocking_chest',
        questionType: GoldenMangoQuestionType.multipleChoice,
        questionText: '90,000 + 0 + 900 + 90 + 9 විහිදුවූ අගයන්ගෙන් සෑදෙන සංඛ්‍යාව කුමක්ද?',
        options: [
          ExerciseOption(text: '99,999', isCorrect: false),
          ExerciseOption(text: '90,999', isCorrect: true), // Option B
          ExerciseOption(text: '90,990', isCorrect: false),
          ExerciseOption(text: '9,999', isCorrect: false),
        ],
        skillTag: 'expanded_form_zero',
        difficulty: 3,
        hintLevel1: 'දහස්ස්ථානයේ අගය 0 වේ! 90,000 + 0 + 999 සිතන්න.',
        hintLevel2: '90,000 + 999 = 90,999.',
        explanation: 'දහස්ස්ථානයේ 0 ඇති බැවින් සංඛ්‍යාව 90,999 වේ.',
      ),
    ],
  };

  /// Get questions for a concept
  static List<GoldenMangoQuestion> getQuestionsForConcept(String conceptId) {
    return conceptQuestions[conceptId] ?? [];
  }
}
