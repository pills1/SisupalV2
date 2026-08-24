import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_widgets.dart';
import 'maths/maths_adventure_map_screen.dart';
import 'maths/games/maths_game_hub_screen.dart';
import '../models/maths/maths_game_model.dart';

class GamesScreen extends StatelessWidget {
  final int studentGrade;

  const GamesScreen({
    super.key,
    this.studentGrade = 5,
  });

  MathsGameType _mapTemplateToType(String? template) {
    switch (template) {
      case 'abacus':
        return MathsGameType.abacusChallenge;
      case 'lily_pad_leap':
        return MathsGameType.lilyPadLeap;
      case 'number_archery':
        return MathsGameType.numberArchery;
      case 'digit_builder':
        return MathsGameType.digitBuilder;
      case 'place_value':
        return MathsGameType.placeValueExplorer;
      case 'expanded_form':
        return MathsGameType.expandedFormBuilder;
      case 'rapid_fire':
        return MathsGameType.rapidNumberChallenge;
      default:
        return MathsGameType.abacusChallenge;
    }
  }

  IconData _getTemplateIcon(String? template) {
    switch (template) {
      case 'abacus':
        return Icons.calculate_rounded;
      case 'lily_pad_leap':
        return Icons.water_rounded;
      case 'number_archery':
        return Icons.gps_fixed_rounded;
      case 'digit_builder':
        return Icons.extension_rounded;
      case 'place_value':
        return Icons.military_tech_rounded;
      case 'expanded_form':
        return Icons.view_column_rounded;
      case 'rapid_fire':
        return Icons.bolt_rounded;
      default:
        return Icons.sports_esports_rounded;
    }
  }

  List<Color> _getTemplateGradient(String? template) {
    switch (template) {
      case 'abacus':
        return const [Color(0xFF8E44AD), Color(0xFF9B59B6)];
      case 'lily_pad_leap':
        return const [Color(0xFF059669), Color(0xFF10B981)];
      case 'number_archery':
        return const [Color(0xFFD35400), Color(0xFFE67E22)];
      case 'digit_builder':
        return const [Color(0xFF6C5CE7), Color(0xFFA29BFE)];
      case 'place_value':
        return const [Color(0xFF2980B9), Color(0xFF3498DB)];
      case 'expanded_form':
        return const [Color(0xFF16A085), Color(0xFF1ABC9C)];
      case 'rapid_fire':
        return const [Color(0xFFF39C12), Color(0xFFF1C40F)];
      default:
        return const [Color(0xFF6C5CE7), Color(0xFFA29BFE)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Educational Games 🎮',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parrot Companion Banner Header
            SlideInWidget(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    FloatingWidget(
                      offset: 6,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            MathsAssets.parrotIdle,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text("🦜", style: TextStyle(fontSize: 36)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Games Kingdom 🎮',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '🦜 "Welcome to Educational Games! Challenge your speed, solve puzzles, and earn extra XP!"',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Adventure Story Quests Card
            _buildGameCard(
              context: context,
              title: 'Adventure Map Quests 🗺️ (ගණිත වික්‍රමය)',
              subtitle: 'Play story-driven mathematics adventure lessons',
              icon: Icons.map_rounded,
              gradient: const [Color(0xFFFF6B35), Color(0xFFFF8E53)],
              badge: 'STORY QUEST',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MathsAdventureMapScreen(studentGrade: studentGrade),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Section Title
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Live Published Mini-Games 🎯',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dynamic Stream from Firestore `math_games` where status == 'published'
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('math_games')
                  .where('status', isEqualTo: 'published')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Failed to load games: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                // Deduplicate games by templateType / normalized title
                final Map<String, QueryDocumentSnapshot> uniqueDocs = {};
                for (final doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final key = data['templateType']?.toString() ?? data['title']?.toString() ?? doc.id;
                  if (!uniqueDocs.containsKey(key)) {
                    uniqueDocs[key] = doc;
                  }
                }

                final displayDocs = uniqueDocs.values.toList();

                if (displayDocs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: const [
                        Text('🎮', style: TextStyle(fontSize: 40)),
                        SizedBox(height: 8),
                        Text(
                          'No Games Currently Published',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your teacher is preparing new interactive games.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayDocs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final data = displayDocs[index].data() as Map<String, dynamic>;
                    final String title = data['title'] ?? 'Math Mini-Game';
                    final String desc = data['description'] ?? 'Grade 5 interactive math activity';
                    final String template = data['templateType'] ?? 'abacus';
                    final MathsGameType gameType = _mapTemplateToType(template);

                    return _buildGameCard(
                      context: context,
                      title: title,
                      subtitle: desc,
                      icon: _getTemplateIcon(template),
                      gradient: _getTemplateGradient(template),
                      badge: 'PLAY NOW',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MathsGameHubScreen(
                              studentGrade: studentGrade,
                              initialGameType: gameType,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required String badge,
    required VoidCallback onTap,
  }) {
    return SlideInWidget(
      child: BouncingButton(
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
