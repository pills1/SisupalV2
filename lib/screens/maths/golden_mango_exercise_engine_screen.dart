import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/maths/golden_mango_exercise_data.dart';
import '../../models/maths/golden_mango_exercise_models.dart';
import '../../models/maths/maths_game_model.dart';
import '../../services/progress_service.dart';
import '../../services/sound_service.dart';
import '../../services/math_curriculum_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/animated_widgets.dart';
import '../../widgets/maths/games/abacus_challenge_widget.dart';
import '../../widgets/maths/games/digit_builder_widget.dart';
import '../../widgets/maths/games/expanded_form_game_widget.dart';
import '../../widgets/maths/games/place_value_game_widget.dart';

/// ============================================
/// GOLDEN MANGO ADAPTIVE EXERCISE ENGINE SCREEN
/// Replaces ExercisePlaceholderScreen with a 3-attempt adaptive teaching engine.
///
/// Flow per question:
///   Attempt 1 (Question) ──► Wrong ──► Attempt 1 Light Hint ──► Retry
///   Attempt 2 (Retry) ──► Wrong ──► Attempt 2 Guided Explanation ──► Retry
///   Attempt 3 (Retry) ──► Wrong ──► Worked Solution & Recovery ──► Next Question
/// ============================================
class GoldenMangoExerciseEngineScreen extends StatefulWidget {
  final String conceptId;
  final String conceptTitle;
  final String learningObjective;

  const GoldenMangoExerciseEngineScreen({
    super.key,
    required this.conceptId,
    required this.conceptTitle,
    required this.learningObjective,
  });

  @override
  State<GoldenMangoExerciseEngineScreen> createState() =>
      _GoldenMangoExerciseEngineScreenState();
}

