import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/animated_widgets.dart';
import '../../utils/app_theme.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Analytics data
  int _totalStudents = 0;
  int _totalXP = 0;
  double _avgQuizScore = 0.0;
  int _activeStreaks = 0;
  Map<int, int> _gradeDistribution = {3: 0, 4: 0, 5: 0};
  Map<String, double> _subjectAvgScores = {};
  List<Map<String, dynamic>> _topPerformers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      // Load all students
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .get();

      int totalXP = 0;
      int activeStreaks = 0;
      Map<int, int> gradeDistribution = {3: 0, 4: 0, 5: 0};
      List<Map<String, dynamic>> studentData = [];

      for (var doc in studentsSnapshot.docs) {
        final data = doc.data();
        final xp = (data['xp'] ?? 0) as int;
        final streak = (data['streak'] ?? 0) as int;
        final grade = (data['grade'] ?? 5) as int;

        totalXP += xp;
        if (streak > 0) activeStreaks++;
        gradeDistribution[grade] = (gradeDistribution[grade] ?? 0) + 1;

        studentData.add({
          'name': data['name'] ?? 'Unknown',
          'xp': xp,
          'streak': streak,
          'grade': grade,
          'avatar': data['avatar'] ?? '🎓',
        });
      }

      // Sort by XP for top performers
      studentData.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
      
      // Load quiz scores for average calculation
      double totalScore = 0;
      int totalQuizzes = 0;
      Map<String, List<double>> subjectScores = {};

      for (var doc in studentsSnapshot.docs) {
        final examResults = await _firestore
            .collection('users')
            .doc(doc.id)
            .collection('exam_results')
            .get();

        for (var exam in examResults.docs) {
          final examData = exam.data();
          final score = (examData['score'] ?? 0) as int;
          final total = (examData['total'] ?? 10) as int;
          final subject = (examData['subject'] ?? 'Unknown') as String;
          
          if (total > 0) {
            double percentage = (score / total) * 100;
            totalScore += percentage;
            totalQuizzes++;

            if (!subjectScores.containsKey(subject)) {
              subjectScores[subject] = [];
            }
            subjectScores[subject]!.add(percentage);
          }
        }
      }

      // Calculate subject averages
      Map<String, double> subjectAvgScores = {};
      subjectScores.forEach((subject, scores) {
        if (scores.isNotEmpty) {
          subjectAvgScores[subject] = scores.reduce((a, b) => a + b) / scores.length;
        }
      });

      setState(() {
        _totalStudents = studentsSnapshot.docs.length;
        _totalXP = totalXP;
        _avgQuizScore = totalQuizzes > 0 ? totalScore / totalQuizzes : 0;
        _activeStreaks = activeStreaks;
        _gradeDistribution = gradeDistribution;
        _subjectAvgScores = subjectAvgScores;
        _topPerformers = studentData.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  child: CustomScrollView(
                    slivers: [
                      // App Bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              BouncingButton(
                                onPressed: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.arrow_back, color: Colors.white),
                                ),
                              ),
                              const Spacer(),
                              BouncingButton(
                                onPressed: _loadAnalytics,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.refresh, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SlideInWidget(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFfa709a), Color(0xFFfee140)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFfa709a).withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.analytics, color: Colors.white, size: 32),
                                ),
                                const SizedBox(width: 16),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Analytics",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Classroom insights & reports",
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),

                      // Overview Stats Grid
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.4,
                          ),
                          delegate: SliverChildListDelegate([
                            SlideInWidget(
                              delay: const Duration(milliseconds: 100),
                              child: _StatCard(
                                title: "Students",
                                value: _totalStudents.toString(),
                                icon: Icons.people,
                                gradient: const [Color(0xFF4facfe), Color(0xFF00f2fe)],
                              ),
                            ),
                            SlideInWidget(
                              delay: const Duration(milliseconds: 200),
                              child: _StatCard(
                                title: "Total XP",
                                value: _formatNumber(_totalXP),
                                icon: Icons.diamond,
                                gradient: const [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                              ),
                            ),
                            SlideInWidget(
                              delay: const Duration(milliseconds: 300),
                              child: _StatCard(
                                title: "Avg. Score",
                                value: "${_avgQuizScore.toStringAsFixed(1)}%",
                                icon: Icons.trending_up,
                                gradient: const [Color(0xFF11998e), Color(0xFF38ef7d)],
                              ),
                            ),
                            SlideInWidget(
                              delay: const Duration(milliseconds: 400),
                              child: _StatCard(
                                title: "Active Streaks",
                                value: _activeStreaks.toString(),
                                icon: Icons.local_fire_department,
                                gradient: const [Color(0xFFfc4a1a), Color(0xFFf7b733)],
                              ),
                            ),
                          ]),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),

                      // Grade Distribution
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SlideInWidget(
                            delay: const Duration(milliseconds: 500),
                            child: _SectionCard(
                              title: "Students by Grade",
                              icon: Icons.school,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _GradeBadge(grade: 3, count: _gradeDistribution[3] ?? 0, color: const Color(0xFF11998e)),
                                  _GradeBadge(grade: 4, count: _gradeDistribution[4] ?? 0, color: const Color(0xFFfc4a1a)),
                                  _GradeBadge(grade: 5, count: _gradeDistribution[5] ?? 0, color: const Color(0xFF667eea)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // Subject Performance
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SlideInWidget(
                            delay: const Duration(milliseconds: 600),
                            child: _SectionCard(
                              title: "Subject Performance",
                              icon: Icons.bar_chart,
                              child: _subjectAvgScores.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        "No quiz data yet",
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    )
                                  : Column(
                                      children: _subjectAvgScores.entries.map((entry) {
                                        return _SubjectBar(
                                          subject: entry.key,
                                          percentage: entry.value,
                                        );
                                      }).toList(),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // Top Performers
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SlideInWidget(
                            delay: const Duration(milliseconds: 700),
                            child: _SectionCard(
                              title: "Top Performers",
                              icon: Icons.emoji_events,
                              child: _topPerformers.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        "No students yet",
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    )
                                  : Column(
                                      children: _topPerformers.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final student = entry.value;
                                        return _LeaderboardTile(
                                          rank: index + 1,
                                          name: student['name'],
                                          xp: student['xp'],
                                          avatar: student['avatar'],
                                        );
                                      }).toList(),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Section Card Widget
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a2a3a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          child,
        ],
      ),
    );
  }
}

