import 'package:flutter/material.dart';
import '../../models/maths/adventure_node_model.dart';
import '../../services/maths/maths_progress_adapter.dart';
import '../../services/sound_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/animated_widgets.dart';
import '../../widgets/maths/adventure_node_widget.dart';
import '../../widgets/parent_pin_dialog.dart';
import 'maths_lesson_player_screen.dart';
import 'golden_mango_lesson_screen.dart';
import 'number_train_lesson_screen.dart';
import 'games/maths_game_hub_screen.dart';

class MathsAdventureMapScreen extends StatefulWidget {
  final int studentGrade;

  const MathsAdventureMapScreen({
    super.key,
    required this.studentGrade,
  });

  @override
  State<MathsAdventureMapScreen> createState() => _MathsAdventureMapScreenState();
}

class _MathsAdventureMapScreenState extends State<MathsAdventureMapScreen>
    with TickerProviderStateMixin {
  final MathsProgressAdapter _progressAdapter = MathsProgressAdapter();
  final SoundService _soundService = SoundService();

  late AnimationController _parrotController;
  late Animation<double> _parrotBob;

  @override
  void initState() {
    super.initState();
    _parrotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _parrotBob = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _parrotController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _parrotController.dispose();
    super.dispose();
  }

  /// Contextual Parrot speech based on progress state
  String _getParrotSpeech(List<AdventureNodeModel> nodes) {
    final completedCount = nodes.where((n) => n.state == LessonNodeState.completed).length;
    final hasInProgress = nodes.any((n) => n.state == LessonNodeState.inProgress);

    if (completedCount == nodes.length && nodes.isNotEmpty) {
      return 'සියලුම ගණිත අභියෝග ජයගත්තා! ඔයා සැබෑ ගණිත විශාරදයෙක්! 🏆';
    } else if (hasInProgress) {
      return 'ආයෙත් ආවාද? අපි ගමන දිගටම යමු! 💪';
    } else if (completedCount > 0) {
      return 'නියමයි! ඊළඟ ගණිත අභියෝගයට සූදානම්ද? ⭐';
    } else {
      return 'අපි අපේ පළමු ගණිත අභියෝගයට යමු! 🚀';
    }
  }

  void _showLockedDialog(BuildContext context, AdventureNodeModel node) {
    _soundService.playClick();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1A1A2E),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Parrot image
              ClipOval(
                child: Image.asset(
                  MathsAssets.parrotIdle,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2C3E50),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🦜', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Speech bubble
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  node.isPlaceholder
                      ? '🦜 "මේ ගණිත අභියෝගය ඉක්මනින්ම එනවා! ටිකක් ඉන්න!"'
                      : '🦜 "පළමුව පෙර අභියෝගය ජයගමු, ටිකිරි ගණිතඥයා!"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '🔒 ${node.title}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mathOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'හරි! 👍',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNodeTap(BuildContext context, AdventureNodeModel node) {
    if (node.state == LessonNodeState.locked || node.isPlaceholder) {
      _showLockedDialog(context, node);
      return;
    }

    _soundService.playClick();

    // Route node_1 to Golden Mango; node_2 to Great Number Train (all concepts); other nodes to legacy player
    final Widget targetScreen;
    if (node.id == 'node_1') {
      targetScreen = GoldenMangoLessonScreen(
        studentGrade: widget.studentGrade,
      );
    } else if (node.id == 'node_2') {
      targetScreen = GreatNumberTrainLessonScreen(
        studentGrade: widget.studentGrade,
      );
    } else {
      targetScreen = MathsLessonPlayerScreen(
        studentGrade: widget.studentGrade,
      );
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => targetScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<AdventureNodeModel>>(
        stream: _progressAdapter.streamEvaluatedNodes(),
        builder: (context, snapshot) {
          final nodes = snapshot.data ?? [];
          final totalStars = nodes.fold<int>(0, (sum, node) => sum + node.stars);
          final maxStars = nodes.length * 3;
          final completedCount = nodes.where((n) => n.state == LessonNodeState.completed).length;
          final journeyPercent = nodes.isEmpty ? 0 : ((completedCount / nodes.length) * 100).round();

          return Container(
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
                  // ─── HEADER ───
                  _buildGameHeader(totalStars, maxStars, journeyPercent),

                  // ─── MAP WORLD ───
                  Expanded(
                    child: nodes.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.mathOrange,
                            ),
                          )
                        : _buildMapWorld(nodes),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Premium two-row game-style header bar
  Widget _buildGameHeader(int totalStars, int maxStars, int journeyPercent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: AppColors.mathOrange.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── ROW 1: Navigation ───
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 12),

              // Title
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ගණිත රාජධානිය',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Mathematics Kingdom',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Parent Zone 🛡️ Button
              GestureDetector(
                onTap: () => ParentPinDialog.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.15),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_rounded, color: Color(0xFFFFD700), size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Parent',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ─── ROW 2: Stats & Actions ───
          Row(
            children: [
              // Stars pill
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$totalStars/$maxStars',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Journey percent pill
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.mathOrange.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: AppColors.mathOrange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$journeyPercent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Games 🎮 Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MathsGameHubScreen(studentGrade: widget.studentGrade),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFF8B78E6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_esports_rounded, color: Color(0xFFFFD700), size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Games',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Main scrollable map world with winding path and nodes
  Widget _buildMapWorld(List<AdventureNodeModel> nodes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        // Calculate node positions for zig-zag winding path
        final nodePositions = _calculateNodePositions(nodes.length, mapWidth);
        // Total map height: space for parrot section + nodes + bottom padding
        final mapHeight = 260.0 + (nodes.length * 180.0) + 80.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: SizedBox(
            width: mapWidth,
            height: mapHeight,
            child: Stack(
              children: [
                // Background decorations
                _buildBackgroundDecorations(mapWidth, mapHeight),

                // Winding path connecting nodes
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AdventurePathPainter(
                      nodePositions: nodePositions,
                      nodes: nodes,
                      pathOffset: 260.0,
                    ),
                  ),
                ),

                // Parrot companion section at top
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: _buildParrotSection(nodes),
                ),

                // Lesson nodes
                for (int i = 0; i < nodes.length; i++)
                  Positioned(
                    left: nodePositions[i].dx - 70,
                    top: 260.0 + (i * 180.0),
                    child: SlideInWidget(
                      delay: Duration(milliseconds: 150 * (i + 1)),
                      child: AdventureNodeWidget(
                        node: nodes[i],
                        onTap: () => _handleNodeTap(context, nodes[i]),
                        alignRight: i.isOdd,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Calculate zig-zag node positions
  List<Offset> _calculateNodePositions(int count, double mapWidth) {
    final List<Offset> positions = [];
    final centerX = mapWidth / 2;
    final amplitude = mapWidth * 0.22; // Zig-zag amplitude

    for (int i = 0; i < count; i++) {
      final xOffset = i.isEven ? -amplitude : amplitude;
      positions.add(Offset(centerX + xOffset, 0)); // Y is handled by Positioned
    }
    return positions;
  }

  /// Parrot companion section with speech bubble
  Widget _buildParrotSection(List<AdventureNodeModel> nodes) {
    return Column(
      children: [
        // Parrot with floating animation
        AnimatedBuilder(
          animation: _parrotBob,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _parrotBob.value),
              child: child,
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.mathOrange.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                MathsAssets.parrotIdle,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C3E50),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🦜', style: TextStyle(fontSize: 52)),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Speech bubble
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: Text(
            _getParrotSpeech(nodes),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Subtle background decorations (stars, trees, clouds)
  Widget _buildBackgroundDecorations(double mapWidth, double mapHeight) {
    return Stack(
      children: [
        // Scattered small stars
        for (int i = 0; i < 20; i++)
          Positioned(
            left: (mapWidth * ((i * 37 + 13) % 100) / 100),
            top: (mapHeight * ((i * 53 + 7) % 100) / 100),
            child: Icon(
              Icons.star_rounded,
              size: 6 + (i % 4) * 2.0,
              color: Colors.white.withOpacity(0.08 + (i % 5) * 0.03),
            ),
          ),
        // Decorative tree/cloud emojis
        Positioned(
          left: 16,
          top: 300,
          child: Text('🌳', style: TextStyle(fontSize: 28, color: Colors.white.withOpacity(0.15))),
        ),
        Positioned(
          right: 20,
          top: 500,
          child: Text('🏡', style: TextStyle(fontSize: 24, color: Colors.white.withOpacity(0.12))),
        ),
        Positioned(
          left: 24,
          top: 700,
          child: Text('🌲', style: TextStyle(fontSize: 26, color: Colors.white.withOpacity(0.12))),
        ),
        Positioned(
          right: 16,
          top: 850,
          child: Text('🏰', style: TextStyle(fontSize: 28, color: Colors.white.withOpacity(0.10))),
        ),
        Positioned(
          left: 20,
          top: 1000,
          child: Text('🌉', style: TextStyle(fontSize: 26, color: Colors.white.withOpacity(0.10))),
        ),
      ],
    );
  }
}

/// CustomPainter that draws a thick winding golden road connecting adventure nodes
class _AdventurePathPainter extends CustomPainter {
  final List<Offset> nodePositions;
  final List<AdventureNodeModel> nodes;
  final double pathOffset;

  _AdventurePathPainter({
    required this.nodePositions,
    required this.nodes,
    required this.pathOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

    for (int i = 0; i < nodePositions.length - 1; i++) {
      final startY = pathOffset + (i * 180.0) + 40;
      final endY = pathOffset + ((i + 1) * 180.0) + 40;
      final startX = nodePositions[i].dx;
      final endX = nodePositions[i + 1].dx;

      // Determine path state
      final isCompleted = nodes[i].state == LessonNodeState.completed;
      final isNextAvailable = i + 1 < nodes.length &&
          (nodes[i + 1].state == LessonNodeState.available ||
           nodes[i + 1].state == LessonNodeState.inProgress ||
           nodes[i + 1].state == LessonNodeState.completed);

      // Bezier curve path
      final path = Path();
      path.moveTo(startX, startY);

      final controlX1 = startX;
      final controlY1 = startY + (endY - startY) * 0.45;
      final controlX2 = endX;
      final controlY2 = startY + (endY - startY) * 0.55;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, endX, endY);

      if (isCompleted && isNextAvailable) {
        // ─── COMPLETED + ACTIVE PATH: Golden glowing road ───

        // Outer glow
        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFFD700).withOpacity(0.15);
        canvas.drawPath(path, glowPaint);

        // Dark outline (road border)
        final outlinePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF2C1810);
        canvas.drawPath(path, outlinePaint);

        // Golden fill (road surface)
        final fillPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFFD700).withOpacity(0.7);
        canvas.drawPath(path, fillPaint);

        // Center highlight
        final highlightPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFFF8DC).withOpacity(0.4);
        canvas.drawPath(path, highlightPaint);

      } else if (isCompleted) {
        // ─── COMPLETED BUT NEXT LOCKED: Dimmer golden road ───
        final outlinePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF2C1810).withOpacity(0.6);
        canvas.drawPath(path, outlinePaint);

        final fillPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFFD700).withOpacity(0.35);
        canvas.drawPath(path, fillPaint);

      } else {
        // ─── LOCKED PATH: Faint dotted trail ───

        // Thin faint background line
        final bgPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withOpacity(0.06);
        canvas.drawPath(path, bgPaint);

        // Dotted overlay
        final dotPaint = Paint()
          ..color = Colors.white.withOpacity(0.12)
          ..style = PaintingStyle.fill;

        final pathMetrics = path.computeMetrics();
        for (final metric in pathMetrics) {
          double distance = 0;
          while (distance < metric.length) {
            final tangent = metric.getTangentForOffset(distance);
            if (tangent != null) {
              canvas.drawCircle(tangent.position, 3, dotPaint);
            }
            distance += 16;
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AdventurePathPainter oldDelegate) {
    return oldDelegate.nodes != nodes;
  }
}
