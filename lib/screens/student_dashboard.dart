import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/gamification_widgets.dart';
import '../widgets/challenge_carousel.dart';
import '../services/daily_challenge_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';
import 'lesson_list_screen.dart';
import 'past_paper_selector.dart';
import 'language_tabs_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'mistakes_screen.dart';
import 'video_hub_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _streak = 0;
  int _studentGrade = 5;
  int _userXP = 0;
  
  late AnimationController _fabAnimController;
  final DailyChallengeService _challengeService = DailyChallengeService();
  final ProgressService _progressService = ProgressService();
  final SoundService _soundService = SoundService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkStreak();
    _fetchUserData();
    _challengeService.checkAndResetChallenges();
    _sendWelcomeNotificationIfNeeded();
  }

  Future<void> _sendWelcomeNotificationIfNeeded() async {
    // Check if we've already sent a welcome notification today
    await _notificationService.sendWelcomeNotification();
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            _studentGrade = doc.data()?['grade'] ?? 5;
            _userXP = doc.data()?['xp'] ?? 0;
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _checkStreak() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      final doc = await userRef.get();
      if (!doc.exists) {
        await userRef.set({
          'streak': 1, 'xp': 0, 'lastLogin': FieldValue.serverTimestamp(), 'email': user.email, 'grade': 3,
        }, SetOptions(merge: true));
        if (mounted) setState(() => _streak = 1);
        return;
      }
      final data = doc.data() as Map<String, dynamic>;
      final lastLoginTs = data['lastLogin'] as Timestamp?;
      int currentStreak = data['streak'] ?? 0;
      int currentXP = data['xp'] ?? 0;
      int newStreak = 1;
      int bonusXP = 0;
      bool showPopup = false;

      if (lastLoginTs != null) {
        final lastLoginDate = lastLoginTs.toDate();
        final lastLoginMidnight = DateTime(lastLoginDate.year, lastLoginDate.month, lastLoginDate.day);
        final difference = today.difference(lastLoginMidnight).inDays;

        if (difference == 0) {
          if (mounted) setState(() => _streak = currentStreak);
          return;
        } else if (difference == 1) {
          newStreak = currentStreak + 1;
          bonusXP = 50;
          showPopup = true;
        }
      }
      await userRef.update({'lastLogin': FieldValue.serverTimestamp(), 'streak': newStreak, 'xp': currentXP + bonusXP});
      if (mounted) setState(() => _streak = newStreak);

      if (showPopup && mounted) {
        _showStreakDialog(newStreak, bonusXP);
      }
    } catch (e) { print("Error checking streak: $e"); }
  }

  void _showStreakDialog(int streak, int xp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.fireGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 60),
              const SizedBox(height: 16),
              const Text(
                "🔥 Daily Streak!",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "$streak day streak!",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "+ $xp XP",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Awesome!", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0: return _buildHomeTab();
      case 1: return const VideoHubScreen();
      case 2: return const LeaderboardScreen();
      case 3: return const ProfileScreen();
      default: return _buildHomeTab();
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: _selectedIndex == 0 ? _buildHomeAppBar() : null,
      body: _buildCurrentPage(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.primaryDark,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: Colors.grey.shade500,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: [
            _buildNavItem(Icons.home_rounded, 'Home', 0),
            _buildNavItem(Icons.play_circle_fill, 'Classes', 1),
            _buildNavItem(Icons.emoji_events, 'Rank', 2),
            _buildNavItem(Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: isSelected ? 28 : 24),
      ),
      label: label,
    );
  }

  AppBar _buildHomeAppBar() {
    final user = FirebaseAuth.instance.currentUser;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80,
      title: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          String name = "Student";
          String avatar = "";
          int xp = 0;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            name = data?['name'] ?? "Student";
            avatar = data?['avatar'] ?? "";
            xp = data?['xp'] ?? 0;
          }
          final level = LevelSystem.getLevel(xp);
          
          return Row(
            children: [
              // Avatar with level ring
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: LevelSystem.getLevelColor(level), width: 3),
                    ),
                    child: ClipOval(
                      child: avatar.isNotEmpty
                          ? Image.network(avatar, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _defaultAvatar())
                          : _defaultAvatar(),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: LevelSystem.getLevelColor(level),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Lv.$level",
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome back,", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    Text(name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        // Streak Badge
        StreakFlame(streak: _streak, size: 36),
        const SizedBox(width: 8),
        // Notification Badge
        NotificationBadge(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        ),
        const SizedBox(width: 8),
        // History Button
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.history, color: Colors.blue),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: Colors.blue.shade100,
      child: const Icon(Icons.person, color: Colors.blue, size: 30),
    );
  }

  /// Build subject card with real progress data from Firestore
  Widget _buildSubjectCard({
    required String subject,
    required IconData icon,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return SlideInWidget(
      delay: Duration(milliseconds: delay),
      child: StreamBuilder<SubjectProgress>(
        stream: _progressService.streamProgress(subject),
        builder: (context, snapshot) {
          final progress = snapshot.data;
          final completedLessons = progress?.completedLessonsCount ?? 0;
          final completedQuizzes = progress?.completedQuizzesCount ?? 0;
          // Estimate progress based on lessons and quizzes completed
          final progressValue = (completedLessons + completedQuizzes) / 20.0; // Assume ~20 total items
          
          return SubjectProgressCard(
            subject: subject,
            icon: icon,
            color: color,
            progress: progressValue.clamp(0.0, 1.0),
            lessonsCompleted: completedLessons,
            totalLessons: 10, // Default estimate
            onTap: onTap,
          );
        },
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _fetchUserData();
        await _checkStreak();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Daily Challenges Carousel
            SlideInWidget(
              delay: const Duration(milliseconds: 100),
              child: StreamBuilder<List<DailyChallenge>>(
                stream: _challengeService.streamTodaysChallenges(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return DailyChallengeCard(
                      title: "Daily Challenge",
                      description: "Loading challenges...",
                      xpReward: 50,
                      progress: 0.0,
                      onTap: () {},
                    );
                  }
                  return DailyChallengesCarousel(
                    challenges: snapshot.data!,
                    onChallengeTap: (challenge) {
                      // Could navigate to relevant screen based on challenge type
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Stats Row
            SlideInWidget(
              delay: const Duration(milliseconds: 200),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
                builder: (context, snapshot) {
                  int xp = 0;
                  int streak = 0;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    xp = data?['xp'] ?? 0;
                    streak = data?['streak'] ?? 0;
                  }
                  final level = LevelSystem.getLevel(xp);
                  final progress = LevelSystem.getProgress(xp);
                  final nextLevelXP = LevelSystem.getXPForNextLevel(xp);
                  
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppShadows.cardShadow,
                    ),
                    child: Row(
                      children: [
                        XPProgressRing(currentXP: xp, size: 70),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  LevelBadge(xp: xp, compact: true),
                                  const Spacer(),
                                  Text(
                                    "$xp / $nextLevelXP XP",
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              AnimatedProgressBar(
                                progress: progress,
                                height: 10,
                                gradient: LinearGradient(
                                  colors: [LevelSystem.getLevelColor(level).withOpacity(0.7), LevelSystem.getLevelColor(level)],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${(progress * 100).toInt()}% to Level ${level + 1}",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Mistakes Button
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).collection('mistakes').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
                return SlideInWidget(
                  delay: const Duration(milliseconds: 300),
                  child: BouncingButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MistakesScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFff6b6b), Color(0xFFee5a5a)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.refresh, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Review Mistakes",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  "${snapshot.data!.docs.length} questions to practice",
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Section Title
            SlideInWidget(
              delay: const Duration(milliseconds: 400),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("My Subjects", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subject Grid with Real Progress
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
              children: [
                _buildSubjectCard(
                  subject: "Mathematics",
                  icon: Icons.calculate_outlined,
                  color: AppColors.mathOrange,
                  delay: 500,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonListScreen(subject: "Mathematics", color: AppColors.mathOrange, studentGrade: _studentGrade))),
                ),
                _buildSubjectCard(
                  subject: "Sinhala",
                  icon: Icons.auto_stories_outlined,
                  color: AppColors.sinhalaViolet,
                  delay: 600,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonListScreen(subject: "Sinhala", color: AppColors.sinhalaViolet, studentGrade: _studentGrade))),
                ),
                _buildSubjectCard(
                  subject: "Environment",
                  icon: Icons.public,
                  color: AppColors.environmentGreen,
                  delay: 700,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonListScreen(subject: "Environment", color: AppColors.environmentGreen, studentGrade: _studentGrade))),
                ),
                _buildSubjectCard(
                  subject: "English",
                  icon: Icons.language,
                  color: AppColors.languageTeal,
                  delay: 800,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LanguageTabsScreen(grade: _studentGrade))),
                ),
                if (_studentGrade == 5)
                  SlideInWidget(
                    delay: const Duration(milliseconds: 900),
                    child: BouncingButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PastPaperSelector())),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C5CE7).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.description, color: Colors.white, size: 28),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Past Papers",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              "Grade 5 Scholarship",
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}