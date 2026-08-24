import 'package:flutter/material.dart';
import '../../../models/maths/maths_game_model.dart';
import '../../../services/sound_service.dart';
import '../../../utils/app_theme.dart';
import '../../animated_widgets.dart';

class AbacusChallengeWidget extends StatefulWidget {
  final AbacusRoundModel round;
  final Function(bool isCorrect, int xpEarned) onRoundCompleted;

  const AbacusChallengeWidget({
    super.key,
    required this.round,
    required this.onRoundCompleted,
  });

  @override
  State<AbacusChallengeWidget> createState() => _AbacusChallengeWidgetState();
}

class _AbacusChallengeWidgetState extends State<AbacusChallengeWidget> {
  final SoundService _soundService = SoundService();

  // Bead counts per place value column (MUST start at 0)
  late List<int> _columnBeads;

  int _hintIndex = 0;
  bool _showHint = false;
  bool _hasSubmitted = false;
  bool _isCorrect = false;

  static const String _mangoBeadAsset = MathsAssets.abacusMangoBead;

  @override
  void initState() {
    super.initState();
    _resetAbacus();
  }

  @override
  void didUpdateWidget(covariant AbacusChallengeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.round.id != widget.round.id) {
      _resetAbacus();
    }
  }

  /// Reset all column beads to EXACTLY ZERO (0)
  void _resetAbacus() {
    setState(() {
      _columnBeads = List.filled(widget.round.placeValues.length, 0);
      _hintIndex = 0;
      _showHint = false;
      _hasSubmitted = false;
      _isCorrect = false;
    });
  }

  void _addBead(int columnIndex) {
    if (_hasSubmitted) return;
    if (_columnBeads[columnIndex] < 9) {
      _soundService.playClick();
      setState(() {
        _columnBeads[columnIndex]++;
      });
    }
  }

  void _removeBead(int columnIndex) {
    if (_hasSubmitted) return;
    if (_columnBeads[columnIndex] > 0) {
      _soundService.playClick();
      setState(() {
        _columnBeads[columnIndex]--;
      });
    }
  }

  int get _constructedTotal {
    int total = 0;
    int multiplier = 1;
    for (int i = _columnBeads.length - 1; i >= 0; i--) {
      total += _columnBeads[i] * multiplier;
      multiplier *= 10;
    }
    return total;
  }

  void _submitAnswer() {
    if (_hasSubmitted) return;
    final constructed = _constructedTotal;
    final target = widget.round.targetNumber;
    final correct = constructed == target;

    setState(() {
      _hasSubmitted = true;
      _isCorrect = correct;
    });

    if (correct) {
      _soundService.playCorrect();
      int xp = _showHint ? 30 : 50;
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

  String _getMultiplierLabel(int totalColumns, int colIdx) {
    final int power = totalColumns - 1 - colIdx;
    switch (power) {
      case 4:
        return '10,000';
      case 3:
        return '1,000';
      case 2:
        return '100';
      case 1:
        return '10';
      case 0:
        return '1';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFiveDigit = widget.round.placeValues.length == 5;
    final isMatchingTarget = _constructedTotal == widget.round.targetNumber;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Parrot Prompt Banner
          _buildParrotPromptCard(),

          const SizedBox(height: 14),

          // Target Number Banner (Royal Golden Quest Card)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A148C).withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'සාදිය යුතු සංඛ්‍යාව:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '${widget.round.targetNumber}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Interactive Carved Mahogany Abacus Frame
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3E2723), Color(0xFF2C1810), Color(0xFF1E100B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Frame Header with Live Value
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            _mangoBeadAsset,
                            width: 22,
                            height: 22,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.calculate_rounded,
                              color: Color(0xFFFFD700),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ගණක රාමුව (Abacus)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isMatchingTarget
                              ? const Color(0xFF2ECC71).withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isMatchingTarget
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFFFFD700).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'තැනූ අගය: $_constructedTotal',
                          style: TextStyle(
                            color: isMatchingTarget
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFFFFD700),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Columns & Brass Rods with Mango Beads
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(_columnBeads.length, (colIdx) {
                    final placeValueTitle = widget.round.placeValues[colIdx];
                    final multiplier = _getMultiplierLabel(_columnBeads.length, colIdx);
                    final count = _columnBeads[colIdx];

                    return _buildAbacusColumn(
                      colIdx: colIdx,
                      title: placeValueTitle,
                      multiplier: multiplier,
                      count: count,
                      isFiveDigit: isFiveDigit,
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Hint Drawer Card
          if (_showHint) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
                boxShadow: AppShadows.softShadow,
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
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
                  child: const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 22),
                ),
              ),
              const SizedBox(width: 8),

              // Reset Button
              OutlinedButton.icon(
                onPressed: _resetAbacus,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('නැවත සකසන්න'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Submit Button
              Expanded(
                child: BouncingButton(
                  onPressed: _hasSubmitted ? null : _submitAnswer,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: _hasSubmitted
                          ? LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade700])
                          : const LinearGradient(
                              colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                            ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2ECC71).withValues(alpha: 0.35),
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
                          'පරීක්ෂා කරන්න',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
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
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isCorrect
                          ? 'නියමයි! ${widget.round.targetNumber} අගය ගණක රාමුව මත නිවැරදිව සාදා ඇත!'
                          : 'හොඳ උත්සාහයක්! අඹ පබළු ගණන නැවත පරීක්ෂා කර සකසමු.',
                      style: TextStyle(
                        color: _isCorrect ? const Color(0xFF1E8449) : const Color(0xFF922B21),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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

  /// Parrot Prompt Banner
  Widget _buildParrotPromptCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                MathsAssets.parrotIdle,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.smart_toy_rounded, color: Color(0xFF4CAF50), size: 24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.round.parrotPrompt,
              style: const TextStyle(
                color: Color(0xFF5D4037),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Single Abacus Rod Column with Mango Fruit Beads
  Widget _buildAbacusColumn({
    required int colIdx,
    required String title,
    required String multiplier,
    required int count,
    required bool isFiveDigit,
  }) {
    final bool canAdd = count < 9 && !_hasSubmitted;
    final bool canRemove = count > 0 && !_hasSubmitted;
    final double colWidth = isFiveDigit ? 48 : 58;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Place Value Header Label (Sinhala Name)
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.w900,
            fontSize: isFiveDigit ? 11 : 13,
          ),
        ),
        // Numerical Multiplier (e.g. 1,000)
        Text(
          multiplier,
          style: TextStyle(
            color: Colors.white60,
            fontWeight: FontWeight.bold,
            fontSize: isFiveDigit ? 9 : 10,
          ),
        ),
        const SizedBox(height: 6),

        // Plus (+) Stepper Button
        InkWell(
          onTap: canAdd ? () => _addBead(colIdx) : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isFiveDigit ? 32 : 36,
            height: isFiveDigit ? 32 : 36,
            decoration: BoxDecoration(
              gradient: canAdd
                  ? const LinearGradient(
                      colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade700, Colors.grey.shade800],
                    ),
              shape: BoxShape.circle,
              boxShadow: canAdd
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2ECC71).withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.add_rounded,
              color: canAdd ? Colors.white : Colors.white30,
              size: isFiveDigit ? 18 : 20,
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Vertical Brass Rod Container with Stacked Mango Beads
        Container(
          width: colWidth,
          height: 195,
          decoration: BoxDecoration(
            color: const Color(0xFF180E08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Vertical Brass Metallic Rod
              Center(
                child: Container(
                  width: 5,
                  height: 185,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE082), Color(0xFFD4AF37), Color(0xFF8D6E63)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Bottom Base Stopper on the Rod
              Positioned(
                bottom: 0,
                child: Container(
                  width: colWidth - 8,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Stacked Mango Fruit Beads
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(count, (bIdx) {
                    return _buildFruitBead(isFiveDigit: isFiveDigit);
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Minus (−) Stepper Button
        InkWell(
          onTap: canRemove ? () => _removeBead(colIdx) : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isFiveDigit ? 32 : 36,
            height: isFiveDigit ? 32 : 36,
            decoration: BoxDecoration(
              gradient: canRemove
                  ? const LinearGradient(
                      colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade700, Colors.grey.shade800],
                    ),
              shape: BoxShape.circle,
              boxShadow: canRemove
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE74C3C).withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.remove_rounded,
              color: canRemove ? Colors.white : Colors.white30,
              size: isFiveDigit ? 18 : 20,
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Digit Count Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: count > 0
                ? const Color(0xFFFFD700)
                : Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: count > 0 ? Colors.white : Colors.white24,
              width: 1,
            ),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: count > 0 ? const Color(0xFF2C1810) : Colors.white70,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// Dedicated 2D Mango Fruit Bead Widget for Abacus Rod Stack
  Widget _buildFruitBead({required bool isFiveDigit}) {
    final beadWidth = isFiveDigit ? 34.0 : 42.0;
    const beadHeight = 20.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.4),
      child: SizedBox(
        width: beadWidth,
        height: beadHeight,
        child: Image.asset(
          _mangoBeadAsset,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.circle, color: Color(0xFFFFB300), size: 16),
          ),
        ),
      ),
    );
  }
}
