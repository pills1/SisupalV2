import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/maths/maths_game_model.dart';
import '../../../services/sound_service.dart';
import '../../../utils/app_theme.dart';
import '../../animated_widgets.dart';

class RapidNumberGameWidget extends StatefulWidget {
  final List<RapidChallengeRoundModel> rounds;
  final Function(int totalXp, int stars) onGameCompleted;

  const RapidNumberGameWidget({
    super.key,
    required this.rounds,
    required this.onGameCompleted,
  });

  @override
  State<RapidNumberGameWidget> createState() => _RapidNumberGameWidgetState();
}

class _RapidNumberGameWidgetState extends State<RapidNumberGameWidget> {
  final SoundService _soundService = SoundService();

  int _currentRoundIdx = 0;
  int _correctCount = 0;
  int _totalXpEarned = 0;

  Timer? _timer;
  int _secondsRemaining = 15;

  late List<String> _shuffledOptions;
  int? _selectedOptionIndex;
  bool _hasSubmitted = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _startRound(0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRound(int roundIdx) {
    _timer?.cancel();
    final round = widget.rounds[roundIdx];

    setState(() {
      _currentRoundIdx = roundIdx;
      _shuffledOptions = List.from(round.options)..shuffle();
      _selectedOptionIndex = null;
      _hasSubmitted = false;
      _isCorrect = false;
      _secondsRemaining = round.timeLimitSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0 && !_hasSubmitted) {
        setState(() => _secondsRemaining--);
      } else if (_secondsRemaining == 0 && !_hasSubmitted) {
        _onTimeOut();
      }
    });
  }

  void _onTimeOut() {
    _soundService.playWrong();
    setState(() {
      _hasSubmitted = true;
      _isCorrect = false;
    });
    _timer?.cancel();
  }

  void _selectOption(int optIdx) {
    if (_hasSubmitted) return;
    _timer?.cancel();

    final round = widget.rounds[_currentRoundIdx];
    final selectedText = _shuffledOptions[optIdx];
    final correct = selectedText == round.correctAnswer;

    setState(() {
      _selectedOptionIndex = optIdx;
      _hasSubmitted = true;
      _isCorrect = correct;
    });

    if (correct) {
      _soundService.playCorrect();
      _correctCount++;
      // Speed bonus: extra XP if answered quickly!
      int speedBonus = _secondsRemaining > 8 ? 10 : 5;
      _totalXpEarned += (15 + speedBonus);
    } else {
      _soundService.playWrong();
    }
  }

  void _nextRound() {
    if (_currentRoundIdx < widget.rounds.length - 1) {
      _startRound(_currentRoundIdx + 1);
    } else {
      _finishGame();
    }
  }

  void _finishGame() {
    _timer?.cancel();
    int stars = 1;
    if (_correctCount >= 4) {
      stars = 3;
    } else if (_correctCount >= 2) {
      stars = 2;
    }
    widget.onGameCompleted(_totalXpEarned, stars);
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.rounds[_currentRoundIdx];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar with Round Progress & Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Round Counter Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Color(0xFFFFD700), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'වටය ${_currentRoundIdx + 1} / ${widget.rounds.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Countdown Timer Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _secondsRemaining <= 5 ? Colors.redAccent : const Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_secondsRemaining <= 5 ? Colors.redAccent : const Color(0xFF6C5CE7))
                          .withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${_secondsRemaining}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Parrot Dialogue Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      MathsAssets.parrotIdle,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('🦜', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    round.parrotDialogue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Question Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ප්‍රශ්නය ${_currentRoundIdx + 1}:',
                  style: const TextStyle(
                    color: AppColors.mathOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  round.questionText,
                  style: const TextStyle(
                    color: Color(0xFF2D3436),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Shuffled Options Grid
          Column(
            children: List.generate(_shuffledOptions.length, (optIdx) {
              final optText = _shuffledOptions[optIdx];
              final isSelected = _selectedOptionIndex == optIdx;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => _selectOption(optIdx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6C5CE7) : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.2),
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + optIdx),
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            optText,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          // Feedback & Next Round Button
          if (_hasSubmitted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCorrect ? const Color(0xFFE8F8F5) : const Color(0xFFFDEDEC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isCorrect ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isCorrect ? Icons.stars_rounded : Icons.error_outline_rounded,
                    color: _isCorrect ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isCorrect
                          ? '🦜 "නියමයි! ${round.explanationSi}"'
                          : '🦜 "කාලය අවසන් හෝ වැරදියි! ${round.explanationSi}"',
                      style: TextStyle(
                        color: _isCorrect ? const Color(0xFF1E8449) : const Color(0xFF922B21),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BouncingButton(
              onPressed: _nextRound,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2ECC71).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentRoundIdx < widget.rounds.length - 1 ? 'ඊළඟ අභියෝගය 🚀' : 'අවසාන කරන්න 🏆',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
