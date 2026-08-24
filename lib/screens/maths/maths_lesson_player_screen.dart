import 'package:flutter/material.dart';
import '../../data/maths/maths_lesson_1_data.dart';
import '../../models/maths/lesson_step_model.dart';
import '../../services/progress_service.dart';
import '../../services/sound_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/animated_widgets.dart';
import '../../widgets/maths/lesson_step_widget.dart';
import 'games/maths_game_hub_screen.dart';

class MathsLessonPlayerScreen extends StatefulWidget {
  final int studentGrade;

  const MathsLessonPlayerScreen({
    super.key,
    required this.studentGrade,
  });

  @override
  State<MathsLessonPlayerScreen> createState() => _MathsLessonPlayerScreenState();
}

class _MathsLessonPlayerScreenState extends State<MathsLessonPlayerScreen> {
  final ProgressService _progressService = ProgressService();
  final SoundService _soundService = SoundService();

  // Navigation flow stage tracker
  int _currentDialogueIndex = 0;
  int _currentChapterIndex = 0; // 0..3 (4 chapters)
  int _currentGuidedIndex = 0; // 0..5 (6 questions)
  int _currentAssessmentIndex = 0; // 0..3 (4 questions)
  int _currentAdaptiveIndex = 0; // 0..2 (3 questions)
  int _currentRapidFireIndex = 0; // 0..2 (3 questions)

  // Overall player mode states
  bool _inIntro = true;
  bool _inLearnChapters = false;
  bool _inGuidedPractice = false;
  bool _inAssessment = false;
  bool _inAdaptivePath = false;
  bool _inRapidFire = false;
  bool _inAbacusRevision = false;
  bool _isCompleted = false;

  // Scoring & Adaptive states
  int _assessmentCorrectCount = 0;
  bool _isAdvancedPath = false;
  int _totalXpEarned = 0;

  void _nextDialogue() {
    if (_currentDialogueIndex < MathsLesson1Data.introDialogues.length - 1) {
      setState(() {
        _currentDialogueIndex++;
      });
    } else {
      setState(() {
        _inIntro = false;
        _inLearnChapters = true;
        _currentChapterIndex = 0;
      });
    }
  }

  void _nextLearnChapter() {
    if (_currentChapterIndex < 3) {
      setState(() {
        _currentChapterIndex++;
      });
    } else {
      setState(() {
        _inLearnChapters = false;
        _inGuidedPractice = true;
        _currentGuidedIndex = 0;
      });
    }
  }

  void _onGuidedAnswer(bool isCorrect, String? explanation) {
    if (isCorrect) _totalXpEarned += 10;
  }

  void _nextGuidedStep() {
    if (_currentGuidedIndex < MathsLesson1Data.guidedQuestions.length - 1) {
      setState(() {
        _currentGuidedIndex++;
      });
    } else {
      setState(() {
        _inGuidedPractice = false;
        _inAssessment = true;
        _currentAssessmentIndex = 0;
        _assessmentCorrectCount = 0;
      });
    }
  }

  void _onAssessmentAnswer(bool isCorrect, String? explanation) {
    if (isCorrect) {
      _assessmentCorrectCount++;
      _totalXpEarned += 20;
    }
  }

  void _nextAssessmentStep() {
    if (_currentAssessmentIndex < MathsLesson1Data.assessmentQuestions.length - 1) {
      setState(() {
        _currentAssessmentIndex++;
      });
    } else {
      // Evaluate Assessment score for Adaptive Routing (>= 80% pass threshold)
      final scoreRatio = _assessmentCorrectCount / MathsLesson1Data.assessmentQuestions.length;
      setState(() {
        _inAssessment = false;
        _inAdaptivePath = true;
        _isAdvancedPath = scoreRatio >= 0.8;
        _currentAdaptiveIndex = 0;
      });
    }
  }

  void _onAdaptiveAnswer(bool isCorrect, String? explanation) {
    if (isCorrect) _totalXpEarned += 20;
  }