// Grade Badge Widget
class _GradeBadge extends StatelessWidget {
  final int grade;
  final int count;
  final Color color;

  const _GradeBadge({
    required this.grade,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Grade $grade",
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }
}

// Subject Bar Widget
class _SubjectBar extends StatelessWidget {
  final String subject;
  final double percentage;

  const _SubjectBar({
    required this.subject,
    required this.percentage,
  });

  Color _getColor() {
    if (percentage >= 80) return const Color(0xFF11998e);
    if (percentage >= 60) return const Color(0xFF4facfe);
    if (percentage >= 40) return const Color(0xFFf7b733);
    return const Color(0xFFfc4a1a);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              subject,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (percentage / 100).clamp(0.0, 1.0),
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_getColor(), _getColor().withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 45,
            child: Text(
              "${percentage.toStringAsFixed(0)}%",
              style: TextStyle(
                color: _getColor(),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Leaderboard Tile Widget
class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final String avatar;

  const _LeaderboardTile({
    required this.rank,
    required this.name,
    required this.xp,
    required this.avatar,
  });

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white54;
    }
  }

  Widget _buildAvatar() {
    // Check if avatar is a URL or an emoji
    if (avatar.startsWith('http') || avatar.length > 10) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text('🎓', style: TextStyle(fontSize: 18)),
        ),
      );
    }
    return SizedBox(
      width: 32,
      child: Text(avatar, style: const TextStyle(fontSize: 22)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _getRankColor().withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "#$rank",
                style: TextStyle(
                  color: _getRankColor(),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Avatar
          _buildAvatar(),
          const SizedBox(width: 8),
          // Name - this is the flexible part
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          // XP badge - fixed size
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF9B59B6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond, color: Color(0xFF9B59B6), size: 12),
                const SizedBox(width: 3),
                Text(
                  "$xp",
                  style: const TextStyle(
                    color: Color(0xFF9B59B6),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
