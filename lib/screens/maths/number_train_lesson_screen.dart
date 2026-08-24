import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../data/maths/number_train_data.dart';
import '../../models/maths/number_train_models.dart';
import '../../services/progress_service.dart';
import '../../services/sound_service.dart';
import '../../services/math_curriculum_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/maths/games/number_train_challenge_widget.dart';

/// Lesson 2 Phase State Machine
enum _TrainLessonPhase {
  storyBeat,
  miniTeaching,
  challenges,
  conceptReward,
}

/// ============================================
/// GREAT NUMBER TRAIN LESSON SCREEN
/// Lesson 2: Multi-concept lesson player.
/// Supports Concept 1 (comparing) and Concept 2 (ordering).
/// ============================================
class GreatNumberTrainLessonScreen extends StatefulWidget {
  final int studentGrade;
  final int conceptIndex;

  const GreatNumberTrainLessonScreen({
    super.key,
    required this.studentGrade,
    this.conceptIndex = 0,
  });

  @override
  State<GreatNumberTrainLessonScreen> createState() =>
      _GreatNumberTrainLessonScreenState();
}

class _GreatNumberTrainLessonScreenState
    extends State<GreatNumberTrainLessonScreen>
    with TickerProviderStateMixin {
  final SoundService _soundService = SoundService();
  final ProgressService _progressService = ProgressService();

  // Concept State
  late int _currentConceptIndex;

  // Live cache maps from Firestore
  final Map<String, List<NumberTrainStoryBeatModel>> _liveStoryBeatsMap = {};
  final Map<String, List<NumberTrainChallengeModel>> _liveChallengesMap = {};

  // Phase State
  _TrainLessonPhase _phase = _TrainLessonPhase.storyBeat;
  int _currentBeatIndex = 0;
  int _miniTeachingStep = 0; // 0: 2-digit, 1: 3-digit, 2: equal-hundreds
  int _currentChallengeIndex = 0;

  // Felix interactive choice state
  bool _felixChoiceMade = false;
  bool _felixChoiceCorrect = false;

  // Animation Controllers
  late AnimationController _characterAnimController;
  late Animation<double> _popScaleAnim;

  // Confetti Controller
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _currentConceptIndex = widget.conceptIndex;

    _characterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _popScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _characterAnimController, curve: Curves.elasticOut));

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));

    _characterAnimController.forward();
    _loadLiveCurriculum();
  }

  Future<void> _loadLiveCurriculum() async {
    try {
      for (final c in NumberTrainData.allConcepts) {
        final beats =
            await MathCurriculumService().getNumberTrainStoryBeats(c.id);
        final challenges =
            await MathCurriculumService().getNumberTrainChallenges(c.id);
        if (mounted) {
          setState(() {
            if (beats.isNotEmpty) _liveStoryBeatsMap[c.id] = beats;
            if (challenges.isNotEmpty) _liveChallengesMap[c.id] = challenges;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _characterAnimController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  NumberTrainConceptModel get _concept =>
      NumberTrainData.allConcepts[_currentConceptIndex];

  List<NumberTrainStoryBeatModel> get _currentStoryBeats =>
      _liveStoryBeatsMap[_concept.id] ?? _concept.storyBeats;

  List<NumberTrainChallengeModel> get _currentChallenges =>
      _liveChallengesMap[_concept.id] ?? _concept.challenges;

  NumberTrainStoryBeatModel get _currentBeat {
    final beats = _currentStoryBeats;
    if (_currentBeatIndex >= beats.length) {
      return beats.last;
    }
    return beats[_currentBeatIndex];
  }

  void _nextStoryBeat() {
    _soundService.playClick();
    if (_currentBeatIndex < _currentStoryBeats.length - 1) {
      setState(() {
        _currentBeatIndex++;
        _felixChoiceMade = false;
      });
      _characterAnimController.reset();
      _characterAnimController.forward();
    } else {
      // Transition to Mini-Teaching Phase
      setState(() {
        _phase = _TrainLessonPhase.miniTeaching;
        _miniTeachingStep = 0;
      });
    }
  }

  void _nextMiniTeachingStep() {
    _soundService.playClick();
    if (_miniTeachingStep < 2) {
      setState(() => _miniTeachingStep++);
    } else {
      // Transition to Challenges Phase
      setState(() {
        _phase = _TrainLessonPhase.challenges;
        _currentChallengeIndex = 0;
      });
    }
  }

  void _onChallengeCompleted() {
    if (_currentChallengeIndex < _currentChallenges.length - 1) {
      setState(() => _currentChallengeIndex++);
    } else {
      // All 6 challenges completed -> Reward Phase
      _soundService.playLevelUp();
      _confettiController.play();

      // Save concept completion to progress and award +100 XP
      _progressService.completeConcept(
          'maths', 'math_grade5_02', _concept.id);

      // If it's the final concept, mark lesson 2 completed in progress and award bonus +200 XP
      if (_currentConceptIndex >= NumberTrainData.allConcepts.length - 1) {
        _progressService.completeLesson('maths', 'math_grade5_02');
      }

      setState(() => _phase = _TrainLessonPhase.conceptReward);
    }
  }

  void _nextConcept() {
    _soundService.playClick();
    if (_currentConceptIndex < NumberTrainData.allConcepts.length - 1) {
      setState(() {
        _currentConceptIndex++;
        _phase = _TrainLessonPhase.storyBeat;
        _currentBeatIndex = 0;
        _miniTeachingStep = 0;
        _currentChallengeIndex = 0;
        _felixChoiceMade = false;
        _felixChoiceCorrect = false;
      });
      _characterAnimController.reset();
      _characterAnimController.forward();
    } else {
      _progressService.completeLesson('maths', 'math_grade5_02');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background: use image only for storyBeat, solid gradient for other phases
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: _phase == _TrainLessonPhase.storyBeat
                  ? SizedBox.expand(
                      key: ValueKey(_getBackgroundForPhase()),
                      child: Image.asset(
                        _getBackgroundForPhase(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildFallbackBackground(_phase),
                      ),
                    )
                  : SizedBox.expand(
                      key: ValueKey('gradient_${_phase.name}'),
                      child: _buildFallbackBackground(_phase),
                    ),
            ),
          ),

          // Subtle background overlay for text contrast (story only)
          if (_phase == _TrainLessonPhase.storyBeat)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),

          // Main Phase Renderer
          SafeArea(
            child: Column(
              children: [
                // Top App Bar Navigation & Progress
                _buildTopNavigationHeader(),

                // Phase Content Area
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _buildPhaseContent(),
                  ),
                ),
              ],
            ),
          ),

          // Confetti Overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBackground(_TrainLessonPhase phase) {
    switch (phase) {
      case _TrainLessonPhase.storyBeat:
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B1464), Color(0xFF3B3B98), Color(0xFF1E272C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 50),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShadows.softShadow,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🚂 ', style: TextStyle(fontSize: 20)),
                    Text(
                      'මහා සංඛ්‍යා දුම්රිය ස්ථානය 🚉',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      case _TrainLessonPhase.miniTeaching:
      case _TrainLessonPhase.challenges:
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF16213E), Color(0xFF0F3460), Color(0xFF1A1A2E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );

      case _TrainLessonPhase.conceptReward:
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF009432), Color(0xFF006266), Color(0xFF1B1464)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );
    }
  }

  String _getBackgroundForPhase() {
    switch (_phase) {
      case _TrainLessonPhase.storyBeat:
        return _concept.stationBgAsset;
      case _TrainLessonPhase.miniTeaching:
      case _TrainLessonPhase.challenges:
        return _concept.interiorBgAsset;
      case _TrainLessonPhase.conceptReward:
        return MathsAssets.bgTrainCountryside;
    }
  }

  // ─── TOP NAVIGATION HEADER ───

  Widget _buildTopNavigationHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () {
              _soundService.playClick();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _concept.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _concept.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (_phase == _TrainLessonPhase.challenges)
            _buildTrainProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildTrainProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🚂', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            '${_currentChallengeIndex + 1} / ${_currentChallenges.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─── PHASE CONTENT SWITCHER ───

  Widget _buildPhaseContent() {
    switch (_phase) {
      case _TrainLessonPhase.storyBeat:
        return _buildStoryBeatPhase();
      case _TrainLessonPhase.miniTeaching:
        return _buildMiniTeachingPhase();
      case _TrainLessonPhase.challenges:
        return NumberTrainChallengeWidget(
          key: ValueKey('ch_$_currentChallengeIndex'),
          challenge: _currentChallenges[_currentChallengeIndex],
          onChallengeCompleted: _onChallengeCompleted,
        );
      case _TrainLessonPhase.conceptReward:
        return _buildConceptRewardPhase();
    }
  }

  // ─── 1. STORY BEAT PHASE (Lesson 1-Style Character Stage) ───

  Color _getSpeakerThemeColor(TrainStorySpeaker speaker) {
    switch (speaker) {
      case TrainStorySpeaker.leo:
        return const Color(0xFFE67E22);
      case TrainStorySpeaker.ella:
        return const Color(0xFF3498DB);
      case TrainStorySpeaker.felix:
        return const Color(0xFFE74C3C);
    }
  }

  String _getSpeakerAssetPath(TrainStorySpeaker speaker) {
    switch (speaker) {
      case TrainStorySpeaker.leo:
        return MathsAssets.lionIdle;
      case TrainStorySpeaker.ella:
        return MathsAssets.elephantIdle;
      case TrainStorySpeaker.felix:
        return MathsAssets.foxIdle;
    }
  }

  String _getSpeakerEmoji(TrainStorySpeaker speaker) {
    switch (speaker) {
      case TrainStorySpeaker.leo:
        return '🦁';
      case TrainStorySpeaker.ella:
        return '🐘';
      case TrainStorySpeaker.felix:
        return '🦊';
    }
  }

  Widget _buildStoryBeatPhase() {
    final beat = _currentBeat;
    final activeSpeaker = beat.speaker;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Story Character Stage Area — fills remaining space
          Expanded(
            child: _buildCharacterStage(activeSpeaker),
          ),

          const SizedBox(height: 12),

          // Story Dialogue Card — wraps to content height
          _buildDialoguePanel(beat),
        ],
      ),
    );
  }

  Widget _buildCharacterStage(TrainStorySpeaker activeSpeaker) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final charSize = (constraints.maxHeight * 0.7).clamp(110.0, 180.0);

        // Only render the active/speaking character, centered on stage
        return Center(
          child: ScaleTransition(
            scale: _popScaleAnim,
            child: _buildCharacterAvatarBadge(
              activeSpeaker,
              charSize,
              isActive: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCharacterAvatarBadge(
      TrainStorySpeaker speaker, double size, {required bool isActive}) {
    final color = _getSpeakerThemeColor(speaker);
    final assetPath = _getSpeakerAssetPath(speaker);
    final emoji = _getSpeakerEmoji(speaker);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: isActive ? color : Colors.white70,
          width: isActive ? 4 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isActive ? 0.5 : 0.2),
            blurRadius: isActive ? 20 : 10,
            spreadRadius: isActive ? 3 : 1,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: color.withOpacity(0.2),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: size * 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialoguePanel(NumberTrainStoryBeatModel beat) {
    final speakerColor = _getSpeakerThemeColor(beat.speaker);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: speakerColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: speakerColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_getSpeakerEmoji(beat.speaker),
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      beat.speakerNameSi,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: speakerColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${_currentBeatIndex + 1} / ${_currentStoryBeats.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            beat.dialogueSi,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436),
              height: 1.4,
            ),
          ),

          // Interactive Choice inside Story (Beat 3)
          if (beat.isInteractiveChoice) ...[
            const SizedBox(height: 12),
            Text(
              beat.choicePromptSi!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C5CE7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _soundService.playWrong();
                      setState(() {
                        _felixChoiceMade = true;
                        _felixChoiceCorrect = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _felixChoiceMade && !_felixChoiceCorrect
                            ? Colors.red
                            : Colors.grey.shade400,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      beat.wrongOptionText!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _soundService.playCorrect();
                      setState(() {
                        _felixChoiceMade = true;
                        _felixChoiceCorrect = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      beat.correctOptionText!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            if (_felixChoiceMade && !_felixChoiceCorrect)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  beat.wrongFeedbackSi!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
          ],

          const SizedBox(height: 12),

          // Next Beat Button
          ElevatedButton.icon(
            onPressed: (beat.isInteractiveChoice && !_felixChoiceMade)
                ? null
                : _nextStoryBeat,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mathOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 20),
            label: const Text(
              'ඉදිරියට ➔',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. MINI TEACHING PHASE ───

  Widget _buildMiniTeachingPhase() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 24)),
                Expanded(
                  child: Text(
                    _currentConceptIndex == 0
                        ? 'සංඛ්‍යා සසඳන රීතිය ඉගෙන ගනිමු'
                        : 'සංඛ්‍යා පටිපාටිගත කරන රීතිය',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C5CE7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_miniTeachingStep + 1} / 3',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: _buildMiniTeachingStepContent(),
              ),
            ),

            ElevatedButton.icon(
              onPressed: _nextMiniTeachingStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: Text(
                _miniTeachingStep < 2
                    ? 'ඊළඟ රීතිය ➔'
                    : 'අභියෝග වලට යමු! 🚀',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTeachingStepContent() {
    if (_currentConceptIndex == 1) {
      return _buildConcept2MiniTeachingStep();
    } else if (_currentConceptIndex == 2) {
      return _buildConcept3MiniTeachingStep();
    } else if (_currentConceptIndex == 3) {
      return _buildConcept4MiniTeachingStep();
    } else if (_currentConceptIndex == 4) {
      return _buildConcept5MiniTeachingStep();
    } else if (_currentConceptIndex == 5) {
      return _buildConcept6MiniTeachingStep();
    }
    // Concept 1 mini-teaching (original)
    if (_miniTeachingStep == 0) {
      // 2-digit numbers
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1️⃣ ඉලක්කම් 2ක සංඛ්‍යා සසඳමු:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'මුලින්ම දහයස්ථානයේ ඉලක්කම් සසඳන්න.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeachingNumberCard('56', highlightDigit: '5', label: 'දහය: 5'),
              _buildTeachingNumberCard('28', highlightDigit: '2', label: 'දහය: 2'),
              _buildTeachingNumberCard('32', highlightDigit: '3', label: 'දහය: 3'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '✨ 5 > 3 > 2 බැවින් විශාලම සංඛ්‍යාව 56 වේ. කුඩාම සංඛ්‍යාව 28 වේ.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      );
    } else if (_miniTeachingStep == 1) {
      // 3-digit numbers
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2️⃣ ඉලක්කම් 3ක සංඛ්‍යා සසඳමු:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'මුලින්ම සියයස්ථානයේ ඉලක්කම් සසඳන්න.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeachingNumberCard('541', highlightDigit: '5', label: 'සිය: 5'),
              _buildTeachingNumberCard('358', highlightDigit: '3', label: 'සිය: 3'),
              _buildTeachingNumberCard('722', highlightDigit: '7', label: 'සිය: 7'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '✨ 7 > 5 > 3 බැවින් විශාලම සංඛ්‍යාව 722 වේ. කුඩාම සංඛ්‍යාව 358 වේ.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      );
    } else {
      // Equal Hundreds comparison
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3️⃣ සියයස්ථාන සමාන වූ විට:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'සියයස්ථාන සමාන නම්, ඊළඟට දහයස්ථානයේ ඉලක්කම් සසඳන්න.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeachingNumberCard('541', highlightDigit: '4', label: 'දහය: 4'),
              _buildTeachingNumberCard('528', highlightDigit: '2', label: 'දහය: 2'),
              _buildTeachingNumberCard('301', highlightDigit: '3', label: 'සිය: 3'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '✨ 541 සහ 528 හි සියයස්ථානය 5ම වේ. නමුත් දහයස්ථානයේ 4 > 2 නිසා 541 > 528 වේ!',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
            ),
          ),
        ],
      );
    }
  }

  // ─── CONCEPT 2 MINI-TEACHING ───

  Widget _buildConcept2MiniTeachingStep() {
    if (_miniTeachingStep == 0) {
      // Ascending order intro
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1️⃣ ආරෝහණ පිළිවෙළ (කුඩා → විශාල):',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'සංඛ්‍යා කුඩාම සිට විශාලම දක්වා සකස් කරන්න.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeachingNumberCard('47', highlightDigit: '4', label: 'දහය: 4'),
              const Text('➔', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF27AE60))),
              _buildTeachingNumberCard('74', highlightDigit: '7', label: 'දහය: 7'),
              const Text('➔', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF27AE60))),
              _buildTeachingNumberCard('81', highlightDigit: '8', label: 'දහය: 8'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '🚃 47 ➔ 74 ➔ 81\nකුඩාම සිට විශාලම දක්වා = ආරෝහණ පිළිවෙළ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      );
    } else if (_miniTeachingStep == 1) {
      // Descending order intro
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2️⃣ අවරෝහණ පිළිවෙළ (විශාල → කුඩා):',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'සංඛ්‍යා විශාලම සිට කුඩාම දක්වා සකස් කරන්න.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeachingNumberCard('81', highlightDigit: '8', label: 'දහය: 8'),
              const Text('➔', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE74C3C))),
              _buildTeachingNumberCard('74', highlightDigit: '7', label: 'දහය: 7'),
              const Text('➔', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE74C3C))),
              _buildTeachingNumberCard('47', highlightDigit: '4', label: 'දහය: 4'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '🚃 81 ➔ 74 ➔ 47\nවිශාලම සිට කුඩාම දක්වා = අවරෝහණ පිළිවෙළ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
            ),
          ),
        ],
      );
    } else {
      // Place-value ordering
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3️⃣ ඉලක්කම් 3ක සංඛ්‍යා පටිපාටිගත කරමු:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'සියලුම සංඛ්‍යාවල සියයස්ථානය සමාන නම්, දහයස්ථානයේ ඉලක්කම් සසඳන්න.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeachingNumberCard('412', highlightDigit: '1', label: 'දහය: 1'),
              _buildTeachingNumberCard('450', highlightDigit: '5', label: 'දහය: 5'),
              _buildTeachingNumberCard('489', highlightDigit: '8', label: 'දහය: 8'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'සියලුම සංඛ්‍යාවල සියයස්ථානයේ 4 ඇත.\nදහයස්ථානයේ: 1 < 5 < 8 වේ.\n\nආරෝහණ: 412 ➔ 450 ➔ 489',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
            ),
          ),
        ],
      );
    }
  }

  // ─── CONCEPT 3 MINI-TEACHING ───

  Widget _buildConcept3MiniTeachingStep() {
    if (_miniTeachingStep == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1️⃣ විශාලම සංඛ්‍යාව සෑදීම:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'විශාලම සංඛ්‍යාව සෑදීමට විශාලතම ඉලක්කම මුලට තබන්න.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeachingNumberCard('9', highlightDigit: '9', label: 'දහස්: 9'),
              _buildTeachingNumberCard('7', highlightDigit: '7', label: 'සිය: 7'),
              _buildTeachingNumberCard('5', highlightDigit: '5', label: 'දහය: 5'),
              _buildTeachingNumberCard('2', highlightDigit: '2', label: 'ඒක: 2'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '✨ 2, 5, 9, 7 ඉලක්කම්වලින් සෑදිය හැකි විශාලම සංඛ්‍යාව 9752 වේ.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      );
    } else if (_miniTeachingStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2️⃣ කුඩාම සංඛ්‍යාව සෑදීම:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'කුඩාම සංඛ්‍යාව සෑදීමට කුඩාම ඉලක්කම මුලට තබන්න.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeachingNumberCard('2', highlightDigit: '2', label: 'දහස්: 2'),
              _buildTeachingNumberCard('5', highlightDigit: '5', label: 'සිය: 5'),
              _buildTeachingNumberCard('7', highlightDigit: '7', label: 'දහය: 7'),
              _buildTeachingNumberCard('9', highlightDigit: '9', label: 'ඒක: 9'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '✨ 2, 5, 9, 7 ඉලක්කම්වලින් සෑදිය හැකි කුඩාම සංඛ්‍යාව 2579 වේ.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3️⃣ ඉලක්කම්වල පිහිටීම සහ අගය:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'ඉලක්කම්වල පිහිටීම වෙනස් වන විට සංඛ්‍යාවේ අගය වෙනස් වේ.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeachingNumberCard('9752', highlightDigit: '9', label: 'විශාලම'),
              const Text('≠', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              _buildTeachingNumberCard('2579', highlightDigit: '2', label: 'කුඩාම'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '9752 > 2579 (දහස්ස්ථානයේ 9 > 2 නිසා අගයන් වෙනස් වේ!)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
            ),
          ),
        ],
      );
    }
  }

  // ─── CONCEPT 4 MINI-TEACHING ───

  Widget _buildConcept4MiniTeachingStep() {
    if (_miniTeachingStep == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1️⃣ දසදහස්ස්ථානය හඳුනාගනිමු:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'ඉලක්කම් 5ක සංඛ්‍යාවක වම්පසම ඉලක්කම දසදහස්ස්ථානයයි.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeachingNumberCard('6', highlightDigit: '6', label: 'දසදහස්: 6', isCompact: true),
                const SizedBox(width: 4),
                _buildTeachingNumberCard('1', highlightDigit: '1', label: 'දහස්: 1', isCompact: true),
                const SizedBox(width: 4),
                _buildTeachingNumberCard('0', highlightDigit: '0', label: 'සිය: 0', isCompact: true),
                const SizedBox(width: 4),
                _buildTeachingNumberCard('8', highlightDigit: '8', label: 'දහය: 8', isCompact: true),
                const SizedBox(width: 4),
                _buildTeachingNumberCard('8', highlightDigit: '8', label: 'ඒක: 8', isCompact: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '🚃 61,088 හි 6 දසදහස්ස්ථානයේ ඇත. එහි අගය 60,000 වේ.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      );
    } else if (_miniTeachingStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2️⃣ දසදහස්ස්ථාන සසඳමු:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'මුලින්ම දසදහස්ස්ථානයේ ඉලක්කම් සසඳන්න: 1, 3, 6.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeachingNumberCard('18508', highlightDigit: '1', label: 'දසදහස් 1', isCompact: true),
                const Text(' < ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF27AE60))),
                _buildTeachingNumberCard('33240', highlightDigit: '3', label: 'දසදහස් 3', isCompact: true),
                const Text(' < ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF27AE60))),
                _buildTeachingNumberCard('61088', highlightDigit: '6', label: 'දසදහස් 6', isCompact: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '1 < 3 < 6 බැවින්: 18,508 < 33,240 < 61,088 වේ.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3️⃣ දසදහස්ස්ථාන සමාන වූ විට:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'දසදහස්ස්ථාන සමාන නම්, ඊළඟට දහස්ස්ථානයේ ඉලක්කම් සසඳන්න.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeachingNumberCard('42900', highlightDigit: '2', label: 'දහස්: 2', isCompact: true),
                const Text(' < ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                _buildTeachingNumberCard('45600', highlightDigit: '5', label: 'දහස්: 5', isCompact: true),
                const Text(' < ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                _buildTeachingNumberCard('48200', highlightDigit: '8', label: 'දහස්: 8', isCompact: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'දසදහස් 4 සමාන බැවින් දහස්ස්ථානයෙන්: 2 < 5 < 8\n\nආරෝහණ: 42,900 < 45,600 < 48,200',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
            ),
          ),
        ],
      );
    }
  }

  // ─── CONCEPT 5 MINI-TEACHING ───

  Widget _buildConcept5MiniTeachingStep() {
    if (_miniTeachingStep == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1️⃣ දසදහස්ස්ථාන සංසන්දනය:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'විශාලම දසදහස්ස්ථානය ඇති සංඛ්‍යාව විශාලම සංඛ්‍යාව වේ.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeachingNumberCard('12450', highlightDigit: '1', label: 'දසදහස් 1', isCompact: true),
                const SizedBox(width: 6),
                _buildTeachingNumberCard('21450', highlightDigit: '2', label: 'දසදහස් 2', isCompact: true),
                const SizedBox(width: 6),
                _buildTeachingNumberCard('19999', highlightDigit: '1', label: 'දසදහස් 1', isCompact: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '✨ 2 > 1 බැවින් 21,450 යනු මෙම සංඛ්‍යා 3 අතරින් විශාලම සංඛ්‍යාවයි.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      );
    } else if (_miniTeachingStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2️⃣ ඉලක්කම් ගණන බලමු:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'ඉලක්කම් 4ක සංඛ්‍යා ඉලක්කම් 5ක සංඛ්‍යාවලට වඩා කුඩා වේ.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeachingNumberCard('8999', highlightDigit: '8', label: 'ඉලක්කම් 4'),
              const Text('<', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF27AE60))),
              _buildTeachingNumberCard('10025', highlightDigit: '1', label: 'ඉලක්කම් 5'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '8,999 < 10,025 (8,999 හි ඉලක්කම් 4ක් පමණක් ඇත!)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3️⃣ සමාන මුලාරම්භය ඇති සංඛ්‍යා:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'මුල් ඉලක්කම් සමාන නම්, ඊළඟට වෙනස් වන ස්ථානීය අගය සසඳන්න.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeachingNumberCard('52340', highlightDigit: '3', label: 'සිය: 3', isCompact: true),
                const Text(' < ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                _buildTeachingNumberCard('52403', highlightDigit: '0', label: 'දහය: 0', isCompact: true),
                const Text(' < ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                _buildTeachingNumberCard('52430', highlightDigit: '3', label: 'දහය: 3', isCompact: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '52,340 හි සියයස්ථානය 3 කුඩාම වේ.\n52,403 සහ 52,430 හි දහයස්ථානයෙන්: 0 < 3 වේ.\n\nආරෝහණ: 52,340 ➔ 52,403 ➔ 52,430',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
            ),
          ),
        ],
      );
    }
  }

  // ─── CONCEPT 6 MINI-TEACHING ───

  Widget _buildConcept6MiniTeachingStep() {
    if (_miniTeachingStep == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1️⃣ අවසන් දුම්රිය ටිකට්පත:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'විශාලතම දසදහස්ස්ථානය සොයාගනිමු: 3, 8, 4.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeachingNumberCard('38421', highlightDigit: '3', label: 'දසදහස් 3', isCompact: true),
                const SizedBox(width: 6),
                _buildTeachingNumberCard('83214', highlightDigit: '8', label: 'දසදහස් 8', isCompact: true),
                const SizedBox(width: 6),
                _buildTeachingNumberCard('48321', highlightDigit: '4', label: 'දසදහස් 4', isCompact: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '🎫 8 > 4 > 3 බැවින් 83,214 යනු විශාලම ටිකට්පත වේ.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      );
    } else if (_miniTeachingStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2️⃣ මුල් ස්ථාන සමාන වූ විට:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            '24,785 සහ 24,875 හි දසදහස් සහ දහස් (24) සමානයි.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeachingNumberCard('24785', highlightDigit: '7', label: 'සිය: 7'),
              const Text('<', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF27AE60))),
              _buildTeachingNumberCard('24875', highlightDigit: '8', label: 'සිය: 8'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'සියයස්ථානයෙන් 7 < 8 බැවින්: 24,785 < 24,875 වේ.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3️⃣ මහා රන් දුම්රිය අවසන් ගමන 👑:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'සංඛ්‍යා 5ම නිවැරදි ආරෝහණ පිළිවෙළට සකස් කරමු.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeachingNumberCard('47805', highlightDigit: '0', label: '1 වන', isCompact: true),
                const Text(' ➔ ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                _buildTeachingNumberCard('47850', highlightDigit: '5', label: '2 වන', isCompact: true),
                const Text(' ➔ ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                _buildTeachingNumberCard('70485', highlightDigit: '0', label: '3 වන', isCompact: true),
                const Text(' ➔ ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                _buildTeachingNumberCard('74508', highlightDigit: '0', label: '4 වන', isCompact: true),
                const Text(' ➔ ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                _buildTeachingNumberCard('74580', highlightDigit: '8', label: '5 වන', isCompact: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '👑 සුබ පැතුම්! ඔබ මහා සංඛ්‍යා දුම්රියේ සියලුම නීති ප්‍රගුණ කර ඇත!',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildTeachingNumberCard(String numberStr,
      {required String highlightDigit, required String label, bool isCompact = false}) {
    final useCompact = isCompact || numberStr.length >= 5;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: useCompact ? 8.0 : 14.0,
        vertical: useCompact ? 8.0 : 12.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD166), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            numberStr,
            style: TextStyle(
              fontSize: useCompact ? 16.0 : 22.0,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: useCompact ? 6.0 : 8.0,
              vertical: 2.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.mathOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: useCompact ? 9.0 : 10.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 4. CONCEPT REWARD PHASE ───

  Widget _buildConceptRewardPhase() {
    final hasNextConcept =
        _currentConceptIndex < NumberTrainData.allConcepts.length - 1;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏅', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 12),
              Text(
                _getRewardTitle(_currentConceptIndex),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF6C5CE7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _getRewardBadgeText(_currentConceptIndex),
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // XP Reward Container
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD166), width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚡ ', style: TextStyle(fontSize: 24)),
                    Text(
                      _getXpRewardText(_currentConceptIndex),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (hasNextConcept) {
                      _nextConcept();
                    } else {
                      _soundService.playClick();
                      _progressService.completeLesson('maths', 'math_grade5_02');
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mathOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    hasNextConcept
                        ? Icons.arrow_forward_rounded
                        : Icons.emoji_events_rounded,
                    size: 22,
                  ),
                  label: Text(
                    hasNextConcept
                        ? 'ඊළඟ නැවතුමට යමු 🚂 ➔'
                        : 'පාඩම සාර්ථකයි! ආපසු සිතියමට 🗺️',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getXpRewardText(int index) {
    if (index == 4) {
      return '+200 XP ළඟා කරගත්තා!';
    } else if (index == 5) {
      return '+300 XP ළඟා කරගත්තා!';
    }
    return '+150 XP ළඟා කරගත්තා!';
  }

  String _getRewardTitle(int index) {
    switch (index) {
      case 0:
        return 'ජයග්‍රාහී පළමු නැවතුම! 🏆';
      case 1:
        return 'ජයග්‍රාහී දෙවන නැවතුම! 🏆';
      case 2:
        return 'ජයග්‍රාහී තෙවන නැවතුම! 🏆';
      case 3:
        return 'ජයග්‍රාහී හතරවන නැවතුම! 🏆';
      case 4:
        return 'ජයග්‍රාහී පස්වන නැවතුම! 🏆';
      case 5:
        return 'මහා සංඛ්‍යා දුම්රිය ජයග්‍රහණය! 👑';
      default:
        return 'ජයග්‍රාහී නැවතුම! 🏆';
    }
  }

  String _getRewardBadgeText(int index) {
    switch (index) {
      case 0:
        return 'සංඛ්‍යා සසඳන වීරයා බැජ් එක හිමි කරගත්තා!';
      case 1:
        return 'සංඛ්‍යා පටිපාටිගත කිරීමේ වීරයා බැජ් එක හිමි කරගත්තා!';
      case 2:
        return 'ඉලක්කම් නිර්මාණ වීරයා බැජ් එක හිමි කරගත්තා!';
      case 3:
        return 'දහස් කඳුකර වීරයා බැජ් එක හිමි කරගත්තා!';
      case 4:
        return 'අභියෝග දුම්රිය වීරයා බැජ් එක හිමි කරගත්තා!';
      case 5:
        return 'මහා සංඛ්‍යා වීරයා බැජ් එක හිමි කරගත්තා!';
      default:
        return 'ගණිත ශූරයා බැජ් එක හිමි කරගත්තා!';
    }
  }
}
