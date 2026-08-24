import 'package:flutter/material.dart';
import '../../../models/maths/maths_game_model.dart';
import '../../../services/sound_service.dart';
import '../../../utils/app_theme.dart';
import '../../animated_widgets.dart';

class PlaceValueGameWidget extends StatefulWidget {
  final PlaceValueRoundModel round;
  final Function(bool isCorrect, int xpEarned) onRoundCompleted;

  const PlaceValueGameWidget({
    super.key,
    required this.round,
    required this.onRoundCompleted,
  });

  @override
  State<PlaceValueGameWidget> createState() => _PlaceValueGameWidgetState();
}

class _PlaceValueGameWidgetState extends State<PlaceValueGameWidget> {
  final SoundService _soundService = SoundService();

  late List<String> _shuffledOptions;
  int? _selectedOptionIndex;
  int? _selectedDigitIndex;

  bool _hasSubmitted = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _resetRound();
  }

  @override
  void didUpdateWidget(covariant PlaceValueGameWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.round.id != widget.round.id) {
      _resetRound();
    }
  }

  void _resetRound() {
    final numberDigits = widget.round.fullNumber.split('');
    final targetIdx = numberDigits.indexOf(widget.round.targetDigit);
    setState(() {
      _shuffledOptions = List.from(widget.round.options)..shuffle();
      _selectedOptionIndex = null;
      _selectedDigitIndex = targetIdx != -1 ? targetIdx : (numberDigits.isNotEmpty ? 0 : null);
      _hasSubmitted = false;
      _isCorrect = false;
    });
  }

  void _selectOption(int index) {
    if (_hasSubmitted) return;
    _soundService.playClick();
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _submitAnswer() {
    if (_hasSubmitted || _selectedOptionIndex == null) return;
    final selectedText = _shuffledOptions[_selectedOptionIndex!];
    final correct = (selectedText == widget.round.correctRepresentedValue ||
        selectedText == widget.round.correctPlaceValue);

    setState(() {
      _hasSubmitted = true;
      _isCorrect = correct;
    });

    if (correct) {
      _soundService.playCorrect();
      int xp = 40;
      widget.onRoundCompleted(true, xp);
    } else {
      _soundService.playWrong();
      widget.onRoundCompleted(false, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberDigits = widget.round.fullNumber.split('');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Parrot Prompt Banner
          _buildParrotPromptCard(),

          const SizedBox(height: 16),

          // Interactive Number & Place Value Table Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2A38),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF9B59B6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '🏰 ස්ථානීය අගය ගවේෂකය (Tap any digit)',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Digit Boxes with Place Value Labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(numberDigits.length, (dIdx) {
                    final digitStr = numberDigits[dIdx];
                    final isUserSelected = _selectedDigitIndex == dIdx;
                    final isHighlighted = isUserSelected || (_selectedDigitIndex == null && digitStr == widget.round.targetDigit);

                    return GestureDetector(
                      onTap: () {
                        _soundService.playClick();
                        setState(() => _selectedDigitIndex = dIdx);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isHighlighted ? const Color(0xFFFFD700) : const Color(0xFF2C3E50),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isHighlighted ? const Color(0xFFF39C12) : Colors.white24,
                            width: isHighlighted ? 3 : 1,
                          ),
                          boxShadow: isHighlighted
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withOpacity(0.4),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            digitStr,
                            style: TextStyle(
                              color: isHighlighted ? Colors.black : Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                if (_selectedDigitIndex != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'තෝරාගත් ඉලක්කම: ${numberDigits[_selectedDigitIndex!]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Question Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ප්‍රශ්නය:',
                  style: TextStyle(
                    color: AppColors.mathOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.round.questionText,
                  style: const TextStyle(
                    color: Color(0xFF2D3436),
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
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
              Color cardColor = Colors.white;
              Color borderColor = Colors.grey.shade300;
              Color textColor = const Color(0xFF2D3436);
              Color badgeBg = Colors.grey.shade200;
              Color badgeTextColor = Colors.black87;

              if (isSelected) {
                cardColor = const Color(0xFFE8F5E9);
                borderColor = const Color(0xFF27AE60);
                textColor = const Color(0xFF1B5E20);
                badgeBg = AppColors.mathOrange;
                badgeTextColor = Colors.white;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BouncingButton(
                  onPressed: _hasSubmitted
                      ? null
                      : () {
                          _selectOption(optIdx);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: borderColor,
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: AppShadows.softShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: badgeBg,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + optIdx),
                              style: TextStyle(
                                color: badgeTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            optText,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF27AE60),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Submit Button (Single clear button)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_hasSubmitted || _selectedOptionIndex == null)
                  ? null
                  : _submitAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mathOrange,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              label: const Text(
                'පිළිතුර තහවුරු කරමු 🔍',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Feedback Status Banner
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
                          ? '🦜 "නියමයි! ${widget.round.explanationSi}"'
                          : '🦜 "ආයෙත් බලමු. ${widget.round.explanationSi}"',
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
          ],
        ],
      ),
    );
  }

  Widget _buildParrotPromptCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
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
          const Expanded(
            child: Text(
              '🦜 "ස්ථානීය අගය හඳුනාගෙන නිවැරදි පිළිතුර තෝරන්න!"',
              style: TextStyle(
                color: Color(0xFF5D4037),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
