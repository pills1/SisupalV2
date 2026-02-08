import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'login_screen.dart';
import 'lesson_list_screen.dart';
import 'past_paper_selector.dart';
import 'language_tabs_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'mistakes_screen.dart';
import 'video_hub_screen.dart';
import 'history_screen.dart';


class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0; // Tracks which tab is active
  int _streak = 0;
  int _studentGrade = 5; // Default to 5, will update from Firestore

  @override
  void initState() {
    super.initState();
    _checkStreak();
    _fetchUserGrade();
  }

  // --- 1. FETCH USER GRADE ---
  Future<void> _fetchUserGrade() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            _studentGrade = doc.data()?['grade'] ?? 5;
          });
        }
      } catch (e) {
        print("Error fetching grade: $e");
      }
    }
  }

  // --- 2. STREAK LOGIC ---
  Future<void> _checkStreak() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      final doc = await userRef.get();
      // If user is new (no doc), create it
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("🔥 Daily Streak!"),
            content: Text("You are on a $newStreak day streak!\n+ $bonusXP XP!"),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Awesome!"))],
          ),
        );
      }
    } catch (e) { print("Error checking streak: $e"); }
  }

  // --- 3. PAGE SWITCHING LOGIC ---
  // Returns the widget for the currently selected tab
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
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Light Blue-Grey Background

      // Only show the Custom AppBar on Home (Index 0)
      appBar: _selectedIndex == 0 ? _buildHomeAppBar() : null,

      // Display the active page
      body: _buildCurrentPage(),

      // --- BOTTOM NAVIGATION BAR (Fluento Style) ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // Needed for 4+ items
          backgroundColor: const Color(0xFF1A1A2E), // Dark Navy Background
          selectedItemColor: const Color(0xFFFFD700), // Gold for selected
          unselectedItemColor: Colors.grey.shade500,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_fill),
              label: 'Classes', // Video Hub
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events),
              label: 'Rank', // Leaderboard
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile', // Profile
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER: HOME APP BAR ---
  AppBar _buildHomeAppBar() {
    final user = FirebaseAuth.instance.currentUser;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          String name = "Student";
          if (snapshot.hasData && snapshot.data!.exists) {
            name = snapshot.data!['name'] ?? "Student";
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome back,", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          );
        },
      ),
      actions: [
        // Streak Badge
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.deepOrange.shade50, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 20),
              Text(" $_streak", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ],
          ),
        ),
        // History Button (Only on Home)
        IconButton(
          icon: const Icon(Icons.history, color: Colors.blue),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
          },
        ),
      ],
    );
  }

  // --- HELPER: HOME TAB CONTENT ---
  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row( //
              children: [
                Lottie.network(
                  'https://assets5.lottiefiles.com/packages/lf20_j1adxtyb.json',
                  height: 80, // Bigger size for effect
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if internet fails
                    return const Icon(Icons.rocket_launch, color: Colors.white, size: 40);
                  },
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ready to Learn?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Let's complete a lesson today!",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Mistakes Button
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).collection('mistakes').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MistakesScreen())),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      const SizedBox(width: 10),
                      Text("Review My Mistakes (${snapshot.data!.docs.length})", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                    ],
                  ),
                ),
              );
            },
          ),

          const Text("My Subjects", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Subject Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildSubjectCard("Mathematics", Icons.calculate_outlined, Colors.orange),
                _buildSubjectCard("Sinhala", Icons.auto_stories_outlined, Colors.purple),
                _buildSubjectCard("Environment", Icons.public, Colors.green),

                // English/Tamil Card
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LanguageTabsScreen(grade: _studentGrade))),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(radius: 30, backgroundColor: Colors.teal.withOpacity(0.1), child: const Icon(Icons.language, size: 30, color: Colors.teal)),
                        const SizedBox(height: 12),
                        const Text("English/Tamil", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

                // Past Papers (Only for Grade 5)
                if (_studentGrade == 5)
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PastPaperSelector())),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(radius: 30, backgroundColor: Colors.indigo.withOpacity(0.1), child: const Icon(Icons.description, size: 30, color: Colors.indigo)),
                          const SizedBox(height: 12),
                          const Text("Past Papers", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonListScreen(subject: title, color: color, studentGrade: _studentGrade))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 30, backgroundColor: color.withOpacity(0.1), child: Icon(icon, size: 30, color: color)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}