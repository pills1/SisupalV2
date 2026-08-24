import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/maths/number_archery_model.dart';
import '../../../data/maths/number_archery_data.dart';
import '../../../services/sound_service.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/animated_widgets.dart';

class NumberArcheryGameWidget extends StatefulWidget {
  final VoidCallback? onCompleted;

  const NumberArcheryGameWidget({
    super.key,
    this.onCompleted,
  });

  @override
  State<NumberArcheryGameWidget> createState() => _NumberArcheryGameWidgetState();
}

class _NumberArcheryGameWidgetState extends State<NumberArcheryGameWidget>
    with TickerProviderStateMixin {
  final SoundService _soundService = SoundService();
  late ConfettiController _confettiController;

  late List<NumberArcheryChallenge> _challenges;
  int _currentChallengeIndex = 0;

  // Selected Target
  int _selectedTargetIndex = -1;
  int _shakingTargetIndex = -1;
  int _hitTargetIndex = -1;

  // Bow & Arrow Animation
  double _bowAngle = 0.0;
  bool _isShooting = false;
  late AnimationController _shootAnimationController;
  late AnimationController _targetPulseController;
  late AnimationController _shakeAnimationController;

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

  // 2D Game Assets
  static const String _bowAsset = MathsAssets.archeryBow;
  static const String _arrowAsset = MathsAssets.archeryArrow;
  static const String _targetAsset = MathsAssets.archeryTarget;
  static const String _crosshairAsset = MathsAssets.archeryCrosshair;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _shootAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _targetPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shakeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _challenges = NumberArcheryData.generateGameSession();
    _startChallenge();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    _shootAnimationController.dispose();
    _targetPulseController.dispose();
    _shakeAnimationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startChallenge() {
    _roundTimer?.cancel();

    setState(() {
      _selectedTargetIndex = -1;
      _shakingTargetIndex = -1;
      _hitTargetIndex = -1;
      _bowAngle = 0.0;
      _isShooting = false;
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

  void _selectTarget(int index, Size arenaSize) {
    if (_isShooting || _isChallengeComplete) return;
    _soundService.playClick();

    final targetPos = _getTargetPosition(index, arenaSize);
    final bowPos = Offset(arenaSize.width / 2, arenaSize.height - 40);

    final dx = targetPos.dx - bowPos.dx;
    final dy = targetPos.dy - bowPos.dy;
    final angle = math.atan2(dx, -dy);

    setState(() {
      _selectedTargetIndex = index;
      _bowAngle = angle;
      _shakingTargetIndex = -1;
    });
  }

  Offset _getTargetPosition(int index, Size size) {
    final count = _challenges[_currentChallengeIndex].targetOptions.length;
    final step = size.width / (count + 1);
    return Offset(step * (index + 1), size.height * 0.32);
  }

  void _shootArrow() {
    if (_isShooting || _isChallengeComplete || _selectedTargetIndex == -1) return;

    final challenge = _challenges[_currentChallengeIndex];
    final selectedValue = challenge.targetOptions[_selectedTargetIndex];
    final bool isCorrect = selectedValue == challenge.correctRoundedNumber;

    _soundService.playClick();
    _attemptCount++;

    setState(() => _isShooting = true);

    _shootAnimationController.forward(from: 0.0).then((_) {
      if (!mounted) return;

      if (isCorrect) {
        // BULLSEYE HIT!
        _roundTimer?.cancel();
        _soundService.playCorrect();

        int points = _attemptCount == 1 ? 30 : 15;
        _score += points;
        if (_attemptCount == 1) _firstTrySuccessCount++;

        setState(() {
          _isShooting = false;
          _hitTargetIndex = _selectedTargetIndex;
          _isChallengeComplete = true;
          _activeHintText = 'නියම ඉලක්කය! ${challenge.explanationSinhala}';
        });

        _recordAttemptTelemetry(
          challenge: challenge,
          answerGiven: selectedValue.toString(),
          isCorrect: true,
          hintUsed: _showHint,
        );

        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted && _isChallengeComplete) {
            _nextChallenge();
          }
        });
      } else {
        // MISS / WRONG HIT
        _soundService.playWrong();
        _shakeAnimationController.forward(from: 0.0);

        setState(() {
          _isShooting = false;
          _shakingTargetIndex = _selectedTargetIndex;
          _selectedTargetIndex = -1;
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
            _activeHintText = 'නිවැරදි පිළිතුර: ${challenge.explanationSinhala}';
          });

          _recordAttemptTelemetry(
            challenge: challenge,
            answerGiven: selectedValue.toString(),
            isCorrect: false,
            hintUsed: true,
          );
        }
      }
    });
  }

  void _recordAttemptTelemetry({
    required NumberArcheryChallenge challenge,
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
        'gameId': 'number_archery',
        'challengeId': challenge.id,
        'attemptNumber': _attemptCount,
        'answerGiven': answerGiven,
        'correctAnswer': challenge.correctRoundedNumber.toString(),
        'isCorrect': isCorrect,
        'hintUsed': hintUsed,
        'hintLevel': _attemptCount,
        'skillTag': 'rounding_numbers',
        'difficulty': challenge.difficultyLevel,
        'interactionType': 'number_archery',
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
              colors: [Color(0xFF2C1810), Color(0xFF5D2E14)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFD700), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
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
                  Image.asset(_bowAsset, width: 64, height: 64, fit: BoxFit.contain),
                  const SizedBox(width: 14),
                  Image.asset(_targetAsset, width: 64, height: 64, fit: BoxFit.contain),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'දක්ෂ දුනු ශිල්පියා!',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'ඔයා සියලුම සංඛ්‍යා වැටයීමේ අභියෝග නිවැරදිව ඉලක්ක කළා!',
                style: TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'ක්‍රීඩා හබ් වෙත',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _challenges[_currentChallengeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1E140C),
      body: Stack(
        children: [
          // Archery Field Background
          Positioned.fill(child: _buildArcheryBackground()),

          SafeArea(
            child: Column(
              children: [
                // Top HUD
                _buildHUD(challenge),

                // Prompt Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: _buildPromptBanner(challenge),
                ),

                // Math Parrot Dialogue
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: _buildParrotDialogueCard(challenge),
                ),

                // Archery Arena with Targets, Bow, and Flying Arrow
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final arenaSize = Size(constraints.maxWidth, constraints.maxHeight);

                      return Stack(
                        children: [
                          // Target Boards
                          for (int i = 0; i < challenge.targetOptions.length; i++)
                            _buildTargetBoard(i, arenaSize, challenge),

                          // Flying Arrow Animation
                          if (_isShooting && _selectedTargetIndex != -1)
                            _buildFlyingArrow(arenaSize),

                          // Bow at Bottom Center
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildBow(arenaSize),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Action / Shoot Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                  child: _buildShootButton(),
                ),
              ],
            ),
          ),

          // Confetti
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

  Widget _buildArcheryBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E140C),
            Color(0xFF3E2718),
            Color(0xFF2C1810),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildHUD(NumberArcheryChallenge challenge) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE67E22).withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lives
          Row(
            children: List.generate(3, (idx) {
              bool isActive = idx >= _attemptCount;
              return Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Icon(
                  isActive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isActive ? const Color(0xFFFF4757) : Colors.white24,
                  size: 20,
                ),
              );
            }),
          ),

          // Score Badge
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
              const SizedBox(width: 2),
              Text(
                '$_score',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Round & Timer
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE67E22).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_currentChallengeIndex + 1}/${_challenges.length}',
                  style: const TextStyle(
                    color: Color(0xFFF39C12),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, color: Color(0xFFFF7675), size: 13),
                    const SizedBox(width: 2),
                    Text(
                      '${_secondsRemaining}s',
                      style: const TextStyle(
                        color: Color(0xFFFF7675),
                        fontSize: 11,
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

  Widget _buildPromptBanner(NumberArcheryChallenge challenge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE67E22), Color(0xFFD35400)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE67E22).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'මුල් සංඛ්‍යාව',
                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                challenge.formattedOriginal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed_rounded, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 6),
                Text(
                  challenge.roundingInstruction,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParrotDialogueCard(NumberArcheryChallenge challenge) {
    String textToDisplay = _showHint
        ? _activeHintText
        : '${challenge.formattedOriginal} හි නිවැරදි වැටයූ අගය ඇති ඉලක්කය තෝරා විදින්න!';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD166), width: 2),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                MathsAssets.parrotIdle,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.smart_toy_rounded,
                      color: Color(0xFF4CAF50), size: 22),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              textToDisplay,
              style: const TextStyle(
                color: Color(0xFF3E2723),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetBoard(int index, Size arenaSize, NumberArcheryChallenge challenge) {
    final pos = _getTargetPosition(index, arenaSize);
    final value = challenge.targetOptions[index];
    final isSelected = _selectedTargetIndex == index;
    final isHit = _hitTargetIndex == index;
    final isShaking = _shakingTargetIndex == index;

    return AnimatedBuilder(
      animation: _shakeAnimationController,
      builder: (context, child) {
        double shakeOffset = 0.0;
        if (isShaking) {
          shakeOffset = math.sin(_shakeAnimationController.value * 6 * math.pi) * 8;
        }

        return Positioned(
          left: pos.dx - 48 + shakeOffset,
          top: pos.dy - 48,
          child: GestureDetector(
            onTap: () => _selectTarget(index, arenaSize),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 2D Archery Target Asset + Overlay Number
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Target Board Asset
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isSelected ? 96 : 88,
                      height: isSelected ? 96 : 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Image.asset(
                        _targetAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFC0392B),
                          ),
                        ),
                      ),
                    ),

                    // Crosshair overlay when selected
                    if (isSelected && !isHit)
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: Image.asset(
                          _crosshairAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.gps_fixed_rounded,
                            color: Color(0xFFFFD700),
                            size: 32,
                          ),
                        ),
                      ),

                    // Target Number Pill Overlay
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFD700)
                            : (isHit
                                ? const Color(0xFF2ECC71)
                                : Colors.black.withValues(alpha: 0.75)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white54,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '$value',
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF2C1810) : Colors.white,
                          fontSize: (value > 999) ? 12 : 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ඉලක්කය ${index + 1}',
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFFFD700) : Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlyingArrow(Size arenaSize) {
    final targetPos = _getTargetPosition(_selectedTargetIndex, arenaSize);
    final bowPos = Offset(arenaSize.width / 2, arenaSize.height - 40);

    return AnimatedBuilder(
      animation: _shootAnimationController,
      builder: (context, child) {
        final double t = Curves.easeInQuad.transform(_shootAnimationController.value);
        final currentX = bowPos.dx + (targetPos.dx - bowPos.dx) * t;
        final currentY = bowPos.dy + (targetPos.dy - bowPos.dy) * t;

        return Positioned(
          left: currentX - 18,
          top: currentY - 18,
          child: Transform.rotate(
            angle: _bowAngle,
            child: Image.asset(
              _arrowAsset,
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.navigation_rounded,
                color: Color(0xFFFFD700),
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBow(Size arenaSize) {
    return Transform.rotate(
      angle: _bowAngle,
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: 90,
        height: 75,
        child: Image.asset(
          _bowAsset,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            width: 60,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE67E22), width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.arrow_upward_rounded, color: Color(0xFFE67E22), size: 36),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShootButton() {
    final bool hasSelection = _selectedTargetIndex != -1;
    final bool isActive = hasSelection || _isChallengeComplete;

    final String btnText = _isChallengeComplete
        ? 'ඊළඟ අභියෝගය'
        : (hasSelection ? 'විදින්න (Shoot Arrow)' : 'ඉලක්කයක් තෝරන්න');

    return BouncingButton(
      onPressed: _isChallengeComplete
          ? _nextChallenge
          : (hasSelection ? _shootArrow : null),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isChallengeComplete
                ? [const Color(0xFF2ECC71), const Color(0xFF27AE60)]
                : (hasSelection
                    ? [const Color(0xFFE67E22), const Color(0xFFD35400)]
                    : [Colors.grey.shade800, Colors.grey.shade900]),
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFFE67E22).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasSelection && !_isChallengeComplete) ...[
              Image.asset(_bowAsset, width: 22, height: 22, fit: BoxFit.contain),
              const SizedBox(width: 8),
            ],
            Text(
              btnText,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
