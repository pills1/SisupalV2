import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../data/maths/golden_mango_data.dart';
import '../../models/maths/golden_mango_models.dart';
import '../../services/progress_service.dart';
import '../../services/sound_service.dart';
import '../../services/math_curriculum_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/animated_widgets.dart';
import 'golden_mango_exercise_engine_screen.dart';
import 'games/maths_game_hub_screen.dart';

/// ============================================
/// GOLDEN MANGO LESSON SCREEN (Sinhala Localized)
/// Interactive story-driven Mathematics lesson player.
///
/// State machine:
///   STORY_BEAT → EXERCISE_PLACEHOLDER → CONCEPT_REWARD → NEXT_CONCEPT
///   After concept 5 → FINAL_CELEBRATION
/// ============================================
class GoldenMangoLessonScreen extends StatefulWidget {
  final int studentGrade;
  final int conceptIndex;

  const GoldenMangoLessonScreen({
    super.key,
    required this.studentGrade,
    this.conceptIndex = 0,
  });

  @override
  State<GoldenMangoLessonScreen> createState() =>
      _GoldenMangoLessonScreenState();
}

/// Story player phase
enum _StoryPhase {
  storyBeat,
  conceptReward,
  finalCelebration,
}

class _GoldenMangoLessonScreenState extends State<GoldenMangoLessonScreen>
    with TickerProviderStateMixin {
  final SoundService _soundService = SoundService();
  final ProgressService _progressService = ProgressService();

  // Story state
  late int _currentConceptIndex;
  int _currentBeatIndex = 0;
  _StoryPhase _phase = _StoryPhase.storyBeat;

  // Live story beats cache from Firestore
  final Map<String, List<StoryBeat>> _liveStoryBeatsMap = {};

  // Debounce rapid taps
  bool _isTransitioning = false;

  // Animation controllers
  late AnimationController _characterController;
  late AnimationController _dialogueController;

  // Character animations
  late Animation<Offset> _slideFromLeftAnim;
  late Animation<Offset> _slideFromRightAnim;
  late Animation<double> _popInScaleAnim;
  late Animation<double> _fadeInAnim;

  // Dialogue fade/slide
  late Animation<double> _dialogueFadeAnim;
  late Animation<Offset> _dialogueSlideAnim;

  // Confetti for final celebration
  late ConfettiController _confettiController;

  // Track which character was last shown (for idle display)
  StoryCharacter? _lastShownSpeaker;

  @override
  void initState() {
    super.initState();
    _currentConceptIndex = widget.conceptIndex;

    // Character entrance animation
    _characterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideFromLeftAnim = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _characterController, curve: Curves.easeOutCubic));

    _slideFromRightAnim = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _characterController, curve: Curves.easeOutCubic));

    _popInScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _characterController, curve: Curves.elasticOut));

    _fadeInAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _characterController, curve: Curves.easeIn));

    // Dialogue bubble entrance
    _dialogueController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _dialogueFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _dialogueController, curve: Curves.easeOut));

    _dialogueSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _dialogueController, curve: Curves.easeOutCubic));

    // Confetti
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));

    // Play initial beat animation
    _playBeatAnimations();

    // Fetch live story beats from Firestore in background
    _loadLiveStoryBeats();
  }

  Future<void> _loadLiveStoryBeats() async {
    try {
      for (final c in GoldenMangoData.concepts) {
        final beats =
            await MathCurriculumService().getGoldenMangoStoryBeats(c.id);
        if (mounted && beats.isNotEmpty) {
          setState(() {
            _liveStoryBeatsMap[c.id] = beats;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _characterController.dispose();
    _dialogueController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // ─── ACCESSORS ───

  GoldenMangoConcept get _currentConcept =>
      GoldenMangoData.concepts[_currentConceptIndex];

  List<StoryBeat> get _currentBeats =>
      _liveStoryBeatsMap[_currentConcept.id] ?? _currentConcept.beats;

  StoryBeat get _currentBeat {
    final beats = _currentBeats;
    if (_currentBeatIndex >= beats.length) {
      return beats.last;
    }
    return beats[_currentBeatIndex];
  }

  bool get _isLastConcept =>
      _currentConceptIndex >= GoldenMangoData.totalConcepts - 1;

  // ─── STATE TRANSITIONS ───

  Future<void> _playBeatAnimations() async {
    _characterController.reset();
    _dialogueController.reset();
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    _characterController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _dialogueController.forward();
  }

  void _advanceBeat() {
    if (_isTransitioning) return;

    final beat = _currentBeat;

    if (beat.isFinal || _currentBeatIndex >= _currentBeats.length - 1) {
      // Launch exercise placeholder
      _launchExercise();
      return;
    }

    if (_currentBeatIndex < _currentBeats.length - 1) {
      setState(() {
        _lastShownSpeaker = _currentBeat.speaker;
        _currentBeatIndex++;
      });
      _playBeatAnimations();
    }
  }

  Future<void> _launchExercise() async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    final concept = _currentConcept;

    // Launch real adaptive Golden Mango exercise engine
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GoldenMangoExerciseEngineScreen(
          conceptId: concept.id,
          conceptTitle: concept.title,
          learningObjective: concept.learningObjective,
        ),
      ),
    );

    if (!mounted) return;
    _isTransitioning = false;

    if (result == true) {
      _soundService.playCorrect();
      _showConceptReward();
    }
  }

  void _showConceptReward() {
    setState(() {
      _phase = _StoryPhase.conceptReward;
    });
  }

  void _advanceToConcept() {
    if (_isTransitioning) return;
    _isTransitioning = true;

    if (_isLastConcept) {
      // All 5 concepts done → final celebration
      _completeLessonAndCelebrate();
      return;
    }

    setState(() {
      _currentConceptIndex++;
      _currentBeatIndex = 0;
      _lastShownSpeaker = null;
      _phase = _StoryPhase.storyBeat;
    });

    _isTransitioning = false;
    _playBeatAnimations();
  }

  Future<void> _completeLessonAndCelebrate() async {
    // Persist completion using existing ProgressService
    try {
      await _progressService.completeLesson(
          'Mathematics', GoldenMangoData.lessonId);
    } catch (_) {}

    if (!mounted) return;

    _confettiController.play();
    _soundService.playLevelUp();

    setState(() {
      _phase = _StoryPhase.finalCelebration;
    });
    _isTransitioning = false;
  }

  // ─── BUILD ───

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await _showExitConfirmation();
        if (shouldLeave && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background layer
            _buildBackground(),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top bar with progress
                  _buildTopBar(),

                  // Story content area
                  Expanded(
                    child: _buildPhaseContent(),
                  ),
                ],
              ),
            ),

            // Confetti overlay for final celebration
            if (_phase == _StoryPhase.finalCelebration)
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFFFF6B35),
                    Color(0xFFFFD700),
                    Color(0xFF6C5CE7),
                    Color(0xFF27AE60),
                    Color(0xFFE17055),
                  ],
                  numberOfParticles: 30,
                  maxBlastForce: 20,
                  minBlastForce: 5,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── BACKGROUND ───

  Widget _buildBackground() {
    final bgAsset = _currentConcept.backgroundAsset;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: SizedBox.expand(
        key: ValueKey(bgAsset),
        child: Image.asset(
          bgAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0C29), Color(0xFF302B63)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── TOP BAR ───

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () async {
              final shouldLeave = await _showExitConfirmation();
              if (shouldLeave && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),

          // Concept title
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'සංකල්පය ${_currentConceptIndex + 1} / ${GoldenMangoData.totalConcepts}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentConcept.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Progress dots
          const Text('🥭 ', style: TextStyle(fontSize: 18)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(GoldenMangoData.totalConcepts, (i) {
              return Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= _currentConceptIndex
                      ? const Color(0xFFFFD700)
                      : Colors.white.withOpacity(0.3),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── PHASE CONTENT ───

  Widget _buildPhaseContent() {
    switch (_phase) {
      case _StoryPhase.storyBeat:
        return _buildStoryBeatView();
      case _StoryPhase.conceptReward:
        return _buildConceptRewardView();
      case _StoryPhase.finalCelebration:
        return _buildFinalCelebrationView();
    }
  }

  // ─── STORY BEAT VIEW ───

  Widget _buildStoryBeatView() {
    final beat = _currentBeat;
    final speaker = beat.speaker;

    return Column(
      children: [
        // Character display area
        Expanded(
          flex: 5,
          child: _buildCharacterStage(speaker),
        ),

        // Dialogue panel
        Expanded(
          flex: 4,
          child: _buildDialoguePanel(beat),
        ),
      ],
    );
  }

  Widget _buildCharacterStage(StoryCharacter activeSpeaker) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final charSize = constraints.maxHeight * 0.7;
        final clampedSize = charSize.clamp(80.0, 160.0);

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Previously shown characters (idle/faded)
            if (_lastShownSpeaker != null &&
                _lastShownSpeaker != activeSpeaker)
              Positioned(
                bottom: 8,
                left: _lastShownSpeaker == StoryCharacter.leo
                    ? constraints.maxWidth * 0.05
                    : null,
                right: _lastShownSpeaker == StoryCharacter.ella
                    ? constraints.maxWidth * 0.05
                    : null,
                child: Opacity(
                  opacity: 0.4,
                  child: _buildCharacterImage(
                      _lastShownSpeaker!, clampedSize * 0.7),
                ),
              ),

            // Active speaker (animated entrance)
            Positioned(
              bottom: 8,
              left: activeSpeaker == StoryCharacter.leo
                  ? constraints.maxWidth * 0.08
                  : null,
              right: activeSpeaker == StoryCharacter.ella
                  ? constraints.maxWidth * 0.08
                  : null,
              child: _buildAnimatedCharacter(activeSpeaker,
                  _currentBeat.resolvedAnimation, clampedSize),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedCharacter(
      StoryCharacter character, StoryAnimation anim, double size) {
    Widget charWidget = _buildCharacterImage(character, size);

    switch (anim) {
      case StoryAnimation.slideFromLeft:
        return SlideTransition(
          position: _slideFromLeftAnim,
          child: FadeTransition(
            opacity: _fadeInAnim,
            child: charWidget,
          ),
        );
      case StoryAnimation.slideFromRight:
        return SlideTransition(
          position: _slideFromRightAnim,
          child: FadeTransition(
            opacity: _fadeInAnim,
            child: charWidget,
          ),
        );
      case StoryAnimation.popIn:
        return AnimatedBuilder(
          animation: _popInScaleAnim,
          builder: (_, child) => Transform.scale(
            scale: _popInScaleAnim.value,
            child: Opacity(
              opacity: _fadeInAnim.value.clamp(0.0, 1.0),
              child: child,
            ),
          ),
          child: charWidget,
        );
      case StoryAnimation.fadeIn:
        return FadeTransition(
          opacity: _fadeInAnim,
          child: charWidget,
        );
    }
  }

  Widget _buildCharacterImage(StoryCharacter character, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: character.themeColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: character.themeColor.withOpacity(0.4),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          character.assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: character.themeColor.withOpacity(0.2),
            child: Center(
              child: Text(character.emoji,
                  style: TextStyle(fontSize: size * 0.5)),
            ),
          ),
        ),
      ),
    );
  }

  // ─── DIALOGUE PANEL ───

  Widget _buildDialoguePanel(StoryBeat beat) {
    final speaker = beat.speaker;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.75),
            Colors.black.withOpacity(0.9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speaker name tag
            FadeTransition(
              opacity: _dialogueFadeAnim,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: speaker.themeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(speaker.emoji,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      speaker.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Dialogue text
            Expanded(
              child: SlideTransition(
                position: _dialogueSlideAnim,
                child: FadeTransition(
                  opacity: _dialogueFadeAnim,
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: speaker.bubbleColor.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: speaker.themeColor.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        beat.text,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3436),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Action button
            FadeTransition(
              opacity: _dialogueFadeAnim,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _advanceBeat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: beat.isFinal
                        ? const Color(0xFF27AE60)
                        : AppColors.mathOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    beat.isFinal ? 'අභියෝගයට සූදානම්ද? ⚔️' : 'ඊළඟට ➡️',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── CONCEPT REWARD VIEW ───

  Widget _buildConceptRewardView() {
    final concept = _currentConcept;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Celebration icon
            ScaleInWidget(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA726)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.glowShadow(const Color(0xFFFFD700)),
                ),
                child: const Center(
                  child: Text('⭐', style: TextStyle(fontSize: 48)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SlideInWidget(
              child: Text(
                'සංකල්පය ${_currentConceptIndex + 1} සාර්ථකයි! 🌟',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD700),
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            SlideInWidget(
              delay: const Duration(milliseconds: 200),
              child: Text(
                concept.rewardText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Learning badge
            SlideInWidget(
              delay: const Duration(milliseconds: 400),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school_rounded,
                        color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${concept.learningObjective} ✓',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            SlideInWidget(
              delay: const Duration(milliseconds: 500),
              beginOffset: const Offset(0, 0.5),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _advanceToConcept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLastConcept
                        ? const Color(0xFFFFD700)
                        : AppColors.mathOrange,
                    foregroundColor:
                        _isLastConcept ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  icon: Icon(
                    _isLastConcept
                        ? Icons.emoji_events_rounded
                        : Icons.arrow_forward_rounded,
                    size: 24,
                  ),
                  label: Text(
                    _isLastConcept
                        ? 'රන් අඹ ගෙඩිය ලබාගන්න! 🥭'
                        : 'ඊළඟ ගමන ➡️',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FINAL CELEBRATION VIEW ───

  Widget _buildFinalCelebrationView() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Golden Mango trophy
            PulsingWidget(
              minScale: 0.95,
              maxScale: 1.05,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA726)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.glowShadow(const Color(0xFFFFD700)),
                ),
                child: const Center(
                  child: Text('🥭', style: TextStyle(fontSize: 64)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              '🥭 ජයග්‍රාහී ගමන නිමා විය! 🥭',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFD700),
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            const Text(
              'ඔබ රන් අඹ ගෙඩිය සොයාගත්තා!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            // Character farewell dialogues
            _buildFarewellBubble(StoryCharacter.leo, 'අපි එකතුවෙලා ජයගත්තා!'),
            const SizedBox(height: 12),
            _buildFarewellBubble(
                StoryCharacter.ella, 'ඔයා නියම ගණිත වීරයෙක්!'),
            const SizedBox(height: 12),
            _buildFarewellBubble(
                StoryCharacter.felix, 'මෙහෙම දෙයක්... ඔයා ඔක්කොම ප්‍රහේලිකා විසඳුවාද?!'),

            const SizedBox(height: 28),

            // Stars
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 44),
                Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 44),
                Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 44),
              ],
            ),

            const SizedBox(height: 28),

            // Game button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MathsGameHubScreen(
                          studentGrade: widget.studentGrade),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.sports_esports_rounded,
                    color: Color(0xFFFFD700), size: 24),
                label: const Text(
                  'ගණිත Mini-Games සෙල්ලම් කරමු 🎮',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Return to map
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side:
                      const BorderSide(color: Color(0xFFFFD700), width: 2),
                  foregroundColor: const Color(0xFFFFD700),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.map_rounded, size: 22),
                label: const Text(
                  'Adventure Map වෙත ආපසු යන්න 🗺️',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFarewellBubble(StoryCharacter character, String text) {
    return Row(
      children: [
        _buildCharacterImage(character, 48),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: character.bubbleColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: character.themeColor.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Text(
              '"$text"',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: character.themeColor,
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── EXIT CONFIRMATION ───

  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🥭', style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'ගමනින් ඉවත් වෙනවද?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'දැන් ඉවත් වුණොත් ඔයාගේ ගමනේ ප්‍රගතිය අහිමි වෙයි. ඔබට ඉවත් වීමට අවශ්‍යද?',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('නැත',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mathOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ඉවත් වන්න',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
