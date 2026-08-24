import 'package:flutter/material.dart';
import '../../../models/maths/maths_game_model.dart';
import '../../../services/sound_service.dart';
import '../../../utils/app_theme.dart';
import '../../animated_widgets.dart';

class ExpandedFormGameWidget extends StatefulWidget {
  final ExpandedFormRoundModel round;
  final Function(bool isCorrect, int xpEarned) onRoundCompleted;

  const ExpandedFormGameWidget({
    super.key,
    required this.round,
    required this.onRoundCompleted,
  });

  @override
  State<ExpandedFormGameWidget> createState() => _ExpandedFormGameWidgetState();
}

class _ExpandedFormGameWidgetState extends State<ExpandedFormGameWidget> {
  final SoundService _soundService = SoundService();

  // Placed values in slots
  late List<String?> _placedSlots;

  // Available cards pool (shuffled)
  late List<String> _availableCards;

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
  void didUpdateWidget(covariant ExpandedFormGameWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.round.id != widget.round.id) {
      _resetRound();
    }
  }

  void _resetRound() {
    setState(() {
      _placedSlots = List.filled(widget.round.correctComponents.length, null);
      _availableCards = List.from(widget.round.availableCards)..shuffle();
      _hintIndex = 0;
      _showHint = false;
      _hasSubmitted = false;
      _isCorrect = false;
    });
  }

  void _onCardTapped(String cardValue, int cardIndex) {
    if (_hasSubmitted) return;
    _soundService.playClick();

    final firstEmptyIdx = _placedSlots.indexOf(null);
    if (firstEmptyIdx != -1) {
      setState(() {
        _placedSlots[firstEmptyIdx] = cardValue;
        _availableCards.removeAt(cardIndex);
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
        _availableCards.add(val);
      });
    }
  }

  void _submitAnswer() {
    if (_hasSubmitted) return;

    if (_placedSlots.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('කරුණාකර සියලුම ස්ථාන විහිදුවා ලියන්න!'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    bool correct = true;
    for (int i = 0; i < _placedSlots.length; i++) {
      if (_placedSlots[i] != widget.round.correctComponents[i]) {
        correct = false;
        break;
      }
    }

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
          // Parrot Prompt Banner
          _buildParrotPromptCard(),

          const SizedBox(height: 16),

          // Target Number Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE67E22), Color(0xFFD35400)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE67E22).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'විහිදුවිය යුතු සංඛ්‍යාව:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.round.targetNumber,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Expanded Equation Target Slots
          const Text(
            'විහිදූ අගයන් (Tap slot to remove):',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_placedSlots.length, (slotIdx) {
                final slotVal = _placedSlots[slotIdx];
                final isLast = slotIdx == _placedSlots.length - 1;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DragTarget<String>(
                      onAcceptWithDetails: (details) {
                        if (_hasSubmitted) return;
                        _soundService.playClick();
                        setState(() {
                          final oldVal = _placedSlots[slotIdx];
                          if (oldVal != null) _availableCards.add(oldVal);
                          _placedSlots[slotIdx] = details.data;
                          _availableCards.remove(details.data);
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return GestureDetector(
                          onTap: () => _onSlotTapped(slotIdx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            constraints: const BoxConstraints(minWidth: 64),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            decoration: BoxDecoration(
                              color: slotVal != null ? const Color(0xFF6C5CE7) : const Color(0xFF1F2A38),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: candidateData.isNotEmpty
                                    ? const Color(0xFF2ECC71)
                                    : (slotVal != null ? const Color(0xFFFFD700) : Colors.white24),
                                width: candidateData.isNotEmpty ? 3 : 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                slotVal ?? '____',
                                style: TextStyle(
                                  color: slotVal != null ? Colors.white : Colors.white38,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (!isLast)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '+',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 24),

          // Available Value Cards Pool
          const Text(
            'අගය කාඩ්පත් (Tap or drag to slot):',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_availableCards.length, (cIdx) {
              final cardVal = _availableCards[cIdx];

              return Draggable<String>(
                data: cardVal,
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B59B6),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      cardVal,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(cardVal, style: const TextStyle(color: Colors.transparent)),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => _onCardTapped(cardVal, cIdx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8E44AD).withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      cardVal,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
              OutlinedButton.icon(
                onPressed: _resetRound,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('නැවත සකසන්න'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BouncingButton(
                  onPressed: _hasSubmitted ? null : _submitAnswer,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: _hasSubmitted
                          ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600])
                          : const LinearGradient(
                              colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                            ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2ECC71).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'තහවුරු කරන්න',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
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
                          ? '🦜 "අපි ${widget.round.targetNumber} සාර්ථකව විහිදුවා ලිව්වා! 🏆"'
                          : '🦜 "නැවත බලමු. ස්ථානීය අගයන් නිවැරදි අනුපිළිවෙලට තබමු."',
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
              '🦜 "සංඛ්‍යාව විහිදුවා ලියන නිවැරදි අගයන් තෝරා තබන්න!"',
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
