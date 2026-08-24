import 'package:flutter/material.dart';
import '../../models/maths/lesson_step_model.dart';
import '../../utils/app_theme.dart';
import '../../services/sound_service.dart';
import '../animated_widgets.dart';

/// Interactive Step Renderer supporting multiple question types, teaching chapters,
/// place-value castle, expanded form builders, matching tables, and abacus challenges.
class LessonStepWidget extends StatefulWidget {
  final LessonStepModel step;
  final Function(bool isCorrect, String? explanation) onAnswerSubmitted;

  const LessonStepWidget({
    super.key,
    required this.step,
    required this.onAnswerSubmitted,
  });

  @override
  State<LessonStepWidget> createState() => _LessonStepWidgetState();
}

class _LessonStepWidgetState extends State<LessonStepWidget> {
  final SoundService _soundService = SoundService();
  
  // Shuffled options list (randomized order)
  late List<QuestionOption> _shuffledOptions;
  
  // Interaction states
  int? _selectedOptionIndex;
  String _inputText = '';
  Map<String, String?> _matchingAnswers = {}; // Digit -> Selected PlaceValue
  bool _hasSubmitted = false;

  // Abacus state
  int _thousandsBeads = 0;
  int _hundredsBeads = 0;
  int _tensBeads = 0;
  int _onesBeads = 0;

  @override
  void initState() {
    super.initState();
    _shuffledOptions = widget.step.getShuffledOptions();
    if (widget.step.matchingPairs != null) {
      for (var pair in widget.step.matchingPairs!) {
        _matchingAnswers[pair.digit] = null;
      }
    }
  }

