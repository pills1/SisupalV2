import 'package:flutter/material.dart';
import '../../../models/maths/maths_game_model.dart';
import '../../../services/sound_service.dart';
import '../../../utils/app_theme.dart';

class DigitBuilderWidget extends StatefulWidget {
  final DigitBuilderRoundModel round;
  final Function(bool isCorrect, int xpEarned) onRoundCompleted;

  const DigitBuilderWidget({
    super.key,
    required this.round,
    required this.onRoundCompleted,
  });

  @override
  State<DigitBuilderWidget> createState() => _DigitBuilderWidgetState();
}

class _DigitBuilderWidgetState extends State<DigitBuilderWidget> {
  final SoundService _soundService = SoundService();

  // Placed digits in order (null means empty slot)
  late List<int?> _placedSlots;

  // Available unplaced digits
  late List<int> _availableDigits;

  int _hintIndex = 0;
  bool _showHint = false;
  bool _hasSubmitted = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _resetRound();
  }

  @override
  void didUpdateWidget(covariant DigitBuilderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.round.id != widget.round.id) {
      _resetRound();
    }
  }

  void _resetRound() {
    setState(() {
      _placedSlots = List.filled(widget.round.digits.length, null);
      final shuffled = List<int>.from(widget.round.digits)..shuffle();
      if (shuffled.join('') == widget.round.targetAnswer && shuffled.length > 1) {
        shuffled.shuffle();
      }
      _availableDigits = shuffled;
      _hintIndex = 0;
      _showHint = false;
      _hasSubmitted = false;
      _isCorrect = false;
    });
  }

  void _onDigitTapped(int digitValue, int digitIndex) {
    if (_hasSubmitted) return;
    _soundService.playClick();

    // Find first empty slot
    final firstEmptyIdx = _placedSlots.indexOf(null);
    if (firstEmptyIdx != -1) {
      setState(() {
        _placedSlots[firstEmptyIdx] = digitValue;
        _availableDigits.removeAt(digitIndex);
      });
    }
  }

  void _onSlotTapped(int slotIndex) {
    if (_hasSubmitted) return;
    final val = _placedSlots[slotIndex];
    if (val != null) {
      _soundService.playClick();
      setState(() {
        _placedSlots[slotIndex] = null;
        _availableDigits.add(val);
      });
    }
  }

  String get _constructedNumber {
    return _placedSlots.map((e) => e == null ? '' : e.toString()).join();
  }

  void _submitAnswer() {
    if (_hasSubmitted) return;
    final builtNum = _constructedNumber;

    if (builtNum.length < widget.round.digits.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('කරුණාකර සියලුම ඉලක්කම් සකසන්න!'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    final correct = builtNum == widget.round.targetAnswer;

    setState(() {
      _hasSubmitted = true;
      _isCorrect = correct;
    });

    if (correct) {
      _soundService.playCorrect();
      int xp = _showHint ? 25 : 40;
      widget.onRoundCompleted(true, xp);
    } else {
      _soundService.playWrong();
      widget.onRoundCompleted(false, 0);
    }
  }

  void _toggleNextHint() {
    _soundService.playClick();
    setState(() {
      _showHint = true;
      if (_hintIndex < widget.round.hints.length - 1) {
        _hintIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Parrot Prompt Card
          _buildParrotPromptCard(),

          const SizedBox(height: 16),

          // Challenge Goal Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3498DB).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.touch_app_rounded, color: Color(0xFFFFD700), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.round.instructionSi,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Target Placement Slots [ _ ][ _ ][ _ ][ _ ]
          const Text(
            'තැනූ සංඛ්‍යාව (Tap slot to remove):',
            style: TextStyle(
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_placedSlots.length, (slotIdx) {
              final slotVal = _placedSlots[slotIdx];

              return DragTarget<int>(
                onAcceptWithDetails: (details) {
                  if (_hasSubmitted) return;
                  _soundService.playClick();
                  setState(() {
                    final oldVal = _placedSlots[slotIdx];
                    if (oldVal != null) {
                      _availableDigits.add(oldVal);
                    }
                    _placedSlots[slotIdx] = details.data;
                    _availableDigits.remove(details.data);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return GestureDetector(
                    onTap: () => _onSlotTapped(slotIdx),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 54,
                      height: 64,
                      decoration: BoxDecoration(
                        color: slotVal != null ? const Color(0xFFFFD700) : const Color(0xFF1F2A38),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: candidateData.isNotEmpty
                              ? const Color(0xFF2ECC71)
                              : (slotVal != null ? const Color(0xFFF39C12) : Colors.grey.shade400),
                          width: candidateData.isNotEmpty ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: candidateData.isNotEmpty ? 8 : 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          slotVal != null ? '$slotVal' : '_',
                          style: TextStyle(
                            color: slotVal != null ? Colors.black : Colors.white60,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          const SizedBox(height: 24),

          // Available Digits Pool
          const Text(
            'ලබාදී ඇති ඉලක්කම් (Tap or drag to slot):',
            style: TextStyle(
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_availableDigits.length, (dIdx) {
              final digitVal = _availableDigits[dIdx];

              return Draggable<int>(
                data: digitVal,
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$digitVal',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => _onDigitTapped(digitVal, dIdx),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE67E22).withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$digitVal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 28),

          // Hint Drawer Card
          if (_showHint) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, color: Colors.orange, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.round.hints[_hintIndex],
                      style: const TextStyle(
                        color: Color(0xFF5D4037),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Control & Action Buttons
          Row(
            children: [
              // Hint Button
              IconButton(
                onPressed: _toggleNextHint,
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 24),
                ),
              ),
              const SizedBox(width: 8),

              // Reset Button
              OutlinedButton.icon(
                onPressed: _resetRound,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('නැවත සකසන්න'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.mathOrange,
                  side: const BorderSide(color: AppColors.mathOrange, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Submit Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _hasSubmitted ? null : _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  label: const Text(
                    'තහවුරු කරන්න',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
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
                          ? '🦜 "නියමයි! ඔයා ඉලක්කම් නිවැරදිව සකසා ${widget.round.targetAnswer} හැදුවා! 🏆"'
                          : '🦜 "ආයෙත් බලමු. ඉලක්කම්වල විශාල කුඩා අගයන් නැවත සිතන්න."',
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
              '🦜 "ඉලක්කම් කාඩ්පත් slots වලට drag කරන්න හෝ tap කරන්න!"',
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
