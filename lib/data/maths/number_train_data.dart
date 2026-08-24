import '../../models/maths/number_train_models.dart';
import '../../utils/app_theme.dart';

/// Data Repository for Lesson 2: The Great Number Train
class NumberTrainData {
  /// Concept 1 Model & Questions
  static const NumberTrainConceptModel concept1 = NumberTrainConceptModel(
    id: 'c1_number_train_station',
    title: 'පළමු නැවතුම – සංඛ්‍යා සසඳමු',
    subtitle: 'විශාලම සහ කුඩාම සංඛ්‍යාව සොයමු',
    learningObjective: 'සංඛ්‍යා 3ක් අතරින් විශාලම සහ කුඩාම සංඛ්‍යාව හඳුනාගැනීම සහ පෙළගැස්වීම',
    stationBgAsset: MathsAssets.bgTrainStation,
    interiorBgAsset: MathsAssets.bgTrainInterior,
    storyBeats: [
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.leo,
        speakerNameSi: 'ලියෝ 🦁',
        dialogueSi: 'අපේ ඊළඟ ගමන කොහෙද කියලා මට හරිම කුතුහලයි!',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.ella,
        speakerNameSi: 'එළි 🐘',
        dialogueSi: 'අපි අද යන්නේ මහා සංඛ්‍යා දුම්රියෙන්! දුම්රියට ගොඩවෙන්න සූදානම්ද?',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.felix,
        speakerNameSi: 'ෆීලික්ස් 🦊',
        dialogueSi: 'හහ්! සංඛ්‍යා තුනක් දැක්කාම විශාලම එක මම ඇස් දෙකෙන්ම තෝරන්නම්!',
        isInteractiveChoice: true,
        choicePromptSi: '56, 28, 32 අතරින් විශාලම සංඛ්‍යාව කුමක්ද කියා ෆීලික්ස් තෝරයි:',
        wrongOptionText: '32 තෝරමු (ෆීලික්ස්ගේ තේරීම)',
        correctOptionText: '56 තෝරමු (නිවැරදි තේරීම)',
        wrongFeedbackSi: 'ෆීලික්ස් වැරදියි! 32 ට වඩා 56 විශාලයි!',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.ella,
        speakerNameSi: 'එළි 🐘',
        dialogueSi: 'ෆීලික්ස්, සංඛ්‍යාවක් විශාලද කුඩාද කියලා බලන්න නම් ඒවා හොඳින් සසඳන්න ඕනේ. අපි මුලින්ම සංඛ්‍යාවල ඉලක්කම් පිහිටි ස්ථාන බලමු!',
      ),
    ],
    challenges: [
      // Challenge 1: 2-digit Tap Selection
      NumberTrainChallengeModel(
        id: 'c1_ch1',
        conceptId: 'c1_number_train_station',
        challengeNumber: 1,
        interactionType: NumberTrainInteractionType.tapSelection,
        title: 'අභියෝගය 1: විශාලම සංඛ්‍යාව තෝරන්න',
        questionText: '56, 28, 32 අතරින් විශාලම සංඛ්‍යාව තෝරන්න.',
        numbers: ['56', '28', '32'],
        correctAnswer: '56',
        hintLevel1: 'මුලින්ම දහයස්ථානයේ ඉලක්කම් බලමු. 5, 2, 3 අතරින් විශාලම ඉලක්කම කුමක්ද?',
        hintLevel2: '56 හි දහයස්ථානයේ 5ක් තියෙනවා. 28 හි 2ක් සහ 32 හි 3ක් තියෙනවා. එබැවින් විශාලම සංඛ්‍යාව කුමක්ද?',
        explanation: 'දහයස්ථානයේ ඉලක්කම විශාල වන විට, මේ සංඛ්‍යා අතර එය විශාල සංඛ්‍යාව වේ. 5 > 3 > 2 නිසා 56 විශාලම සංඛ්‍යාවයි.',
        skillTag: 'compare_two_digit_numbers',
        difficulty: 1,
      ),

      // Challenge 2: Train Ticket Drag to Ticket Counter
      NumberTrainChallengeModel(
        id: 'c1_ch2',
        conceptId: 'c1_number_train_station',
        challengeNumber: 2,
        interactionType: NumberTrainInteractionType.ticketDrag,
        title: 'අභියෝගය 2: දුම්රිය ටිකට්පත',
        questionText: 'විශාලම සංඛ්‍යාව සහිත ටිකට්පත දුම්රිය ටිකට් කවුන්ටරයට ඇද තබන්න.',
        numbers: ['541', '358', '722'],
        correctAnswer: '722',
        hintLevel1: 'සියයස්ථානයේ ඉලක්කම් බලමු: 5, 3, 7 අතරින් විශාලම ඉලක්කම කුමක්ද?',
        hintLevel2: '722 හි සියයස්ථානයේ 7ක් ඇත. එය 5 සහ 3ට වඩා විශාලය.',
        explanation: 'සියයස්ථානයේ 7 > 5 > 3 බැවින් විශාලම සංඛ්‍යාව 722 වේ.',
        skillTag: 'compare_three_digit_numbers',
        difficulty: 1,
      ),

      // Challenge 3: Train Carriage Ordering Smallest -> Largest
      NumberTrainChallengeModel(
        id: 'c1_ch3',
        conceptId: 'c1_number_train_station',
        challengeNumber: 3,
        interactionType: NumberTrainInteractionType.carriageOrdering,
        title: 'අභියෝගය 3: දුම්රිය මැදිරි අනුපිළිවෙල',
        questionText: 'කුඩාම සංඛ්‍යාවේ සිට විශාලම සංඛ්‍යාව දක්වා දුම්රිය මැදිරි සකස් කරන්න.',
        numbers: ['28', '56', '32'],
        correctAnswer: '28,32,56',
        hintLevel1: 'දහයස්ථානයේ ඉලක්කම් කුඩාම සංඛ්‍යාවේ සිට පෙළගස්වන්න: 2, 3, 5.',
        hintLevel2: '28 (දහය 2) ➔ 32 (දහය 3) ➔ 56 (දහය 5) අනුපිළිවෙල සිතන්න.',
        explanation: 'දහයස්ථාන අගයන් සසඳන විට: 28 < 32 < 56 වේ.',
        skillTag: 'ascending_order',
        difficulty: 2,
      ),

      // Challenge 4: Guided Place Value Digit Comparison
      NumberTrainChallengeModel(
        id: 'c1_ch4',
        conceptId: 'c1_number_train_station',
        challengeNumber: 4,
        interactionType: NumberTrainInteractionType.guidedPlaceValue,
        title: 'අභියෝගය 4: ස්ථානීය අගය සසඳමු',
        questionText: '541, 528, 301 අතරින් විශාලම සංඛ්‍යාව සොයන්න.',
        numbers: ['541', '528', '301'],
        correctAnswer: '541',
        hintLevel1: 'සියයස්ථානයේ 541 සහ 528 දෙකෙහිම 5 ඇත. එනිසා දහයස්ථානය බලන්න.',
        hintLevel2: '541 හි දහයස්ථානයේ 4ක් ද, 528 හි 2ක් ද ඇත. 4 > 2 වේ.',
        explanation: 'සියයස්ථාන සමාන නිසා දහයස්ථානය සසඳමු: 4 > 2 බැවින් 541 > 528 > 301 වේ.',
        skillTag: 'place_value_comparison',
        difficulty: 2,
      ),

      // Challenge 5: Train Carriage Sorting
      NumberTrainChallengeModel(
        id: 'c1_ch5',
        conceptId: 'c1_number_train_station',
        challengeNumber: 5,
        interactionType: NumberTrainInteractionType.carriageSorting,
        title: 'අභියෝගය 5: මැදිරි පේළිගත කිරීම',
        questionText: 'කුඩාම සංඛ්‍යාවේ සිට විශාලම සංඛ්‍යාව දක්වා දුම්රිය මැදිරි පේළිගත කරන්න.',
        numbers: ['352', '258', '219'],
        correctAnswer: '219,258,352',
        hintLevel1: 'සියයස්ථානය බලන්න: 219 සහ 258 හි සියයස්ථානයේ 2 ඇත. දහයස්ථානයේ 1 < 5 වේ.',
        hintLevel2: 'කුඩාම සංඛ්‍යාව 219 වේ. ඉන්පසු 258 සහ විශාලම සංඛ්‍යාව 352 වේ.',
        explanation: 'සියයස්ථාන සහ දහයස්ථාන අනුපිළිවෙලින්: 219 < 258 < 352 වේ.',
        skillTag: 'number_ordering',
        difficulty: 2,
      ),

      // Challenge 6: 4-digit Concept Mastery
      NumberTrainChallengeModel(
        id: 'c1_ch6',
        conceptId: 'c1_number_train_station',
        challengeNumber: 6,
        interactionType: NumberTrainInteractionType.masteryOrdering,
        title: 'අභියෝගය 6: මහා දුම්රිය ජයග්‍රහණය! 🏆',
        questionText: 'මෙම සංඛ්‍යා තුන කුඩාම සංඛ්‍යාවේ සිට විශාලම සංඛ්‍යාව දක්වා පටිපාටිගත කරන්න.',
        numbers: ['4825', '3967', '4512'],
        correctAnswer: '3967,4512,4825',
        hintLevel1: 'දහස්ස්ථානය බලන්න: 3,967 හි දහස්ස්ථානයේ 3 ඇත. එය කුඩාම වේ!',
        hintLevel2: '4,825 සහ 4,512 හි දහස් 4 බැවින් සියයස්ථානය බලන්න: 500 < 800 වේ.',
        explanation: 'දහස්ස්ථානයෙන් 3,967 කුඩාම වේ. සියයස්ථානයෙන් 4,512 < 4,825 වේ. අනුපිළිවෙල: 3,967 ➔ 4,512 ➔ 4,825.',
        skillTag: 'compare_four_digit_numbers',
        difficulty: 3,
      ),
    ],
  );

  /// Concept 2: "දෙවන නැවතුම – සංඛ්‍යා පටිපාටිගත කරමු"
  static const NumberTrainConceptModel concept2 = NumberTrainConceptModel(
    id: 'c2_number_train_ordering',
    title: 'දෙවන නැවතුම – සංඛ්‍යා පටිපාටිගත කරමු',
    subtitle: 'ආරෝහණ හා අවරෝහණ පිළිවෙළ',
    learningObjective: 'සංඛ්‍යා තුනක් ආරෝහණ හා අවරෝහණ පිළිවෙළට පටිපාටිගත කිරීම',
    stationBgAsset: MathsAssets.bgTrainInterior,
    interiorBgAsset: MathsAssets.bgTrainInterior,
    storyBeats: [
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.leo,
        speakerNameSi: 'ලියෝ 🦁',
        dialogueSi: 'අපේ දුම්රියේ මැදිරි ටික අවුල් වෙලා! මේවා නිවැරදි පිළිවෙළට සකස් කරන්න ඕනේ.',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.ella,
        speakerNameSi: 'එළි 🐘',
        dialogueSi: 'හරි! කුඩාම සංඛ්‍යාවේ සිට විශාලම සංඛ්‍යාව දක්වා සකස් කරන එකට "ආරෝහණ පිළිවෙළ" කියනවා. විශාලම සිට කුඩාම දක්වා "අවරෝහණ පිළිවෙළ" කියනවා.',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.felix,
        speakerNameSi: 'ෆීලික්ස් 🦊',
        dialogueSi: 'හහ්! මට නම් හිතෙන විදිහට දාන්න පුළුවන්!',
        isInteractiveChoice: true,
        choicePromptSi: '47, 81, 74 ආරෝහණ පිළිවෙළට ෆීලික්ස් තෝරයි:',
        wrongOptionText: '81, 74, 47 (ෆීලික්ස්)',
        correctOptionText: '47, 74, 81 (නිවැරදි)',
        wrongFeedbackSi: 'ෆීලික්ස් වැරදියි! ආරෝහණ පිළිවෙළ කුඩාම සිට විශාලම දක්වා!',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.ella,
        speakerNameSi: 'එළි 🐘',
        dialogueSi: 'ෆීලික්ස්, ඉක්මන් වෙන්න එපා! මුලින්ම සංඛ්‍යා සංසන්දනය කරමු. ඊට පස්සේ නිවැරදිව පටිපාටිගත කරන්න පුළුවන්.',
      ),
    ],
    challenges: [
      // Challenge 1: Tap Selection Warm-Up
      NumberTrainChallengeModel(
        id: 'c2_ch1',
        conceptId: 'c2_number_train_ordering',
        challengeNumber: 1,
        interactionType: NumberTrainInteractionType.tapSelection,
        title: 'අභියෝගය 1: බෝඩිම් ටිකට්පත',
        questionText: '45, 18, 62 අතරින් කුඩාම සංඛ්‍යාව තෝරන්න.',
        numbers: ['45', '18', '62'],
        correctAnswer: '18',
        hintLevel1: 'දහයස්ථානයේ ඉලක්කම් බලන්න: 4, 1, 6. කුඩාම දහය කුමක්ද?',
        hintLevel2: '18 හි දහයස්ථානයේ 1 ඇත. එය 4 සහ 6 ට වඩා කුඩාය.',
        explanation: 'දහයස්ථානය සසඳන විට: 1 < 4 < 6 බැවින් 18 කුඩාම සංඛ්‍යාව වේ.',
        skillTag: 'smallest_number',
        difficulty: 1,
      ),

      // Challenge 2: Ascending Ordering Drag
      NumberTrainChallengeModel(
        id: 'c2_ch2',
        conceptId: 'c2_number_train_ordering',
        challengeNumber: 2,
        interactionType: NumberTrainInteractionType.carriageOrdering,
        title: 'අභියෝගය 2: මැදිරි සකස් කරමු',
        questionText: 'සංඛ්‍යා කුඩාම සංඛ්‍යාවේ සිට විශාලම සංඛ්‍යාව දක්වා (ආරෝහණ පිළිවෙළට) සකස් කරන්න.',
        numbers: ['74', '47', '81'],
        correctAnswer: '47,74,81',
        hintLevel1: 'දහයස්ථානයේ ඉලක්කම් බලන්න: 7, 4, 8. කුඩාම ඉලක්කම පළමුවට තබන්න.',
        hintLevel2: '47 (දහය 4) ➔ 74 (දහය 7) ➔ 81 (දහය 8) ලෙස පටිපාටිගත කරන්න.',
        explanation: 'දහයස්ථානයෙන්: 4 < 7 < 8 බැවින් ආරෝහණ පිළිවෙළ 47 ➔ 74 ➔ 81 වේ.',
        skillTag: 'ascending_order',
        difficulty: 2,
      ),

      // Challenge 3: Descending Ordering Drag
      NumberTrainChallengeModel(
        id: 'c2_ch3',
        conceptId: 'c2_number_train_ordering',
        challengeNumber: 3,
        interactionType: NumberTrainInteractionType.carriageSorting,
        title: 'අභියෝගය 3: දුම්රිය ආපසු හරවමු',
        questionText: 'විශාලම සංඛ්‍යාවේ සිට කුඩාම සංඛ්‍යාව දක්වා (අවරෝහණ පිළිවෙළට) සකස් කරන්න.',
        numbers: ['95', '63', '88'],
        correctAnswer: '95,88,63',
        hintLevel1: 'අවරෝහණ පිළිවෙළ යනු විශාලම සිට කුඩාම දක්වාය. විශාලම සංඛ්‍යාව පළමුවට තබන්න.',
        hintLevel2: '95 (දහය 9) ➔ 88 (දහය 8) ➔ 63 (දහය 6) ලෙස අවරෝහණ පිළිවෙළට සකස් කරන්න.',
        explanation: 'දහයස්ථානයෙන්: 9 > 8 > 6 බැවින් අවරෝහණ පිළිවෙළ 95 ➔ 88 ➔ 63 වේ.',
        skillTag: 'descending_order',
        difficulty: 2,
      ),

      // Challenge 4: Guided Ascending Comparison
      NumberTrainChallengeModel(
        id: 'c2_ch4',
        conceptId: 'c2_number_train_ordering',
        challengeNumber: 4,
        interactionType: NumberTrainInteractionType.carriageOrdering,
        title: 'අභියෝගය 4: ස්ථානීය අගය ඉලක්කම් කියවමු',
        questionText: 'මෙම සංඛ්‍යා ආරෝහණ පිළිවෙළට පෙළගස්වන්න.',
        numbers: ['412', '489', '450'],
        correctAnswer: '412,450,489',
        hintLevel1: 'සියලුම සංඛ්‍යාවල සියයස්ථානයේ 4 ඇත. එබැවින් දහයස්ථානය සසඳන්න.',
        hintLevel2: 'දහයස්ථානයේ 1, 8, 5 ඇත. ඒවා කුඩාම සිට විශාලමට පෙළගස්වන්න.',
        explanation: 'සියයස්ථාන සමාන නිසා දහයස්ථානය සසඳමු: 1 < 5 < 8 බැවින් පිළිවෙළ 412 ➔ 450 ➔ 489 වේ.',
        skillTag: 'guided_ascending_comparison',
        difficulty: 2,
      ),

      // Challenge 5: 3-Digit Ascending Ordering
      NumberTrainChallengeModel(
        id: 'c2_ch5',
        conceptId: 'c2_number_train_ordering',
        challengeNumber: 5,
        interactionType: NumberTrainInteractionType.carriageOrdering,
        title: 'අභියෝගය 5: මැදිරි පේළිගත කරමු',
        questionText: 'කුඩාම සංඛ්‍යාවේ සිට විශාලම සංඛ්‍යාව දක්වා දුම්රිය මැදිරි සකස් කරන්න.',
        numbers: ['805', '621', '799'],
        correctAnswer: '621,799,805',
        hintLevel1: 'සියයස්ථානය බලන්න: 8, 6, 7. කුඩාම සියයස්ථානය කුමක්ද?',
        hintLevel2: '621 (සියය 6) පළමුවත්, 799 (සියය 7) දෙවනුවත් පැමිණේ.',
        explanation: 'සියයස්ථාන සසඳන විට: 6 < 7 < 8 බැවින් ආරෝහණ පිළිවෙළ 621 ➔ 799 ➔ 805 වේ.',
        skillTag: 'ascending_order_3digit',
        difficulty: 2,
      ),

      // Challenge 6: 4-Digit Descending Mastery
      NumberTrainChallengeModel(
        id: 'c2_ch6',
        conceptId: 'c2_number_train_ordering',
        challengeNumber: 6,
        interactionType: NumberTrainInteractionType.masteryOrdering,
        title: 'අභියෝගය 6: මහා දුම්රිය ජයග්‍රහණය! 🏆',
        questionText: 'මෙම සංඛ්‍යා තුන අවරෝහණ පිළිවෙළට (විශාලම සිට කුඩාමට) සකස් කරන්න.',
        numbers: ['5240', '2980', '5610'],
        correctAnswer: '5610,5240,2980',
        hintLevel1: 'දහස්ස්ථානය බලන්න: 5, 2, 5. විශාලම දහස්ස්ථානය 5 වේ.',
        hintLevel2: '5,610 සහ 5,240 හි දහස් 5 බැවින් සියයස්ථානය බලන්න: 600 > 200 වේ.',
        explanation: 'දහස්ස්ථානයෙන් 5 > 2 වේ. 5,610 සහ 5,240 හි සියයස්ථානය සසඳන විට 6 > 2 වේ. අනුපිළිවෙළ: 5,610 ➔ 5,240 ➔ 2,980.',
        skillTag: 'descending_order_4digit',
        difficulty: 3,
      ),
    ],
  );

  /// Concept 3: "තෙවන නැවතුම – ඉලක්කම් පත්‍ර දුම්රිය"
  static const NumberTrainConceptModel concept3 = NumberTrainConceptModel(
    id: 'c3_digit_card_train',
    title: 'තෙවන නැවතුම – ඉලක්කම් පත්‍ර දුම්රිය',
    subtitle: 'ඉලක්කම් පත්වලින් සංඛ්‍යා හදමු',
    learningObjective: '0-9 ඉලක්කම් පත් භාවිත කර සංඛ්‍යා නිර්මාණය සහ සංසන්දනය',
    stationBgAsset: MathsAssets.bgTrainInterior,
    interiorBgAsset: MathsAssets.bgTrainInterior,
    storyBeats: [
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.leo,
        speakerNameSi: 'ලියෝ 🦁',
        dialogueSi: 'අපිට අලුත් දුම්රිය මැදිරි හමු වුණා! ඒත් ඒවායේ අංක තවම සකස් කරලා නැහැ.',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.ella,
        speakerNameSi: 'එළි 🐘',
        dialogueSi: 'මෙන්න 0 සිට 9 දක්වා ඉලක්කම් පත්! මේවා භාවිත කරලා අපිට අලුත් සංඛ්‍යා හදන්න පුළුවන්.',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.felix,
        speakerNameSi: 'ෆීලික්ස් 🦊',
        dialogueSi: 'හහ්! මම නම් ඕනෑම ඉලක්කම් ටිකක් අරගෙන ලොකුම සංඛ්‍යාව හදනවා!',
        isInteractiveChoice: true,
        choicePromptSi: '2, 5, 9, 7 භාවිත කර සෑදිය හැකි විශාලම සංඛ්‍යාව කුමක්ද?',
        wrongOptionText: '2579 (ෆීලික්ස්)',
        correctOptionText: '9752 (නිවැරදි)',
        wrongFeedbackSi: 'ෆීලික්ස් වැරදියි! විශාලම සංඛ්‍යාව සෑදීමට විශාලම ඉලක්කම මුලට තබන්න!',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.ella,
        speakerNameSi: 'එළි 🐘',
        dialogueSi: 'හොඳයි! හැබැයි ඉලක්කම්වල පිහිටීම වෙනස් කළොත් සංඛ්‍යාවේ අගයත් වෙනස් වෙනවා.',
      ),
    ],
    challenges: [
      // Challenge 1: Digit Builder
      NumberTrainChallengeModel(
        id: 'c3_ch1',
        conceptId: 'c3_digit_card_train',
        challengeNumber: 1,
        interactionType: NumberTrainInteractionType.digitBuilder,
        title: 'අභියෝගය 1: සංඛ්‍යාව සාදන්න',
        questionText: 'මෙම ඉලක්කම් භාවිත කර 6431 සංඛ්‍යාව සාදන්න.',
        numbers: ['4', '6', '1', '3'],
        correctAnswer: '6431',
        hintLevel1: 'ඉලක්කම් හතර නිවැරදි ස්ථානවලට තබන්න.',
        hintLevel2: 'හදන්න ඕනේ 6431. මුලින් 6 තබන්න.',
        explanation: '6 දහස්ස්ථානයේ, 4 සියයස්ථානයේ, 3 දහයස්ථානයේ සහ 1 ඒකස්ථානයේ ඇත.',
        skillTag: 'digit_construction',
        difficulty: 1,
      ),

      // Challenge 2: Train Cards
      NumberTrainChallengeModel(
        id: 'c3_ch2',
        conceptId: 'c3_digit_card_train',
        challengeNumber: 2,
        interactionType: NumberTrainInteractionType.digitBuilder,
        title: 'අභියෝගය 2: දුම්රිය පත් සාදමු',
        questionText: 'දුම්රිය මැදිරියේ අංකය 5,284 විය යුතුයි. ඉලක්කම් පත් නිවැරදි අනුපිළිවෙළට තබන්න.',
        numbers: ['8', '5', '4', '2'],
        correctAnswer: '5284',
        hintLevel1: 'මුලින්ම දහස්ස්ථානය ගැන සිතන්න.',
        hintLevel2: '5 ➔ 2 ➔ 8 ➔ 4 ලෙස තබන්න.',
        explanation: '5 දහස් + 2 සිය + 8 දහය + 4 ඒක = 5284 වේ.',
        skillTag: 'card_placement',
        difficulty: 1,
      ),

      // Challenge 3: Make the Largest
      NumberTrainChallengeModel(
        id: 'c3_ch3',
        conceptId: 'c3_digit_card_train',
        challengeNumber: 3,
        interactionType: NumberTrainInteractionType.digitBuilder,
        title: 'අභියෝගය 3: විශාලම සංඛ්‍යාව සාදමු',
        questionText: 'මෙම ඉලක්කම් හතරෙන් (3, 8, 1, 6) සෑදිය හැකි විශාලම සංඛ්‍යාව සාදන්න.',
        numbers: ['3', '8', '1', '6'],
        correctAnswer: '8631',
        hintLevel1: 'විශාලම ඉලක්කම මුලට තබන්න.',
        hintLevel2: '8 පළමුවත්, ඉන් පසු 6, 3, 1ත් තබන්න.',
        explanation: 'විශාලම සංඛ්‍යාව සෑදීමට ඉලක්කම් විශාලතම එකේ සිට කුඩාම එක දක්වා තැබිය හැක (8631).',
        skillTag: 'make_largest_number',
        difficulty: 2,
      ),

      // Challenge 4: Make the Smallest
      NumberTrainChallengeModel(
        id: 'c3_ch4',
        conceptId: 'c3_digit_card_train',
        challengeNumber: 4,
        interactionType: NumberTrainInteractionType.digitBuilder,
        title: 'අභියෝගය 4: කුඩාම සංඛ්‍යාව සාදමු',
        questionText: 'මෙම ඉලක්කම් හතරෙන් (7, 2, 9, 4) සෑදිය හැකි කුඩාම සංඛ්‍යාව සාදන්න.',
        numbers: ['7', '2', '9', '4'],
        correctAnswer: '2479',
        hintLevel1: 'කුඩාම ඉලක්කම මුලට තබන්න.',
        hintLevel2: '2 ➔ 4 ➔ 7 ➔ 9 ලෙස තැබීමෙන් කුඩාම සංඛ්‍යාව ලැබේ.',
        explanation: 'කුඩාම සංඛ්‍යාව සෑදීමට ඉලක්කම් කුඩාම එකේ සිට විශාලම එක දක්වා තැබිය හැක (2479).',
        skillTag: 'make_smallest_number',
        difficulty: 2,
      ),

      // Challenge 5: Which Train is Larger?
      NumberTrainChallengeModel(
        id: 'c3_ch5',
        conceptId: 'c3_digit_card_train',
        challengeNumber: 5,
        interactionType: NumberTrainInteractionType.tapSelection,
        title: 'අභියෝගය 5: කුමන දුම්රිය විශාලද?',
        questionText: 'කුමන දුම්රිය මැදිරියේ අංකය විශාලද? (6842 vs 6482)',
        numbers: ['6842', '6482'],
        correctAnswer: '6842',
        hintLevel1: 'මුලින්ම දහස්ස්ථානය බලන්න. දෙකෙහිම 6 ඇත.',
        hintLevel2: 'දැන් සියයස්ථානය බලන්න: 8 > 4 වේ. එනිසා 6842 විශාල වේ.',
        explanation: 'දහස්ස්ථාන 6=6 වේ. සියයස්ථානයේ 8 > 4 බැවින් 6842 > 6482 වේ.',
        skillTag: 'compare_constructed_numbers',
        difficulty: 2,
      ),

      // Challenge 6: Master Train Builder
      NumberTrainChallengeModel(
        id: 'c3_ch6',
        conceptId: 'c3_digit_card_train',
        challengeNumber: 6,
        interactionType: NumberTrainInteractionType.digitBuilder,
        title: 'අභියෝගය 6: මහා ඉලක්කම් ශූරයා! 🏆',
        questionText: '1, 4, 7, 2, 9 ඉලක්කම් භාවිත කර සෑදිය හැකි විශාලම ඉලක්කම් 5 සංඛ්‍යාව සාදන්න.',
        numbers: ['1', '4', '7', '2', '9'],
        correctAnswer: '97421',
        hintLevel1: 'ඉලක්කම් 5 විශාලම එකේ සිට කුඩාම එක දක්වා සකස් කරන්න.',
        hintLevel2: '9 ➔ 7 ➔ 4 ➔ 2 ➔ 1 අනුපිළිවෙලට තබන්න.',
        explanation: '97,421 යනු මෙම ඉලක්කම් 5න් සෑදිය හැකි විශාලම 5-digit සංඛ්‍යාවයි!',
        skillTag: 'master_digit_builder',
        difficulty: 3,
      ),
    ],
  );

  /// Concept 4: "හතරවන නැවතුම – දහස් කඳුකරය"
  static const NumberTrainConceptModel concept4 = NumberTrainConceptModel(
    id: 'c4_thousands_mountain',
    title: 'හතරවන නැවතුම – දහස් කඳුකරය',
    subtitle: '4 සහ 5 ඉලක්කම් සංඛ්‍යා සසඳමු',
    learningObjective: '99,999 දක්වා 4 සහ 5 ඉලක්කම් සංඛ්‍යා සසඳමින් දසදහස්ස්ථානය හඳුනාගැනීම',
    stationBgAsset: MathsAssets.bgTrainMountainStation,
    interiorBgAsset: MathsAssets.bgTrainMountainStation,
    storyBeats: [
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.leo,
        speakerNameSi: 'ලියෝ 🦁',
        dialogueSi: 'වාව්! අපි දහස් කඳුකරයට ඇවිල්ලා!',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.ella,
        speakerNameSi: 'එළි 🐘',
        dialogueSi: 'මෙතැන තියෙන සංඛ්‍යා 4 සහ 5 ඉලක්කම් සංඛ්‍යා. ඒවා හොඳින් සසඳන්න ඕනේ.',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.felix,
        speakerNameSi: 'ෆීලික්ස් 🦊',
        dialogueSi: 'මට නම් 18,508 ලොකුයි වගේ!',
        isInteractiveChoice: true,
        choicePromptSi: '18,508, 33,240, 61,088 අතරින් විශාලම සංඛ්‍යාව කුමක්ද?',
        wrongOptionText: '18,508 (ෆීලික්ස්)',
        correctOptionText: '61,088 (නිවැරදි)',
        wrongFeedbackSi: 'අයියෝ! මම වැරදුණා! දසදහස්ස්ථානයේ 6 > 1 වේ!',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.ella,
        speakerNameSi: 'එළි 🐘',
        dialogueSi: 'පළමුව දසදහස්ස්ථානය බලමු. එතැනින් පටන් ගත්තොත් පහසුයි!',
      ),
    ],
    challenges: [
      // Challenge 1: Mountain Sign
      NumberTrainChallengeModel(
        id: 'c4_ch1',
        conceptId: 'c4_thousands_mountain',
        challengeNumber: 1,
        interactionType: NumberTrainInteractionType.tapSelection,
        title: 'අභියෝගය 1: කඳුකර සංඛ්‍යා පුවරුව',
        questionText: '18,508, 33,240, 61,088 අතරින් විශාලම සංඛ්‍යාව සොයන්න.',
        numbers: ['18508', '33240', '61088'],
        correctAnswer: '61088',
        hintLevel1: 'දසදහස්ස්ථානය බලන්න: 1, 3, 6.',
        hintLevel2: '1, 3, 6 අතරින් 6 විශාලමයි. ඒ නිසා 61,088 විශාලම වේ.',
        explanation: 'දසදහස්ස්ථානයේ 6 > 3 > 1 බැවින් 61,088 විශාලම සංඛ්‍යාව වේ.',
        skillTag: 'mountain_largest_number',
        difficulty: 1,
      ),

      // Challenge 2: Expanded Form Train
      NumberTrainChallengeModel(
        id: 'c4_ch2',
        conceptId: 'c4_thousands_mountain',
        challengeNumber: 2,
        interactionType: NumberTrainInteractionType.carriageOrdering,
        title: 'අභියෝගය 2: විස්තරාත්මක සටහන් දුම්රිය',
        questionText: '33,240 හි විස්තරාත්මක සටහන සාදන්න: 30,000 + 3,000 + 200 + 40 + 0',
        numbers: ['200', '30000', '40', '3000', '0'],
        correctAnswer: '30000,3000,200,40,0',
        hintLevel1: 'සෑම ඉලක්කමකම ස්ථානීය අගය වෙන වෙනම බලන්න.',
        hintLevel2: '33,240 = 30,000 + 3,000 + 200 + 40 + 0',
        explanation: '33,240 = 30,000 (දසදහස්) + 3,000 (දහස්) + 200 (සිය) + 40 (දහය) + 0 (ඒක).',
        skillTag: 'expanded_form_5digit',
        difficulty: 2,
      ),

      // Challenge 3: Equal Ten-Thousands
      NumberTrainChallengeModel(
        id: 'c4_ch3',
        conceptId: 'c4_thousands_mountain',
        challengeNumber: 3,
        interactionType: NumberTrainInteractionType.carriageOrdering,
        title: 'අභියෝගය 3: සමාන දසදහස්ස්ථාන',
        questionText: 'මෙම සංඛ්‍යා තුන කුඩාම සිට විශාලම දක්වා (ආරෝහණ පිළිවෙළට) සකස් කරන්න.',
        numbers: ['45600', '48200', '42900'],
        correctAnswer: '42900,45600,48200',
        hintLevel1: 'දසදහස්ස්ථානයේ ඉලක්කම් තුනේම 4යි.',
        hintLevel2: 'දහස්ස්ථානය බලන්න: 2, 5, 8. 42,900 පළමුවට තබන්න.',
        explanation: 'දසදහස්ස්ථාන සමාන නිසා දහස්ස්ථානයෙන්: 2 < 5 < 8 ➔ 42,900 < 45,600 < 48,200.',
        skillTag: 'equal_ten_thousands_comparison',
        difficulty: 2,
      ),

      // Challenge 4: Value Detector
      NumberTrainChallengeModel(
        id: 'c4_ch4',
        conceptId: 'c4_thousands_mountain',
        challengeNumber: 4,
        interactionType: NumberTrainInteractionType.tapSelection,
        title: 'අභියෝගය 4: ස්ථානීය අගය සෙවීම',
        questionText: '76,405 හි 7 ඉලක්කමෙන් දැක්වෙන අගය කීයද?',
        numbers: ['70,000 (දසදහස්ස්ථානය)', '7,000 (දහස්ස්ථානය)', '700 (සියයස්ථානය)'],
        correctAnswer: '70,000 (දසදහස්ස්ථානය)',
        hintLevel1: '7 තිබෙන්නේ කුමන ස්ථානයේදැයි බලන්න.',
        hintLevel2: '7 තිබෙන්නේ දසදහස්ස්ථානයේය. එනිසා එහි අගය 70,000 වේ.',
        explanation: '76,405 හි 7 දසදහස්ස්ථානයේ පිහිටන බැවින් එහි අගය 70,000 වේ.',
        skillTag: 'value_detector',
        difficulty: 2,
      ),

      // Challenge 5: Mountain Train Sort
      NumberTrainChallengeModel(
        id: 'c4_ch5',
        conceptId: 'c4_thousands_mountain',
        challengeNumber: 5,
        interactionType: NumberTrainInteractionType.carriageSorting,
        title: 'අභියෝගය 5: කඳුකර දුම්රිය පේළිගත කිරීම',
        questionText: 'විශාලම සංඛ්‍යාවේ සිට කුඩාම සංඛ්‍යාව දක්වා (අවරෝහණ පිළිවෙළට) මැදිරි සකස් කරන්න.',
        numbers: ['54543', '14628', '76500'],
        correctAnswer: '76500,54543,14628',
        hintLevel1: 'දසදහස්ස්ථානය බලන්න: 7, 5, 1.',
        hintLevel2: '7 > 5 > 1 නිසා 76,500 පළමුව, 54,543 දෙවනුව, 14,628 අවසානයේ.',
        explanation: 'දසදහස්ස්ථානයෙන් 7 > 5 > 1 බැවින් අවරෝහණ පිළිවෙළ 76,500 ➔ 54,543 ➔ 14,628 වේ.',
        skillTag: 'descending_mountain_sort',
        difficulty: 2,
      ),

      // Challenge 6: Mountain Master
      NumberTrainChallengeModel(
        id: 'c4_ch6',
        conceptId: 'c4_thousands_mountain',
        challengeNumber: 6,
        interactionType: NumberTrainInteractionType.masteryOrdering,
        title: 'අභියෝගය 6: දහස් කඳුකර ශූරයා! 🏆',
        questionText: 'මෙම සංඛ්‍යා 5 කුඩාම සිට විශාලම දක්වා (ආරෝහණ පිළිවෙළට) සකස් කරන්න.',
        numbers: ['18508', '33240', '61088', '47205', '52010'],
        correctAnswer: '18508,33240,47205,52010,61088',
        hintLevel1: 'දසදහස්ස්ථාන බලන්න: 1, 3, 6, 4, 5.',
        hintLevel2: 'කුඩාම සිට විශාලමට දසදහස්ස්ථාන පෙළගස්වන්න: 1 ➔ 3 ➔ 4 ➔ 5 ➔ 6.',
        explanation: 'දසදහස්ස්ථාන අනුව ආරෝහණ පිළිවෙළ: 18,508 ➔ 33,240 ➔ 47,205 ➔ 52,010 ➔ 61,088.',
        skillTag: 'mountain_master_5digit',
        difficulty: 3,
      ),
    ],
  );

  /// Concept 5: "පස්වන නැවතුම – අභියෝග දුම්රිය"
  static const NumberTrainConceptModel concept5 = NumberTrainConceptModel(
    id: 'c5_challenge_train',
    title: 'පස්වන නැවතුම – අභියෝග දුම්රිය',
    subtitle: 'සංඛ්‍යා අභියෝග ජයගමු',
    learningObjective: 'ස්ථානීය අගය සහ සංඛ්‍යා සංසන්දන නීති භාවිතයෙන් අභියෝග විසඳීම',
    stationBgAsset: MathsAssets.bgTrainStormTunnel,
    interiorBgAsset: MathsAssets.bgTrainStormTunnel,
    storyBeats: [
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.leo,
        speakerNameSi: 'ලියෝ 🦁',
        dialogueSi: 'අපි දැන් සංඛ්‍යා අභියෝග දුම්රියට ළඟා වෙලා!',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.ella,
        speakerNameSi: 'එළි 🐘',
        dialogueSi: 'මෙතැනින් පස්සේ ප්‍රශ්න ටික ටික අමාරු වෙනවා. අපි කලින් ඉගෙනගත්ත හැම දෙයක්ම භාවිත කරන්න වෙයි.',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.felix,
        speakerNameSi: 'ෆීලික්ස් 🦊',
        dialogueSi: 'අමාරුද? හහ්! මට නම් මේක ලේසියි!',
        isInteractiveChoice: true,
        choicePromptSi: '12,450, 21,450, 19,999 අතරින් විශාලම සංඛ්‍යාව කුමක්ද?',
        wrongOptionText: '19,999 (ෆීලික්ස්)',
        correctOptionText: '21,450 (නිවැරදි)',
        wrongFeedbackSi: 'ෆීලික්ස් වැරදියි! දසදහස්ස්ථානයේ 2 > 1 නිසා 21,450 විශාලයි!',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.ella,
        speakerNameSi: 'එළි 🐘',
        dialogueSi: 'ඉක්මනින් තෝරන්න එපා Felix! පළමුව දසදහස්ස්ථානය බලමු.',
      ),
    ],
    challenges: [
      // Challenge 1: Number Signal
      NumberTrainChallengeModel(
        id: 'c5_ch1',
        conceptId: 'c5_challenge_train',
        challengeNumber: 1,
        interactionType: NumberTrainInteractionType.tapSelection,
        title: 'අභියෝගය 1: දුම්රිය සංඥා පුවරුව',
        questionText: 'විශාලම සංඛ්‍යාව ඇති දුම්රිය තෝරන්න.',
        numbers: ['12450', '21450', '19999'],
        correctAnswer: '21450',
        hintLevel1: 'මුලින්ම දසදහස්ස්ථානය බලන්න: 1, 2, 1.',
        hintLevel2: '2 > 1 නිසා 21,450 විශාලයි.',
        explanation: 'දසදහස්ස්ථානයෙන් 2 > 1 බැවින් 21,450 විශාලම සංඛ්‍යාව වේ.',
        skillTag: 'signal_largest_number',
        difficulty: 2,
      ),

      // Challenge 2: Find the Last Train
      NumberTrainChallengeModel(
        id: 'c5_ch2',
        conceptId: 'c5_challenge_train',
        challengeNumber: 2,
        interactionType: NumberTrainInteractionType.ticketDrag,
        title: 'අභියෝගය 2: කුඩාම සංඛ්‍යාව සොයමු',
        questionText: 'කුඩාම සංඛ්‍යාව දුම්රිය නැවතුම් ස්ථානයට ඇදගෙන යන්න.',
        numbers: ['9876', '10205', '8999', '10025'],
        correctAnswer: '8999',
        hintLevel1: 'මුලින් සංඛ්‍යාවල ඉලක්කම් ගණන බලන්න.',
        hintLevel2: 'ඉලක්කම් 4ක් ඇති සංඛ්‍යා 5ක් ඇති සංඛ්‍යාවලට වඩා කුඩා විය හැක. 8,999 < 10,025.',
        explanation: '8,999 ඉලක්කම් 4ක සංඛ්‍යාවක් වන අතර අනෙක්වා ඉලක්කම් 5ක සංඛ්‍යා වේ. එනිසා 8,999 කුඩාම වේ.',
        skillTag: 'digit_count_comparison',
        difficulty: 2,
      ),

      // Challenge 3: Same Mountain, Different Height
      NumberTrainChallengeModel(
        id: 'c5_ch3',
        conceptId: 'c5_challenge_train',
        challengeNumber: 3,
        interactionType: NumberTrainInteractionType.carriageOrdering,
        title: 'අභියෝගය 3: සමාන මුලාරම්භය, වෙනස් අගයන්',
        questionText: 'මෙම සංඛ්‍යා තුන කුඩාම සිට විශාලම දක්වා (ආරෝහණ පිළිවෙළට) සකස් කරන්න.',
        numbers: ['52430', '52340', '52403'],
        correctAnswer: '52340,52403,52430',
        hintLevel1: 'පළමු ඉලක්කම් දෙක සමානයි (52). ඊළඟ ස්ථානය (සියයස්ථානය) බලන්න.',
        hintLevel2: '52,403 සහ 52,430 දෙකේ සියයස්ථානය 4යි. දැන් දහයස්ථානය බලන්න: 0 < 3.',
        explanation: 'සියයස්ථානයෙන් 3 < 4 බැවින් 52,340 කුඩාම වේ. 52,403 සහ 52,430 හි දහයස්ථානයෙන් 0 < 3 වේ.',
        skillTag: 'deep_place_value_ordering',
        difficulty: 3,
      ),

      // Challenge 4: Number Detective
      NumberTrainChallengeModel(
        id: 'c5_ch4',
        conceptId: 'c5_challenge_train',
        challengeNumber: 4,
        interactionType: NumberTrainInteractionType.tapSelection,
        title: 'අභියෝගය 4: සංඛ්‍යා රහස් පරීක්ෂක 🕵️‍♂️',
        questionText: 'හෝඩුවාවලට (6 දසදහස්, 2 දහස්, 5 සිය) ගැළපෙන සංඛ්‍යාව සොයා තෝරන්න.',
        numbers: ['62507', '62057', '65207', '52607'],
        correctAnswer: '62507',
        hintLevel1: 'දසදහස්ස්ථානයේ 6 සහ දහස්ස්ථානයේ 2 ඇති සංඛ්‍යාව සොයන්න.',
        hintLevel2: '62,507 හි 6 | 2 | 5 | 0 | 7 ලෙස ඉලක්කම් පිහිටා ඇත.',
        explanation: '62,507 හි දසදහස් 6, දහස් 2, සිය 5, දහය 0 සහ ඒක 7 පිහිටා ඇත.',
        skillTag: 'detective_place_value',
        difficulty: 2,
      ),

      // Challenge 5: Reverse the Train
      NumberTrainChallengeModel(
        id: 'c5_ch5',
        conceptId: 'c5_challenge_train',
        challengeNumber: 5,
        interactionType: NumberTrainInteractionType.carriageSorting,
        title: 'අභියෝගය 5: දුම්රිය ආපසු හරවමු 🔄',
        questionText: 'දුම්රිය ආපසු ගමන් කරයි. සංඛ්‍යා විශාලම සිට කුඩාම දක්වා (අවරෝහණ පිළිවෙළට) සකස් කරන්න.',
        numbers: ['45210', '54201', '40512', '52410'],
        correctAnswer: '54201,52410,45210,40512',
        hintLevel1: 'අවරෝහණ පිළිවෙළ කියන්නේ විශාලම සිට කුඩාම දක්වායි.',
        hintLevel2: 'දසදහස්ස්ථානයේ 5 ඇති සංඛ්‍යා (54,201 සහ 52,410) පළමුව සසඳන්න.',
        explanation: 'දසදහස්ස්ථානයෙන් 5 > 4 වේ. 54,201 > 52,410 > 45,210 > 40,512.',
        skillTag: 'reverse_carriage_sorting',
        difficulty: 3,
      ),

      // Challenge 6: Challenge Train Mastery
      NumberTrainChallengeModel(
        id: 'c5_ch6',
        conceptId: 'c5_challenge_train',
        challengeNumber: 6,
        interactionType: NumberTrainInteractionType.masteryOrdering,
        title: 'අභියෝගය 6: මහා අභියෝග දුම්රිය! 🏆',
        questionText: 'මෙම සංඛ්‍යා 5 කුඩාම සිට විශාලම දක්වා (ආරෝහණ පිළිවෙළට) සකස් කරන්න.',
        numbers: ['27540', '72405', '27450', '70245', '25740'],
        correctAnswer: '25740,27450,27540,70245,72405',
        hintLevel1: 'කුඩාම දසදහස්ස්ථානය 2 ඇති සංඛ්‍යා (25,740, 27,450, 27,540) මුලින්ම සසඳන්න.',
        hintLevel2: '25,740 < 27,450 < 27,540 < 70,245 < 72,405.',
        explanation: 'අනුපිළිවෙළ: 25,740 ➔ 27,450 ➔ 27,540 ➔ 70,245 ➔ 72,405.',
        skillTag: 'challenge_mastery_5digit',
        difficulty: 3,
      ),
    ],
  );

  /// Concept 6: "හයවන නැවතුම – මහා සංඛ්‍යා දුම්රියේ අවසන් ගමන"
  static const NumberTrainConceptModel concept6 = NumberTrainConceptModel(
    id: 'c6_great_number_train_mastery',
    title: 'හයවන නැවතුම – මහා සංඛ්‍යා දුම්රියේ අවසන් ගමන',
    subtitle: 'මහා ගණිත ශූරතාවය',
    learningObjective: 'පාඩම පුරා ඉගෙනගත් සියලු සංඛ්‍යා සංසන්දන සහ පටිපාටිගත කිරීමේ කුසලතා පූර්ණ ලෙස ප්‍රගුණ කිරීම',
    stationBgAsset: MathsAssets.bgTrainFinalStation,
    interiorBgAsset: MathsAssets.bgTrainFinalStation,
    storyBeats: [
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.leo,
        speakerNameSi: 'ලියෝ 🦁',
        dialogueSi: 'අපි අවසන් නැවතුමට ආවා!',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.ella,
        speakerNameSi: 'එළි 🐘',
        dialogueSi: 'මේ තමයි මහා සංඛ්‍යා දුම්රියේ අවසන් අභියෝගය.',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.felix,
        speakerNameSi: 'ෆීලික්ස් 🦊',
        dialogueSi: 'අන්තිම එකද? මේකත් මම ලේසියෙන්ම ජයගන්නවා!',
        isInteractiveChoice: true,
        choicePromptSi: '24,875, 42,578, 24,785 අතරින් විශාලම සංඛ්‍යාව කුමක්ද?',
        wrongOptionText: '24,875 (ෆීලික්ස්)',
        correctOptionText: '42,578 (නිවැරදි)',
        wrongFeedbackSi: 'ෆීලික්ස් වැරදියි! 42,578 හි දසදහස්ස්ථානයේ 4 ඇත (4 > 2)!',
      ),
      NumberTrainStoryBeatModel(
        speaker: TrainStorySpeaker.ella,
        speakerNameSi: 'එළි 🐘',
        dialogueSi: 'අපි කලින් ඉගෙනගත්ත නීති හැම එකක්ම මතක තියාගෙන බලමු.',
      ),
    ],
    challenges: [
      // Challenge 1: The Final Ticket
      NumberTrainChallengeModel(
        id: 'c6_ch1',
        conceptId: 'c6_great_number_train_mastery',
        challengeNumber: 1,
        interactionType: NumberTrainInteractionType.tapSelection,
        title: 'අභියෝගය 1: අවසන් දුම්රිය ටිකට්පත 🎟️',
        questionText: 'අවසන් දුම්රියට යාමට අවශ්‍ය විශාලම අංකය සහිත ටිකට්පත තෝරන්න.',
        numbers: ['38421', '83214', '48321'],
        correctAnswer: '83214',
        hintLevel1: 'දසදහස්ස්ථාන සසඳන්න: 3, 8, 4.',
        hintLevel2: '83,214 හි දසදහස් 8 විශාලතම වේ.',
        explanation: 'දසදහස්ස්ථානයේ 8 > 4 > 3 බැවින් 83,214 විශාලම ටිකට්පත වේ.',
        skillTag: 'final_ticket_largest',
        difficulty: 2,
      ),

      // Challenge 2: Five-Carriage Order
      NumberTrainChallengeModel(
        id: 'c6_ch2',
        conceptId: 'c6_great_number_train_mastery',
        challengeNumber: 2,
        interactionType: NumberTrainInteractionType.carriageOrdering,
        title: 'අභියෝගය 2: මැදිරි 4ක අනුපිළිවෙල 🚃',
        questionText: 'දුම්රිය මැදිරි කුඩාම සිට විශාලම දක්වා (ආරෝහණ පිළිවෙළට) සකස් කරන්න.',
        numbers: ['15620', '51206', '25160', '12560'],
        correctAnswer: '12560,15620,25160,51206',
        hintLevel1: 'දසදහස්ස්ථාන බලන්න: 1, 5, 2, 1.',
        hintLevel2: '12,560 සහ 15,620 හි දහස්ස්ථානය බලන්න: 2 < 5. 12,560 පළමුවට තබන්න.',
        explanation: 'ආරෝහණ පිළිවෙළ: 12,560 ➔ 15,620 ➔ 25,160 ➔ 51,206.',
        skillTag: 'final_carriage_ordering',
        difficulty: 3,
      ),

      // Challenge 3: The Equal Signal
      NumberTrainChallengeModel(
        id: 'c6_ch3',
        conceptId: 'c6_great_number_train_mastery',
        challengeNumber: 3,
        interactionType: NumberTrainInteractionType.tapSelection,
        title: 'අභියෝගය 3: සමාන සංඥා පුවරුව 🚥',
        questionText: 'මෙම සංඛ්‍යා තුනේ විශාලම සංඛ්‍යාව සොයන්න. (64,215 vs 64,251 vs 64,125)',
        numbers: ['64215', '64251', '64125'],
        correctAnswer: '64251',
        hintLevel1: 'දසදහස් සහ දහස් 64=64 සමානයි. සියයස්ථානය බලන්න: 2, 2, 1.',
        hintLevel2: '64,215 සහ 64,251 හි දහයස්ථානය සසඳන්න: 5 > 1 බැවින් 64,251 විශාලයි.',
        explanation: 'සියයස්ථානයෙන් 2 > 1 වේ. 64,215 සහ 64,251 හි දහයස්ථානයෙන් 5 > 1 බැවින් 64,251 විශාලම වේ.',
        skillTag: 'equal_leading_digits_mastery',
        difficulty: 3,
      ),

      // Challenge 4: The Expansion Bridge
      NumberTrainChallengeModel(
        id: 'c6_ch4',
        conceptId: 'c6_great_number_train_mastery',
        challengeNumber: 4,
        interactionType: NumberTrainInteractionType.tapSelection,
        title: 'අභියෝගය 4: විස්තරාත්මක පාලම 🌉',
        questionText: '70,406 හි 4 ඉලක්කමෙන් දැක්වෙන ස්ථානීය අගය කුමක්ද?',
        numbers: ['400 (සියයස්ථානය)', '4,000 (දහස්ස්ථානය)', '40 (දහයස්ථානය)'],
        correctAnswer: '400 (සියයස්ථානය)',
        hintLevel1: '70,406 හි 4 පිහිටන්නේ කුමන ස්ථානයේ දැයි බලන්න.',
        hintLevel2: '4 පිහිටන්නේ සියයස්ථානයේය. එනිසා එහි අගය 400 වේ.',
        explanation: '70,406 හි 4 සියයස්ථානයේ පිහිටන බැවින් එහි අගය 400 (සියයස්ථානය) වේ.',
        skillTag: 'expansion_bridge_place_value',
        difficulty: 2,
      ),

      // Challenge 5: The Final Route
      NumberTrainChallengeModel(
        id: 'c6_ch5',
        conceptId: 'c6_great_number_train_mastery',
        challengeNumber: 5,
        interactionType: NumberTrainInteractionType.carriageSorting,
        title: 'අභියෝගය 5: අවසන් ගමන් මාර්ගය 🗺️',
        questionText: 'මෙම සංඛ්‍යා 4 විශාලම සිට කුඩාම දක්වා (අවරෝහණ පිළිවෙළට) සකස් කරන්න.',
        numbers: ['91205', '19520', '90125', '91025'],
        correctAnswer: '91205,91025,90125,19520',
        hintLevel1: 'දසදහස්ස්ථාන බලන්න: 9, 1, 9, 9.',
        hintLevel2: '91,205 සහ 91,025 හි සියයස්ථානය සසඳන්න: 2 > 0 වේ.',
        explanation: 'අවරෝහණ පිළිවෙළ: 91,205 ➔ 91,025 ➔ 90,125 ➔ 19,520.',
        skillTag: 'final_route_descending',
        difficulty: 3,
      ),

      // Challenge 6: The Golden Final Run
      NumberTrainChallengeModel(
        id: 'c6_ch6',
        conceptId: 'c6_great_number_train_mastery',
        challengeNumber: 6,
        interactionType: NumberTrainInteractionType.masteryOrdering,
        title: 'අභියෝගය 6: මහා රන් දුම්රිය අවසන් ගමන! 👑',
        questionText: 'මෙම සංඛ්‍යා 5ම සම්පූර්ණයෙන් කුඩාම සිට විශාලම දක්වා (ආරෝහණ පිළිවෙළට) සකස් කරන්න.',
        numbers: ['74508', '47850', '74580', '70485', '47805'],
        correctAnswer: '47805,47850,70485,74508,74580',
        hintLevel1: '47,805 සහ 47,850 හි දහයස්ථානය බලන්න: 0 < 5.',
        hintLevel2: '74,508 සහ 74,580 හි දහයස්ථානය බලන්න: 0 < 8.',
        explanation: 'සම්පූර්ණ ආරෝහණ පිළිවෙළ: 47,805 ➔ 47,850 ➔ 70,485 ➔ 74,508 ➔ 74,580.',
        skillTag: 'golden_final_mastery_5digit',
        difficulty: 3,
      ),
    ],
  );

  /// All concepts for Lesson 2 progression
  static List<NumberTrainConceptModel> get allConcepts =>
      [concept1, concept2, concept3, concept4, concept5, concept6];
}
