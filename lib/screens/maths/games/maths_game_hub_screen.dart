import 'package:flutter/material.dart';
import '../../../data/maths/maths_game_data.dart';
import '../../../models/maths/maths_game_model.dart';
import '../../../services/progress_service.dart';
import '../../../services/sound_service.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/animated_widgets.dart';
import '../../../widgets/maths/games/abacus_challenge_widget.dart';
import '../../../widgets/maths/games/lily_pad_leap_game.dart';
import '../../../widgets/maths/games/number_archery_game.dart';
import '../../../widgets/maths/games/digit_builder_widget.dart';
import '../../../widgets/maths/games/expanded_form_game_widget.dart';
import '../../../widgets/maths/games/place_value_game_widget.dart';
import '../../../widgets/maths/games/rapid_number_game_widget.dart';

class MathsGameHubScreen extends StatefulWidget {
  final int studentGrade;
  final MathsGameType? initialGameType;

  const MathsGameHubScreen({
    super.key,
    required this.studentGrade,
    this.initialGameType,
  });

  @override
  State<MathsGameHubScreen> createState() => _MathsGameHubScreenState();
}

class _MathsGameHubScreenState extends State<MathsGameHubScreen> {
  final ProgressService _progressService = ProgressService();
  final SoundService _soundService = SoundService();

