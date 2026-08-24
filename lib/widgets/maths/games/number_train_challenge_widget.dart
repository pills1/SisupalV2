import 'package:flutter/material.dart';
import '../../../models/maths/number_train_models.dart';
import '../../../services/progress_service.dart';
import '../../../services/sound_service.dart';
import '../../../utils/app_theme.dart';
import '../../animated_widgets.dart';

/// ============================================
/// NUMBER TRAIN CHALLENGE WIDGET
/// Renders 6 distinct train-themed challenges with:
///   - 3-Attempt Adaptive Lifecycle (Attempt 1 -> Hint 1, Attempt 2 -> Hint 2, Attempt 3 -> Explanation)
///   - Visual attempt indicator dots (● ○ ○)
///   - High contrast dark text Math Parrot speech bubble
///   - Prominent explicit action button ("පරීක්ෂා කරමු 🔍")
///   - Firestore telemetry tracking via ProgressService
/// ============================================
class NumberTrainChallengeWidget extends StatefulWidget {
  final NumberTrainChallengeModel challenge;
  final VoidCallback onChallengeCompleted;

  const NumberTrainChallengeWidget({
    super.key,
    required this.challenge,
    required this.onChallengeCompleted,
  });

  @override
  State<NumberTrainChallengeWidget> createState() =>
      _NumberTrainChallengeWidgetState();
}

