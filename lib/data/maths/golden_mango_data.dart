import '../../models/maths/golden_mango_models.dart';

/// ============================================
/// GOLDEN MANGO STORY DATA
/// Complete story content for all 5 concepts (Localized into natural Sinhala)
/// ============================================
class GoldenMangoData {
  static const String lessonId = 'golden_mango_quest';
  static const String lessonTitle = 'Quest for the Golden Mango';
  static const String lessonTitleSi = 'රන් අඹ ගෙඩිය සොයා ගමන 🥭';
  static const int totalConcepts = 5;

  /// All 5 concepts in story order
  static const List<GoldenMangoConcept> concepts = [
    // ─── CONCEPT 1: THE JUNGLE MAP ───
    GoldenMangoConcept(
      id: 'c1_jungle_map',
      title: 'අංක කැලෑ සිතියම',
      learningObjective: '9,999 දක්වා සංඛ්‍යා කියවීම හා ලිවීම',
      learningObjectiveSi: '9,999 දක්වා සංඛ්‍යා කියවීම හා ලිවීම',
      backgroundAsset: 'assets/images/bg_c1_jungle_map.png',
      rewardText: 'පබළු ගඟ දෙසට ඇති මඟ විවෘත විය! 🌊',
      beats: [
        StoryBeat(
          speaker: StoryCharacter.leo,
          text:
              'මෙන්න බලන්න පැරණි සිතියමක්! රන් අඹ ගෙඩිය සොයායන පාර හොයාගන්න නම් 84, 101, 528 සහ 997 කියන අංක ඇති ගස් පසුකරගෙන යන්න ඕනේ!',
        ),
        StoryBeat(
          speaker: StoryCharacter.felix,
          text:
              'අපෝ... අංක කියවන්න මහන්සි වෙන්නේ ඇයි? ඇස් දෙක පියාගෙන කොළ තියෙන ඕනෑම ගහක් ළඟින් දුවමු!',
          animation: StoryAnimation.popIn,
        ),
        StoryBeat(
          speaker: StoryCharacter.ella,
          text:
              'අනේ ෆීලික්ස්, එහෙම කළොත් අපි මුළු කැලේම අතරමං වෙයි! 9,999 දක්වා සංඛ්‍යා නිවැරදිව කියවන්න සහ ලියන්න අපි දැනගන්න ඕනේ.',
        ),
        StoryBeat(
          speaker: StoryCharacter.ella,
          text:
              'යහළුවේ, නිවැරදි පාර තෝරාගන්න අපිට මේ අංක ටික කියවන්න උදව් කරනවද?',
          isFinal: true,
        ),
      ],
    ),

    // ─── CONCEPT 2: THE RIVER OF BEADS ───
    GoldenMangoConcept(
      id: 'c2_river_of_beads',
      title: 'පබළු ගඟ',
      learningObjective: 'ඉලක්කම් 4ක සංඛ්‍යාවල ස්ථානීය අගය',
      learningObjectiveSi: 'ඉලක්කම් 4ක සංඛ්‍යාවල ස්ථානීය අගය (ඒකස්ථානය, දහස්ථානය, සියස්ථානය, දහස්ස්ථානය)',
      backgroundAsset: 'assets/images/bg_c2_abacus_river.png',
      rewardText: 'පාලම නැවත සැකසුණා! ඝන කැලෑවට මඟ විවෘත විය! 🌳',
      beats: [
        StoryBeat(
          speaker: StoryCharacter.leo,
          text:
              'අනේ පාලම කැඩිලා! ඒත් බලන්න, මෙතන ඒකස්ථානය, දහස්ථානය, සියස්ථානය, සහ දහස්ස්ථානය කියලා කණු 4ක් තියෙනවා. අපි මේ ගල් කැට තියන්නේ කොහොමද?',
        ),
        StoryBeat(
          speaker: StoryCharacter.felix,
          text:
              'ඒක හරිම ලේසියි! හැම ගල් කැටයක්ම පළමු කණුවට දාමු! ගල් කැටයක් කියන්නේ ගල් කැටයක්නේ, කොතැන තිබ්බම මොකද?',
          animation: StoryAnimation.popIn,
        ),
        StoryBeat(
          speaker: StoryCharacter.ella,
          text:
              'ෆීලික්ස්, ස්ථානීය අගය ක්‍රියා කරන්නේ එහෙම නෙවෙයි! ගල් කැටයක් දහස්ස්ථානයට දැම්මම ඒකෙන් එකස්ථානයට වඩා ගොඩක් විශාල අගයක් නිරූපණය වෙනවා.',
        ),
        StoryBeat(
          speaker: StoryCharacter.ella,
          text:
              'යහළුවේ, පාලම නැවත හදන්න මේ ගල් කැට නිවැරදි කණුවල තියන්න අපිට උදව් කරනවද?',
          isFinal: true,
        ),
      ],
    ),

    // ─── CONCEPT 3: THE GIANT'S GATE ───
    GoldenMangoConcept(
      id: 'c3_giants_gate',
      title: 'යෝධයාගේ දොරටුව',
      learningObjective: '100,000 දක්වා සංඛ්‍යා කියවීම හා ලිවීම',
      learningObjectiveSi: '100,000 දක්වා සංඛ්‍යා කියවීම හා ලිවීම',
      backgroundAsset: 'assets/images/bg_c3_giant_gate.png',
      rewardText: 'මහා යෝධ ගල් දොරටුව විවෘත විය! රන් ගුහාවට මඟ ලැබුණි! 💎',
      beats: [
        StoryBeat(
          speaker: StoryCharacter.leo,
          text:
              'අම්මෝ, මේ දොරටුව කොච්චර විශාලද! දොරටුව අරින්න නම් 10,100 හෝ 25,602 වගේ මහා සංඛ්‍යාවක රහස් පදය කියන්න ඕනේ. මම මෙච්චර ලොකු අංක ගැන අහලා නෑ!',
        ),
        StoryBeat(
          speaker: StoryCharacter.felix,
          text:
              'හයියෙන් "දහයයි!" කියලා කෑගහමු! දොරටු ගොඩක් කැමතියි දහය කියන අංකයට. ඔය ඉතිරි ඉලක්කම් ගැන හිතන්න ඕනේ නෑ!',
          animation: StoryAnimation.popIn,
        ),
        StoryBeat(
          speaker: StoryCharacter.ella,
          text:
              'ඒක හරියන්නේ නෑ ෆීලික්ස්! මේවා සියක් දහස (100,000) දක්වා ඇති විශාල සංඛ්‍යා. දොරටුව අරින්න නම් අපි ඒවා නිවැරදිව කියවන්න ඕනේ.',
        ),
        StoryBeat(
          speaker: StoryCharacter.ella,
          text: 'යහළුවේ, නිවැරදි විශාල සංඛ්‍යාව හඳුනාගන්න අපිට උදව් කරනවද?',
          isFinal: true,
        ),
      ],
    ),

    // ─── CONCEPT 4: THE GLOWING PEDESTALS ───
    GoldenMangoConcept(
      id: 'c4_glowing_pedestals',
      title: 'දිදුලන වේදිකා',
      learningObjective: 'දසදහස්ස්ථානය ඇතුළු ස්ථානීය අගයන් හඳුනාගැනීම',
      learningObjectiveSi: 'දසදහස්ස්ථානය ඇතුළු ස්ථානීය අගයන් හඳුනාගැනීම',
      backgroundAsset: 'assets/images/bg_c4_cave_pedestals.png',
      rewardText:
          'වේදිකා සියල්ල රත්පැහැයෙන් දිදුලන්නට විය! අවසාන නිධන් පෙට්ටිය සොයාගන්නා ලදී! 🥭',
      beats: [
        StoryBeat(
          speaker: StoryCharacter.leo,
          text:
              'රහස් අංකය 68,507! ඒත් කෝකටද මේ ඉලක්කම් තියන්නේ? මෙතන දසදහස්ස්ථානය, දහස්ස්ථානය කියලා ස්ථානීය අගයන් තියෙනවා.',
        ),
        StoryBeat(
          speaker: StoryCharacter.felix,
          text:
              '6 තියන්න කුඩාම වේදිකාව උඩින්! 6 කියන්නේ කුඩා අංකයක්නේ, ඒක අන්තිමටම තියමු!',
          animation: StoryAnimation.popIn,
        ),
        StoryBeat(
          speaker: StoryCharacter.ella,
          text:
              'නැහැ ෆීලික්ස්! 68,507 හි 6 තියෙන්නේ දසදහස්ස්ථානයේ. ඒ කියන්නේ ඒකේ නිරූපිත අගය 60,000ක්!',
        ),
        StoryBeat(
          speaker: StoryCharacter.ella,
          text:
              'පුංචි යාළුවේ, අටවලා තියෙන උගුල්වලට අහුවෙන්නේ නැතිවෙන්න ඉලක්කම් නිවැරදි ස්ථානීය අගයන්වල තියන්න උදව් කරන්න!',
          isFinal: true,
        ),
      ],
    ),

    // ─── CONCEPT 5: UNLOCKING THE CHEST ───
    GoldenMangoConcept(
      id: 'c5_unlocking_chest',
      title: 'නිධන් පෙට්ටිය විවෘත කිරීම',
      learningObjective: 'සංඛ්‍යා විහිදුවා ලිවීම',
      learningObjectiveSi: 'සංඛ්‍යා විහිදුවා ලිවීම',
      backgroundAsset: 'assets/images/bg_c5_treasure_chest.png',
      rewardText: '🥭 රන් අඹ ගෙඩිය ඔබට හිමිවිය!',
      beats: [
        StoryBeat(
          speaker: StoryCharacter.leo,
          text:
              'අපි ජයග්‍රහණයට ගොඩක් ළඟයි! ඒත් නිධන් පෙට්ටියේ ඉබි යතුර අහන්නේ 68,507 සංඛ්‍යාව විහිදුවා ලියන්න කියලයි. අපි ඒක කරන්නේ කොහොමද?',
        ),
        StoryBeat(
          speaker: StoryCharacter.felix,
          text:
              'පස්සට වෙන්න! මම මේ මිටියෙන් ගහලා යතුර කඩලා දාන්නම්! විහිදුවනවා කියන්නේ කඩන එකනේ!',
          animation: StoryAnimation.popIn,
        ),
        StoryBeat(
          speaker: StoryCharacter.ella,
          text:
              'මිටිය පසෙකින් තියන්න ෆීලික්ස්! ගණිතයේදී සංඛ්‍යාවක් විහිදුවනවා කියන්නේ ඒක කඩන එක නෙවෙයි, ස්ථානීය අගයන්වලට වෙන් කර ලියන එකයි.',
        ),
        StoryBeat(
          speaker: StoryCharacter.ella,
          text:
              'ඒ කියන්නේ 68,507 විහිදුවා ලියන්නේ 60,000 + 8,000 + 500 + 0 + 7 ලෙසයි.',
        ),
        StoryBeat(
          speaker: StoryCharacter.ella,
          text:
              'එන්න යාළුවේ, අවසාන ඉබි යතුර අරින්න සංඛ්‍යාව විහිදුවා ලියන්න අපිට උදව් කරන්න!',
          isFinal: true,
        ),
      ],
    ),
  ];
}