  MathsGameType? _activeGameType;
  int _currentRoundIndex = 0;
  int _sessionTotalXp = 0;
  int _sessionStars = 0;
  bool _isGameCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialGameType != null) {
      _activeGameType = widget.initialGameType;
    }
  }

  void _selectGame(MathsGameType gameType) {
    _soundService.playClick();
    setState(() {
      _activeGameType = gameType;
      _currentRoundIndex = 0;
      _sessionTotalXp = 0;
      _sessionStars = 0;
      _isGameCompleted = false;
    });
  }

  void _onAbacusRoundCompleted(bool isCorrect, int xpEarned) {
    if (isCorrect) _sessionTotalXp += xpEarned;
    if (_currentRoundIndex < MathsGameData.abacusRounds.length - 1) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _currentRoundIndex++;
          });
        }
      });
    } else {
      _finishMiniGame(MathsGameType.abacusChallenge, 3);
    }
  }

  void _onDigitBuilderRoundCompleted(bool isCorrect, int xpEarned) {
    if (isCorrect) _sessionTotalXp += xpEarned;
    if (_currentRoundIndex < MathsGameData.digitBuilderRounds.length - 1) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _currentRoundIndex++;
          });
        }
      });
    } else {
      _finishMiniGame(MathsGameType.digitBuilder, 3);
    }
  }

  void _onPlaceValueRoundCompleted(bool isCorrect, int xpEarned) {
    if (isCorrect) _sessionTotalXp += xpEarned;
    if (_currentRoundIndex < MathsGameData.placeValueRounds.length - 1) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _currentRoundIndex++;
          });
        }
      });
    } else {
      _finishMiniGame(MathsGameType.placeValueExplorer, 3);
    }
  }

  void _onExpandedFormRoundCompleted(bool isCorrect, int xpEarned) {
    if (isCorrect) _sessionTotalXp += xpEarned;
    if (_currentRoundIndex < MathsGameData.expandedFormRounds.length - 1) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _currentRoundIndex++;
          });
        }
      });
    } else {
      _finishMiniGame(MathsGameType.expandedFormBuilder, 3);
    }
  }

  void _onRapidGameCompleted(int totalXp, int stars) {
    _sessionTotalXp += totalXp;
    _finishMiniGame(MathsGameType.rapidNumberChallenge, stars);
  }

  Future<void> _finishMiniGame(MathsGameType type, int stars) async {
    _soundService.playLevelUp();
    setState(() {
      _sessionStars = stars;
      _isGameCompleted = true;
    });

    // Update Firestore progress safely
    try {
      await _progressService.completeQuiz('Mathematics', 'math_grade5_01_${type.name}', 10, 10);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF302B63),
              Color(0xFF24243E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header App Bar
              _buildHeaderBar(),

              // Game Body Content or Selector Menu
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _activeGameType == null
                      ? _buildGameSelectorMenu()
                      : (_isGameCompleted ? _buildCompletionScreen() : _buildActiveGameWidget()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: AppColors.mathOrange.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_activeGameType != null) {
                setState(() => _activeGameType = null);
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activeGameType == null ? 'ගණිත ක්‍රීඩා මණ්ඩපය' : _getGameTitle(_activeGameType!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Lesson 1: සංඛ්‍යා - 1 Mini Games',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 4),
                Text(
                  '+$_sessionTotalXp XP',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGameTitle(MathsGameType type) {
    switch (type) {
      case MathsGameType.abacusChallenge:
        return 'ගණක රාමුව අභියෝගය 🧮';
      case MathsGameType.lilyPadLeap:
        return 'දිය ගෙම්බාගේ පිම්ම';
      case MathsGameType.numberArchery:
        return 'ඉලක්කයට විදින්න';
      case MathsGameType.digitBuilder:
        return 'ඉලක්කම් සකස් කරමු 🔢';
      case MathsGameType.placeValueExplorer:
        return 'ස්ථානීය අගය ගවේෂකයා 🏰';
      case MathsGameType.expandedFormBuilder:
        return 'විහිදුවා ලියමු ➕';
      case MathsGameType.rapidNumberChallenge:
        return 'ඉක්මන් සංඛ්‍යා අභියෝගය ⚡';
    }
  }

  Widget _buildGameSelectorMenu() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parrot Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      MathsAssets.parrotIdle,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('🦜', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    '🦜 "අපි අද සංඛ්‍යා සමඟ ක්‍රීඩා කරමු! ක්‍රීඩාවක් තෝරන්න!"',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Grade 5 Mathematics Mini-Games 🎮',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          // ACTIVE GAME 1: Abacus Challenge
          _buildGameCard(
            type: MathsGameType.abacusChallenge,
            title: '1. ගණක රාමුව අභියෝගය 🧮',
            subtitle: 'අබකසයේ පබළු යොදා සංඛ්‍යා තනමු (Abacus Challenge)',
            gradientColors: [const Color(0xFF8E44AD), const Color(0xFF9B59B6)],
          ),
          const SizedBox(height: 14),

          // ACTIVE GAME 2: Lily Pad Leap
          _buildGameCard(
            type: MathsGameType.lilyPadLeap,
            title: '2. දිය ගෙම්බාගේ පිම්ම',
            subtitle: 'සංඛ්‍යා රටා හඳුනාගෙන පොකුණ තරණය කරමු (Lily Pad Leap)',
            gradientColors: [const Color(0xFF059669), const Color(0xFF10B981)],
          ),
          const SizedBox(height: 14),

          // ACTIVE GAME 3: Number Archery
          _buildGameCard(
            type: MathsGameType.numberArchery,
            title: '3. ඉලක්කයට විදින්න',
            subtitle: 'ළඟම 10, 100, 1000 ට වැටයීමේ අභියෝගය (Number Archery)',
            gradientColors: [const Color(0xFFD35400), const Color(0xFFE67E22)],
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required MathsGameType type,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: () => _selectGame(type),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveGameWidget() {
    switch (_activeGameType!) {
      case MathsGameType.abacusChallenge:
        return AbacusChallengeWidget(
          round: MathsGameData.abacusRounds[_currentRoundIndex],
          onRoundCompleted: _onAbacusRoundCompleted,
        );
      case MathsGameType.lilyPadLeap:
        return LilyPadLeapGameWidget(
          onCompleted: () => setState(() => _activeGameType = null),
        );
      case MathsGameType.numberArchery:
        return NumberArcheryGameWidget(
          onCompleted: () => setState(() => _activeGameType = null),
        );

      case MathsGameType.digitBuilder:
        return DigitBuilderWidget(
          round: MathsGameData.digitBuilderRounds[_currentRoundIndex],
          onRoundCompleted: _onDigitBuilderRoundCompleted,
        );
      case MathsGameType.placeValueExplorer:
        return PlaceValueGameWidget(
          round: MathsGameData.placeValueRounds[_currentRoundIndex],
          onRoundCompleted: _onPlaceValueRoundCompleted,
        );
      case MathsGameType.expandedFormBuilder:
        return ExpandedFormGameWidget(
          round: MathsGameData.expandedFormRounds[_currentRoundIndex],
          onRoundCompleted: _onExpandedFormRoundCompleted,
        );
      case MathsGameType.rapidNumberChallenge:
        return RapidNumberGameWidget(
          rounds: MathsGameData.rapidRounds,
          onGameCompleted: _onRapidGameCompleted,
        );
    }
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD700), width: 3),
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 72),
          ),
          const SizedBox(height: 20),

          const Text(
            'විශිෂ්ටයි! 🏆',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'ඔයා ${_getGameTitle(_activeGameType!)} සාර්ථකව අවසන් කළා!',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Stars Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (idx) {
              final isFilled = idx < _sessionStars;
              return Icon(
                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                color: const Color(0xFFFFD700),
                size: 40,
              );
            }),
          ),

          const SizedBox(height: 20),

          // XP Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD700)),
            ),
            child: Text(
              '+$_sessionTotalXp XP එකතු විය!',
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 32),

          BouncingButton(
            onPressed: () => setState(() => _activeGameType = null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'ක්‍රීඩා ලැයිස්තුවට යන්න 🎮',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
