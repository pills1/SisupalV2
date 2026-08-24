import '../../models/maths/lesson_step_model.dart';

/// Complete content dataset for Lesson 1: සංඛ්‍යා - 1 (Numbers - Part 1)
class MathsLesson1Data {
  static const String lessonId = 'math_grade5_01';
  static const String lessonTitleSi = 'සංඛ්‍යා - 1';
  static const String lessonTitleEn = 'Numbers - Part 1';

  /// Dialogue Introduction steps led by Mathematics Parrot 🦜
  static final List<String> introDialogues = [
    'ආයුබෝවන් පුංචි ගණිත වීරයා! 🦜✨\nමම ඔයාගේ ගණිත ගිරවා!',
    'අපේ අංක රාජධානියේ අංක ටිකක් අවුල් වෙලා!\nඅපිට ඒවා නැවත නිවැරදි තැන්වලට යවන්න ඔයාගේ උදව් ඕනේ!',
    'මේ ගමනේදී අපි අංක කියවමු, අංක ලියමු, ඉලක්කම්වල ස්ථාන හඳුනාගමු, ස්ථානීය අගයන් සොයමු, අංක විහිදුවා ලියමු! 🚀',
  ];

  /// Guided Practice Questions (6 Items)
  static final List<LessonStepModel> guidedQuestions = [
    const LessonStepModel(
      id: 'gq1',
      stage: StepStage.guidedPractice,
      title: 'අභ්‍යාසය 1',
      parrotDialogue: '🦜 "84 කියවන්නේ කෙසේද කියා තෝරන්න!"',
      interactionType: QuestionInteractionType.multipleChoice,
      questionText: '84 කියවන්නේ කෙසේද?',
      options: [
        QuestionOption(text: 'අසූ හතර', isCorrect: true),
        QuestionOption(text: 'අටසිය හතර', isCorrect: false),
        QuestionOption(text: 'අසූ හත', isCorrect: false),
      ],
    ),
    const LessonStepModel(
      id: 'gq2',
      stage: StepStage.guidedPractice,
      title: 'අභ්‍යාසය 2',
      parrotDialogue: '🦜 "997 නිවැරදිව කියවන ආකාරය කුමක්ද?"',
      interactionType: QuestionInteractionType.multipleChoice,
      questionText: '997 කියවන්නේ කෙසේද?',
      options: [
        QuestionOption(text: 'නවසිය අනූ හත', isCorrect: true),
        QuestionOption(text: 'නවසිය හතළිස් හත', isCorrect: false),
        QuestionOption(text: 'නවදහස් සත', isCorrect: false),
      ],
    ),
    const LessonStepModel(
      id: 'gq3',
      stage: StepStage.guidedPractice,
      title: 'අභ්‍යාසය 3',
      parrotDialogue: '🦜 "වචනයෙන් ඇති අංකය ඉලක්කම් වලින් ලියමු!"',
      interactionType: QuestionInteractionType.numericInput,
      questionText: '"තුන් දහස් හාරසිය විසි එක" ඉලක්කම් වලින් ලියන්න.',
      correctAnswer: '3421',
    ),
    const LessonStepModel(
      id: 'gq4',
      stage: StepStage.guidedPractice,
      title: 'අභ්‍යාසය 4',
      parrotDialogue: '🦜 "5421 හි 4 තිබෙන ස්ථානය සොයන්න!"',
      interactionType: QuestionInteractionType.placeValuePicker,
      questionText: '5421 හි \'4\' තිබෙන ස්ථානය කුමක්ද?',
      options: [
        QuestionOption(text: 'සිය', isCorrect: true),
        QuestionOption(text: 'දහස්', isCorrect: false),
        QuestionOption(text: 'දහය', isCorrect: false),
        QuestionOption(text: 'එකක', isCorrect: false),
      ],
    ),
    const LessonStepModel(
      id: 'gq5',
      stage: StepStage.guidedPractice,
      title: 'අභ්‍යාසය 5',
      parrotDialogue: '🦜 "4 හි නිරූපිත අගය (Represented Value) කොපමණද?"',
      interactionType: QuestionInteractionType.placeValuePicker,
      questionText: '5421 හි \'4\' හි නිරූපිත අගය කොපමණද?',
      options: [
        QuestionOption(text: '400', isCorrect: true),
        QuestionOption(text: '4', isCorrect: false),
        QuestionOption(text: '40', isCorrect: false),
        QuestionOption(text: '4000', isCorrect: false),
      ],
    ),
    const LessonStepModel(
      id: 'gq6',
      stage: StepStage.guidedPractice,
      title: 'අභ්‍යාසය 6',
      parrotDialogue: '🦜 "6831 විහිදුවා ලියන ආකාරය තෝරන්න!"',
      interactionType: QuestionInteractionType.expandedFormBuilder,
      questionText: '6831 විහිදුවා ලිවිය හැකි ආකාරය?',
      correctAnswer: '6000 + 800 + 30 + 1',
      options: [
        QuestionOption(text: '6000 + 800 + 30 + 1', isCorrect: true),
        QuestionOption(text: '600 + 800 + 30 + 1', isCorrect: false),
        QuestionOption(text: '6000 + 80 + 300 + 1', isCorrect: false),
      ],
    ),
  ];

