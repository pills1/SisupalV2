import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/parent_pin_dialog.dart';
import '../services/progress_service.dart';
import 'video_list_screen.dart';
import 'maths/maths_adventure_map_screen.dart';
import 'maths/maths_lesson_player_screen.dart';
import 'maths/maths_lessons_screen.dart';
import 'maths/maths_revision_screen.dart';
import 'maths/games/maths_game_hub_screen.dart';
import 'user_guide_screen.dart';

class MathsKingdomScreen extends StatelessWidget {
  final int studentGrade;

  const MathsKingdomScreen({
    super.key,
    required this.studentGrade,
  });

  void _showComingSoonDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_clock, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                "🔒 $featureName",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "This feature is being prepared for Maths Kingdom and will be available in an upcoming update!",
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Got it!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── HEADER BAR ───
              _buildHeader(context),

              // ─── SCROLLABLE CONTENT WITH LIVE DATA BINDING ───
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUserId)
                      .snapshots(),
                  builder: (context, userSnap) {
                    int userXP = 0;
                    if (userSnap.hasData && userSnap.data!.exists) {
                      final data = userSnap.data!.data() as Map<String, dynamic>?;
                      userXP = data?['xp'] ?? 0;
                    }

                    return StreamBuilder<SubjectProgress>(
                      stream: ProgressService().streamProgress('Mathematics'),
                      builder: (context, progressSnap) {
                        final mathProgress = progressSnap.data;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          child: Column(
                            children: [
                              // Compact Mascot Banner (Clickable User Guide)
                              SlideInWidget(
                                child: _buildCompactMascotBanner(context),
                              ),

                              const SizedBox(height: 16),

                              // Dynamic Kingdom Progress Bar
                              SlideInWidget(
                                delay: const Duration(milliseconds: 100),
                                child: _buildProgressSection(userXP, mathProgress),
                              ),

                              const SizedBox(height: 20),

                              // Section Title
                              _buildSectionTitle("Kingdom Activities"),

                              const SizedBox(height: 14),

                              // 2-Column Grid of Kingdom Tiles
                              _buildKingdomGrid(context, mathProgress),

                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dark-themed header bar
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: AppColors.mathOrange.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          BouncingButton(
            onPressed: () => Navigator.pop(context),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Maths Kingdom",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text("👑", style: TextStyle(fontSize: 18)),
                  ],
                ),
                Text(
                  "Grade $studentGrade • ගණිත රාජධානිය",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Guide & Parent Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User Guide Button
              BouncingButton(
                onPressed: () => UserGuideScreen.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFA29BFE),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withOpacity(0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('📖', style: TextStyle(fontSize: 13)),
                      SizedBox(width: 4),
                      Text(
                        'Guide',
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

              // Parent Zone button
              BouncingButton(
                onPressed: () => ParentPinDialog.show(context),
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
        ],
      ),
    );
  }

  /// Compact mascot banner — clickable interactive student guide
  Widget _buildCompactMascotBanner(BuildContext context) {
    return BouncingButton(
      onPressed: () => UserGuideScreen.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFF8B78E6), Color(0xFFA29BFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Compact mascot avatar with floating animation
            FloatingWidget(
              offset: 4,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    MathsAssets.parrotIdle,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text("🦜", style: TextStyle(fontSize: 26)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Maths Guide 🦜",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "📖 Guide",
                              style: TextStyle(
                                color: Color(0xFF2C3E50),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Welcome! Let's master Grade $studentGrade Mathematics! (Tap for Guide 🚀)",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateCompletedConceptsCount(SubjectProgress? progress) {
    if (progress == null) return 0;
    final concepts = progress.completedConcepts;
    int count = 0;
    // Lesson 1 (5 concepts)
    if (concepts.contains('c1_jungle_map') || concepts.contains('c1_map_reading') || concepts.contains('c1')) count++;
    if (concepts.contains('c2_river_of_beads') || concepts.contains('c2_abacus_river') || concepts.contains('c2')) count++;
    if (concepts.contains('c3_giants_gate') || concepts.contains('c3_place_value_gate') || concepts.contains('c3')) count++;
    if (concepts.contains('c4_crystal_cavern') || concepts.contains('c4_cave_pedestals') || concepts.contains('c4')) count++;
    if (concepts.contains('c5_golden_chest') || concepts.contains('c5_golden_mango_chest') || concepts.contains('c5')) count++;

    // Lesson 2 (6 concepts)
    for (int i = 1; i <= 6; i++) {
      if (concepts.contains('l2_c$i') ||
          concepts.any((c) => c.startsWith('c$i') && c.contains('train'))) {
        count++;
      }
    }
    return count;
  }

  /// Dynamic Kingdom progress bar section
  Widget _buildProgressSection(int xp, SubjectProgress? progress) {
    final int level = LevelSystem.getLevel(xp);
    final String levelTitle = LevelSystem.getLevelTitle(level);
    
    final int completedConcepts = _calculateCompletedConceptsCount(progress);
    // Total 11 concepts across Grade 5 curriculum (5 in L1 + 6 in L2)
    const int totalKingdomConcepts = 11;
    final double kingdomPercent = (completedConcepts / totalKingdomConcepts).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          // Progress label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.castle_rounded, color: Color(0xFFFFD700), size: 18),
                  SizedBox(width: 6),
                  Text(
                    "Kingdom Progress",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
                        const SizedBox(width: 3),
                        Text(
                          "$xp XP",
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // Track
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                // Fill
                if (kingdomPercent > 0)
                  FractionallySizedBox(
                    widthFactor: kingdomPercent,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFF39C12), Color(0xFFFF6B35)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                completedConcepts > 0
                    ? "${(kingdomPercent * 100).toInt()}% Complete ($completedConcepts/11 Concepts)"
                    : "0% Complete (0/11 Concepts)",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Level $level $levelTitle",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section title with accent bar
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), AppColors.mathOrange],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// 2-column grid of kingdom activity tiles
  Widget _buildKingdomGrid(BuildContext context, SubjectProgress? mathProgress) {
    final int completedConcepts = _calculateCompletedConceptsCount(mathProgress);
    final completedLessonsCount = mathProgress?.completedLessonsCount ?? (completedConcepts >= 5 ? 1 : 0);

    final double adventureProgress = (completedConcepts / 11.0).clamp(0.0, 1.0);
    final double lessonsProgress = (completedConcepts / 11.0).clamp(0.0, 1.0);
    final double revisionProgress = (completedConcepts / 11.0).clamp(0.0, 1.0);

    final tiles = [
      _KingdomTile(
        title: "Adventure\nMap",
        icon: Icons.map_rounded,
        gradientColors: [const Color(0xFF00B894), const Color(0xFF55E6C1)],
        badgeText: completedConcepts > 0 ? "$completedConcepts/11 CONCEPTS" : "EXPLORE",
        progress: adventureProgress,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MathsAdventureMapScreen(studentGrade: studentGrade),
            ),
          );
        },
      ),
      _KingdomTile(
        title: "Mathematics\nLessons",
        icon: Icons.menu_book_rounded,
        gradientColors: [AppColors.mathOrange, const Color(0xFFFF8E53)],
        badgeText: completedLessonsCount > 0
            ? "$completedLessonsCount/3 DONE 📚"
            : (completedConcepts > 0 ? "$completedConcepts/11 CONCEPTS 📚" : "3 LESSONS 📚"),
        progress: lessonsProgress,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MathsLessonsScreen(studentGrade: studentGrade),
            ),
          );
        },
      ),
      _KingdomTile(
        title: "Maths\nGames",
        icon: Icons.sports_esports_rounded,
        gradientColors: [const Color(0xFFE17055), const Color(0xFFFAB1A0)],
        badgeText: "5 GAMES",
        progress: 0.0,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MathsGameHubScreen(studentGrade: studentGrade),
            ),
          );
        },
      ),
      _KingdomTile(
        title: "Revision\nZone 🔄",
        icon: Icons.autorenew_rounded,
        gradientColors: [const Color(0xFF0984E3), const Color(0xFF74B9FF)],
        badgeText: "PERSONALIZED 🎯",
        progress: revisionProgress,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MathsRevisionScreen(studentGrade: studentGrade),
            ),
          );
        },
      ),
      _KingdomTile(
        title: "Video\nClasses",
        icon: Icons.play_circle_fill_rounded,
        gradientColors: [const Color(0xFFD63031), const Color(0xFFFF7675)],
        badgeText: "ACTIVE",
        progress: 0.0,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const VideoListScreen(
                category: "mathematics",
                title: "Mathematics Video Lessons",
              ),
            ),
          );
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        return SlideInWidget(
          delay: Duration(milliseconds: 100 * (index + 1)),
          child: _buildGridTile(tiles[index]),
        );
      },
    );
  }

  /// Individual grid tile with icon, progress ring, title, and badge
  Widget _buildGridTile(_KingdomTile tile) {
    return BouncingButton(
      onPressed: tile.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: tile.gradientColors.first.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: tile.gradientColors.first.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with progress ring
            SizedBox(
              width: 68,
              height: 68,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress ring background
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 3,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  // Progress ring fill
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: CircularProgressIndicator(
                      value: tile.progress,
                      strokeWidth: 3,
                      color: tile.gradientColors.first,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Icon circle
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: tile.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: tile.gradientColors.first.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      tile.icon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              tile.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: tile.gradientColors.first.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: tile.gradientColors.first.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                tile.badgeText,
                style: TextStyle(
                  color: tile.gradientColors.first,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for kingdom grid tiles
class _KingdomTile {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final String badgeText;
  final double progress;
  final VoidCallback onTap;

  const _KingdomTile({
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.badgeText,
    required this.progress,
    required this.onTap,
  });
}
