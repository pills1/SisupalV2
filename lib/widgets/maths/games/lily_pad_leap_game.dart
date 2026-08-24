import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/maths/lily_pad_leap_model.dart';
import '../../../data/maths/lily_pad_leap_data.dart';
import '../../../services/sound_service.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/animated_widgets.dart';

class LilyPadLeapGameWidget extends StatefulWidget {
  final VoidCallback? onCompleted;

  const LilyPadLeapGameWidget({
    super.key,
    this.onCompleted,
  });

  @override
  State<LilyPadLeapGameWidget> createState() => _LilyPadLeapGameWidgetState();
}

class _LilyPadLeapGameWidgetState extends State<LilyPadLeapGameWidget>
    with TickerProviderStateMixin {
  final SoundService _soundService = SoundService();
  late ConfettiController _confettiController;

  late List<LilyPadLeapChallenge> _challenges;
  int _currentChallengeIndex = 0;

  // Selected leaf choice
  int? _shakingOption;

  // Frog & Pond Animation Controllers
  late AnimationController _sequenceJumpController;
  late AnimationController _journeyJumpController;
  late AnimationController _waterFloatingController;
  late AnimationController _shakeController;

  bool _isJumping = false;
  int _sequenceFrogSlot = 0; // Current slot in 5-pad sequence

  // 3-Attempt System state
  int _attemptCount = 0;
  bool _showHint = false;
  String _activeHintText = '';
  bool _isChallengeComplete = false;

  // Timer per round (45s)
  int _secondsRemaining = 45;
  Timer? _roundTimer;

  // Score tracking
  int _score = 0;
  int _firstTrySuccessCount = 0;

  // 2D Game Asset paths
  static const String _frogAsset = 'assets/images/games/frog_idle.png';
  static const String _lilyPadAsset = 'assets/images/games/lily_pad.png';
  static const String _goldenLotusAsset = 'assets/images/games/golden_lotus.png';

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _sequenceJumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _journeyJumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _waterFloatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _challenges = LilyPadLeapData.generateGameSession();
    _startChallenge();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    _sequenceJumpController.dispose();
    _journeyJumpController.dispose();
    _waterFloatingController.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startChallenge() {
    _roundTimer?.cancel();
    final challenge = _challenges[_currentChallengeIndex];

    setState(() {
      _shakingOption = null;
      _sequenceFrogSlot = challenge.missingIndex > 0 ? challenge.missingIndex - 1 : 0;
      _isJumping = false;
      _attemptCount = 0;
      _showHint = false;
      _activeHintText = '';
      _isChallengeComplete = false;
      _secondsRemaining = 45;
    });

    _roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0 && !_isChallengeComplete) {
        setState(() => _secondsRemaining--);
      } else if (_secondsRemaining == 0 && !_isChallengeComplete) {
        _roundTimer?.cancel();
        _soundService.playWrong();
        setState(() {
          _showHint = true;
          _activeHintText = 'කාලය අවසන්! අපි නැවත උත්සාහ කරමු.';
        });
      }
    });
  }

  void _onSelectChoice(int choice) {
    if (_isJumping || _isChallengeComplete) return;

    final challenge = _challenges[_currentChallengeIndex];
    final bool isCorrect = choice == challenge.correctAnswer;

    _soundService.playClick();
    _attemptCount++;

    if (isCorrect) {
      // CORRECT HOP
      _roundTimer?.cancel();
      _soundService.playCorrect();

      int points = _attemptCount == 1 ? 30 : 15;
      _score += points;
      if (_attemptCount == 1) _firstTrySuccessCount++;

      setState(() => _isJumping = true);

      // Trigger sequence hop and journey jump together
      _sequenceJumpController.forward(from: 0.0);
      _journeyJumpController.forward(from: 0.0).then((_) {
        if (!mounted) return;
        setState(() {
          _sequenceFrogSlot = challenge.missingIndex;
          _isJumping = false;
          _isChallengeComplete = true;
          _activeHintText =
              'නියමයි! රටාව: ${challenge.patternRuleSinhala}';
        });

        _recordAttemptTelemetry(
          challenge: challenge,
          answerGiven: choice.toString(),
          isCorrect: true,
          hintUsed: _showHint,
        );

        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted && _isChallengeComplete) {
            _nextChallenge();
          }
        });
      });
    } else {
      // WRONG HOP / SHAKE
      _soundService.playWrong();
      _shakeController.forward(from: 0.0);

      setState(() {
        _shakingOption = choice;
      });

      if (_attemptCount == 1) {
        setState(() {
          _showHint = true;
          _activeHintText = challenge.hint1Sinhala;
        });
      } else if (_attemptCount == 2) {
        setState(() {
          _showHint = true;
          _activeHintText = challenge.hint2Sinhala;
        });
      } else {
        _roundTimer?.cancel();
        setState(() {
          _isChallengeComplete = true;
          _activeHintText =
              'නිවැරදි පිළිතුර: ${challenge.explanationSinhala}';
        });

        _recordAttemptTelemetry(
          challenge: challenge,
          answerGiven: choice.toString(),
          isCorrect: false,
          hintUsed: true,
        );
      }
    }
  }

  void _recordAttemptTelemetry({
    required LilyPadLeapChallenge challenge,
    required String answerGiven,
    required bool isCorrect,
    required bool hintUsed,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('question_attempts')
          .add({
        'studentId': user.uid,
        'lessonId': 'math_grade5_01',
        'gameId': 'lily_pad_leap',
        'challengeId': challenge.id,
        'attemptNumber': _attemptCount,
        'answerGiven': answerGiven,
        'correctAnswer': challenge.correctAnswer.toString(),
        'isCorrect': isCorrect,
        'hintUsed': hintUsed,
        'hintLevel': _attemptCount,
        'skillTag': 'number_patterns',
        'difficulty': challenge.difficultyLevel,
        'interactionType': 'lily_pad_leap',
        'source': 'game',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  void _nextChallenge() async {
    if (_currentChallengeIndex < _challenges.length - 1) {
      setState(() => _currentChallengeIndex++);
      _startChallenge();
    } else {
      _soundService.playLevelUp();
      _confettiController.play();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'xp': FieldValue.increment(150),
        }, SetOptions(merge: true));
      }

      _showVictoryDialog();
    }
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F382C), Color(0xFF1B5E20)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFD700), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(_frogAsset, width: 72, height: 72),
                  const SizedBox(width: 14),
                  Image.asset(_goldenLotusAsset, width: 72, height: 72),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'දිය ගෙම්බාගේ ජයග්‍රහණය!',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'ඔයා සියලුම සංඛ්‍යා රටා නිවැරදිව හඳුනාගෙන රන් නෙළුම වෙත ළඟා වුණා!',
                style: TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(Icons.star_rounded, '+150 XP', const Color(0xFFFFD700)),
                    _buildStatItem(Icons.gps_fixed_rounded, '$_firstTrySuccessCount/6 First Try', const Color(0xFF2ECC71)),
                    _buildStatItem(Icons.diamond_rounded, '$_score pts', const Color(0xFF00CEC9)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  if (widget.onCompleted != null) widget.onCompleted!();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'ක්‍රීඩා හබ් වෙත',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _challenges[_currentChallengeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF082620),
      body: Stack(
        children: [
          // 1. Crystal-Clear Deep Water Gradient (Clean, distraction-free)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF134E45), // Deep clear emerald
                    Color(0xFF0D3B34),
                    Color(0xFF06231E),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top HUD (Lives, Title, Timer, Score)
                _buildHUD(challenge),

                // Simplified Progress Bar with dot indicators + LinearProgressIndicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: _buildSimplifiedProgressBar(),
                ),

                // Math Parrot Dialogue
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: _buildParrotDialogueCard(challenge),
                ),

                // Main Central Arena: Grounded Frog/Lotus on Lily Pads
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _buildMainSequenceArena(challenge),
                    ),
                  ),
                ),

                // Bottom 3 Large Shuffled Choice Cards
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildChoiceRow(challenge),
                ),
              ],
            ),
          ),

          // Confetti Celebration
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHUD(LilyPadLeapChallenge challenge) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF2ECC71).withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hearts / Lives (Material icons, no emoji)
          Row(
            children: List.generate(3, (idx) {
              bool isActive = idx >= _attemptCount;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  isActive
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isActive
                      ? const Color(0xFFFF4757)
                      : Colors.white24,
                  size: 22,
                ),
              );
            }),
          ),

          // Title (plain text, no emoji)
          Flexible(
            child: Text(
              challenge.title,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Timer & Score
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9F43).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded,
                        color: Color(0xFFFF9F43), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      '${_secondsRemaining}s',
                      style: const TextStyle(
                        color: Color(0xFFFF9F43),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFD700), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimplifiedProgressBar() {
    final double progress = (_currentChallengeIndex + (_isChallengeComplete ? 1 : 0)) / 6;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          // Header row with properly-sized icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Image.asset(_frogAsset, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'පොකුණ තරණය',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'පියවර ${_currentChallengeIndex + 1}/6',
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 13,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Image.asset(_goldenLotusAsset, fit: BoxFit.contain),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Linear progress bar only — no dot indicators
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParrotDialogueCard(LilyPadLeapChallenge challenge) {
    String textToDisplay = _showHint
        ? _activeHintText
        : 'පොකුණේ හිස් තැනට ගැළපෙන නෙළුම් පත්‍රය තෝරා පනින්න!';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD166), width: 2),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        children: [
          // Parrot avatar from local asset (no emoji fallback)
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                MathsAssets.parrotIdle,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.smart_toy_rounded,
                      color: Color(0xFF4CAF50), size: 24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              textToDisplay,
              style: const TextStyle(
                color: Color(0xFF3E2723),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // REQ 2 & 3: Main Sequence Arena — frog/lotus GROUNDED on lily pads via
  //            Stack + Positioned, and '?' badge uses BoxShape.circle
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildMainSequenceArena(LilyPadLeapChallenge challenge) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(challenge.sequence.length, (index) {
          final isMissingSlot = index == challenge.missingIndex;
          final value = challenge.sequence[index];
          final hasFrog = _sequenceFrogSlot == index;
          final isAnswered = isMissingSlot && _isChallengeComplete;
          final isLastPad = index == challenge.sequence.length - 1;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Grounded frog / lotus on lily pad via Stack ──
                SizedBox(
                  width: 110,
                  height: 140,
                  child: AnimatedBuilder(
                    animation: _waterFloatingController,
                    builder: (context, child) {
                      final floatOffset = math.sin(
                              _waterFloatingController.value *
                                  math.pi *
                                  (index % 2 == 0 ? 1 : -1)) *
                          4;
                      return Transform.translate(
                        offset: Offset(0, floatOffset),
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Lily Pad at the bottom of the Stack
                            Positioned(
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: isMissingSlot
                                      ? [
                                          BoxShadow(
                                            color: (isAnswered
                                                    ? const Color(0xFF2ECC71)
                                                    : const Color(0xFFFFD700))
                                                .withValues(alpha: 0.7),
                                            blurRadius: 24,
                                            spreadRadius: 4,
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.4),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                ),
                                child: Image.asset(
                                  _lilyPadAsset,
                                  width: 100,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            // Frog grounded: bottom edge overlaps center-top of lily pad
                            if (hasFrog)
                              Positioned(
                                bottom: 50, // bottom of frog sits at center-top of pad
                                child: AnimatedBuilder(
                                  animation: _sequenceJumpController,
                                  builder: (context, child) {
                                    double hopY = 0.0;
                                    if (_isJumping) {
                                      hopY = -math.sin(
                                              _sequenceJumpController.value *
                                                  math.pi) *
                                          44;
                                    }
                                    return Transform.translate(
                                      offset: Offset(0, hopY),
                                      child: Image.asset(
                                        _frogAsset,
                                        width: 68,
                                        height: 68,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  },
                                ),
                              ),

                            // Golden lotus grounded on last pad (when frog is elsewhere)
                            if (isLastPad && !hasFrog)
                              Positioned(
                                bottom: 52,
                                child: Image.asset(
                                  _goldenLotusAsset,
                                  width: 50,
                                  height: 50,
                                ),
                              ),

                            // Number badge on the lily pad center
                            Positioned(
                              bottom: 20,
                              child: Container(
                                width: isMissingSlot ? 40 : null,
                                height: isMissingSlot ? 40 : null,
                                padding: isMissingSlot
                                    ? null
                                    : const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  // REQ 3: Circle shape for the '?' target
                                  shape: isMissingSlot
                                      ? BoxShape.circle
                                      : BoxShape.rectangle,
                                  borderRadius: isMissingSlot
                                      ? null
                                      : BorderRadius.circular(12),
                                  color: isMissingSlot
                                      ? (isAnswered
                                          ? const Color(0xFF2ECC71)
                                          : const Color(0xFFFFD700))
                                      : Colors.black.withValues(alpha: 0.6),
                                  border: Border.all(
                                    color: isMissingSlot
                                        ? Colors.white
                                        : Colors.white24,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    isMissingSlot
                                        ? (isAnswered
                                            ? '${challenge.correctAnswer}'
                                            : '?')
                                        : '$value',
                                    style: TextStyle(
                                      color: isMissingSlot && !isAnswered
                                          ? const Color(0xFF3E2723)
                                          : Colors.white,
                                      fontSize: (value ?? 0) > 999 ? 13 : 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'පියවර ${index + 1}',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// 3 Large Shuffled Choice Cards at the Bottom (no emoji)
  Widget _buildChoiceRow(LilyPadLeapChallenge challenge) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(_lilyPadAsset, width: 18, height: 14),
            const SizedBox(width: 6),
            const Text(
              'පනින්න නිවැරදි නෙළුම් කොළය තෝරන්න',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: challenge.options.map((option) {
            final isShaking = _shakingOption == option;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    double shakeOffset = 0.0;
                    if (isShaking) {
                      shakeOffset =
                          math.sin(_shakeController.value * 6 * math.pi) * 8;
                    }
                    return Transform.translate(
                      offset: Offset(shakeOffset, 0),
                      child: BouncingButton(
                        onPressed: _isChallengeComplete
                            ? null
                            : () => _onSelectChoice(option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF047857)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: const Color(0xFF6EE7B7), width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF059669)
                                    .withValues(alpha: 0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$option',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
