import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_widgets.dart';
import '../services/sound_service.dart';

/// ============================================
/// USER GUIDE SCREEN - SisuPal Student Guide
/// Clean, charming, minimal design for Grade 5
/// ============================================
class UserGuideScreen extends StatefulWidget {
  final bool isModal;

  const UserGuideScreen({
    super.key,
    this.isModal = false,
  });

  static Future<void> show(BuildContext context) {
    SoundService().playClick();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const UserGuideScreen(isModal: true),
    );
  }

  @override
  State<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen>
    with SingleTickerProviderStateMixin {
  final SoundService _soundService = SoundService();
  int _activeStep = 0;
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bounceAnim = CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut);
    _bounceCtrl.forward();
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  // ─── Palette ───
  static const _bg = Color(0xFFF8F6FF);
  static const _cardBg = Colors.white;
  static const _accent = Color(0xFF6C5CE7);
  static const _gold = Color(0xFFFFD700);
  static const _orange = Color(0xFFFF6B35);
  static const _mint = Color(0xFF00CEC9);
  static const _coral = Color(0xFFFF7675);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * (widget.isModal ? 0.92 : 1.0),
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: widget.isModal
            ? const BorderRadius.vertical(top: Radius.circular(28))
            : BorderRadius.zero,
      ),
      child: SafeArea(
        top: !widget.isModal,
        child: Column(
          children: [
            if (widget.isModal) _dragHandle(),
            _header(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  children: [
                    _mascotBanner(),
                    const SizedBox(height: 24),
                    _stepSelector(),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOut,
                      child: _activeStepContent(),
                    ),
                    const SizedBox(height: 20),
                    _proTip(),
                    const SizedBox(height: 28),
                    _goButton(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.isModal) return content;
    return Scaffold(backgroundColor: _bg, body: content);
  }

  // ─── Drag Handle ───
  Widget _dragHandle() => Center(
        child: Container(
          margin: const EdgeInsets.only(top: 12, bottom: 4),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  // ─── Header ───
  Widget _header() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Text('📖', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Student Guide",
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "ගණිත මාර්ගෝපදේශය",
                    style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.grey.shade100,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  _soundService.playClick();
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.close_rounded, color: Colors.grey.shade600, size: 20),
                ),
              ),
            ),
          ],
        ),
      );

  // ─── Mascot Banner ───
  Widget _mascotBanner() => ScaleTransition(
        scale: _bounceAnim,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8F5E9), Color(0xFFFFF9C4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Parrot Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF81C784), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.15),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    MathsAssets.parrotIdle,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Text("🦜", style: TextStyle(fontSize: 34))),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Speech
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Parrot Guide",
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text("🦜", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "හායි යහළුවේ! මේ පියවර 3 කියවා ගණිත ශූරයෙක් වෙන්න! 🌟",
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Read these 3 steps to become a maths champion!",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  // ─── Step Selector Tabs ───
  Widget _stepSelector() {
    final steps = [
      _StepTab('🌟', 'XP & Levels', _gold),
      _StepTab('💡', '3 Hints', _mint),
      _StepTab('🎮', 'Games', _coral),
    ];

    return Row(
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        final active = _activeStep == i;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              _soundService.playClick();
              setState(() => _activeStep = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(
                left: i == 0 ? 0 : 5,
                right: i == 2 ? 0 : 5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: active ? s.color.withOpacity(0.15) : _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active ? s.color : Colors.grey.shade200,
                  width: active ? 2 : 1,
                ),
                boxShadow: active
                    ? [BoxShadow(color: s.color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 3))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: Column(
                children: [
                  Text(s.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Text(
                    s.label,
                    style: TextStyle(
                      color: active ? s.color : Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: active ? FontWeight.bold : FontWeight.w500,
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

  // ─── Step Content Router ───
  Widget _activeStepContent() {
    switch (_activeStep) {
      case 0:
        return _step1XP();
      case 1:
        return _step2Hints();
      case 2:
      default:
        return _step3Games();
    }
  }

  // ═══════════════════════════════════════════
  // STEP 1: XP & LEVELS
  // ═══════════════════════════════════════════
  Widget _step1XP() => _cleanCard(
        key: const ValueKey('step1'),
        accentColor: _gold,
        icon: '🌟',
        titleSi: "XP සහ Level ලබා ගැනීම",
        titleEn: "Earning XP & Leveling Up",
        children: [
          _tipRow(
            emoji: '🎯',
            text: "සෑම සංකල්පයක්ම අවසන් කිරීමෙන් +100 XP ලැබේ!",
            sub: "Complete each concept to earn +100 XP",
          ),
          _tipRow(
            emoji: '👑',
            text: "Beginner 🌿 → Explorer 🔍 → Learner 📚 → Scholar 🎓 → Master 👑",
            sub: "Level up as your XP grows",
          ),
          _tipRow(
            emoji: '🔥',
            text: "දිනපතා පාඩම් කර Streak Fire බෝනස් XP ලබාගන්න!",
            sub: "Daily streaks unlock bonus rewards",
          ),
        ],
      );

  // ═══════════════════════════════════════════
  // STEP 2: 3 HINTS
  // ═══════════════════════════════════════════
  Widget _step2Hints() => _cleanCard(
        key: const ValueKey('step2'),
        accentColor: _mint,
        icon: '💡',
        titleSi: "බුද්ධිමත් ඉඟි සහාය",
        titleEn: "The 3-Attempt Hint Engine",
        children: [
          _hintChip(
            number: "1",
            emoji: "🦁",
            label: "Leo ගෙන් සැහැල්ලු ඉඟියක්",
            sub: "Light hint from Leo",
            color: const Color(0xFFFF9F43),
          ),
          _hintChip(
            number: "2",
            emoji: "🐘",
            label: "Ella ගෙන් ස්ථානීය අගය දර්ශනය",
            sub: "Visual column breakdown from Ella",
            color: const Color(0xFF54A0FF),
          ),
          _hintChip(
            number: "3",
            emoji: "💡",
            label: "සම්පූර්ණ විසඳුම පැහැදිලි කිරීම",
            sub: "Full worked solution revealed",
            color: const Color(0xFF1DD1A1),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('❤️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "වැරදුණත් ලකුණු අඩු නොවේ — වැරදිවලින් ඉගෙනගන්න!",
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  // ═══════════════════════════════════════════
  // STEP 3: GAMES & REVISION
  // ═══════════════════════════════════════════
  Widget _step3Games() => _cleanCard(
        key: const ValueKey('step3'),
        accentColor: _coral,
        icon: '🎮',
        titleSi: "ගණිත ක්‍රීඩා සහ පුනරීක්ෂණ",
        titleEn: "Mini-Games & Revision Bank",
        children: [
          _tipRow(
            emoji: '🏹',
            text: "Number Archery, Abacus River, Bubble Cannon ක්‍රීඩා පුහුණුව!",
            sub: "Fun interactive games to sharpen your skills",
          ),
          _tipRow(
            emoji: '📝',
            text: "ප්‍රශ්න 40ක ශිෂ්‍යත්ව පුනරීක්ෂණ බැංකුව සමඟ විභාගයට සූදානම්!",
            sub: "40-question Revision Bank for Grade 5 Scholarship",
          ),
          _tipRow(
            emoji: '🏆',
            text: "වැරදුණු ප්‍රශ්න Mistakes Bank එකෙන් නැවත පුහුණු වන්න.",
            sub: "Revisit past mistakes until you master them",
          ),
        ],
      );

  // ─── Clean Card Shell ───
  Widget _cleanCard({
    required Key key,
    required Color accentColor,
    required String icon,
    required String titleSi,
    required String titleEn,
    required List<Widget> children,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleSi,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      titleEn,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  // ─── Tip Row (emoji + Sinhala + English subtitle) ───
  Widget _tipRow({
    required String emoji,
    required String text,
    required String sub,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hint Chip (numbered badge row) ───
  Widget _hintChip({
    required String number,
    required String emoji,
    required String label,
    required String sub,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Number circle
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Emoji
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Pro Tip Banner ───
  Widget _proTip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFCC80)),
        ),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "දිනපතා විනාඩි 15ක් පාඩම් කර ශිෂ්‍යත්ව විභාගයෙන් ඉහළම ලකුණු ලබාගන්න!",
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );

  // ─── Go Button ───
  Widget _goButton() => BouncingButton(
        onPressed: () {
          _soundService.playCorrect();
          Navigator.pop(context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF9F43)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _orange.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ආරම්භ කරමු!  Let's Go!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text('🚀', style: TextStyle(fontSize: 22)),
            ],
          ),
        ),
      );
}

// ─── Helper model ───
class _StepTab {
  final String emoji;
  final String label;
  final Color color;
  const _StepTab(this.emoji, this.label, this.color);
}