  /// Core Assessment Questions (4 Items)
  static final List<LessonStepModel> assessmentQuestions = [
    const LessonStepModel(
      id: 'aq1',
      stage: StepStage.assessment,
      title: 'ඇගයීම 1',
      parrotDialogue: '🦜 "68 507 හි \'6\' පිහිටි ස්ථානය කුමක්ද?"',
      interactionType: QuestionInteractionType.multipleChoice,
      questionText: '68 507 — \'6\' පිහිටා ඇත්තේ කොතැනද?',
      options: [
        QuestionOption(text: 'දස දහස්', isCorrect: true),
        QuestionOption(text: 'දහස්', isCorrect: false),
        QuestionOption(text: 'සිය', isCorrect: false),
        QuestionOption(text: 'දහය', isCorrect: false),
      ],
    ),
    const LessonStepModel(
      id: 'aq2',
      stage: StepStage.assessment,
      title: 'ඇගයීම 2',
      parrotDialogue: '🦜 "35 421 හි 4 හි නිරූපිත අගය කොපමණද?"',
      interactionType: QuestionInteractionType.multipleChoice,
      questionText: '35 421 හි \'4\' හි නිරූපිත අගය කොපමණද?',
      options: [
        QuestionOption(text: '400', isCorrect: true),
        QuestionOption(text: '40', isCorrect: false),
        QuestionOption(text: '4000', isCorrect: false),
        QuestionOption(text: '40000', isCorrect: false),
      ],
    ),
    const LessonStepModel(
      id: 'aq3',
      stage: StepStage.assessment,
      title: 'ඇගයීම 3',
      parrotDialogue: '🦜 "68 507 විහිදුවා ලියන ආකාරය තෝරන්න!"',
      interactionType: QuestionInteractionType.expandedFormBuilder,
      questionText: '68 507 විහිදුවා ලිවිය හැකි ආකාරය?',
      correctAnswer: '60000 + 8000 + 500 + 0 + 7',
      options: [
        QuestionOption(text: '60000 + 8000 + 500 + 0 + 7', isCorrect: true),
        QuestionOption(text: '6000 + 8000 + 500 + 0 + 7', isCorrect: false),
        QuestionOption(text: '60000 + 800 + 500 + 0 + 7', isCorrect: false),
      ],
    ),
    const LessonStepModel(
      id: 'aq4',
      stage: StepStage.assessment,
      title: 'ඇගයීම 4',
      parrotDialogue: '🦜 "26 147 හි සෑම ඉලක්කමකම ස්ථානය යා කරන්න!"',
      interactionType: QuestionInteractionType.matchingTable,
      questionText: '26 147 — සෑම ඉලක්කමේ ම ස්ථානය සටහන් කරන්න.',
      matchingPairs: [
        MatchingPair(digit: '2', placeValue: 'දස දහස්'),
        MatchingPair(digit: '6', placeValue: 'දහස්'),
        MatchingPair(digit: '1', placeValue: 'සිය'),
        MatchingPair(digit: '4', placeValue: 'දහය'),
        MatchingPair(digit: '7', placeValue: 'එකක'),
      ],
    ),
  ];

  /// Advanced Questions (3 Items - Score >= 80%)
  static final List<LessonStepModel> advancedQuestions = [
    const LessonStepModel(
      id: 'adv1',
      stage: StepStage.adaptivePath,
      title: 'විශේෂ අභියෝගය 1',
      parrotDialogue: '🦜 "1, 3, 6, 4 භාවිතයෙන් සෑදිය හැකි විශාලතම අංකය කුමක්ද?"',
      interactionType: QuestionInteractionType.numericInput,
      questionText: '1, 3, 6, 4 ඉලක්කම් භාවිතයෙන් සෑදිය හැකි විශාලතම අංකය කුමක්ද?',
      correctAnswer: '6431',
      options: [
        QuestionOption(text: '6431', isCorrect: true),
        QuestionOption(text: '6413', isCorrect: false),
        QuestionOption(text: '6341', isCorrect: false),
        QuestionOption(text: '4631', isCorrect: false),
      ],
    ),
    const LessonStepModel(
      id: 'adv2',
      stage: StepStage.adaptivePath,
      title: 'විශේෂ අභියෝගය 2',
      parrotDialogue: '🦜 "68507 හි සිය ස්ථානයේ ඉලක්කමේ නිරූපිත අගය කුමක්ද?"',
      interactionType: QuestionInteractionType.multipleChoice,
      questionText: '68507 හි සිය ස්ථානයේ ඉලක්කමේ නිරූපිත අගය?',
      options: [
        QuestionOption(text: '500', isCorrect: true),
        QuestionOption(text: '5', isCorrect: false),
        QuestionOption(text: '5000', isCorrect: false),
        QuestionOption(text: '50', isCorrect: false),
      ],
    ),
    const LessonStepModel(
      id: 'adv3',
      stage: StepStage.adaptivePath,
      title: 'විශේෂ අභියෝගය 3',
      parrotDialogue: '🦜 "99 999 වචනවලින් ලියන ආකාරය කුමක්ද?"',
      interactionType: QuestionInteractionType.wordArrangement,
      questionText: '99 999 වචනවලින් ලියන ආකාරය?',
      correctAnswer: 'අනූ නවදහස් නවසිය අනූ නවය',
      options: [
        QuestionOption(text: 'අනූ නවදහස් නවසිය අනූ නවය', isCorrect: true),
        QuestionOption(text: 'නවසිය අනූ නවදහස් නවය', isCorrect: false),
        QuestionOption(text: 'අනූ දහස් නවසිය අනූ නවය', isCorrect: false),
      ],
    ),
  ];