class _GoldenMangoExerciseEngineScreenState
    extends State<GoldenMangoExerciseEngineScreen>
    with SingleTickerProviderStateMixin {
  final SoundService _soundService = SoundService();
  final ProgressService _progressService = ProgressService();

  late List<GoldenMangoQuestion> _questions;
  int _currentQuestionIndex = 0;

  // 3-Attempt State
  int _currentAttempt = 1; // 1, 2, or 3
  int _hintLevel = 0; // 0 = none, 1 = light, 2 = guided, 3 = worked solution
  bool _isAnswered = false;
  bool _isCorrect = false;
  int? _selectedOptionIndex;
  final TextEditingController _inputController = TextEditingController();

  // Shuffled MCQ Options Cache
  final Map<String, List<ExerciseOption>> _shuffledMcqOptionsMap = {};

  // Timing telemetry
  late DateTime _questionStartTime;

  @override
  void initState() {
    super.initState();
    // Default immediate load from offline-first cache/fallback
    _questions = GoldenMangoExerciseData.getQuestionsForConcept(widget.conceptId);
    _startQuestionTimer();
    _loadLiveQuestions();
  }

  Future<void> _loadLiveQuestions() async {
    try {
      final liveQuestions = await MathCurriculumService()
          .getGoldenMangoQuestions(widget.conceptId);
      if (mounted && liveQuestions.isNotEmpty) {
        setState(() {
          _questions = liveQuestions;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _startQuestionTimer() {
    _questionStartTime = DateTime.now();
  }

  GoldenMangoQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  // ─── ANSWER SUBMISSION & ATTEMPT EVALUATION ───

  Future<void> _submitAnswer(String answerGiven, bool isCorrect) async {
    if (_isAnswered && _isCorrect) return;

    final timeTaken = DateTime.now().difference(_questionStartTime).inSeconds;

    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
    });

    // Record itemized attempt telemetry
    await _progressService.recordQuestionAttempt(
      lessonId: 'golden_mango_quest',
      conceptId: widget.conceptId,
      questionId: _currentQuestion.id,
      attemptNumber: _currentAttempt,
      answerGiven: answerGiven,
      correctAnswer: _currentQuestion.correctAnswer ??
          (_currentQuestion.options.isEmpty
              ? ''
              : _currentQuestion.options
                  .firstWhere((o) => o.isCorrect,
                      orElse: () => const ExerciseOption(text: ''))
                  .text),
      isCorrect: isCorrect,
      timeTakenSeconds: timeTaken,
      hintUsed: _hintLevel > 0,
      hintLevel: _hintLevel,
      skillTag: _currentQuestion.skillTag,
      difficulty: _currentQuestion.difficulty,
    );

    if (isCorrect) {
      _soundService.playCorrect();
    } else {
      _soundService.playWrong();
      if (_currentAttempt == 1) {
        setState(() {
          _hintLevel = 1;
        });
      } else if (_currentAttempt == 2) {
        setState(() {
          _hintLevel = 2;
        });
      } else {
        setState(() {
          _hintLevel = 3; // Worked solution
        });
      }
    }
  }

  void _onRetry() {
    setState(() {
      _isAnswered = false;
      _isCorrect = false;
      _selectedOptionIndex = null;
      _inputController.clear();
      if (_currentAttempt < 3) {
        _currentAttempt++;
      }
    });
    _startQuestionTimer();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _currentAttempt = 1;
        _hintLevel = 0;
        _isAnswered = false;
        _isCorrect = false;
        _selectedOptionIndex = null;
        _inputController.clear();
      });
      _startQuestionTimer();
    } else {
      // Completed all 6 questions for this concept!
      _showConceptCompletionBadge();
    }
  }

  void _showConceptCompletionBadge() {
    String badgeTitle = 'ගණිත වීරයා 🏅';
    switch (widget.conceptId) {
      case 'c1_jungle_map':
        badgeTitle = 'සිතියම් වීරයා 🗺️';
        break;
      case 'c2_river_of_beads':
        badgeTitle = 'ගණක රාමු වීරයා 🧮';
        break;
      case 'c3_giants_gate':
        badgeTitle = 'යෝධ සංඛ්‍යා වීරයා 🏰';
        break;
      case 'c4_glowing_pedestals':
        badgeTitle = 'ස්ථානීය අගය වීරයා 💎';
        break;
      case 'c5_unlocking_chest':
        badgeTitle = 'විහිදුම් වීරයා 🔓';
        break;
    }

    _soundService.playLevelUp();

    // 🌟 Save progress to Firestore and award +100 XP!
    ProgressService().completeConcept('maths', 'math_grade5_01', widget.conceptId);
    if (widget.conceptId == 'c5_unlocking_chest') {
      ProgressService().completeLesson('maths', 'math_grade5_01');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA726)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🏅', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badgeTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.mathOrange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.conceptTitle} අභියෝගය සාර්ථකව නිම කළා!',
              style: const TextStyle(fontSize: 15, color: Color(0xFF5D4037)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true); // Return true to advance story
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mathOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'කතාන්දරයට යමු 🚀',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BUILD UI ───

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.conceptTitle)),
        body: const Center(child: Text('අභියෝග ප්‍රශ්න ළඟදීම එකතු වේ!')),
      );
    }

    final question = _currentQuestion;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await _showExitConfirmation();
        if (shouldLeave && mounted) {
          Navigator.pop(context, false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              // Question area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question text card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppShadows.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'අභියෝගය ${_currentQuestionIndex + 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mathOrange,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _currentAttempt == 1
                                          ? '● ○ ○  '
                                          : (_currentAttempt == 2
                                              ? '● ● ○  '
                                              : '● ● ●  '),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _currentAttempt == 3
                                            ? Colors.redAccent
                                            : Colors.amber.shade800,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _currentAttempt == 3
                                            ? Colors.red.shade100
                                            : Colors.amber.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _currentAttempt == 3
                                            ? 'අවසාන උත්සාහය 3 / 3'
                                            : 'උත්සාහය $_currentAttempt / 3',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _currentAttempt == 3
                                              ? Colors.red.shade900
                                              : const Color(0xFFD68910),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.questionText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Question interface
                      _buildQuestionInterface(question),

                      const SizedBox(height: 20),

                      // Parrot tutor feedback area
                      if (_isAnswered || _hintLevel > 0)
                        _buildParrotTutorFeedback(question),
                    ],
                  ),
                ),
              ),

              // Bottom action bar
              _buildBottomActionBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── APP BAR ───

  PreferredSizeWidget _buildAppBar() {
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    return AppBar(
      backgroundColor: AppColors.mathOrange,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () async {
          final shouldLeave = await _showExitConfirmation();
          if (shouldLeave && mounted) {
            Navigator.pop(context, false);
          }
        },
      ),
      title: Column(
        children: [
          Text(
            widget.conceptTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            'අභියෝගය ${_currentQuestionIndex + 1} / ${_questions.length}',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(6),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
          minHeight: 6,
        ),
      ),
    );
  }

  // ─── INTERFACE SWITCHER ───

  Widget _buildQuestionInterface(GoldenMangoQuestion question) {
    switch (question.questionType) {
      case GoldenMangoQuestionType.multipleChoice:
        return _buildMultipleChoiceInterface(question);
      case GoldenMangoQuestionType.placeValuePicker:
        return _buildPlaceValueInterface(question);
      case GoldenMangoQuestionType.numericInput:
        return _buildNumericInputInterface(question);
      case GoldenMangoQuestionType.abacusInteractive:
        return _buildAbacusInterface(question);
      case GoldenMangoQuestionType.expandedFormBuilder:
        return _buildExpandedFormInterface(question);
      case GoldenMangoQuestionType.digitBuilder:
        return _buildDigitBuilderInterface(question);
    }
  }

  List<ExerciseOption> _getShuffledOptions(GoldenMangoQuestion question) {
    if (!_shuffledMcqOptionsMap.containsKey(question.id)) {
      final list = List<ExerciseOption>.from(question.options);
      // Use question ID hash as seed so option order is scrambled but stable per question
      list.shuffle(Random(question.id.hashCode));
      _shuffledMcqOptionsMap[question.id] = list;
    }
    return _shuffledMcqOptionsMap[question.id]!;
  }

  // MCQ Interface
  Widget _buildMultipleChoiceInterface(GoldenMangoQuestion question) {
    final options = _getShuffledOptions(question);
    return Column(
      children: List.generate(options.length, (index) {
        final option = options[index];
        final isSelected = _selectedOptionIndex == index;
        Color cardColor = Colors.white;
        Color borderColor = Colors.grey.shade300;

        if (_isAnswered && isSelected) {
          if (option.isCorrect) {
            cardColor = const Color(0xFFE8F5E9);
            borderColor = const Color(0xFF27AE60);
          } else {
            cardColor = const Color(0xFFFFEBEE);
            borderColor = const Color(0xFFE74C3C);
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: BouncingButton(
            onPressed: _isAnswered && _isCorrect
                ? null
                : () {
                    setState(() {
                      _selectedOptionIndex = index;
                    });
                    _submitAnswer(option.text, option.isCorrect);
                  },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: AppShadows.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.mathOrange
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      option.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ),
                  if (_isAnswered && isSelected)
                    Icon(
                      option.isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: option.isCorrect
                          ? const Color(0xFF27AE60)
                          : const Color(0xFFE74C3C),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Numeric Input
  Widget _buildNumericInputInterface(GoldenMangoQuestion question) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          TextField(
            controller: _inputController,
            keyboardType: TextInputType.number,
            enabled: !(_isAnswered && _isCorrect),
            cursorColor: AppColors.mathOrange,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'පිළිතුර මෙතැන ලියන්න',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.mathOrange, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isAnswered && _isCorrect
                  ? null
                  : () {
                      final input = _inputController.text.trim();
                      if (input.isEmpty) return;
                      final isCorrect = input == question.correctAnswer;
                      _submitAnswer(input, isCorrect);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mathOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'පිළිතුර පරීක්ෂා කරමු 🔍',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Embedded Abacus Widget
  Widget _buildAbacusInterface(GoldenMangoQuestion question) {
    final extra = question.extraData ?? {};
    final targetNum = int.tryParse(
            (extra['targetNumber'] ?? question.correctAnswer ?? '3618')
                .toString()) ??
        3618;
    final placeVals = List<String>.from(
        extra['placeValues'] ?? const ['දහස්', 'සිය', 'දහය', 'ඒක']);

    final round = AbacusRoundModel(
      id: question.id,
      targetNumber: targetNum,
      placeValues: placeVals,
      parrotPrompt: question.questionText,
      hints: [question.hintLevel1, question.hintLevel2],
    );

    return AbacusChallengeWidget(
      key: ValueKey('abacus_${question.id}_attempt_$_currentAttempt'),
      round: round,
      onRoundCompleted: (isCorrect, xp) {
        _submitAnswer(
            isCorrect ? targetNum.toString() : 'incorrect', isCorrect);
      },
    );
  }

  // Embedded Expanded Form Widget
  Widget _buildExpandedFormInterface(GoldenMangoQuestion question) {
    final extra = question.extraData ?? {};
    final targetNum = (extra['targetNumber'] ?? '68507').toString();
    final correctComps = List<String>.from(
        extra['correctComponents'] ?? const ['60000', '8000', '500', '0', '7']);
    final available = List<String>.from(extra['availableCards'] ??
        const ['60000', '8000', '500', '0', '7', '6000', '80']);

    final round = ExpandedFormRoundModel(
      id: question.id,
      targetNumber: targetNum,
      correctComponents: correctComps,
      availableCards: available,
      hints: [question.hintLevel1, question.hintLevel2],
    );

    return ExpandedFormGameWidget(
      key: ValueKey('expanded_${question.id}_attempt_$_currentAttempt'),
      round: round,
      onRoundCompleted: (isCorrect, xp) {
        _submitAnswer(
            isCorrect ? correctComps.join(' + ') : 'incorrect', isCorrect);
      },
    );
  }

  // Embedded Digit Builder Widget
  Widget _buildDigitBuilderInterface(GoldenMangoQuestion question) {
    final extra = question.extraData ?? {};
    final String? ans = question.correctAnswer;
    List<int> digits = [];
    if (extra['digits'] is List && (extra['digits'] as List).isNotEmpty) {
      digits = (extra['digits'] as List)
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList();
    } else if (question.id == 'c1_q5') {
      digits = const [4, 9, 5, 0];
    } else if (ans != null && ans.isNotEmpty) {
      digits = ans
          .split('')
          .map((c) => int.tryParse(c))
          .whereType<int>()
          .toList();
    }
    if (digits.isEmpty) {
      digits = const [4, 9, 5, 0];
    }

    final targetAns = (extra['targetAnswer'] ??
            (ans != null && ans.isNotEmpty ? ans : '4905'))
        .toString();
    final instruction =
        (extra['instructionSi'] ?? question.questionText).toString();

    final round = DigitBuilderRoundModel(
      id: question.id,
      digits: digits,
      instructionSi: instruction,
      targetAnswer: targetAns,
      hints: [question.hintLevel1, question.hintLevel2],
    );

    return DigitBuilderWidget(
      key: ValueKey('digit_${question.id}_attempt_$_currentAttempt'),
      round: round,
      onRoundCompleted: (isCorrect, xp) {
        _submitAnswer(isCorrect ? targetAns : 'incorrect', isCorrect);
      },
    );
  }

  // Embedded Place Value Explorer Widget
  Widget _buildPlaceValueInterface(GoldenMangoQuestion question) {
    if (question.options.isEmpty) {
      return _buildMultipleChoiceInterface(question);
    }

    final extra = question.extraData ?? {};
    
    // Extract full number (e.g. '5421' from '5,421')
    String fullNum = (extra['fullNumber'] ?? '').toString();
    if (fullNum.isEmpty) {
      final numMatch = RegExp(r'(\d[\d,]*\d|\d+)').firstMatch(question.questionText);
      if (numMatch != null) {
        fullNum = numMatch.group(1)!.replaceAll(',', '');
      } else {
        fullNum = '5421';
      }
    }

    // Extract target digit (e.g. '1' from "'1' ඉලක්කම")
    String targetDig = (extra['targetDigit'] ?? '').toString();
    if (targetDig.isEmpty) {
      final digMatch = RegExp(r"['\u2018\u2019](\d)['\u2018\u2019]").firstMatch(question.questionText);
      if (digMatch != null) {
        targetDig = digMatch.group(1)!;
      } else {
        targetDig = '1';
      }
    }

    final correctPlace = (extra['correctPlaceValue'] ??
            question.correctAnswer ??
            'ඒකස්ථානය')
        .toString();
    final correctRep =
        (extra['correctRepresentedValue'] ?? targetDig).toString();

    final round = PlaceValueRoundModel(
      id: question.id,
      fullNumber: fullNum,
      targetDigit: targetDig,
      questionText: question.questionText,
      correctPlaceValue: correctPlace,
      correctRepresentedValue: correctRep,
      options: question.options.map((o) => o.text).toList(),
      explanationSi: question.explanation,
      hints: [question.hintLevel1, question.hintLevel2],
    );

    return PlaceValueGameWidget(
      key: ValueKey('pv_${question.id}_attempt_$_currentAttempt'),
      round: round,
      onRoundCompleted: (isCorrect, xp) {
        _submitAnswer(isCorrect ? correctPlace : 'incorrect', isCorrect);
      },
    );
  }

  // ─── PARROT TUTOR FEEDBACK UI ───

  Widget _buildParrotTutorFeedback(GoldenMangoQuestion question) {
    String feedbackText = '';
    Color bubbleBg = const Color(0xFFFFF9E6);
    Color borderColor = const Color(0xFFFFD166);
    Color textColor = const Color(0xFF1E293B);

    if (_isCorrect) {
      feedbackText = '🦜 "හරිම හොඳයි! නිවැරදි පිළිතුර! 🎉"';
      bubbleBg = const Color(0xFFE8F5E9);
      borderColor = const Color(0xFF27AE60);
      textColor = const Color(0xFF1B5E20);
    } else if (_hintLevel == 1) {
      feedbackText = '🦜 "අපි එකට බලමු! ${question.hintLevel1}"';
      textColor = const Color(0xFF2D3436);
    } else if (_hintLevel == 2) {
      feedbackText = '🦜 "තව ටිකක් හිතමු! ${question.hintLevel2}"';
      textColor = const Color(0xFF2D3436);
    } else if (_hintLevel == 3) {
      feedbackText = '🦜 "කමක් නැහැ! මෙන්න විසඳුම:\n${question.explanation}"';
      bubbleBg = const Color(0xFFFFF3E0);
      borderColor = AppColors.mathOrange;
      textColor = const Color(0xFF5D4037);
    }

    return SlideInWidget(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: AppShadows.softShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Text('🦜', style: TextStyle(fontSize: 28)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ගණිත ගිරවා 🦜',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feedbackText,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM ACTION BAR ───

  Widget _buildBottomActionBar() {
    String buttonText = 'නැවත උත්සාහ කරන්න (උත්සාහය ${_currentAttempt + 1} / 3) 🔄';
    Color buttonColor = AppColors.mathOrange;
    IconData buttonIcon = Icons.refresh_rounded;
    VoidCallback? action = _onRetry;

    if (_isCorrect) {
      buttonText = 'ඊළඟ අභියෝගය ➡️';
      buttonColor = const Color(0xFF27AE60);
      buttonIcon = Icons.arrow_forward_rounded;
      action = _nextQuestion;
    } else if (_currentAttempt == 3 && _isAnswered) {
      buttonText = 'ඉදිරියට යන්න ➡️';
      buttonColor = const Color(0xFF6C5CE7);
      buttonIcon = Icons.arrow_forward_rounded;
      action = _nextQuestion;
    } else if (!_isAnswered) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: action,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Icon(buttonIcon, size: 22),
            label: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── EXIT CONFIRMATION DIALOG ───

  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('⚔️', style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'අභියෝගයෙන් ඉවත් වෙනවද?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'දැන් ඉවත් වුණොත් ඔයාගේ අභියෝගයේ ප්‍රගතිය අහිමි වෙයි. ඔබට ඉවත් වීමට අවශ්‍යද?',
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
