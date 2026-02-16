import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/gamification_widgets.dart';
import '../providers/theme_provider.dart';
import '../services/achievement_service.dart';
import '../services/export_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  late TabController _tabController;

  final List<String> avatars = [
    'https://cdn-icons-png.flaticon.com/512/4140/4140048.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140047.png',
    'https://cdn-icons-png.flaticon.com/512/616/616408.png',
    'https://cdn-icons-png.flaticon.com/512/616/616450.png',
    'https://cdn-icons-png.flaticon.com/512/616/616568.png',
    'https://cdn-icons-png.flaticon.com/512/616/616430.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140051.png',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateAvatar(String url) async {
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'avatar': url,
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("Avatar Updated! 🎉"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String name = data['name'] ?? "Student";
          int grade = data['grade'] ?? 5;
          int xp = data['xp'] ?? 0;
          int streak = data['streak'] ?? 0;
          String currentAvatar = data['avatar'] ?? avatars[2];
          
          final level = LevelSystem.getLevel(xp);
          final levelTitle = LevelSystem.getLevelTitle(level);
          final levelColor = LevelSystem.getLevelColor(level);
          final progress = LevelSystem.getProgress(xp);

          return CustomScrollView(
            slivers: [
              // Custom App Bar with gradient
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          // Avatar with level ring
                          GestureDetector(
                            onTap: () => _showAvatarPicker(context),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: levelColor.withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                // XP Progress ring
                                SizedBox(
                                  width: 115,
                                  height: 115,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 6,
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                // Avatar
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 4),
                                    image: currentAvatar.startsWith('http')
                                        ? DecorationImage(
                                            image: NetworkImage(currentAvatar),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: !currentAvatar.startsWith('http')
                                      ? Center(child: Text(currentAvatar, style: const TextStyle(fontSize: 48)))
                                      : null,
                                ),
                                // Edit badge
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.edit, color: levelColor, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Name and Level
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LevelSystem.getLevelIcon(level), color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  "Level $level • $levelTitle",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  // Theme toggle
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) {
                          return Icon(
                            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            color: Colors.white,
                            size: 20,
                          );
                        },
                      ),
                    ),
                    onPressed: () {
                      context.read<ThemeProvider>().toggleTheme();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                context.read<ThemeProvider>().isDarkMode 
                                    ? Icons.dark_mode 
                                    : Icons.light_mode,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.read<ThemeProvider>().isDarkMode 
                                    ? "Switched to Dark Mode 🌙" 
                                    : "Switched to Light Mode ☀️",
                              ),
                            ],
                          ),
                          backgroundColor: context.read<ThemeProvider>().isDarkMode 
                              ? Colors.grey.shade800 
                              : Colors.blue,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                  // Logout
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout, color: Colors.white, size: 20),
                    ),
                    onPressed: () => _showLogoutDialog(),
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        
                        // Stats Cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  "Total XP",
                                  "$xp",
                                  Icons.star,
                                  Colors.amber,
                                  AppColors.sunsetGradient,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  "Streak",
                                  "$streak Days",
                                  Icons.local_fire_department,
                                  Colors.deepOrange,
                                  AppColors.fireGradient,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  "Grade",
                                  "$grade",
                                  Icons.school,
                                  Colors.blue,
                                  AppColors.oceanGradient,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tab Bar
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppShadows.softShadow,
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey,
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            indicator: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            indicatorPadding: const EdgeInsets.all(4),
                            tabs: const [
                              Tab(text: "Achievements"),
                              Tab(text: "Progress"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tab Content
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildAchievementsTab(xp, streak),
                              _buildProgressTab(xp, level, progress),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(int xp, int streak) {
    final AchievementService achievementService = AchievementService();
    
    return StreamBuilder<Set<String>>(
      stream: achievementService.streamUnlockedAchievements(),
      builder: (context, snapshot) {
        final unlockedIds = snapshot.data ?? {};
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: Achievements.all.length,
            itemBuilder: (context, index) {
              final achievement = Achievements.all[index];
              // Check if unlocked in Firestore, or calculate based on current stats
              bool unlocked = unlockedIds.contains(achievement.id);
              
              // Also check current stats for immediate feedback
              if (!unlocked) {
                switch (achievement.type) {
                  case 'xp':
                    unlocked = xp >= achievement.requiredValue;
                    break;
                  case 'streak':
                    unlocked = streak >= achievement.requiredValue;
                    break;
                }
              }

              return SlideInWidget(
                delay: Duration(milliseconds: 100 * index),
                child: GestureDetector(
                  onTap: () => _showAchievementDetails(achievement, unlocked),
                  child: AchievementBadge(
                    achievement: achievement,
                    unlocked: unlocked,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProgressTab(int xp, int level, double progress) {
    final nextLevelXP = LevelSystem.getXPForNextLevel(xp);
    final currentLevelXP = (level - 1) * LevelSystem.xpPerLevel;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Level Progress Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    XPProgressRing(currentXP: xp, size: 80),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Level $level",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: LevelSystem.getLevelColor(level),
                            ),
                          ),
                          Text(
                            LevelSystem.getLevelTitle(level),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedProgressBar(
                            progress: progress,
                            height: 12,
                            gradient: LinearGradient(
                              colors: [
                                LevelSystem.getLevelColor(level).withOpacity(0.7),
                                LevelSystem.getLevelColor(level),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$xp / $nextLevelXP XP",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Level Journey
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Level Journey",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ...List.generate(5, (index) {
                  final lvl = index + 1;
                  final isUnlocked = level >= lvl;
                  final isCurrent = level == lvl;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isUnlocked ? LevelSystem.getLevelColor(lvl) : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isUnlocked ? Icons.check : Icons.lock,
                            color: isUnlocked ? Colors.white : Colors.grey,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Level $lvl - ${LevelSystem.getLevelTitle(lvl)}",
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isUnlocked ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        Text(
                          "${lvl * 100} XP",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Export Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Export Your Data",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildExportButton(
                        icon: Icons.picture_as_pdf,
                        label: "PDF Report",
                        color: Colors.red,
                        onTap: () => _exportPDF(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildExportButton(
                        icon: Icons.table_chart,
                        label: "CSV Data",
                        color: Colors.green,
                        onTap: () => _exportCSV(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement, bool unlocked) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: unlocked ? achievement.color.withOpacity(0.15) : Colors.grey.shade200,
                shape: BoxShape.circle,
                border: Border.all(
                  color: unlocked ? achievement.color : Colors.grey.shade300,
                  width: 4,
                ),
              ),
              child: Icon(
                achievement.icon,
                color: unlocked ? achievement.color : Colors.grey,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: unlocked ? Colors.green.withOpacity(0.15) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                unlocked ? "✓ Unlocked!" : "🔒 Locked",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: unlocked ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 400,
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Choose Your Avatar",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Pick a character that represents you!",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: avatars.length,
                itemBuilder: (context, index) {
                  return BouncingButton(
                    onPressed: () => _updateAvatar(avatars[index]),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.network(
                          avatars[index],
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportPDF() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Generating PDF report...")),
      );
      await ExportService().exportProgressPDF();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ PDF downloaded successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to export: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _exportCSV() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exporting quiz history...")),
      );
      await ExportService().exportQuizHistoryCSV();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ CSV downloaded successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to export: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout?"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}