  void _nextAdaptiveStep() {
    final list = _isAdvancedPath ? MathsLesson1Data.advancedQuestions : MathsLesson1Data.remedialQuestions;
    if (_currentAdaptiveIndex < list.length - 1) {
      setState(() {
        _currentAdaptiveIndex++;
      });
    } else {
      setState(() {
        _inAdaptivePath = false;
        _inRapidFire = true;
        _currentRapidFireIndex = 0;
      });
    }
  }

  void _onRapidFireAnswer(bool isCorrect, String? explanation) {
    if (isCorrect) _totalXpEarned += 15;
  }

  void _nextRapidFireStep() {
    if (_currentRapidFireIndex < MathsLesson1Data.rapidFireQuestions.length - 1) {
      setState(() {
        _currentRapidFireIndex++;
      });
    } else {
      setState(() {
        _inRapidFire = false;
        _inAbacusRevision = true;
      });
    }
  }

  void _onAbacusSubmitted(bool isCorrect, String? explanation) {
    if (isCorrect) _totalXpEarned += 150;
    _finishLesson();
  }

  Future<void> _finishLesson() async {
    _soundService.playLevelUp();
    _totalXpEarned += 200;

    // Persist lesson completion in Firestore using existing ProgressService
    try {
      await _progressService.completeLesson('Mathematics', MathsLesson1Data.lessonId);
      await _progressService.completeQuiz('Mathematics', MathsLesson1Data.lessonId, 10, 10);
    } catch (_) {}

    setState(() {
      _inAbacusRevision = false;
      _isCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.mathOrange,
        foregroundColor: Colors.white,
        title: Text(
          '${MathsLesson1Data.lessonTitleSi} (${MathsLesson1Data.lessonTitleEn})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // XP Counter Badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFFFFD700), size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_totalXpEarned XP',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildCurrentStageView(),
      ),
    );
  }

  Widget _buildCurrentStageView() {
    if (_inIntro) return _buildIntroDialogueView();
    if (_inLearnChapters) return _buildLearnChapterView();
    if (_inGuidedPractice) return _buildGuidedPracticeView();
    if (_inAssessment) return _buildAssessmentView();
    if (_inAdaptivePath) return _buildAdaptivePathView();
    if (_inRapidFire) return _buildRapidFireView();
    if (_inAbacusRevision) return _buildAbacusRevisionView();
    if (_isCompleted) return _buildRewardCompletionView();

    return _buildIntroDialogueView();
  }

  /// STAGE 1: INTRODUCTION DIALOGUE BUBBLES (Parrot 🦜)
  Widget _buildIntroDialogueView() {
    final text = MathsLesson1Data.introDialogues[_currentDialogueIndex];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingWidget(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppShadows.cardShadow,
              ),
              child: ClipOval(
                child: Image.asset(
                  MathsAssets.parrotIdle,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('🦜', style: TextStyle(fontSize: 64)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SlideInWidget(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFD166), width: 3),
                boxShadow: AppShadows.cardShadow,
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextDialogue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mathOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'ඉදිරියට 🚀',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// STAGE 2: LEARN CHAPTERS (4 Interactive Cards)
  Widget _buildLearnChapterView() {
    Widget content;
    switch (_currentChapterIndex) {
      case 0:
        content = _buildChapter1Village();
        break;
      case 1:
        content = _buildChapter2Castle();
        break;
      case 2:
        content = _buildChapter3Decomposition();
        break;
      case 3:
        content = _buildChapter4TenThousands();
        break;
      default:
        content = _buildChapter1Village();
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Step Progress Bar
          Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i <= _currentChapterIndex ? AppColors.mathOrange : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          Expanded(child: SingleChildScrollView(child: content)),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextLearnChapter,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mathOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'ඊළඟ පාඩම ➡️',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapter1Village() {
    return Column(
      children: [
        _buildChapterTitleCard('පාඩම 1: අංක ගම්මානය 🏠', 'අංක නිවැරදිව කියවීම සහ ලිවීම හඳුනාගනිමු.'),
        const SizedBox(height: 16),
        _buildNumberHouseCard('🏠 84', 'අසූ හතර', '80 (අසූ) + 4 (හතර) = 84'),
        _buildNumberHouseCard('🏠 101', 'එකසිය එක', '100 + 1 = 101'),
        _buildNumberHouseCard('🏠 528', 'පන්සිය විසි අට', '500 + 20 + 8 = 528'),
        _buildNumberHouseCard('🏠 997', 'නවසිය අනූ හත', '900 + 90 + 7 = 997'),
      ],
    );
  }

  Widget _buildChapter2Castle() {
    return Column(
      children: [
        _buildChapterTitleCard('පාඩම 2: ස්ථානීය අගය මාලිගාව 🏰', '5421 අංකයේ ස්ථානීය අගයන් සොයමු.'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Column(
            children: [
              const Text('5421', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.mathOrange)),
              const Divider(height: 24),
              _buildPlaceValueRow('5', 'දහස් ස්ථානය', '1000', '5000'),
              _buildPlaceValueRow('4', 'සිය ස්ථානය', '100', '400'),
              _buildPlaceValueRow('2', 'දහය ස්ථානය', '10', '20'),
              _buildPlaceValueRow('1', 'එකක ස්ථානය', '1', '1'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChapter3Decomposition() {
    return Column(
      children: [
        _buildChapterTitleCard('පාඩම 3: විහිදුවා ලිවීම 🧩', 'සංඛ්‍යාවක් ස්ථානීය අගයන් අනුව විහිදුවමු.'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Column(
            children: [
              const Text('5421', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.mathOrange)),
              const SizedBox(height: 16),
              const Text('=', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDecompChip('5000'),
                  const Text('+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  _buildDecompChip('400'),
                  const Text('+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  _buildDecompChip('20'),
                  const Text('+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  _buildDecompChip('1'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChapter4TenThousands() {
    return Column(
      children: [
        _buildChapterTitleCard('පාඩම 4: දස දහස් ස්ථානය 🌟', 'පස්ස්ථානීය අංක (26 147) හඳුනාගනිමු.'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Column(
            children: [
              const Text('26 147', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.mathOrange)),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                children: const [
                  TableRow(
                    decoration: BoxDecoration(color: Color(0xFFFFF3E0)),
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('දස දහස්', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      Padding(padding: EdgeInsets.all(8), child: Text('දහස්', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      Padding(padding: EdgeInsets.all(8), child: Text('සිය', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      Padding(padding: EdgeInsets.all(8), child: Text('දහය', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      Padding(padding: EdgeInsets.all(8), child: Text('එකක', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(12), child: Text('2', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      Padding(padding: EdgeInsets.all(12), child: Text('6', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      Padding(padding: EdgeInsets.all(12), child: Text('1', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      Padding(padding: EdgeInsets.all(12), child: Text('4', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      Padding(padding: EdgeInsets.all(12), child: Text('7', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChapterTitleCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD166)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.mathOrange)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildNumberHouseCard(String house, String text, String math) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(house, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.mathOrange)),
              Text(math, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceValueRow(String digit, String place, String mult, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(digit, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.mathOrange)),
          Text(place, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Text('$digit × $mult = $val', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildDecompChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mathOrange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  /// STAGE 3: GUIDED PRACTICE (6 Questions)
  Widget _buildGuidedPracticeView() {
    final step = MathsLesson1Data.guidedQuestions[_currentGuidedIndex];
    return Column(
      children: [
        Expanded(
          child: LessonStepWidget(
            step: step,
            onAnswerSubmitted: (isCorrect, explanation) => _onGuidedAnswer(isCorrect, explanation),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextGuidedStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mathOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('ඊළඟ අභ්‍යාසය ➡️', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  /// STAGE 4: ASSESSMENT (4 Questions)
  Widget _buildAssessmentView() {
    final step = MathsLesson1Data.assessmentQuestions[_currentAssessmentIndex];
    return Column(
      children: [
        Expanded(
          child: LessonStepWidget(
            step: step,
            onAnswerSubmitted: (isCorrect, explanation) => _onAssessmentAnswer(isCorrect, explanation),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextAssessmentStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mathOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('ඇගයීම ඉදිරියට ➡️', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  /// STAGE 5: ADAPTIVE ROUTING (Advanced vs Remedial)
  Widget _buildAdaptivePathView() {
    final list = _isAdvancedPath ? MathsLesson1Data.advancedQuestions : MathsLesson1Data.remedialQuestions;
    final step = list[_currentAdaptiveIndex];
    return Column(
      children: [
        Expanded(
          child: LessonStepWidget(
            step: step,
            onAnswerSubmitted: (isCorrect, explanation) => _onAdaptiveAnswer(isCorrect, explanation),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextAdaptiveStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mathOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('ඉදිරියට 🚀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  /// STAGE 6: RAPID-FIRE MINI-GAME (3 Questions)
  Widget _buildRapidFireView() {
    final step = MathsLesson1Data.rapidFireQuestions[_currentRapidFireIndex];
    return Column(
      children: [
        Expanded(
          child: LessonStepWidget(
            step: step,
            onAnswerSubmitted: (isCorrect, explanation) => _onRapidFireAnswer(isCorrect, explanation),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextRapidFireStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mathOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('වේගවත් අභියෝගය ඉදිරියට ⚡', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  /// STAGE 7: REVISION & ABACUS ACTIVITY
  Widget _buildAbacusRevisionView() {
    const abacusStep = LessonStepModel(
      id: 'abacus_rev',
      stage: StepStage.abacusRevision,
      title: 'සංඛ්‍යා පුනරීක්ෂණය & අබකසය 🧮',
      questionText: 'අබකසයේ පබළු සකසා 5 421 අංකය නිරූපණය කරන්න!',
      parrotDialogue: '🦜 "අන්තිම අභියෝගය! අබකසයේ පබළු සකස් කර අගය පරීක්ෂා කරමු!"',
      interactionType: QuestionInteractionType.abacusInteractive,
    );

    return LessonStepWidget(
      step: abacusStep,
      onAnswerSubmitted: (isCorrect, explanation) => _onAbacusSubmitted(isCorrect, explanation),
    );
  }

  /// STAGE 8: MASTERY & REWARD CELEBRATION SCREEN
  Widget _buildRewardCompletionView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingWidget(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppShadows.cardShadow,
              ),
              child: ClipOval(
                child: Image.asset(
                  MathsAssets.parrotIdle,
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('🦜', style: TextStyle(fontSize: 72)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '🎉 පාඩම සාර්ථකව අවසන්!',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.mathOrange),
          ),
          const SizedBox(height: 8),
          const Text(
            '🦜 "ඔයා සංඛ්‍යා වීරයෙක්! නියමයි!"',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
          ),
          const SizedBox(height: 24),

          // Stars Rating Display
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 44),
              Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 44),
              Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 44),
            ],
          ),

          const SizedBox(height: 24),

          // XP & Badge Reward Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRewardCard('⚡ XP', '+$_totalXpEarned'),
              _buildRewardCard('🪙 Coins', '+50'),
              _buildRewardCard('🏅 Badge', 'සංඛ්‍යා වීරයා'),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MathsGameHubScreen(studentGrade: widget.studentGrade),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.sports_esports_rounded, color: Color(0xFFFFD700), size: 24),
              label: const Text(
                'ගණිත Mini-Games සෙල්ලම් කරමු 🎮',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.mathOrange, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Adventure Map වෙත ආපසු යන්න 🗺️',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.mathOrange),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.softShadow,
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.mathOrange)),
        ],
      ),
    );
  }
}