class _NumberTrainChallengeWidgetState
    extends State<NumberTrainChallengeWidget> with SingleTickerProviderStateMixin {
  final SoundService _soundService = SoundService();
  final ProgressService _progressService = ProgressService();

  // Attempt Lifecycle State
  int _currentAttempt = 1; // 1, 2, or 3
  int _hintLevel = 0; // 0: none, 1: hint1, 2: hint2, 3: worked solution
  bool _isAnswered = false;
  bool _isCorrect = false;

  // Interaction State
  String? _selectedOption;
  String? _draggedTicket;
  List<String> _orderedCarriages = [];
  int _placeValueStep = 0; // 0: Hundreds, 1: Tens, 2: Final Selection
  late DateTime _startTime;

  // Train Animation Controller for Challenge 6
  late AnimationController _trainAnimController;
  late Animation<double> _trainMoveAnim;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initInteractionState();

    _trainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _trainMoveAnim = Tween<double>(begin: -100.0, end: 400.0).animate(
      CurvedAnimation(parent: _trainAnimController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(covariant NumberTrainChallengeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.challenge.id != widget.challenge.id) {
      _resetChallengeState();
    }
  }

  @override
  void dispose() {
    _trainAnimController.dispose();
    super.dispose();
  }

  void _initInteractionState() {
    _selectedOption = null;
    _draggedTicket = null;
    _placeValueStep = 0;

    // Shuffle initial options for ordering/sorting so they never start in exact answer order
    final initialNumbers = List<String>.from(widget.challenge.numbers);
    if (widget.challenge.interactionType == NumberTrainInteractionType.carriageOrdering ||
        widget.challenge.interactionType == NumberTrainInteractionType.carriageSorting ||
        widget.challenge.interactionType == NumberTrainInteractionType.masteryOrdering) {
      initialNumbers.shuffle();
      // Ensure initial order is not already correct if length > 1
      if (initialNumbers.join(',') == widget.challenge.correctAnswer && initialNumbers.length > 1) {
        initialNumbers.shuffle();
      }
    }
    _orderedCarriages = [];
  }

  void _resetChallengeState() {
    setState(() {
      _currentAttempt = 1;
      _hintLevel = 0;
      _isAnswered = false;
      _isCorrect = false;
      _startTime = DateTime.now();
      _initInteractionState();
    });
  }

  void _onRetry() {
    setState(() {
      _isAnswered = false;
      _isCorrect = false;
      _selectedOption = null;
      _draggedTicket = null;
      _orderedCarriages = [];
      _placeValueStep = 0;
      if (_currentAttempt < 3) {
        _currentAttempt++;
      }
    });
  }

  // ─── ANSWER CHECK & TELEMETRY ───

  void _checkAnswer() {
    if (_isAnswered) return;

    String studentAnswer = '';
    bool correct = false;

    switch (widget.challenge.interactionType) {
      case NumberTrainInteractionType.tapSelection:
      case NumberTrainInteractionType.guidedPlaceValue:
        studentAnswer = _selectedOption ?? '';
        correct = (studentAnswer == widget.challenge.correctAnswer);
        break;

      case NumberTrainInteractionType.ticketDrag:
        studentAnswer = _draggedTicket ?? '';
        correct = (studentAnswer == widget.challenge.correctAnswer);
        break;

      case NumberTrainInteractionType.carriageOrdering:
      case NumberTrainInteractionType.carriageSorting:
      case NumberTrainInteractionType.masteryOrdering:
      case NumberTrainInteractionType.digitBuilder:
        final delimiter =
            widget.challenge.correctAnswer.contains(',') ? ',' : '';
        studentAnswer = _orderedCarriages.join(delimiter);
        correct = (studentAnswer == widget.challenge.correctAnswer);
        break;
    }

    final timeTaken = DateTime.now().difference(_startTime).inSeconds;

    setState(() {
      _isAnswered = true;
      _isCorrect = correct;

      if (!correct) {
        _hintLevel = _currentAttempt;
      }
    });

    // Record Firestore attempt telemetry
    _progressService.recordQuestionAttempt(
      lessonId: 'math_grade5_02',
      conceptId: widget.challenge.conceptId,
      questionId: widget.challenge.id,
      attemptNumber: _currentAttempt,
      answerGiven: studentAnswer,
      correctAnswer: widget.challenge.correctAnswer,
      isCorrect: correct,
      timeTakenSeconds: timeTaken,
      hintUsed: _hintLevel > 0,
      hintLevel: _hintLevel,
      skillTag: widget.challenge.skillTag,
      difficulty: widget.challenge.difficulty,
    );

    if (correct) {
      _soundService.playCorrect();
      if (widget.challenge.interactionType ==
          NumberTrainInteractionType.masteryOrdering) {
        _trainAnimController.forward(from: 0.0);
      }
    } else {
      _soundService.playWrong();
    }
  }

  bool get _canSubmit {
    if (_isAnswered) return false;
    switch (widget.challenge.interactionType) {
      case NumberTrainInteractionType.tapSelection:
      case NumberTrainInteractionType.guidedPlaceValue:
        return _selectedOption != null;
      case NumberTrainInteractionType.ticketDrag:
        return _draggedTicket != null;
      case NumberTrainInteractionType.carriageOrdering:
      case NumberTrainInteractionType.carriageSorting:
      case NumberTrainInteractionType.masteryOrdering:
      case NumberTrainInteractionType.digitBuilder:
        return _orderedCarriages.length == widget.challenge.numbers.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Challenge Header Card with Attempt Indicator
          _buildChallengeHeaderCard(),

          const SizedBox(height: 16),

          // Train Interaction Arena
          _buildInteractionArena(),

          const SizedBox(height: 16),

          // Math Parrot High-Contrast Tutor Feedback Bubble
          if (_isAnswered || _hintLevel > 0) ...[
            _buildParrotTutorBubble(),
            const SizedBox(height: 16),
          ],

          // Universal Primary Action Button Bar
          _buildActionButtonBar(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── HEADER CARD WITH ATTEMPT INDICATOR ───

  Widget _buildChallengeHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.challenge.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mathOrange,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _currentAttempt == 1
                    ? '● ○ ○  '
                    : (_currentAttempt == 2 ? '● ● ○  ' : '● ● ●  '),
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
          const SizedBox(height: 8),
          Text(
            widget.challenge.questionText,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─── INTERACTION ARENA SWITCHER ───

  Widget _buildInteractionArena() {
    switch (widget.challenge.interactionType) {
      case NumberTrainInteractionType.tapSelection:
        return _buildTapSelectionArena();
      case NumberTrainInteractionType.ticketDrag:
        return _buildTicketDragArena();
      case NumberTrainInteractionType.carriageOrdering:
      case NumberTrainInteractionType.carriageSorting:
      case NumberTrainInteractionType.digitBuilder:
        return _buildCarriageOrderingArena();
      case NumberTrainInteractionType.guidedPlaceValue:
        return _buildGuidedPlaceValueArena();
      case NumberTrainInteractionType.masteryOrdering:
        return _buildMasteryOrderingArena();
    }
  }

  // 1. TAP SELECTION ARENA (Challenge 1)
  Widget _buildTapSelectionArena() {
    return Column(
      children: List.generate(widget.challenge.numbers.length, (idx) {
        final numStr = widget.challenge.numbers[idx];
        final isSelected = _selectedOption == numStr;

        Color bg = Colors.white;
        Color border = Colors.grey.shade300;
        Color textCol = const Color(0xFF2D3436);

        if (isSelected) {
          bg = const Color(0xFFFFF9E6);
          border = AppColors.mathOrange;
          textCol = const Color(0xFFE65100);
        }

        if (_isAnswered && isSelected) {
          if (_isCorrect) {
            bg = const Color(0xFFE8F5E9);
            border = const Color(0xFF27AE60);
            textCol = const Color(0xFF1B5E20);
          } else {
            bg = const Color(0xFFFFEBEE);
            border = const Color(0xFFE74C3C);
            textCol = const Color(0xFFC0392B);
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BouncingButton(
            onPressed: _isAnswered && _isCorrect
                ? null
                : () {
                    _soundService.playClick();
                    setState(() => _selectedOption = numStr);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border, width: isSelected ? 2.5 : 1.5),
                boxShadow: AppShadows.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.confirmation_number_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    numStr,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: textCol,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Icon(
                      _isAnswered
                          ? (_isCorrect
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded)
                          : Icons.radio_button_checked_rounded,
                      color: _isAnswered
                          ? (_isCorrect
                              ? const Color(0xFF27AE60)
                              : const Color(0xFFE74C3C))
                          : AppColors.mathOrange,
                      size: 26,
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // 2. TICKET DRAG ARENA (Challenge 2)
  Widget _buildTicketDragArena() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          // Station Ticket Counter Target Drop Slot
          const Text(
            '🚉 දුම්රිය ටිකට් පරීක්ෂණ කවුන්ටරය',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C5CE7),
            ),
          ),
          const SizedBox(height: 12),

          DragTarget<String>(
            onAcceptWithDetails: (details) {
              if (_isAnswered) return;
              _soundService.playClick();
              setState(() => _draggedTicket = details.data);
            },
            builder: (context, candidateData, rejectedData) {
              final hasTicket = _draggedTicket != null;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 90,
                decoration: BoxDecoration(
                  color: hasTicket
                      ? const Color(0xFFFFF9E6)
                      : (candidateData.isNotEmpty
                          ? const Color(0xFFE8F5E9)
                          : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasTicket
                        ? AppColors.mathOrange
                        : (candidateData.isNotEmpty
                            ? const Color(0xFF27AE60)
                            : Colors.grey.shade400),
                    width: hasTicket || candidateData.isNotEmpty ? 2.5 : 2,
                    style: hasTicket ? BorderStyle.solid : BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: hasTicket
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.confirmation_number_rounded,
                                color: AppColors.mathOrange, size: 30),
                            const SizedBox(width: 10),
                            Text(
                              _draggedTicket!,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE65100),
                                letterSpacing: 2,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel_rounded,
                                  color: Colors.grey),
                              onPressed: _isAnswered
                                  ? null
                                  : () {
                                      setState(() => _draggedTicket = null);
                                    },
                            ),
                          ],
                        )
                      : Text(
                          candidateData.isNotEmpty
                              ? 'මෙතැනට අතහරින්න! 🎟️'
                              : '🎟️ ටිකට්පත මෙතැනට Drag කරන්න',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: candidateData.isNotEmpty
                                ? const Color(0xFF27AE60)
                                : Colors.grey.shade600,
                          ),
                        ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Available Ticket Pool
          const Text(
            'ලබාදී ඇති ටිකට්පත් (Tap or Drag):',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: widget.challenge.numbers.map((tNum) {
              final isUsed = _draggedTicket == tNum;

              if (isUsed) {
                return Opacity(
                  opacity: 0.3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tNum,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }

              return Draggable<String>(
                data: tNum,
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      tNum,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tNum,
                      style: const TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    if (_isAnswered) return;
                    _soundService.playClick();
                    setState(() => _draggedTicket = tNum);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.softShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.confirmation_number_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          tNum,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 3. CARRIAGE ORDERING ARENA (Challenges 3 & 5)
  Widget _buildCarriageOrderingArena() {
    final available = widget.challenge.numbers
        .where((n) => !_orderedCarriages.contains(n))
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_railway_rounded,
                  color: AppColors.mathOrange, size: 24),
              SizedBox(width: 8),
              Text(
                '🚂 කුඩාම ➔ විශාලම දුම්රිය මැදිරි අනුපිළිවෙල',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Railway Track Slots
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF34495E), width: 2),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(widget.challenge.numbers.length, (slotIdx) {
                  final count = widget.challenge.numbers.length;
                  final slotWidth = count >= 5 ? 58.0 : (count == 4 ? 72.0 : 84.0);
                  final carriageFontSize = count >= 5 ? 12.0 : (count == 4 ? 16.0 : 22.0);
                  final hasCarriage = slotIdx < _orderedCarriages.length;
                  final carriageVal =
                      hasCarriage ? _orderedCarriages[slotIdx] : null;

                  return GestureDetector(
                    onTap: () {
                      if (_isAnswered || !hasCarriage) return;
                      _soundService.playClick();
                      setState(() {
                        _orderedCarriages.removeAt(slotIdx);
                      });
                    },
                    child: Container(
                      width: slotWidth,
                      height: 74,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: hasCarriage
                            ? const Color(0xFFFFD700)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasCarriage
                              ? const Color(0xFFF39C12)
                              : Colors.white38,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'මැදිරිය ${slotIdx + 1}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: hasCarriage ? Colors.black54 : Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Text(
                                carriageVal ?? '___',
                                style: TextStyle(
                                  fontSize: carriageFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: hasCarriage ? Colors.black : Colors.white54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Available Carriages Pool to Tap
          const Text(
            'තෝරාගැනීමට ඇති මැදිරි (Tap to place in order):',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: available.map((cNum) {
              return BouncingButton(
                onPressed: _isAnswered
                    ? null
                    : () {
                        _soundService.playClick();
                        setState(() {
                          _orderedCarriages.add(cNum);
                        });
                      },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.softShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🚃 ', style: TextStyle(fontSize: 18)),
                      Text(
                        cNum,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 4. GUIDED PLACE VALUE ARENA (Challenge 4)
  Widget _buildGuidedPlaceValueArena() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _placeValueStep == 0
                      ? 'පියවර 1: සියයස්ථාන ඉලක්කම් සසඳමු'
                      : 'පියවර 2: දහයස්ථාන ඉලක්කම් සසඳමු',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mathOrange,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _placeValueStep = (_placeValueStep == 0) ? 1 : 0;
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                label: Text(
                  _placeValueStep == 0 ? 'දහයස්ථාන ➡️' : 'සියයස්ථාන ⬅️',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Numbers Breakdown Cards
          Column(
            children: widget.challenge.numbers.map((nStr) {
              final digits = nStr.split('');
              final isSelected = _selectedOption == nStr;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    if (_isAnswered) return;
                    _soundService.playClick();
                    setState(() => _selectedOption = nStr);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFF9E6)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.mathOrange
                            : Colors.grey.shade300,
                        width: isSelected ? 2.5 : 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded,
                            color: Colors.amber, size: 24),
                        const SizedBox(width: 12),

                        // Digit Highlights
                        Row(
                          children: List.generate(digits.length, (dIdx) {
                            final isHighlighted = (_placeValueStep == 0 && dIdx == 0) ||
                                (_placeValueStep == 1 && dIdx == 1);

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isHighlighted
                                    ? const Color(0xFFFFD700)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isHighlighted
                                      ? const Color(0xFFF39C12)
                                      : Colors.grey.shade300,
                                  width: isHighlighted ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                digits[dIdx],
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: isHighlighted
                                      ? Colors.black
                                      : const Color(0xFF2D3436),
                                ),
                              ),
                            );
                          }),
                        ),

                        const Spacer(),

                        Text(
                          isSelected ? 'තෝරාගත්තා ✓' : 'තෝරන්න',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.mathOrange
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 5. MASTERY ORDERING ARENA (Challenge 6)
  Widget _buildMasteryOrderingArena() {
    return Column(
      children: [
        // Moving Train Graphic Animation upon success
        if (_trainAnimController.isAnimating || _trainAnimController.isCompleted)
          Container(
            height: 60,
            clipBehavior: Clip.none,
            child: AnimatedBuilder(
              animation: _trainMoveAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_trainMoveAnim.value, 0),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🚂💨', style: TextStyle(fontSize: 36)),
                      Text('🚃', style: TextStyle(fontSize: 32)),
                      Text('🚃', style: TextStyle(fontSize: 32)),
                      Text('🚃', style: TextStyle(fontSize: 32)),
                    ],
                  ),
                );
              },
            ),
          ),

        _buildCarriageOrderingArena(),
      ],
    );
  }

  // ─── PARROT TUTOR HIGH CONTRAST FEEDBACK BUBBLE ───

  Widget _buildParrotTutorBubble() {
    String dialogue = '';
    Color bubbleBg = const Color(0xFFFFF9E6); // Solid readable light cream
    Color borderColor = const Color(0xFFFFD166);
    Color textColor = const Color(0xFF1E293B); // Dark near-black high-contrast text

    if (_isCorrect) {
      dialogue = '🦜 "නියමයි! නිවැරදි පිළිතුර! ඔයා මහා සංඛ්‍යා දුම්රියේ සැබෑ වීරයෙක්! 🎉"';
      bubbleBg = const Color(0xFFE8F5E9);
      borderColor = const Color(0xFF27AE60);
      textColor = const Color(0xFF1B5E20);
    } else if (_hintLevel == 1) {
      dialogue = '🦜 "අපි එකට බලමු! ${widget.challenge.hintLevel1}"';
    } else if (_hintLevel == 2) {
      dialogue = '🦜 "තව ටිකක් හිතමු! ${widget.challenge.hintLevel2}"';
    } else if (_hintLevel == 3) {
      dialogue = '🦜 "කමක් නැහැ! මෙන්න විසඳුම:\n${widget.challenge.explanation}"';
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
                    dialogue,
                    style: TextStyle(
                      fontSize: 16,
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

  // ─── ACTION BUTTON BAR ───

  Widget _buildActionButtonBar() {
    String buttonText = 'පරීක්ෂා කරමු 🔍';
    Color buttonColor = AppColors.mathOrange;
    IconData buttonIcon = Icons.search_rounded;
    VoidCallback? action = _canSubmit ? _checkAnswer : null;

    if (_isAnswered) {
      if (_isCorrect) {
        buttonText = 'ඊළඟ අභියෝගය ➡️';
        buttonColor = const Color(0xFF27AE60);
        buttonIcon = Icons.arrow_forward_rounded;
        action = widget.onChallengeCompleted;
      } else if (_currentAttempt == 3) {
        buttonText = 'ඉදිරියට යමු ➡️';
        buttonColor = const Color(0xFF6C5CE7);
        buttonIcon = Icons.arrow_forward_rounded;
        action = widget.onChallengeCompleted;
      } else {
        buttonText =
            'නැවත උත්සාහ කරන්න (උත්සාහය ${_currentAttempt + 1} / 3) 🔄';
        buttonColor = AppColors.mathOrange;
        buttonIcon = Icons.refresh_rounded;
        action = _onRetry;
      }
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          disabledBackgroundColor: Colors.grey.shade300,
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
    );
  }
}