  /// Remedial Questions (3 Items - Score < 80%)
  static final List<LessonStepModel> remedialQuestions = [
    const LessonStepModel(
      id: 'rem1',
      stage: StepStage.adaptivePath,
      title: 'නැවත පුහුණුව 1',
      parrotDialogue: 'RB 🦜 "කමක් නැහැ! අපි ආයෙත් එකට බලමු. 321 හි සිය ස්ථානයේ ඉලක්කම කුමක්ද?"',
      interactionType: QuestionInteractionType.multipleChoice,
      questionText: '321 හි සිය ස්ථානයේ ඉලක්කම කුමක්ද?',
      options: [
        QuestionOption(text: '3', isCorrect: true),
        QuestionOption(text: '1', isCorrect: false),
        QuestionOption(text: '2', isCorrect: false),
        QuestionOption(text: '0', isCorrect: false),
      ],
    ),
    const LessonStepModel(
      id: 'rem2',
      stage: StepStage.adaptivePath,
      title: 'නැවත පුහුණුව 2',
      parrotDialogue: '🦜 "4000 + 500 + 20 + 1 එකතු කළ විට ලැබෙන අංකය ලියන්න!"',
      interactionType: QuestionInteractionType.numericInput,
      questionText: '4000 + 500 + 20 + 1 = ?',
      correctAnswer: '4521',
    ),
    const LessonStepModel(
      id: 'rem3',
      stage: StepStage.adaptivePath,
      title: 'නැවත පුහුණුව 3',
      parrotDialogue: '🦜 "4521 හි 5 හි නිරූපිත අගය කුමක්ද?"',
      interactionType: QuestionInteractionType.multipleChoice,
      questionText: '4521 හි \'5\' හි නිරූපිත අගය?',
      options: [
        QuestionOption(text: '500', isCorrect: true),
        QuestionOption(text: '5', isCorrect: false),
        QuestionOption(text: '50', isCorrect: false),
        QuestionOption(text: '5000', isCorrect: false),
      ],
    ),
  ];

  /// Rapid-Fire Mini-Game Questions (3 Items)
  static final List<LessonStepModel> rapidFireQuestions = [
    const LessonStepModel(
      id: 'rf1',
      stage: StepStage.rapidFire,
      title: 'වේගවත් අභියෝගය 1 ⚡',
      parrotDialogue: '🦜 "ઝડප්! 7 304 හි 7 හි නිරූපිත අගය කුමක්ද?"',
      interactionType: QuestionInteractionType.multipleChoice,
      questionText: '7 304 හි "7" හි නිරූපිත අගය?',
      options: [
        QuestionOption(text: '7000', isCorrect: true),
        QuestionOption(text: '700', isCorrect: false),
        QuestionOption(text: '70', isCorrect: false),
        QuestionOption(text: '7', isCorrect: false),
      ],
    ),
    const LessonStepModel(
      id: 'rf2',
      stage: StepStage.rapidFire,
      title: 'වේගවත් අභියෝගය 2 ⚡',
      parrotDialogue: '🦜 "45 600 විහිදුවා ලියන්න!"',
      interactionType: QuestionInteractionType.expandedFormBuilder,
      questionText: '45 600 විහිදුවා ලිවීම?',
      correctAnswer: '40000 + 5000 + 600 + 0 + 0',
      options: [
        QuestionOption(text: '40000 + 5000 + 600 + 0 + 0', isCorrect: true),
        QuestionOption(text: '4000 + 5000 + 600 + 0 + 0', isCorrect: false),
        QuestionOption(text: '40000 + 500 + 60 + 0 + 0', isCorrect: false),
      ],
    ),
    const LessonStepModel(
      id: 'rf3',
      stage: StepStage.rapidFire,
      title: 'වේගවත් අභියෝගය 3 ⚡',
      parrotDialogue: '🦜 "විසිතුන් දහස් සිය හතළිස් දෙකක් ඉලක්කම් වලින් ලියන්න!"',
      interactionType: QuestionInteractionType.numericInput,
      questionText: '"විසිතුන් දහස් සිය හතළිස් දෙකක්" = ?',
      correctAnswer: '23142',
    ),
  ];
}
