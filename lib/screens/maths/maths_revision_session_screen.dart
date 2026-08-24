import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../models/maths/revision_models.dart';
import '../../data/maths/revision/maths_revision_data.dart';
import '../../services/maths/revision_engine.dart';
import '../../services/sound_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/animated_widgets.dart';

class MathsRevisionSessionScreen extends StatefulWidget {
  final RevisionSkillModel? skill;
  final List<RevisionChallengeModel>? customChallenges;
  final String? customTitle;
  final int studentGrade;

  const MathsRevisionSessionScreen({
    super.key,
    this.skill,
    this.customChallenges,
    this.customTitle,
    required this.studentGrade,
  });

  @override
  State<MathsRevisionSessionScreen> createState() =>
      _MathsRevisionSessionScreenState();
}

class _MathsRevisionSessionScreenState
    extends State<MathsRevisionSessionScreen> {
  final RevisionEngine _revisionEngine = RevisionEngine();
  final SoundService _soundService = SoundService();
  late ConfettiController _confettiController;

  late List<RevisionChallengeModel> _challenges;
  int _currentChallengeIndex = 0;

  // 3-Attempt System state per challenge
  int _attemptCount = 0; // 0, 1, 2 (corresponds to attempts 1, 2, 3)
  bool _showHint = false;
  String _activeHintText = '';
  bool _isChallengeComplete = false;

  // Selected state for interactive challenges
  dynamic _userAnswer;
  List<dynamic> _orderedUserList = [];
  int _selectedOptionIndex = -1;

  // Score tracking for summary
  int _correctFirstAttemptCount = 0;
  int _correctWithHintsCount = 0;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    if (widget.customChallenges != null && widget.customChallenges!.isNotEmpty) {
      _challenges = List.from(widget.customChallenges!);
    } else if (widget.skill != null) {
      _challenges = MathsRevisionData.generateRevisionSession(
        skillTag: widget.skill!.skillTag,
        lessonId: widget.skill!.lessonId,
        conceptId: widget.skill!.conceptId,
      );
    } else {
      _challenges = MathsRevisionData.getAllOfficialQuestions().take(5).toList();
    }

    _initChallengeState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _initChallengeState() {
    final currentChallenge = _challenges[_currentChallengeIndex];
    setState(() {
      _attemptCount = 0;
      _showHint = false;
      _activeHintText = '';
      _isChallengeComplete = false;
      _selectedOptionIndex = -1;
      _userAnswer = null;

      if (currentChallenge.questionType == RevisionQuestionType.numberOrdering) {
        _orderedUserList = List<dynamic>.from(currentChallenge.optionsOrCards);
      }
    });
  }

  void _onCheckAnswer() {
    if (_isChallengeComplete) {
      _nextChallenge();
      return;
    }

    final currentChallenge = _challenges[_currentChallengeIndex];
    bool isCorrect = false;

    // Check answer based on question type
    if (currentChallenge.questionType == RevisionQuestionType.numberOrdering) {
      final List<dynamic> expected =
          List<dynamic>.from(currentChallenge.correctAnswer);
      isCorrect = _areListsEqual(_orderedUserList, expected);
    } else {
      isCorrect = _userAnswer?.toString().trim() ==
          currentChallenge.correctAnswer?.toString().trim();
    }

    _attemptCount++;

    if (isCorrect) {
      _soundService.playCorrect();
      if (_attemptCount == 1) {
        _correctFirstAttemptCount++;
      } else {
        _correctWithHintsCount++;
      }

      setState(() {
        _isChallengeComplete = true;
        _activeHintText = '🦜 "නියමයි! පිළිතුර නිවැරදියි! 🏆"';
      });

      _revisionEngine.recordRevisionAttempt(
        lessonId: currentChallenge.lessonId,
        conceptId: currentChallenge.conceptId,
        questionId: currentChallenge.id,
        attemptNumber: _attemptCount,
        answerGiven: _userAnswer?.toString() ?? _orderedUserList.toString(),
        correctAnswer: currentChallenge.correctAnswer.toString(),
        isCorrect: true,
        hintUsed: _showHint,
        skillTag: currentChallenge.skillTag,
        difficulty: currentChallenge.difficultyLevel,
      );
    } else {
      _soundService.playWrong();

      if (_attemptCount == 1) {
        // First wrong attempt -> Hint 1
        setState(() {
          _showHint = true;
          _activeHintText = '🦜 "${currentChallenge.hint1Sinhala}"';
        });
      } else if (_attemptCount == 2) {
        // Second wrong attempt -> Hint 2
        setState(() {
          _showHint = true;
          _activeHintText = '🦜 "${currentChallenge.hint2Sinhala}"';
        });
      } else {
        // Third wrong attempt -> Solution Explanation
        setState(() {
          _isChallengeComplete = true;
          _activeHintText =
              '🦜 "${currentChallenge.explanationSinhala}"';
        });

        _revisionEngine.recordRevisionAttempt(
          lessonId: currentChallenge.lessonId,
          conceptId: currentChallenge.conceptId,
          questionId: currentChallenge.id,
          attemptNumber: _attemptCount,
          answerGiven: _userAnswer?.toString() ?? _orderedUserList.toString(),
          correctAnswer: currentChallenge.correctAnswer.toString(),
          isCorrect: false,
          hintUsed: true,
          skillTag: currentChallenge.skillTag,
          difficulty: currentChallenge.difficultyLevel,
        );
      }
    }
  }

  bool _areListsEqual(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].toString().trim() != b[i].toString().trim()) return false;
    }
    return true;
  }

  void _nextChallenge() {
    if (_currentChallengeIndex < _challenges.length - 1) {
      setState(() => _currentChallengeIndex++);
      _initChallengeState();
    } else {
      // 5-Challenge Session Complete -> Show Celebration
      _soundService.playLevelUp();
      _confettiController.play();

      int totalCorrect = _correctFirstAttemptCount + _correctWithHintsCount;
      _revisionEngine.completeRevisionSession(
        skillTitle: widget.skill?.titleSinhala ?? widget.customTitle ?? 'පුනරීක්ෂණ අභ්‍යාස',
        totalQuestions: _challenges.length,
        correctCount: totalCorrect,
        xpEarned: 50,
      );

      _showSessionCompletionDialog();
    }
  }

  void _showSessionCompletionDialog() {
    int totalCorrect = _correctFirstAttemptCount + _correctWithHintsCount;
    int accuracyInt = ((totalCorrect / _challenges.length) * 100).toInt();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        title: const Column(
          children: [
            Text('🎉', style: TextStyle(fontSize: 48)),
            SizedBox(height: 8),
            Text(
              'පුහුණුව සම්පූර්ණයි!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ඔබ අද ප්‍රශ්න ${_challenges.length}ක් සාර්ථකව විසඳුවා!',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      const Text('+50 XP',
                          style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text('$accuracyInt% Accuracy',
                          style: const TextStyle(
                              color: Color(0xFF2ECC71),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '"ඔබේ සංඛ්‍යා හැකියාව වැඩි වෙමින් පවතී!"',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to Revision Hub
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('ආපසු යන්න',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _challenges[_currentChallengeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Navigation & Session Progress Indicator
                _buildHeader(context),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Math Parrot Prompt Card (High-Contrast Dark Sinhala Text)
                        _buildParrotDialogueCard(challenge),

                        const SizedBox(height: 20),

                        // Interactive Challenge Arena
                        _buildInteractiveArena(challenge),

                        const SizedBox(height: 24),

                        // 3-Attempt Dots Indicator (● ○ ○)
                        _buildAttemptDotsIndicator(),

                        const SizedBox(height: 20),

                        // Always Visible Action Button (🔍 පරීක්ෂා කරමු / ඊළඟ ප්‍රශ්නය)
                        _buildActionButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Confetti Overlay
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    double progress = (_currentChallengeIndex + 1) / _challenges.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Challenge ${_currentChallengeIndex + 1} / ${_challenges.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD700)),
                ),
                child: const Text(
                  '⭐ +50 XP',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParrotDialogueCard(RevisionChallengeModel challenge) {
    String textToDisplay = _showHint ? _activeHintText : '🦜 "${challenge.promptSinhala}"';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD166), width: 2),
        boxShadow: AppShadows.softShadow,
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
              textToDisplay,
              style: const TextStyle(
                color: Color(0xFF5D4037), // HIGH-CONTRAST DARK SINHALA TEXT
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveArena(RevisionChallengeModel challenge) {
    if (challenge.questionType == RevisionQuestionType.numberOrdering) {
      return _buildOrderingArena(challenge);
    }
    return _buildOptionsGrid(challenge);
  }

  /// Interactive Ordering Arena (Reorderable List / Chips)
  Widget _buildOrderingArena(RevisionChallengeModel challenge) {
    return Column(
      children: [
        const Text(
          'ඉලක්කම් නිවැරදි පිළිවෙළට සකස් කිරීමට තට්ටු කරන්න:',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 14),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            if (_isChallengeComplete) return;
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = _orderedUserList.removeAt(oldIndex);
              _orderedUserList.insert(newIndex, item);
            });
          },
          children: [
            for (int i = 0; i < _orderedUserList.length; i++)
              Container(
                key: ValueKey('ord_${_orderedUserList[i]}'),
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_orderedUserList[i]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.drag_handle_rounded,
                        color: Colors.white70),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Interactive Options Selection Grid
  Widget _buildOptionsGrid(RevisionChallengeModel challenge) {
    final List<dynamic> options = challenge.optionsOrCards;

    return Column(
      children: List.generate(options.length, (idx) {
        final opt = options[idx];
        final isSelected = _selectedOptionIndex == idx;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BouncingButton(
            onPressed: _isChallengeComplete
                ? null
                : () {
                    setState(() {
                      _selectedOptionIndex = idx;
                      _userAnswer = opt;
                    });
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6C5CE7) : const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
                  width: isSelected ? 2.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + idx), // A, B, C
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF6C5CE7) : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '$opt',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 3-Attempt Dots Indicator (● ○ ○)
  Widget _buildAttemptDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (idx) {
        bool isDone = idx < _attemptCount;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? const Color(0xFFFF6B35) : Colors.white24,
            border: Border.all(
              color: isDone ? const Color(0xFFFF8E53) : Colors.white38,
            ),
          ),
        );
      }),
    );
  }

  /// Always Visible Action Button (🔍 පරීක්ෂා කරමු / ඊළඟ ප්‍රශ්නය)
  Widget _buildActionButton() {
    final String btnText =
        _isChallengeComplete ? 'ඊළඟ ප්‍රශ්නය' : '🔍 පරීක්ෂා කරමු';

    return BouncingButton(
      onPressed: _onCheckAnswer,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isChallengeComplete
                ? [const Color(0xFF2ECC71), const Color(0xFF27AE60)]
                : [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            btnText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