  @override
  void didUpdateWidget(covariant LessonStepWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      setState(() {
        _shuffledOptions = widget.step.getShuffledOptions();
        _selectedOptionIndex = null;
        _inputText = '';
        _matchingAnswers = {};
        _hasSubmitted = false;
        _thousandsBeads = 0;
        _hundredsBeads = 0;
        _tensBeads = 0;
        _onesBeads = 0;
        if (widget.step.matchingPairs != null) {
          for (var pair in widget.step.matchingPairs!) {
            _matchingAnswers[pair.digit] = null;
          }
        }
      });
    }
  }

  void _submitMCQ(int index) {
    if (_hasSubmitted) return;
    final selected = _shuffledOptions[index];
    setState(() {
      _selectedOptionIndex = index;
      _hasSubmitted = true;
    });

    if (selected.isCorrect) {
      _soundService.playCorrect();
    } else {
      _soundService.playWrong();
    }

    widget.onAnswerSubmitted(selected.isCorrect, selected.hint);
  }

  void _submitNumericInput() {
    if (_hasSubmitted) return;
    final isCorrect = _inputText.trim() == (widget.step.correctAnswer ?? '').trim();
    setState(() {
      _hasSubmitted = true;
    });

    if (isCorrect) {
      _soundService.playCorrect();
    } else {
      _soundService.playWrong();
    }

    widget.onAnswerSubmitted(
      isCorrect,
      isCorrect ? 'හරියටම හරි!' : 'නිවැරදි පිළිතුර: ${widget.step.correctAnswer}',
    );
  }

  void _submitMatching() {
    if (_hasSubmitted) return;
    bool allCorrect = true;
    for (var pair in widget.step.matchingPairs!) {
      if (_matchingAnswers[pair.digit] != pair.placeValue) {
        allCorrect = false;
        break;
      }
    }
    setState(() {
      _hasSubmitted = true;
    });

    if (allCorrect) {
      _soundService.playCorrect();
    } else {
      _soundService.playWrong();
    }

    widget.onAnswerSubmitted(
      allCorrect,
      allCorrect ? 'සියලුම ස්ථාන නිවැරදිව යා කරන ලදී!' : 'නැවත පරීක්ෂා කර බලමු!',
    );
  }

  void _submitAbacus() {
    final value = (_thousandsBeads * 1000) + (_hundredsBeads * 100) + (_tensBeads * 10) + _onesBeads;
    final isCorrect = value == 5421;

    if (isCorrect) {
      _soundService.playCorrect();
    } else {
      _soundService.playWrong();
    }

    widget.onAnswerSubmitted(
      isCorrect,
      isCorrect ? 'නියමයි! අබකසයේ සංඛ්‍යාව 5421 ලෙස සාදන ලදී!' : 'අබකසයේ පබළු ගණන පරීක්ෂා කරන්න (5, 4, 2, 1)',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Parrot Dialogue Bubble
          if (widget.step.parrotDialogue != null) _buildParrotSpeechBubble(),

          const SizedBox(height: 16),

          // Question Title Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.step.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mathOrange,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.step.questionText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Interactive Question Component based on QuestionInteractionType
          _buildInteractiveContent(),
        ],
      ),
    );
  }

  /// Parrot Speech Bubble UI
  Widget _buildParrotSpeechBubble() {
    return SlideInWidget(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9E6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD166), width: 2),
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
                    child: Text('🦜', style: TextStyle(fontSize: 28)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                widget.step.parrotDialogue!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5D4037),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveContent() {
    switch (widget.step.interactionType) {
      case QuestionInteractionType.multipleChoice:
      case QuestionInteractionType.wordArrangement:
      case QuestionInteractionType.placeValuePicker:
      case QuestionInteractionType.expandedFormBuilder:
        return _buildMCQView();

      case QuestionInteractionType.numericInput:
        return _buildNumericInputView();

      case QuestionInteractionType.matchingTable:
        return _buildMatchingTableView();

      case QuestionInteractionType.abacusInteractive:
        return _buildAbacusView();

      default:
        return _buildMCQView();
    }
  }

  /// MCQ / Card Picker with Randomized Options
  Widget _buildMCQView() {
    return Column(
      children: List.generate(_shuffledOptions.length, (index) {
        final option = _shuffledOptions[index];
        final isSelected = _selectedOptionIndex == index;

        Color cardBg = Colors.white;
        Color borderColor = Colors.grey.shade300;
        IconData? icon;

        if (_hasSubmitted) {
          if (option.isCorrect) {
            cardBg = const Color(0xFFE8F8F5);
            borderColor = const Color(0xFF2ECC71);
            icon = Icons.check_circle_rounded;
          } else if (isSelected) {
            cardBg = const Color(0xFFFDEDEC);
            borderColor = const Color(0xFFE74C3C);
            icon = Icons.cancel_rounded;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BouncingButton(
            onPressed: () => _submitMCQ(index),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: isSelected ? 3.0 : 1.5),
                boxShadow: AppShadows.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.mathOrange : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
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
                  if (icon != null) Icon(icon, color: borderColor, size: 24),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Numeric Input View
  Widget _buildNumericInputView() {
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
            keyboardType: TextInputType.number,
            onChanged: (val) => setState(() => _inputText = val),
            decoration: InputDecoration(
              hintText: 'පිළිතුර මෙතැන ටයිප් කරන්න...',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.mathOrange, width: 2),
              ),
            ),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _inputText.isEmpty || _hasSubmitted ? null : _submitNumericInput,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mathOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'පිළිතුර පරීක්ෂා කරන්න 🚀',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Matching Table View
  Widget _buildMatchingTableView() {
    final pairs = widget.step.matchingPairs ?? [];
    final availablePlaces = ['දස දහස්', 'දහස්', 'සිය', 'දහය', 'එකක'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...pairs.map((pair) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.mathOrange,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        pair.digit,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _matchingAnswers[pair.digit],
                      hint: const Text('ස්ථානය තෝරන්න'),
                      items: availablePlaces.map((place) {
                        return DropdownMenuItem(value: place, child: Text(place));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _matchingAnswers[pair.digit] = val;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _hasSubmitted ? null : _submitMatching,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mathOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'යා කිරීම් පරීක්ෂා කරන්න 🎯',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive Abacus Challenge View
  Widget _buildAbacusView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          const Text(
            'අබකසයේ පබළු සකසා 5 421 අංකය හදන්න! 🧮',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.mathOrange),
          ),
          const SizedBox(height: 20),

          // Abacus Columns Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAbacusColumn('දහස්', _thousandsBeads, (val) => setState(() => _thousandsBeads = val)),
              _buildAbacusColumn('සිය', _hundredsBeads, (val) => setState(() => _hundredsBeads = val)),
              _buildAbacusColumn('දහය', _tensBeads, (val) => setState(() => _tensBeads = val)),
              _buildAbacusColumn('එකක', _onesBeads, (val) => setState(() => _onesBeads = val)),
            ],
          ),

          const SizedBox(height: 20),

          // Current Abacus Value Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'වත්මන් අගය: ${(_thousandsBeads * 1000) + (_hundredsBeads * 100) + (_tensBeads * 10) + _onesBeads}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitAbacus,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mathOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'අබකසය පරීක්ෂා කරන්න ✨',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbacusColumn(String label, int beads, Function(int) onChange) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.add_circle, color: AppColors.mathOrange),
          onPressed: beads < 9 ? () => onChange(beads + 1) : null,
        ),
        Container(
          width: 44,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(beads, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.5),
                child: Image.asset(
                  MathsAssets.mangoBead,
                  width: 36,
                  height: 11,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    width: 36,
                    height: 11,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text('🥭'),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.grey),
          onPressed: beads > 0 ? () => onChange(beads - 1) : null,
        ),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text('$beads', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mathOrange)),
      ],
    );
  }
}
